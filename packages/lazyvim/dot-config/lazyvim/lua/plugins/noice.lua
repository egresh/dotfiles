function ui_ok()
  if vim.g.started_by_firenvim == true then
    return false
  else
    return true
  end
end

return {
  "folke/noice.nvim",
  enabled = ui_ok(),
  opts = {
    -- debug = true,
    -- routes = {
    --   {
    --     view = "popup",
    --     filter = {
    --       event = "msg_show",
    --       mode = "!",
    --       filter = "ruby",
    --       cmdline = "rake"
    --     },
    --   },
    -- },
    lsp = {
      signature = {
        auto_open = { enabled = false },
      },
    },
    messages = {
      enabled = false,
      view = "popup",
    },
    -- messages = {
    --   enabled = true,
    --   view = "notify",
    -- },
    -- messages = {
    --   enabled = true,
    --   view = "split"
    -- },
    -- presets = {
    --   bottom_search = true
    -- }
  },
}
