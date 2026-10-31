return {
  "numToStr/Navigator.nvim",
  config = function()
    require("Navigator").setup()
  end,
  keys = {
    { "<C-h>", mode = { "n", "v" }, "<cmd>NavigatorLeft<cr>", desc = "Navigate to left pane" },
    { "<C-l>", mode = { "n", "v" }, "<cmd>NavigatorRight<cr>", desc = "Navigate to right pane" },
    { "<C-j>", mode = { "n", "v" }, "<cmd>NavigatorDown<cr>", desc = "Navigate to bottom pane" },
    { "<C-k>", mode = { "n", "v" }, "<cmd>NavigatorUp<cr>", desc = "Navigate to top pane" },
  },
}
