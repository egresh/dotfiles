return {
  "folke/trouble.nvim",
  optional = true,
  specs = {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- for k,v in pairs(opts) do
      --   print(k,v)
      -- end
      return vim.tbl_deep_extend("force", opts or {}, {
        picker = {
          actions = require("trouble.sources.snacks").actions,
          win = {
            input = {
              keys = {
                ["<c-t>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
                ["<c-q>"] = {
                  "trouble_quickfix",
                  mode = { "n", "i" }
                }
              },
            },
          },
        },
      })
    end,
  },
}
