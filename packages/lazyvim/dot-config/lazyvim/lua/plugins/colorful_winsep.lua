return {
  "nvim-zh/colorful-winsep.nvim",
  config = true,
  event = { "WinLeave" },
  opts = {
    smooth = false,
    animate = {
      enabled = "progressive"
    }
  }
}
