let s:save_cpo = &cpo
set cpo&vim

"
" Define a cucumber source for providing definitions.
"
let s:source = {
   \ 'name' : 'cucumber',
   \ 'kind' : 'keyword',
   \ 'mark' : '[CC]',
   \ 'rank' : 7,
   \ 'matchers' :
      \ (g:neocomplete#enable_fuzzy_completion ?
      \ ['matcher_fuzzy'] : ['matcher_head']),
   \ 'min_pattern_length' : 1,
   \ 'max_candidates' : 20,
   \ 'is_volatile': 1,
   \ }

"
" neocomplete suggestions building.
"
function! s:source.gather_candidates(context)
  let suggestions = []
  let steps = join(cucumber#allsteps())

  echom s:source

  call add(suggestions, {
       \ 'word' : "yolo swagalicious",
       \ 'menu' : '[CC]'
       \ })
  call add(suggestions, {
       \ 'word' : "yolo swagalicious2",
       \ 'menu' : '[CC]'
       \ })
  return suggestions
endfunction

"
" neocomplete integration method.
"
function! neocomplete#sources#cucumber#define()
   return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

