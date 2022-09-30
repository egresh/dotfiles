vim.g.mapleader=','

local nos = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- remap ctrl^ to <leader>sl (switch last)
keymap('n', '<LEADER>sl', ':e #<CR>', nos)

-- ctrl-d becomes backspace in insert mode
keymap('i', '<C-,>', '<BS>', nos)

-- maximize and normalize windows
keymap('n', '<LEADER>=', ':wincmd =<CR>', nos)
keymap('n', '<LEADER>-', ':wincmd _<CR> :wincmd |<CR>', nos)

-- paste from the system's clipboard
keymap('n', '<LEADER>p',  ':set paste<cr>o<esc>"*]p:set nopaste<cr>', nos)

-- edit and source vimrc
keymap('n', '<LEADER>ev', string.format(":sp %s <CR>", vim.env.MYVIMRC), nos)
keymap('n', '<LEADER>sv', string.format(":source %s <CR>", vim.env.MYVIMRC), nos)

-- new window vspit or hsplit
keymap('n', '<LEADER>sv', ':vsp <bar> enew<CR>', nos)
keymap('n', '<LEADER>sh', ':sp  <bar> enew<CR>', nos)

-- easier to type
keymap('n', '<LEADER>w', ':w!<CR>', nos)

-- show markdown files in the browser
keymap('n', '<LEADER>mk', ':MarkdownPreview<CR>', nos)

-- shortcut to edit the alternate file
keymap('n', '<LEADER>af', ':e#<CR>', nos)

-- shortcut to pick a buffer to edit
keymap('n', 'gb', ':ls<CR>:b<SPACE>', nos)

-- delete a buffer
keymap('n', '<LEADER>d', ':bd<CR>', nos)

-- use magic mode by default
keymap('n', '/', '/\\v', {})

-- j and k move through wrapped lines
keymap('n', 'j', 'gj', nos)
keymap('n', 'k', 'gk', nos)

-- sometimes helpful
keymap('i', 'jk', '<ESC>', nos)

-- searches are shown centered in the window
keymap('n', 'n', 'nzz', nos)
keymap('n', 'N', 'Nzz', nos)

-- quickly comment a line
vim.cmd [[nmap \\ gcc]]
vim.cmd [[imap \\ <ESC>gcc]]

-- terminal mode remaps
keymap('t', '<ESC>',   '<c-\\><c-n>',       nos)
keymap('t', '<C-h>',   '<c-\\><c-n><c-w>h', nos)
keymap('t', '<C-k>',   '<c-\\><c-n><c-w>k', nos)
keymap('t', '<C-l>',   '<c-\\><c-n><c-w>l', nos)
keymap('t', '<C-j>',   '<c-\\><c-n><c-w>j', nos)

-- move through windows in insert mode
keymap('i', '<C-j>',   '<ESC><C-w>j', nos)
keymap('i', '<C-k>',   '<ESC><C-w>k', nos)
keymap('i', '<C-h>',   '<ESC><C-w>h', nos)
keymap('i', '<C-l>',   '<ESC><C-w>l', nos)

-- cycle through tabs
keymap('t', '<LEFT>',  '<c-\\><c-n>gT',      nos)
keymap('t', '<RIGHT>', '<c-\\><c-n>gt',      nos)
keymap('i', '<LEFT>',  '<ESC>:tabprev<cr>', nos)
keymap('i', '<RIGHT>', '<ESC>:tabnext<cr>', nos)
keymap('n', '<LEFT>',  ':BufferPrevious<cr>',      nos)
keymap('n', '<RIGHT>', ':BufferNext<cr>',      nos)

-- disable arrow keys
keymap('i', '<UP>',    '<NOP>', nos)
keymap('i', '<DOWN>',  '<NOP>', nos)
keymap('n', '<UP>',    '<NOP>', nos)
keymap('n', '<DOWN>',  '<NOP>', nos)
keymap('v', '<UP>',    '<NOP>', nos)
keymap('v', '<DOWN>',  '<NOP>', nos)
keymap('v', '<LEFT>',  '<NOP>', nos)
keymap('v', '<RIGHT>', '<NOP>', nos)

