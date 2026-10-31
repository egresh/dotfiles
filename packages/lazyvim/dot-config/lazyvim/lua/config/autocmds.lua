-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- autocmd BufNewFile,BufRead {.,}tmux*.conf set ft=tmux | compiler tmux
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "tmux" then
      -- Use vim.defer_fn instead of vim.schedule to run after all LspAttach callbacks
      vim.defer_fn(function()
        vim.keymap.set("n", "K", ":call tmux#man()<CR>", {
          buffer = args.buf,
          silent = true,
          desc = "tmux man",
        })
      end, 100)
    end
  end,
})

-- Listen on a socket keyed by the worktree root so bin/nvim-refs (tmux popup
-- picker) can open file:line references from the paired Claude pane in this
-- exact instance. Must match the key derivation in bin/nvim-refs.
local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
if vim.v.shell_error ~= 0 or not root or root == "" then
  root = vim.fn.getcwd()
end
pcall(vim.fn.serverstart, "/tmp/nvim-lazyvim-" .. root:gsub("[^%w]", "_") .. ".sock")

-- claudecode.nvim runs with terminal.provider = "none" (Claude lives in a
-- tmux pane, not an in-editor terminal), so focus that pane ourselves after
-- a :ClaudeCodeSend instead of relying on the plugin's focus_after_send.
vim.api.nvim_create_autocmd("User", {
  pattern = "ClaudeCodeSendComplete",
  callback = function()
    if vim.env.TMUX then
      vim.fn.system({ "tmux", "select-pane", "-t", "{last}" })
    end
  end,
})

-- Dim this nvim when its tmux pane loses focus (tmux window-style can't tint
-- nvim, which paints its own background). Needs tmux `focus-events on`; the bg
-- matches window-style in tmux.conf.
local function set_dim(on)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.wo[win].winhighlight = on and "Normal:NvimDim,NormalNC:NvimDim,SignColumn:NvimDim,EndOfBuffer:NvimDim" or ""
  end
end
local function define_dim() vim.api.nvim_set_hl(0, "NvimDim", { bg = "#1a1a1a" }) end
define_dim()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_dim })

-- Some tinted schemes have a base02 (Visual bg) that blends with or clashes
-- with the text; reverse always contrasts.
local function define_visual() vim.api.nvim_set_hl(0, "Visual", { reverse = true }) end
define_visual()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_visual })

-- Snacks draws ignored/hidden paths with NonText, which some tinted schemes
-- set to ~the background color (invisible); Comment stays dim but readable.
local function define_ignored()
  for _, g in ipairs({ "SnacksPickerPathIgnored", "SnacksPickerPathHidden" }) do
    vim.api.nvim_set_hl(0, g, { link = "Comment" })
  end
end
define_ignored()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_ignored })
vim.api.nvim_create_autocmd("FocusLost", { callback = function() set_dim(true) end })
vim.api.nvim_create_autocmd("FocusGained", { callback = function() set_dim(false) end })
