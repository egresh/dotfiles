return {
  {
    "catppuccin/nvim",
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- load before oter plugins
    config = function(_)
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end,
  },
  {
    "Mofiqul/dracula.nvim",
    opts = {
      overrides = {
        Normal = { bg = "black" },
      },
    },
  },
  -- { "LazyVim/LazyVim", opts = {
  --   colorscheme = "gruvbox",
  -- } },
  {
    "tinted-theming/tinted-nvim",
    priority = 1000, -- load colorscheme early
    lazy = false, -- apply on startup
    opts = {
      default_scheme = "base24-encom",
      selector = {
        enabled = true
      }
      -- compile = true, -- optional: precompile for faster startup
    },
  },
}