-- command mode maps
-- keymap('c', '<C-A>', '<HOME><CR>', nos)
-- keymap('c', '<C-E>', '<END><CR>', nos)
-- cnoremap <C-p> <Up>
-- cnoremap <C-n> <Down>
-- cnoremap <C-b> <Left>
-- cnoremap <C-f> <Right>
-- cnoremap <M-b> <S-Left>
-- cnoremap <M-f> <S-Right>

-- recursively unfold
keymap('n', '<LEADER><LEADER>', 'zA', nos)

-- easy page down
-- keymap('n', '<SPACE><SPACE>', '<PAGEDOWN>', nos)

-- reminder, use ctrl-d now!
keymap('n', 'qq', ':exe \'echo("Use leader-d now!")\'<CR>', nos)

-- execute a file directly
-- keymap('n', '<LEADER>rn', ':w! <BAR> source % <CR>', nos)

-- ctrl-t opens/closes a terminal session
keymap('t', '<C-T>', '<CMD>exe "ToggleTerm"<CR>', nos)
keymap('n', '<C-T>', '<CMD>exe "ToggleTerm"<CR>', nos)
keymap('i', '<C-T>', '<CMD>exe "ToggleTerm"<CR>', nos)

-- for the bfredl/nvim-luadev plugin
keymap('v', '<LEADER>ld', '<PLUG>(Luadev-Run)<CR>', nos)
keymap('x', '<LEADER>ld', 'PLUG<>(Luadev-Runt<CR>', nos)

keymap('n', '<LEADER>mt', ':lua require("maximizer").toggle()<cr>', nos)

-- nnoremap <LEADER>ffr <cmd>lua require('telescope.builtin').file_browser{depth = 100}<cr>
-- nnoremap <LEADER>ff1 <cmd>lua require('telescope.builtin').file_browser{depth = 1  }<cr>
-- nnoremap <LEADER>ff2 <cmd>lua require('telescope.builtin').file_browser{depth = 2  }<cr>
-- nnoremap <LEADER>ff3 <cmd>lua require('telescope.builtin').file_browser{depth = 3  }<cr>
-- keymap('n', '<LEADER>flo', "<CMD>lua require('telescope.builtin').loclist({})<CR>", nos)
-- keymap('n', '<LEADER>ff', "<CMD>lua require('telescope.builtin').find_files({})<CR>", nos)
-- keymap('n', '<LEADER>fu', "<CMD>lua require('telescope.builtin').buffers({ sort_lastused = true })<CR>", nos)
-- keymap('n', '<LEADER>fq', "<CMD>lua require('telescope.builtin').quickfix({})<CR>", nos)
-- keymap('n', '<LEADER>fb', "<CMD>lua require('telescope.builtin').file_browser({})<CR>", nos)
-- keymap('n', '<LEADER>fc', "<CMD>lua require('telescope.builtin').commands({})<CR>", nos)
-- keymap('n', '<LEADER>fh', "<CMD>lua require('telescope.builtin').command_history({})<CR>", nos)
-- keymap('n', '<LEADER>fo', "<CMD>lua require('telescope.builtin').vim_options({})<CR>", nos)
-- keymap('n', '<LEADER>fr', "<CMD>lua require('telescope.builtin').registers({})<CR>", nos)
-- keymap('n', '<LEADER>fg', "<CMD>lua require('telescope.builtin').live_grep({})<CR>", nos)
-- keymap('n', '<LEADER>fs', "<CMD>lua require('telescope.builtin').git_files({})<CR>", nos)
-- keymap('n', '<LEADER>fv', "<CMD>lua require('telescope.builtin').find_files { search_dirs = require('eg/utils').neovim_config_files(), path_display = { 'tail' } }<CR>", nos)

