-- management for tmux.conf
-- K on a keyword grabs tmux doc
return {
  "tmux-plugins/vim-tmux",
  ft = "tmux",
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      pattern = "tmux.conf",
      callback = function(args)
        vim.keymap.set("n", "M", ":call tmux#man()<CR>", {
          buffer = args.buf,
          silent = true,
          desc = "tmux man",
        })
      end,
    })
  end,
}
