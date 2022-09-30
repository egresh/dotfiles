-- is the package.path really needed in the runtime_path?
-- local runtime_path = vim.split(package.path, ";")
-- local runtime_path = {}

-- these seem to be the defaults
-- table.insert(runtime_path, "lua/?.lua")
-- table.insert(runtime_path, "lua/?/init.lua")

-- return {
--     Lua = {
--         runtime = {
--             -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--             version = "LuaJIT",

--             -- path is needed for requiring modules
--             -- intelliSense appears to be enabled for lua files in the runtimepath
--             -- and those don't need to be added to workspace.library
--             path = runtime_path,
--         },
--         diagnostics = {
--             -- Prevent LSP from complaining about these globals...
--             enable = true,
--             globals = { "vim" },
--         },
--         workspace = {
--             maxPreload = 3000,
--             preloadFileSize = 400,
--             checkThirdParty = false,

--             -- LSP support for lua files in the cwd
--             -- without this, intelliSense doesn't work for cwd/*.lua
--             library = { vim.fn.getcwd() },
--         },
--     },
-- }

local lua_file = vim.fn.expand("%:p")

if lua_file == "" then
    lua_file = vim.fn.getcwd()
end

local opts = {}
-- Use lua-dev plugin for configuration when inside a path with 'nvim' or 'neovim'
-- for neovim development. Adjust preloads.
if string.find(lua_file, "nvim") or string.find(lua_file, "neovim") then
    local overrides = {
        Lua = {
            workspace = {
                maxPreload = 10000,
                preloadFileSize = 1000,
                checkThirdParty = false,
            },
        },
    }

    opts = require("lua-dev").setup({
        cmd = { vim.fn.stdpath("data") .. "/lua-language-server-2.5.6/bin/lua-language-server" },
        settings = overrides,
    })
else
    opts.cmd = { vim.fn.stdpath("data") .. "/lua-language-server-2.5.6/bin/lua-language-server" }
    opts.settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",

                -- path is needed for requiring modules
                -- intelliSense appears to be enabled for lua files in the runtimepath
                -- and those don't need to be added to workspace.library
                path = runtime_path,
            },
            diagnostics = {
                -- Prevent LSP from complaining about these globals...
                enable = true,
                globals = { "vim" },
            },
            workspace = {
                maxPreload = 3000,
                preloadFileSize = 400,
                checkThirdParty = false,

                -- LSP support for lua files in the cwd
                -- without this, intelliSense doesn't work for cwd/*.lua
                library = { vim.fn.getcwd() },
            },
        },
    }
end

return opts
