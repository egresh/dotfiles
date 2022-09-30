local lsp_status = require("lsp-status")
lsp_status.register_progress()
lsp_status.update_current_function()

lsp_status.config({
    select_symbol = function(cursor_pos, symbol)
        if symbol.valueRange then
            local value_range = {
                ["start"] = {
                    character = 0,
                    line = vim.fn.byte2line(symbol.valueRange[1]),
                },
                ["end"] = {
                    character = 0,
                    line = vim.fn.byte2line(symbol.valueRange[2]),
                },
            }

            return require("lsp-status.util").in_range(cursor_pos, value_range)
        end
    end,
    indicator_errors = "",
    indicator_warnings = "",
    indicator_info = "",
    indicator_hint = "",
    indicator_ok = "✓",
    indicator_separator = " ",
    component_separator = " ",
    -- status_symbol = "LSP ",
    status_symbol = "LSP ",
})

local pwd = function()
    return vim.api.nvim_exec("pwd", true)
end

local lcd = function()
    return vim.api.nvim_exec("lcd", true)
end

local diff = {
    "diff",
    colored = false,
    symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
}

local filetype = {
    "filetype",
    icon_only = true,
}

local filename = {
    "filename",
    file_status = true,
    path = 1,
}

local branch = {
    "branch",
    icons_enabled = true,
    icon = "",
}

local location = {
    "location",
    padding = { left_padding = 0, right_padding = 0 },
}

local mode = {
    "mode",
    fmt = function(str)
        return "-- " .. str .. " --"
    end,
}

require("lualine").setup({
    options = {
        theme = "gruvbox",
        -- section_separators = { left = "", right = "" },
        -- component_separators = { "|", "|" },
        section_separators = { left = "", right = "" },
        component_separators = { "", "" },
        global_status = true
        -- disabled_filetypes = { 'toggleterm' }
    },
    extensions = { "toggleterm", "quickfix", "fugitive", "nvim-tree" },

    sections = {
        lualine_a = { mode },
        lualine_b = { branch, diff },
        lualine_c = { pwd },
        lualine_x = { filetype, filename },
        lualine_y = { "progress", location },
        lualine_z = { "require'lsp-status'.status()" },
    },
})
