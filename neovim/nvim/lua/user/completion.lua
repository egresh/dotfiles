-- Setup nvim-cmp.
local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
}

local cmp = require("cmp")

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
    },
    mapping = {
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-CR>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["jk"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    },

    -- the order of the sources matter, priority is descending
    -- you can configure keyword length, priority, max_item_count
    sources = {
        { name = "nvim_lsp" },
        { name = "cmp-nvim-lsp-signature-help", keyword_length = 3 },
        { name = "treesitter" },
        { name = "buffer" },
        { name = "tags" },
        -- { name = "vsnip" },
        -- { name = "tags" },
        -- { name = "path" },
        -- { name = "cmdline" },
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s   %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- vim_item.kind = string.format('%s ', kind_icons[vim_item.kind]) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
                cmdline = "[Cmd]",
                path = "[Path]",
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                vsnip = "[Vsnip]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                latex_symbols = "[LaTeX]",
                tmux = "[Tmux]",
                tag = "[Tag]",
                treesitter = "[TSit]",
            })[entry.source.name]
            return vim_item
        end,
    },
    completion = {
        -- keyword_length = 5,
        -- autocomplete = {
        --     cmp.TriggerEvent.TextChanged,
        --     cmp.TriggerEvent.InsertEnter,
        -- },
    },
    experimental = {
        native_menu = false,
        ghost_text = true,
    },
})

-- These setups can be defined per file type ex: ftplugin/*.md
-- cmp.setup.buffer({
--     sources = {
--         { name = "vsnip" },
--         { name = "spell" },
--         {
--             name = "buffer",
--             opts = {
--                 get_bufnrs = function()
--                     return vim.api.nvim_list_bufs()
--                 end,
--             },
--         },
--         { name = "path" },
--     },
-- })

cmp.setup.filetype('html', {
    sources = cmp.config.sources({
        { name = "treesitter" },
        { name = "buffer" },
        { name = "tags" },
        { name = "vsnip" },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
-- keyword_pattern updated to reflect magic search
cmp.setup.cmdline("/", {
    sources = {
        { name = "buffer", keyword_pattern = [=[[^[:blank:]\/v]*]=] },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(":", {
--     sources = {
--         -- Note: Don't use path here.
--         -- { name = "path", option = {
--         --     trailing_slash = true,
--         -- } },
--         { name = "cmdline" },
--     },
-- })
