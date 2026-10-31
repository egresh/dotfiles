return {
  "folke/snacks.nvim",
  opts = {
    indent = {},
    picker = {
      sources = { buffers = { current = false } }, -- ,, lists the alternate buffer first
      win = {
        input = {
          keys = {
            ["<C-q>"] = { "qflist", mode = { "i", "n" } },
            ["<C-R>"] = function()
              Snacks.picker.buffers({current = false, sort_lastused = true, layout = { preview = false, preset = 'select'}})
            end,
          },
        },
        list = {
          keys = {
            ["<C-q>"] = { "qflist", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
