local opt = vim.opt

opt.cmdheight = 2 -- more space in the neovim command line for displaying messages
opt.background = "dark"
opt.fileencoding = "utf-8" -- Used for airline
opt.termguicolors = true -- True Color support - uses gui colors specified in colorscheme
opt.textwidth = 0 -- no forced line width with line breaks
opt.wrap = false -- at end of terminal, wrap text
opt.tabstop = 2 -- all occurrences of ASCII #9 (tab) are 4 spaces
opt.expandtab = true -- convert tabs into typed spaces
opt.shiftwidth = 2 -- when autoindenting code blocks, use this many spaces
opt.shiftround = true -- round indent to the nearest tabstop (multiple of shiftwidth)
opt.modeline = true -- check for a modeline for automatic file defined settings
opt.autoindent = true -- copy indent from current line when starting a new line
opt.smartindent = true -- autoindent c-like programs when starting a new line
opt.wildchar = 9 -- character for wildcard expansion on the command-line (9 is tab)
opt.wildmenu = true -- list wildcard expansion choices above the command-line
opt.number = true -- number lines
opt.ruler = true -- show the ruler
opt.showcmd = true -- show user commands on the command-line
opt.ignorecase = true -- searches should be case insensitive
opt.smartcase = true -- unless a capital letter is used
opt.incsearch = true -- show search results as they are typed
opt.hlsearch = true -- highlight the search targets
opt.mouse = "a" -- enable mouse control
opt.history = 1000 -- number of commands to remember
opt.scrolljump = 5 -- minimum number of lines to scroll
opt.hidden = true -- allow switching buffers without saving first
opt.cursorline = true -- highlight the current line
opt.relativenumber = true -- display line numbers from current line
opt.showmatch = true -- after completing a matching {[<(, go back to the former
opt.matchtime = 2 -- Number of milliseconds to wait after completing a match
opt.visualbell = true -- just trying it out
opt.splitbelow = true -- new vim split happens underneath for horizontal splits
opt.splitright = true -- new vim split happens to the right for veritcal splits
opt.scrolloff = 8 -- always have visible context around line
opt.tm = 250 -- Time in ms to wait for a mapped sequence to complete
opt.timeout = true -- Don't timeout (when leader is pressed)
opt.timeoutlen = 500
opt.undofile = true -- Maintain undo history between sessions
--opt.completeopt     = 'menu,menuone,noinsert,noselect'      -- For autocomplete selections
opt.completeopt = "menu,menuone,noselect" -- For autocomplete selections
opt.autoread = true -- Automatically re-read files if unmodified inside vim
-- opt.foldcolumn = "auto" -- foldmarkers in column 2
opt.backup = true -- create a backup of the current file before any write
opt.backupext = ".bak" -- append an extention to a backup file
opt.backupdir = vim.fn.stdpath('data') .. '/backup'
opt.updatecount = 10 -- write to the swapfile after X characters
opt.updatetime = 300 -- for cursorhold
opt.shada = "'1000,f1,<500" -- save editing state between sessions
opt.sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,winpos,terminal" -- see auto-session plugin
opt.wildmode = "full" -- show list of completions in popup
opt.winblend = 0
opt.signcolumn = "auto:9"
-- opt.foldcolumn = "auto:3"
-- opt.showtabline = 2
opt.numberwidth = 4
opt.pumheight = 10 -- popup menu height
opt.tags = ".git/tags"
opt.matchpairs:append({ "<:>" }) -- add characters for % matching
opt.dictionary:append({ "/usr/share/dict/words" })
opt.clipboard:append({ "unnamedplus" }) -- always copy to the clipboard without naming the register
opt.iskeyword:append({ "-" })
opt.bs = { "indent", "eol", "start" } -- backspace over autoindents, line breaks, start of insert
opt.gcr = "n-v-c:block,i-ci-ve:block-blinkwait200-blinkon500-blinkoff200,r-cr-o:hor2"
opt.listchars = { tab = "▸\\ ", space = " ", eol = "¬", trail = "☐" } -- show these chars when showing whitespace

-- syntax highlighting for lua,ruby embedded in viml
vim.api.nvim_set_var("vimsyn_embed", "lr")

-- set autochdir                           " CD to the directory of the current file
-- opt.spell           = 'spelllang=en_us'                     -- enable spell checking
