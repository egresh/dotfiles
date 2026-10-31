local setup = function()
  local term_one = require('toggleterm.terminal').Terminal:new({
    -- cmd = "lazygit",
    display_name = "Terminal 1",
    dir = "git_dir",
    direction = "float",
  })

  local term_two = require('toggleterm.terminal').Terminal:new({
    -- cmd = "lazygit",
    display_name = "Terminal 2",
    dir = "git_dir",
    direction = "float",
  })

  _term_one_toggle = function()
    term_one:toggle()
  end
  _term_two_toggle = function()
    term_two:toggle()
  end
end

return {
  'akinsho/toggleterm.nvim',
  version = "*",
  keys = {
    { "<leader>1", mode = { "n", "v", "t", "i" }, "<cmd>lua _term_one_toggle()<cr>", desc = "Navigate to terminal 1" },
    { "<leader>2", mode = { "n", "v", "t", "i" }, "<cmd>lua _term_two_toggle()<cr>", desc = "Navigate to terminal 2" }
  },
  cmd = { "ToggleTerm" },
  config = function()
    require("toggleterm").setup{
      direction = 'float',
      float_opts = {
        border = 'curved',
        winblend = 0,
        title_pos = 'center'
      }
    }
  end,
  init = function()
    setup()
  end
}
