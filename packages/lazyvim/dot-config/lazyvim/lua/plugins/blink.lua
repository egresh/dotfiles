return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- add vim-dadbod-completion to your completion providers
      default = { "lsp", "path", "snippets", "buffer", "dadbod" },
      -- default = { "lsp", "path", "dadbod" },
      per_filetype = {
        sql = { "dadbod", "buffer" },
        -- ruby = { "buffer", "lsp" },
      },
      providers = {
        lsp = { name = "LSP", score_offset = 110 },
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink", score_offset = 200 },
        cmdline = {
          min_keyword_length = function(ctx)
            -- when typing a command, only show when the keyword is 3 characters or longer
            if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
              return 3
            end
            return 0
          end,
        },
      },
    },
    keymap = {
      preset = "default",
      ["<C-h>"] = { "hide" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<Up>"] = {
        function(cmp)
          cmp.select_prev({ count = 5 })
          return true
        end,
        "fallback",
      },
      ["<Down>"] = {
        function(cmp)
          cmp.select_next({ count = 5 })
          return true
        end,
        "fallback",
      },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-m>"] = { "accept", "fallback" },
      ["<C-l>"] = { "show_documentation" },
    },
    signature = { enabled = true },
    cmdline = {
      keymap = {
        preset = "default",
        ["<CR>" ] = { "accept_and_enter", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        -- Up/Down search through history
        ["<Up>"] = { "fallback", },
        ["<Down>"] = { "fallback", },
      },
      completion = {
        menu = { auto_show = true },
      --   list = {
      --     selection = {
      --       preselect = true,
      --       auto_insert = true,
      --     },
      --   },
        ghost_text = { enabled = true}
      },
    },
    completion = {
      documentation = { auto_show = false },
      trigger = {
        -- show_on_trigger_character = false,
        prefetch_on_insert = false,
      },
      menu = {
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
            { "source_name" },
          },
        },
      },
    },
  },
}
