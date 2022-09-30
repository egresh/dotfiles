setlocal suffixesadd+=.py
setlocal makeprg=python\ %
set nospell
set shiftwidth=4 tabstop=4 softtabstop=4
inoremap <leader>rp <esc>:w! <esc>:make<cr>
nnoremap <leader>rp <esc>:w! <esc>:make<cr>
