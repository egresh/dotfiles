-- Defaults
-- local disable_filetype = { "TelescopePrompt" }
-- local disable_in_macro = false -- disable when recording or executing a macro
-- local disable_in_visualblock = false -- disable when insert after visual block mode
-- local ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", "")
-- local enable_moveright = true
-- local enable_afterquote = true -- add bracket pairs after quote
-- local enable_check_bracket_line = true --- check bracket in same line
-- local check_ts = false
-- local map_bs = true -- map the <BS> key
-- local map_c_h = false -- Map the <C-h> key to delete a pair
-- local map_c_w = false -- map <c-w> to delete a pair if possible

-- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

local npairs = require("nvim-autopairs")

npairs.setup({
    check_ts = true,
    ts_config = {
        -- lua = {'string'},-- it will not add a pair on that treesitter node
        -- javascript = {'template_string'},
        -- java = false,-- don't check treesitter on java
        lua = false, -- endwise fails on function definitions
        ruby = { 'method', 'identifier' }
    },
    fast_wrap = {
        map = "<leader>aa",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
    },
})

npairs.add_rules(require("nvim-autopairs.rules.endwise-ruby"))

-- workaround for lua function definitions
local endwise = require("nvim-autopairs.ts-rule").endwise
npairs.add_rules({ endwise("function.*%(.*%)$", "end", "lua", nil) })

local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
-- npairs.add_rules({
--     Rule("private", "", "ruby"):use_regex(true):with_pair(cond.none()):with_del(cond.none())
-- })
