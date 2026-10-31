nnoremap <buffer><silent><leader>rl :w! <bar> :!lua %<cr>

setlocal foldmethod=expr
setlocal foldexpr=nvim_treesitter#foldexpr()
setlocal shiftwidth=4 tabstop=2 softtabstop=2
setlocal smartindent
setlocal expandtab
setlocal colorcolumn=80
setlocal signcolumn=auto:9
setlocal path+=lua
setlocal suffixesadd+='.lua'
setlocal formatoptions-=o
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal nospell
