return {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>su", "<cmd>FzfLua buffers<cr>", desc = "Fzf buffers" },
      -- Override LazyVim's "Grep (cwd)": scope the grep to whatever directory the
      -- snacks explorer is currently rooted at (`.` on a folder re-roots it, see
      -- `explorer_focus`). Works from any window, not just the explorer. With no
      -- explorer open, `cwd` stays nil and this behaves like LazyVim's default.
      {
        "<leader>sG",
        function()
          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          LazyVim.pick.open("live_grep", { cwd = explorer and explorer:cwd(), root = false })
        end,
        desc = "Grep (Explorer Root / cwd)",
      },
    },
}
