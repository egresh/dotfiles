local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

-- used in global scope so the mapping can call it
function _G._rails_consoles()
    vim.cmd([[lua require('toggleterm').exec('bundle exec rails c', 5, 20, nil, 'horizontal', nil, nil)]])
    vim.cmd([[lua require('toggleterm').exec('tail -f log/development.log', 6, 20, nil, 'horizontal', nil, nil)]])
    vim.cmd([[lua require('toggleterm').exec('echo "Rails environment"', 7, 20, nil, 'horizontal', nil, nil)]])
end

local setup = {
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
        },
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
        },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    -- operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
        border = "rounded", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0,
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    triggers = "auto", -- automaticall setup triggers
    -- triggers = {"<leader>", "<space>", "z"}, -- or specify a list manually
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for key maps that start with a native binding
        -- most people should not need to change this

        i = { "j", "k" },
        v = { "j", "k" },
    },
}

local opts = {
    mode = "n", -- NORMAL mode
    -- prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
    ["<space>"] = {
        u = { "<CMD>lua require('telescope.builtin').buffers({sort_lastused = true})<CR>", "Buffers" },
        a = { "<CMD>lua vim.diagnostic.open_float()<CR>", "Diagnostic Float" },
        j = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Goto Prev" },
        k = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "Goto Next" },
        q = { "<cmd>lua vim.diagnostic.setloclist()<CR>", "Set Loc List" },
        w = { "<cmd>lua vim.diagnostic.setqflist()<CR>", "Set Loc List" },
        f = { "<CMD>lua vim.lsp.buf.format({ async = true })<CR>", "Format Buffer" },
        d = { "<CMD>lua vim.lsp.buf.definition()<CR>", "Goto Definition" },
        c = { "<CMD>lua vim.lsp.buf.declaration()<CR>", "Goto Declaration" },
        h = { "<CMD>lua vim.lsp.buf.hover()<CR>", "Hover" },
        i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
        t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type Definition" },
        r = { "<cmd>lua vim.lsp.buf.references()<CR>", "Buf Reference" },
        s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signaturee Help" },
        j = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Goto Prev" },
    },
    ["<left>"] = { "<CMD>BufferPrevious<CR>", "Buffer Previous" },
    ["<right>"] = { "<CMD>BufferNext<CR>", "Buffer Next" },
    [",1"] = { ":BufferGoto 1<CR>", "Goto Buffer 1" },
    [",2"] = { ":BufferGoto 2<CR>", "Goto Buffer 2" },
    [",3"] = { ":BufferGoto 3<CR>", "Goto Buffer 3" },
    [",4"] = { ":BufferGoto 4<CR>", "Goto Buffer 4" },
    [",5"] = { ":BufferGoto 5<CR>", "Goto Buffer 5" },
    [",6"] = { ":BufferGoto 6<CR>", "Goto Buffer 6" },
    [",7"] = { ":BufferGoto 7<CR>", "Goto Buffer 7" },
    [",8"] = { ":BufferGoto 8<CR>", "Goto Buffer 8" },
    [",9"] = { ":BufferGoto 9<CR>", "Goto Buffer 9" },
    ["K"] = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },

    [",o"] = {
        name = "Toggle",

        q = { "<CMD> lua require('oleo').toggle_quickfix()<CR>", "Quickfix Toggle" },
        t = { "<CMD> lua print(require('oleo').helpers.show_tagfiles())<CR>", "Tag Files" },
        p = { "<CMD> lua print(require('oleo').helpers.show_path())<CR>", "Path" },
    },
    [",s"] = {
        name = "Shell/Session",

        g = { "<CMD>lua _Lazygit_toggle()<CR>", "LazyGit Toggle" },
        h = { "<CMD>lua _Htop_toggle()<CR>", "Htop Toggle" },
        t = { "<CMD>ToggleTermToggleAll<CR>", "Toggle All" },
        r = { "<CMD>lua _rails_consoles()<CR>", "Rails Consoles" },
        f = { "<CMD>lua _Floaterm_toggle()<CR>", "Floating Terminal" },
        m = { '<CMD>TermExec cmd="glow %"<CR>', "Glow Terminal" },
    },
    [",g"] = {
        name = "Git",
        g = { "<CMD>Git<CR>", "Git Status" },
        s = { "<CMD>Gitsigns stage_hunk<CR>", "Stage Hunk" },
        u = { "<CMD>Gitsigns undo_stage_hunk<CR>", "Undo Stage Hunk" },
        r = { "<CMD>Gitsigns reset_hunk<CR>", "Reset Hunk" },
        R = { "<CMD>Gitsigns reset_buffer<CR>", "Reset Buffer" },
        p = { "<CMD>Gitsigns preview_hunk<CR>", "Preview Hunk" },
        b = { "<CMD>lua require('gitsigns').blame_line{full=true}<CR>", "Blame" },
        S = { "<CMD>Gitsigns stage_buffer<CR>", "Stage Buffer" },
        U = { "<CMD>Gitsigns reset_buffer_index<CR>", "Reset Buffer Index" },
    },
    [",f"] = {
        name = "Find/Search",
        f = { "<CMD>lua require('telescope.builtin').find_files({hidden = true})<CR>", "Files Recursively" },
        u = { "<CMD>lua require('telescope.builtin').buffers({sort_lastused = true})<CR>", "Buffers" },
        U = { "<CMD>lua require('telescope.builtin').buffers({sort_lastused = false})<CR>", "Buffers" },
        q = { "<CMD>lua require('telescope.builtin').quickfix({})<CR>", "Quickfix" },
        c = { "<CMD>lua require('telescope.builtin').commands({})<CR>", "Commands" },
        h = { "<CMD>lua require('telescope.builtin').command_history({})<CR>", "Command History" },
        o = { "<CMD>lua require('telescope.builtin').vim_options({})<CR>", "Neovim Options" },
        r = { "<CMD>lua require('telescope.builtin').registers({})<CR>", "Registers" },
        l = { "<CMD>lua require('telescope.builtin').live_grep({})<CR>", "Live Grep" },
        r = {
            "<CMD>lua require('telescope.builtin').live_grep("
                .. "{ cwd = require('oleo').helpers.project_root(),"
                .. "prompt_title = 'Live Project Root Grep' })<CR>",
            "Live Project Root Grep",
        },
        g = { "<CMD>lua require('telescope.builtin').git_files({show_untracked = false})<CR>", "Git Files" },
        t = { "<CMD>lua require('telescope.builtin').help_tags({})<CR>", "Help Tags" },
        d = { "<CMD>lua require('telescope.builtin').diagnostics({})<CR>", "Diagnostics" },
        p = { "<CMD>Telescope projects<CR>", "Projects" },
        b = { "<CMD>Telescope file_browser<CR>", "File Browser" },
        -- s = { "<CMD>Telescope prosession<CR>", "Session Search" },
        s = {
            "<CMD>lua require('telescope').extensions.prosession.sessions(require('telescope.themes').get_dropdown{})<CR>",
            "Session Search",
        },
        v = {
            -- "<CMD>lua vim.opt.path:append(vim.fn.stdpath('config') .. '/lua'); "
            "<CMD>lua require('telescope.builtin').find_files( {search_dirs = { " .. "'" .. vim.fn.stdpath("config") .. "/config" .. "' ," .. "'" .. vim.fn.stdpath(
                "config"
            ) .. "/after" .. "' ," .. "'" .. vim.fn.stdpath("config") .. "/lua" .. "'" .. "}, follow = true } )<CR>",
            "Neovim Files",
        },
        w = { "Fast Wrap" },
    },
    [",t"] = {
        name = "Nvim Tree",
        f = { "<CMD>NvimTreeFindFile<CR>", "Find File in Tree" },
        -- t = { "<CMD>lua require('user/tree-barbar').toggle()<CR>", "Toggle Tree" },
        t = { "<CMD>NvimTreeToggle<CR>", "Toggle Tree" },
        b = { "<CMD>NvimTreeClipboard<CR>", "Print Clipboard" },
        s = { "<CMD>NvimTreeFocus<CR>", "Focus" },
        h = { "<CMD>NvimTreeRefresh<CR>", "Refresh" },
        -- m = { "<CMD>lua require('user/tree-barbar').resize('+5')<CR>", "Tree Increase" },
        -- l = { "<CMD>lua require('user/tree-barbar').resize('-5')<CR>", "Tree Decrease" },
    },
    [",l"] = {
        name = "Lua Dev/LSP",
        a = { "<CMD>lua require('luapad').attach({})<CR>", "Luapad Attach to Buffer" },
        d = { "<CMD>lua require('luapad').detach({})<CR>", "Luapad Detach from Buffer" },
        l = { "<CMD><Plug>(Luadev-runline)<Plug><CR>", "Luadev run line" },
        i = { "<CMD>LspInfo<CR>", "Lsp Info" },
        m = { "<CMD>help lua51ref<CR>", "Lua 5.1 Reference " },
        s = { "<CMD>:source<CR>", "Source Lua Buffer" },
    },
    [",r"] = {
        name = "Run/Execute",
        n = { "<CMD>w! | TestNearest<CR>", "Test Nearest" },
        f = { "<CMD>w! | TestFile<CR>", "Test File" },
        s = { "<CMD>w! | TestSuite<CR>", "Test Suite" },
        l = { "<CMD>w! | TestLast<CR>", "Test Last" },
        v = { "<CMD>w! | TestVisit<CR>", "Test Visit" },
        t = { "<CMD>lua require('oleo').rspec.toggle_rspec_qf_list()<CR>", "Rspec Toggle" },
        w = { "<CMD>:w! <BAR> source %<CR>", "Run Now" },
        r = { "<CMD>:w! <BAR> !ruby %<CR>", "Run Ruby Now" },
    },
    [",p"] = {
        name = "Packer",
        c = { "<cmd>PackerCompile<cr>", "Compile" },
        i = { "<cmd>PackerInstall<cr>", "Install" },
        s = { "<cmd>PackerSync<cr>", "Sync" },
        t = { "<cmd>PackerStatus<cr>", "Status" },
        u = { "<cmd>PackerUpdate<cr>", "Update" },
    },
    [",b"] = {
        name = "Tabline",
        s = { "<CMD>BufferPick<CR>", "Select Buffer" },
        l = { "<CMD>BufferLast<CR>", "Select Last Buffer" },
        o = { "<CMD>BufferOrderByLanguage<CR>", "Order By Language" },
    },
}

