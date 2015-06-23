# vim-cucumber

This is a fork of vim-cucumber from TPope, supporting multiple Gherkin frameworks
(behave, cucumber-js).

This plugin also offers a source for neocomplete autocompletion.

## Commands

vim-cucumber provides commands to jump from steps to step definitions in
feature files.

In normal mode, pressing `[<C-d>` or `]<C-d>` on a step jumps to the
corresponding step definition and replaces the current buffer. `<C-W>d` or
`<C-w><C-d>` on a step jumps to its definition in a new vertically split buffer
and moves the cursor there. `[d` or `]d` on a step opens the step definition
in a new tab.

## Installation

If you don't have a preferred installation method, I recommend installing
[pathogen.vim](https://github.com/tpope/vim-pathogen), and then simply copy
and paste:

    cd ~/.vim/bundle
    git clone git://github.com/bmustiata/vim-cucumber.git
