-- include in the path lua/ to 'gf' from inside the file to modules
vim.cmd [[
augroup OpenInitLua
    au!
    autocmd BufRead init.lua lua vim.opt_local.path:append(vim.fn.stdpath('config') .. '/lua')
augroup END
]]
