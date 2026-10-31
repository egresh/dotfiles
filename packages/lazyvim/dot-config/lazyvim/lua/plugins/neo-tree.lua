return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- buffers = {
    --   follow_current_file = {
    --     enabled = true,
    --   },
    -- },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = {
        enabled = true,
      },
    },
    reveal = true,
    reveal_force_cwd = true,
    -- cwd_target = {
    --   current = "window",
    --   sidebar = "window",
    -- },
    -- use_libuv_file_watcher = false,
    filesystem = {
      bind_to_cwd = true,
      cwd_target = {
        current = "window",
        sidebar = "window",
      },
      filtered_items = {
        visible = false, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".DS_Store",
          "thumbs.db",
          --"node_modules",
        },
        hide_by_pattern = {
          --"*.meta",
          --"*/src/*/tsconfig.json",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          --".gitignored",
        },
        always_show_by_pattern = { -- uses glob style patterns
          --".env*",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          --".DS_Store",
          --"thumbs.db",
        },
        never_show_by_pattern = { -- uses glob style patterns
          --".null-ls_*",
        },
      },
      find_by_full_path_words = false,
    },
    window = {
      mappings = {
        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        ["l"] = "focus_preview",
        ["<C-b>"] = { "scroll_preview", config = { direction = 10 } },
        ["<C-f>"] = { "scroll_preview", config = { direction = -10 } },
      },
      fuzzy_finder_mappings = {
        ["<C-j>"] = "move_cursor_down",
        ["<C-k>"] = "move_cursor_up",
      },
    },
  },
}
