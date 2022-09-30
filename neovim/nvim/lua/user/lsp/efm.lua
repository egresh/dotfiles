require('lspconfig').efm.setup {
    init_options = {
        documentFormatting = true
    },
    settings = {
        languages = {
            lua = {
                { formatCommand = 'stylua -s -', formatStdin = true }
            },
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
                }
            },
        }
    }
}