-- keymap('n', '<SPACE>q', "<CMD>lua require('telescope.builtin').quickfix({})<CR>", nos)
-- keymap('n', '<SPACE>j', "<CMD>lua require('telescope.builtin').jumplist({})<CR>", nos)
-- keymap('n', '<SPACE>o', "<CMD>lua require('telescope.builtin').vim_options({})<CR>", nos)
-- keymap('n', '<SPACE>t', "<CMD>lua require('telescope.builtin').help_tags({})<CR>", nos)
-- keymap('n', '<SPACE>l', "<CMD>lua require('telescope.builtin').find_files({})<CR>", nos)
-- keymap('n', '<SPACE>r', "<CMD>lua require('telescope.builtin').registers({})<CR>", nos)
-- keymap('n', '<SPACE>g', "<CMD>lua require('telescope.builtin').live_grep({})<CR>", nos)
-- keymap('n', '<SPACE>s', "<CMD>lua require('telescope.builtin').grep_string({})<CR>", nos)
-- keymap('n', '<SPACE>u', "<CMD>lua require('telescope.builtin').buffers({})<CR>", nos)
-- keymap('n', '<SPACE>i', "<CMD>lua require('telescope.builtin').git_files({})<CR>", nos)
-- keymap('n', '<SPACE>v', "<CMD>lua require('telescope.builtin').find_files { search_dirs = require('eg/utils').neovim_config_files(), path_display = { 'tail' } }<CR>", nos)


-- indent repeatedly
keymap('v', '>', '>gv', nos)
keymap('v', '<', '<gv', nos)

-- move visual selections up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", nos)
keymap("x", "K", ":move '<-2<CR>gv-gv", nos)

-- luadev plugin (repl)
-- keymap('n', '<leader>ll', '<PLUG>(Luadev-RunLine)<CR>',  { silent = true })
-- keymap('v', '<leader>lo', '<PLUG>(Luadev-Run)<CR>',      { silent = true })
-- keymap('n', '<leader>lw', '<PLUG>(Luadev-RunWorld)<CR>', { silent = true })

-- pasture/unsure
--
-- nnoremap <LEADER>i  mmgg=G'm
-- nnoremap <LEADER>cd :cd %:p:h<CR>:pwd<CR>
-- nnoremap <LEADER>id :IndentLinesToggle<CR>
-- nnoremap <LEADER>s :call StripTrailingWhiteSpaces()<CR>
-- nnoremap <LEADER><space> :noh<cr>
-- nnoremap <LEADER><space> :noh<cr>
-- nnoremap <LEADER>hl :set cursorline!<CR>
-- nnoremap <LEADER>hc :set cursorcolumn!<CR>
-- " Limelight
-- " nnoremap <LEADER>l :Limelight!!<cr>
-- " xnoremap <LEADER>l :Limelight!!<cr>
-- " let g:limelight_conceal_ctermfg = 'DarkGray'
-- " let g:limelight_conceal_guifg   = 'DarkGray'
-- " Chef syntax checking
-- nnoremap <LEADER>ck  :w ! cookstyle -s %<cr>
-- vnoremap <LEADER>y "*y<cr>
-- " upcase the previous word
-- " \_^ <- start of the line
-- " \s <- space or tab
-- " \
-- imap <c-u> <esc>?\v(\_^\|\s\|<)<cr>gUawA
-- xnoremap . :norm.<CR>
-- nnoremap <LEADER>qq :q!<cr>:q!<cr>
-- nnoremap <LEADER>lc :lclose<CR>
-- nnoremap <LEADER>lo :lopen<CR>
-- nnoremap <LEADER>ln :lnext<CR>
-- nnoremap <LEADER>lp :lprev<CR>
-- nnoremap <LEADER>cn :cnext<CR>
-- nnoremap <LEADER>cc :cclose<CR>
-- nnoremap <LEADER>co :copen<CR>
-- nnoremap <LEADER>qa <ESC>:qa!<CR>

-- " nnoremap <LEADER>tca :ToggleTermCloseAll<cr>
-- " nnoremap <LEADER>th  :ToggleTerm direction=horizontal<cr>
-- " nnoremap <LEADER>tv  :ToggleTerm direction=vertical size=40<cr>
-- " nnoremap <LEADER>tf  :ToggleTerm direction=float size=40<cr>
-- "nnoremap ;y :exe"syntax\<SPACE>"
-- " \.(exists('syntax_on')?'off':'enable')<CR>
-- nnoremap <LEADER>bg :call ToggleBackground()<cr>
-- nnoremap <silent><LEADER>fc :set guicursor=n-v-c:block,i-ci-ve:block-blinkwait202-blinkon500-blinkoff200,r-cr-o:hor2<cr>
-- nnoremap <LEADER>vn :tabnew <bar> :edit ~/self/docs/technical/vimnotes<cr>
-- nnoremap <LEADER>toa :ToggleTermOpenAll<cr>
