return {
  "nvim-neotest/neotest",
  dependencies = { "nvim-neotest/nvim-nio", "olimorris/neotest-rspec" },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-rspec")({
          root_files = { "Gemfile", ".rspec", ".gitignore" },
          rspec_cmd = function()
            return vim.tbl_flatten({
              "bundle",
              "exec",
              "rspec",
            })
          end
        }),
      },
      output = {
        enabled = true,
        open_on_run = false
      }
    })
  end,
  keys = {
    { "<leader>tr", false },
    { "<leader>tn", "<cmd>w! <bar> lua require('neotest').run.run()<cr>", desc = "Neotest Run Nearest" },
    { "<leader>tf", "<cmd>w! <bar> lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Neotest Run File" },
    { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Neotest Toggle Summary" },
  },
}