which_key.setup(setup)
which_key.register(mappings, opts)

-- ["a"] = { "<cmd>Alpha<cr>", "Alpha" },
-- ["b"] = {
--   "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
--   "Buffers",
-- },
-- ["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
-- ["w"] = { "<cmd>w!<CR>", "Save" },
-- ["q"] = { "<cmd>q!<CR>", "Quit" },
-- ["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
-- ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
-- ["f"] = {
--   "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
--   "Find files",
-- },
-- ["F"] = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
-- ["P"] = { "<cmd>Telescope projects<cr>", "Projects" },
--
-- p = {
--   name = "Packer",
--   c = { "<cmd>PackerCompile<cr>", "Compile" },
--   i = { "<cmd>PackerInstall<cr>", "Install" },
--   s = { "<cmd>PackerSync<cr>", "Sync" },
--   S = { "<cmd>PackerStatus<cr>", "Status" },
--   u = { "<cmd>PackerUpdate<cr>", "Update" },
-- },
--
-- g = {
--   name = "Git",
--   g = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
--   j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
--   k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
--   l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
--   p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
--   r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
--   R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
--   s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
--   u = {
--     "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
--     "Undo Stage Hunk",
--   },
--   o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
--   b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
--   c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
--   d = {
--     "<cmd>Gitsigns diffthis HEAD<cr>",
--     "Diff",
--   },
-- },
--
-- l = {
--   name = "LSP",
--   a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
--   d = {
--     "<cmd>Telescope lsp_document_diagnostics<cr>",
--     "Document Diagnostics",
--   },
--   w = {
--     "<cmd>Telescope lsp_workspace_diagnostics<cr>",
--     "Workspace Diagnostics",
--   },
--   f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
--   i = { "<cmd>LspInfo<cr>", "Info" },
--   I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
--   j = {
--     "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
--     "Next Diagnostic",
--   },
--   k = {
--     "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
--     "Prev Diagnostic",
--   },
--   l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
--   q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
--   r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
--   s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
--   S = {
--     "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
--     "Workspace Symbols",
--   },
-- },
-- s = {
--   name = "Search",
--   b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
--   c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
--   h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
--   M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
--   r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
--   R = { "<cmd>Telescope registers<cr>", "Registers" },
--   k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
--   C = { "<cmd>Telescope commands<cr>", "Commands" },
-- },
--
-- t = {
--   name = "Terminal",
--   n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
--   u = { "<cmd>lua _NCDU_TOGGLE()<cr>", "NCDU" },
--   t = { "<cmd>lua _HTOP_TOGGLE()<cr>", "Htop" },
--   p = { "<cmd>lua _PYTHON_TOGGLE()<cr>", "Python" },
--   f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
--   h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
--   v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
-- },
