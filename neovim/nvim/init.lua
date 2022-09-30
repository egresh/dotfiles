-- This file is intended to be used for production. The configuration paths are:
-- .config/neovim/production => configuration files
-- .local/share/neovim/production => data files
-- .cache/neovim/production => cache files

-- set colorscheme first so gitsigns picks up hilights
vim.cmd("colorscheme gruvbox")

-- This is to get python3 working with "danth/pathfinder.vim"
vim.cmd([[ let g:python3_host_prog = "/Users/egresh/.pyenv/shims/python3" ]])
require("user/impatient")
require("user/autocommands")
require("user/gitsigns")
require("user/options")
require("user/plugins")
require("user/mappings")
require("user/tmux_navigator")
require("user/treesitter")
require("user/lsp_installer")
require("user/lsp/lsp_config")
require("user/completion")
require("user/comment")
require("user/lualine")
require("user/telescope")
require("user/telescope-fzf-native")
require("user/null-ls")
require("user/whichkey")
require("user/nvim-tree")
require("user/autopairs")
require("user/indentline")
require("user/toggleterm")
require("user/neovim-session-manager")
-- require("user/barbar")
-- require("user/tree-barbar")
require("user/prosession")
require("user/vim-test")
require("user/rose_pine")
require("user/snippets")
require("user/close_tags")
require("user/nvim-lsputils")

vim.cmd("source " .. vim.fn.stdpath("config") .. "/config/autocommands.vim")

-- vim.cmd("colorscheme rose-pine")

-- black background
vim.cmd("hi Normal guibg=black")

-- vim.o.background = "dark" -- or "light" for light mode
