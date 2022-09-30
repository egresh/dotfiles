require'nvim-treesitter.configs'.setup {
    ensure_installed = 'all',
    sync_install = false,-- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { 'phpdoc' },

    highlight = {
        enable = true,              -- false will disable the whole extension
        disable = { },  -- list of language that will be disabled
        additional_vim_regex_highlighting = false, -- no longer needed given autopairs
    },
    indent = {
        enable = false, -- issues indenting, need to circle back
        disable = { },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "cit",
            node_incremental = "cic",
            scope_incremental = "cii",
            node_decremental = "cid",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["ab"] = "@block.inner",
                ["aB"] = "@block.outer",
                ["ac"] = "@class.inner",
                ["aC"] = "@class.outer",
                ["af"] = "@function.inner",
                ["aF"] = "@function.outer",
            }
        }
    },
}
