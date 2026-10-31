return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "biome",
        "clojure-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-language-server",
        "eslint-lsp",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "taplo",
        "vtsls",
        "vue-language-server",

        -- Formatters / linters / CLI tools
        "erb-formatter",
        "erb-lint",
        "hadolint",
        "markdown-toc",
        "markdownlint-cli2",
        "prettier",
        "shfmt",
        "sqlfluff",
        "stylua",
        "tree-sitter-cli",
      },
    },
  },
}
