" set fdm=syntax
set shiftwidth=2 tabstop=2 softtabstop=2
set colorcolumn=80
nnoremap <leader>rb <esc>:w! <esc>:!bash %<cr>
nnoremap <leader>rz <esc>:w! <esc>:!zsh %<cr>

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
