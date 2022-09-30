-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    local opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- buf_set_keymap("n", "gD", "<xmd>lua vim.lsp.buf.declaration()<CR>", opts)
    -- buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    -- buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    -- buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    -- buf_set_keymap("n", "<leader><C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    -- buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    -- buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    -- buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    -- buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    -- buf_set_keymap("n", "gr", "<cmd>lua vim.lp.buf.references()<CR>", opts)
    -- buf_set_keymap("n", "<space>a", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    -- buf_set_keymap("n", "dk", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    -- buf_set_keymap("n", "dj", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    -- buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
    -- buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    --[[ virtual_text = {
            prefix = "»",
            spacing = 4,
        }, ]]
    signs = true,
    update_in_insert = false,
})

-- Extend default capabilities for completion
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- For Debugging
-- local o = require("oleo").helpers
-- vim.lsp.set_log_level("trace")
-- o.dumptotmpfile(opts, server.name)

local nvim_lsp = require("lspconfig")

nvim_lsp['solargraph'].setup({
    -- to install the standardrb gem
    -- should be ran from neovim_home/lsp_servers/solargraph)
    -- gem install --no-user-install --install-dir=.
    -- --bindir=bin --no-document solargraph-standardrb
    -- OR edit nvim-lsp-installer/lua/nvim-lsp-installer/servers/solargraph/init.lua:
    -- installer = {
    --     gem.packages { "standard" },
    --     gem.packages { "solargraph-standardrb" },
    --     gem.packages { "solargraph-rails" },
    --     gem.packages { "solargraph" },
    -- },
    -- copy the solargraph bin from the rails template directory to
    -- ~/.local/share/nvim/lsp_servers/solargraph/gems/solargraph-0.44.3/bin
    -- opts = require("user/lsp/solargraph")

    -- cmd = "solargraph" ... see vim.lsp.start_client()|  
    settings = {
        solargraph = {
            -- Override here...
            -- useBundler = true,
            -- logLevel = "info",
            -- transport = "socket",
            -- promptDownload = true,
            -- completion = true,
            -- diagnostics = true,
            -- autoformat = false,
            -- formatting = true,
            -- hover = true,
            -- symbols = true,
            -- definitions = true,
            -- folding = true,
            -- references = true,
            -- rename = true,
            -- checkGemVersion = false,
            -- commandPath = "/foo/bar",
        },
    },
    on_attach = on_attach,
    capabilities = capabilities,
})

-- nvim_lsp.sumneko_lua.setup({ require("user/lsp/sumneko_lua") })
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

nvim_lsp.sumneko_lua.setup({
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
    on_attach = on_attach,
    capabilities = capabilities,
})

local signs = function()
    local colorscheme = vim.g.colors_name

    -- Black sign_column background, including icons, when using Gruvbox
    if colorscheme == "gruvbox" then
        vim.cmd("hi SignColumn guibg=black")
        vim.cmd("hi DiagnosticSignHint guifg=#83a598 guibg=black")
        vim.cmd("hi DiagnosticSignInfo guifg=#fabd2f guibg=black")
        vim.cmd("hi DiagnosticSignError guifg=#fb4934 guibg=black")
        vim.cmd("hi DiagnosticSignWarn guifg=#fe8019 guibg=black")
    end

    return {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
        { name = "DiagnosticSignHint", text = "" },
    }
end

for _, sign in ipairs(signs()) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.numhl })
end

vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
    source = true,
    signs = true,
    float = {
        border = "rounded",
    },
})

nvim_lsp.efm.setup({
    filetypes = { 'eruby', 'html' },

    settings = {
        languages = {
            eruby = {
                {
                    formatCommand = "htmlbeautifier",
                    formatStdin = true,
                    lintCommand = "erb -x -T - | ruby -c",
                    lintOffset = 1,
                    lintStdin = true,
                    lintDebounce = 1,
                    lintIgnoreExitCode = true,
                },
            },
            html = {
                {
                    formatCommand = "htmlbeautifier",
                    formatStdin = true,
                },
            },
        },
    },
    on_attach = on_attach,
    capabilites = capabilites,
    -- opts = { filetypes = { "eruby" } }
})

nvim_lsp.tailwindcss.setup({})
nvim_lsp.yamlls.setup({})
