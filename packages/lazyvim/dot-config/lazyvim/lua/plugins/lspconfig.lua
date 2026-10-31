return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      -- LazyVim maps K -> vim.lsp.buf.hover() for every attached client, even ones
      -- that don't implement hover (copilot). Re-declare it with `has` so K is only
      -- taken over when a hover-capable server is attached; otherwise filetype
      -- mappings like vim-tmux's K -> tmux#man() survive.
      ["*"] = {
        keys = {
          {
            "K",
            function()
              return vim.lsp.buf.hover()
            end,
            desc = "Hover",
            has = "hover",
          },
        },
      },
      emmet_language_server = {
        enabled = false,
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "pug",
          "typescriptreact",
          "vue",
        },
      },
      rubocop = {
        mason = false,
      },
      ruby_lsp = {
        mason = false,
        cmd = { "ruby-lsp" },
        init_options = {
          -- rubocop runs as its own LSP client (see `rubocop` above), so let it own
          -- formatting and diagnostics. Disabling only `formatting` still leaves
          -- ruby-lsp's auto-detected `rubocop_internal` linter running, which
          -- duplicates every offense the standalone rubocop client already reports
          -- (ruby-lsp's Prism-based syntax error/warning diagnostics are unaffected
          -- since those don't go through `linters`). Everything else stays at
          -- ruby-lsp's defaults.
          enabledFeatures = {
            formatting = false,
          },
          linters = {},
          addonSettings = {
            ["Ruby LSP Rails"] = {
              enablePendingMigrationsPrompt = false,
            },
          },
        },
      },
    },
  },
}
