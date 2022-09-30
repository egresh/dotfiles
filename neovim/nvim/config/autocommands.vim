if has('nvim')
    augroup configure_terminal
        autocmd!
        autocmd TermOpen * :lua ConfigureTerminal()
        autocmd TermClose term://* call nvim_input('<cr>') " close window when shell exits
        autocmd BufEnter  term://* exec "normal i"
    augroup END
endif

" Go to last cursor position. Change ` to ' for last line instead
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
            \| exe "normal! g`\"" | endif

" Automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

autocmd InsertEnter * :set number norelativenumber
autocmd InsertLeave * :set relativenumber

" Don't make help an unlistable buffer (default). It will cause the help buffer
" to hide so that's it's not viewable in Airline's tabline
augroup filetypes
    au!
    autocmd FileType help :set bl
    autocmd FileType yaml :set shiftwidth=2
    autocmd FileType yaml :set tabstop=2

    " Commentary plugin
    autocmd FileType perl set commentstring=#\ %s
    autocmd FileType ruby set commentstring=#\ %s
augroup END

" Cursor line/column highlighting
augroup Cursorline
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au VimEnter,WinEnter,BufWinEnter * setlocal nocursorcolumn
    au WinLeave * setlocal nocursorline
    au WinLeave * setlocal nocursorcolumn
augroup END

" Delete fugitive buffers on close
autocmd BufReadPost fugitive://* set bufhidden=delete
" autocmd FileType vim setlocal foldmethod=marker

" Save Text Folding
autocmd BufWinLeave *.* mkview

augroup Transparency
    au!
    " au WinEnter * highlight NormalNC guibg=Grey15
    " au WinEnter * highlight Normal   guibg=black
    " au WinEnter * bufdo echo('foo')
    " au WinEnter * bufdo echo('foo')
    " au WinEnter * highlight FoldColumn guibg=black
    " au WinEnter * highlight SignColumn guibg=black
augroup END

augroup scheme_change
    au!
    autocmd ColorScheme * hi clear SignColumn
    autocmd ColorScheme * hi clear FoldColumn
augroup END

augroup BgHighlight
  au!
  " autocmd WinEnter * :lua require('user/utils').winenter()
  " autocmd WinLeave * set nonumber
  " autocmd WinLeave * set norelativenumber
  " autocmd WinLeave * set foldcolumn=0
  " autocmd WinLeave * set signcolumn=no
  autocmd BufEnter * :lua require('oleo').helpers.winenter()
  " autocmd BufEnter * :lua require'lualine'.setup()
  " autocmd BufEnter * :lua require('user/utils').format_lualine()
  autocmd BufLeave * set nonumber
  autocmd BufLeave * set norelativenumber
  autocmd BufLeave * set foldcolumn=0
  autocmd BufLeave * set signcolumn=no
augroup END

augroup Diffing
  au!
  autocmd BufEnter * if &diff | execute "IndentBlanklineDisable" | set nolist | execute 'echo "Disabled"' | endif
  " autocmd BufEnter * if &term | execute 'echo "Hello World"' | endif
  " autocmd BufEnter * if &diff | lua vim.api.nvim_command('IndentBlanklineDisable') | endif
augroup END

au filetype help set nolist
