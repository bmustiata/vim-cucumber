" Vim filetype plugin
" Language:	Cucumber
" Maintainer:	Bogdan Mustiata <bogdan.mustiata@gmail.com>
" Last Change:	2013 Jun 01

" Only do this when not done yet for this buffer
if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1

let s:keepcpo= &cpo
set cpo&vim

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:# commentstring=#\ %s

let b:undo_ftplugin = "setl fo< com< cms< ofu<"

let b:cucumber_root = expand('%:p:h:s?.*[\/]\%(features\|stories\)\zs[\/].*??')
if !exists("b:cucumber_steps_glob")
  let b:cucumber_steps_glob = b:cucumber_root.'/**/*.js'
endif

"
" This registers the shortcuts only if the no_plugin_maps and no_cucumber_maps
" global options are defined.
"
if !exists("g:no_plugin_maps") && !exists("g:no_cucumber_maps")
  cnoremap <SID>foldopen <Bar>if &foldopen =~# 'tag'<Bar>exe 'norm! zv'<Bar>endif
  nnoremap <silent> <script> <buffer> [<C-D>      :<C-U>exe <SID>jump('edit',v:count)<SID>foldopen<CR>
  nnoremap <silent> <script> <buffer> ]<C-D>      :<C-U>exe <SID>jump('edit',v:count)<SID>foldopen<CR>
  nnoremap <silent> <script> <buffer> <C-W>d      :<C-U>exe <SID>jump('vsplit',v:count)<SID>foldopen<CR>
  nnoremap <silent> <script> <buffer> <C-W><C-D>  :<C-U>exe <SID>jump('vsplit',v:count)<SID>foldopen<CR>
  nnoremap <silent> <script> <buffer> [d          :<C-U>exe <SID>jump('tab',v:count)<CR>
  nnoremap <silent> <script> <buffer> ]d          :<C-U>exe <SID>jump('tab',v:count)<CR>
  let b:undo_ftplugin .=
        \ "|sil! nunmap <buffer> [<C-D>" .
        \ "|sil! nunmap <buffer> ]<C-D>" .
        \ "|sil! nunmap <buffer> <C-W>d" .
        \ "|sil! nunmap <buffer> <C-W><C-D>" .
        \ "|sil! nunmap <buffer> [d" .
        \ "|sil! nunmap <buffer> ]d"
endif

"
" This jumps at the given command. Note that the steps have the following
" format:
" [
"   0 - file name
"   1 - line number
"   2 - type (Given/When/Then)
"   3 - expression (regex)
" ]
"
function! s:jump(command,count)
  let steps = s:steps('.')
  if len(steps) == 0 || len(steps) < a:count
    return 'echoerr "No matching step found"'
  elseif len(steps) > 1 && !a:count
    return 'echoerr "Multiple matching steps found"'
  else
    let c = a:count ? a:count-1 : 0
    return a:command.' +'.steps[c][1].' '.escape(steps[c][0],' %#')
  endif
endfunction

"
" allsteps: this function attempts to find all the steps that are defined in the feature folder. In order to do that it will first check if the line is a step line using the `step_pattern` expression. If that is the case it will be added to the steps, using the `expression_pattern` in order to extract the regexp outside it.
"
function! cucumber#allsteps()
  let step_pattern = '\C^\s*\K\k*\>\s*(\=\s*\zs\S.\{-\}\ze\s*)\=\s*\%(do\|{\)\s*\%(|[^|]*|\s*\)\=\%($\|#\)'

  " FIXME: define modes, such as cucumber, cucumber-js or behave to autofetch
  " the expressions

  let step_pattern = '\C^\s*\(this\)\.\(Given\|When\|Then\|defineStep\).*\%(\/.*\/\)'
  let expression_pattern = '\C\/.*\/'
  let steps = []
  for file in split(glob(b:cucumber_steps_glob),"\n")
    let lines = readfile(file)
    let num = 0
    for line in lines
      let num += 1
      if line =~ step_pattern
        let type = matchstr(line,'\w\+')
        let steps += [[file,num,type,matchstr(line,expression_pattern)]]
      endif
    endfor
  endfor
  return steps
endfunction

function! Yolo()
  echo "yolo"
endfunction

function! s:steps(lnum)
  let c = match(getline(a:lnum), '\S') + 1
  while synIDattr(synID(a:lnum,c,1),'name') !~# '^$\|Region$'
    let c = c + 1
  endwhile
  let step = matchstr(getline(a:lnum)[c-1 : -1],'^\s*\zs.\{-\}\ze\s*$')
  return filter(cucumber#allsteps(),'s:stepmatch(v:val[3],step)')
endfunction

"
" stepmatch: this function checks if the target (a.k.a. string value) matches
" against the receiver (a.k.a. expression)
" @return 1 if matches, 0 if it doesn't.
"
function! s:stepmatch(receiver,target)
  if a:receiver =~ '^[''"].*[''"]$'
    let pattern = '^'.escape(substitute(a:receiver[1:-2],'$\w\+','(.*)','g'),'/').'$'
  elseif a:receiver =~ '^/.*/$'
    let pattern = a:receiver[1:-2]
  elseif a:receiver =~ '^%r..*.$'
    let pattern = escape(a:receiver[3:-2],'/')
  else
    return 0
  endif
  try
    let vimpattern = substitute(substitute(pattern,'\\\@<!(?:','%(','g'),'\\\@<!\*?','{-}','g')
    if a:target =~# '\v'.vimpattern
      return 1
    endif
  catch
  endtry
  if has("ruby") && pattern !~ '\\\@<!#{'
    ruby VIM.command("return #{if (begin; Kernel.eval('/'+VIM.evaluate('pattern')+'/'); rescue SyntaxError; end) === VIM.evaluate('a:target') then 1 else 0 end}")
  else
    return 0
  endif
endfunction

function! s:bsub(target,pattern,replacement)
  return  substitute(a:target,'\C\\\@<!'.a:pattern,a:replacement,'g')
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:set sts=2 sw=2:
