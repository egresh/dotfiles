-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = ","
vim.g.lazyvim_picker = "snacks"

vim.opt.guifont = "ShureTechMono Nerd Font"
vim.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,terminal"
-- vim.api.nvim_set_hl(0, 'Normal', {bg = "black"})
vim.api.nvim_set_var("vimsyn_embed", "lr")
vim.opt.matchpairs:append({ "<:>" }) -- add characters for % matching
vim.opt.dictionary:append({ "/usr/share/dict/words" })
vim.opt.iskeyword:append({ "-" })
vim.opt.gcr = "a:ver25-blinkon0"
vim.opt.listchars = { tab = "▸\\ ", space = " ", eol = "¬", trail = "☐" } -- show these chars when showing whitespace
vim.opt.winbar = "%=%m %f"
vim.opt.wildmode = "full"
vim.g.autoformat = false
-- vim.opt.autochdir = true
vim.opt.scrolloff = 10
--vim.g.snacks_animate = false
vim.o.background = "dark" -- or "light" for light mode

-- vim.lsp.set_log_level("debug")
