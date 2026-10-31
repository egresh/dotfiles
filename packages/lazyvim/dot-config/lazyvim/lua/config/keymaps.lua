-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local silent = { silent = true }

vim.keymap.set("i", "jk", "<esc>")
vim.keymap.set({ "n", "v" }, "\\\\", "gcc", { remap = true, silent = true })
vim.keymap.set("n", "\\\\", "<cmd>normal gcc<cr>", { desc = "Toggle Comment" })

-- lazyvim uses <esc><esc> for the same thing
-- vim.keymap.set("t", "<esc>", "<C-\\><c-n>")

vim.keymap.set("n", "<M-j>", ":resize +2<CR>", silent)
vim.keymap.set("n", "<M-k>", ":resize -2<CR>", silent)
vim.keymap.set("n", "<M-h>", ":vertical resize +3<CR>", silent)
vim.keymap.set("n", "<M-l>", ":vertical resize -3<CR>", silent)

vim.keymap.set("n", "<space><enter>", ":close<cr>", { silent = true, desc = "Close Window" })

vim.keymap.del("n", "<leader>gl")
vim.keymap.del("n", "<leader>gL")
vim.keymap.del("n", "<leader>gG")
vim.keymap.del("n", "<leader>gS")
vim.keymap.set("n", "<leader>gg", "<cmd>lua require('neogit').open()<cr>", { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gp", "<cmd>lua require('neogit').pull()<cr>", { desc = "Neogit Pull" })
vim.keymap.set("n", "<leader>gP", "<cmd>lua require('neogit').push()<cr>", { desc = "Neogit Push" })

local function git_picker(name, args)
  return function()
    Snacks.picker.pick({
      source = name,
      finder = "proc",
      cmd = "git",
      args = args,
      transform = function(item)
        item.file = item.text
      end,
      format = "file",
    })
  end
end

vim.keymap.set(
  "n",
  "<leader>gS",
  git_picker("staged", { "diff", "--name-only", "--cached", "--relative" }),
  { desc = "Staged files" }
)
vim.keymap.set(
  "n",
  "<leader>gU",
  git_picker("unstaged", { "diff", "--name-only", "--relative" }),
  { desc = "Unstaged files" }
)
vim.keymap.set(
  "n",
  "<leader>gC",
  git_picker("last_commit", { "diff", "--name-only", "--relative", "HEAD~1", "HEAD" }),
  { desc = "Previous commit files" }
)

-- vim.keymap.set("n", "<leader>md", ":Glow<CR>", { desc = "View Markdown using Glow" })
-- vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
-- vim.keymap.set("n", "<leader>ght", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle current line blame" } )
-- vim.keymap.set("n", "<leader>dhl", "<cmd>Gitsigns preview_hunk_inline<cr>", { desc = "Preview Hunk Inline" })
-- vim.keymap.set("n", "<leader>dhh", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview Hunk" })
-- vim.keymap.set("n", "[a", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Previous Hunk" })
-- vim.keymap.set("n", "]a", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next Hunk" })

-- vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diff_this<cr>", { desc = "Diff View" })
-- vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Blame line" })
-- vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage hunk" })
-- vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = "Unstage hunk" })
-- vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Stage buffer"})
-- vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset buffer"})

-- vim.keymap.set(
--   "n",
--   "\\\\",
--   ":lua MiniComment.toggle_lines(vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[1])<cr>",
--   { silent = true, desc = "Toggle Line Comment " }
-- )
--
-- vim.keymap.set(
--   "i",
--   "\\\\",
--   "<esc>:lua MiniComment.toggle_lines(vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[1])<cr>0ji",
--   { silent = true, desc = "Toggle Line Comment " }
-- )

-- Typo forgiveness: :Qa / :Qa! -> :qa / :qa!
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true })

-- ri docs for the word under the cursor, in a floating markdown buffer (q to close).
-- Global, not a ruby FileType autocmd: this file loads on VeryLazy, after the
-- first buffer's FileType has already fired.
vim.keymap.set("n", "<leader>ri", function()
  local word = vim.fn.expand("<cword>")
  local lines = vim.fn.systemlist({ "ri", "-T", "-f", "markdown", word })
  Snacks.win({
    text = lines,
    ft = "markdown",
    width = 0.7,
    height = 0.7,
    border = "rounded",
    title = " ri " .. word .. " ",
    wo = { wrap = true },
    keys = { q = "close" },
  })
end, { desc = "ri docs for word" })
