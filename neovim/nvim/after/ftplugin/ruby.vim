" set fdm=syntax
setlocal nospell
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal colorcolumn=80

" let g:rubycomplete_buffer_loading=1
" let g:rubycomplete_classes_in_global=1

" Look at the working directory for find completions
setlocal path+=.,,lib/**,spec/**

" compiler ruby
setlocal suffixesadd+=.rb
setlocal makeprg=ruby\ %
" nnoremap <buffer><leader>rf <esc>:w! <esc>:make <cr>
" nnoremap <buffer><leader>rb <esc>:w! <esc>:silent make <bar> redraw!<cr>
" nnoremap <buffer><leader>rs :!rspec %<cr>
" nnoremap <buffer><leader>rr <esc>:w! <esc>:!ruby %<cr>
" nnoremap <buffer><leader>rc :w! <bar> RuboCop <cr>
"
" Rspec Plugin
" let g:rspec_command = 'Dispatch bin/rspec {spec}'
" let g:rspec_command = 'Dispatch rspec {spec}'

" nnoremap <buffer><leader>rs :w! <bar> :call RunCurrentSpecFile()<CR>
" nnoremap <buffer><leader>rn :w! <bar> :call RunNearestSpec()<CR>
" nnoremap <buffer><leader>rl :w! <bar> :call RunLastSpec()<CR>
" nnoremap <buffer><leader>ra :w! <bar> :call RunAllSpecs()<CR>

" nmap <buffer><leader>rr :w! <bar> :!ruby %
" nmap <buffer><space>m ]m
" nmap <buffer><space>M [m

setlocal formatoptions-=o
setlocal foldmethod=expr
setlocal foldexpr=nvim_treesitter#foldexpr()
