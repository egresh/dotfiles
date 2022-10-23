local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

return packer.startup(function(use)
    use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
    use({ "nvim-lua/plenary.nvim" })

    -- Bling
    use({
        "hoob3rt/lualine.nvim",
        requires = {
            "kyazdani42/nvim-web-devicons",
            opt = true,
        },
        disable = false,
    })

    -- Colorschemes
    use({ "rose-pine/neovim", disable = false })
    use({ "ellisonleao/gruvbox.nvim", disable = false })

    -- Utility
    use({
        "numToStr/Navigator.nvim",
        config = function()
            require("Navigator").setup()
        end,
        disable = false,
    })

    use({ "simeji/winresizer", disable = false })
    use({ "folke/which-key.nvim", disable = false })
    use({ "lewis6991/gitsigns.nvim", disable = false })
    use({ "tpope/vim-fugitive", disable = false })
    use({ "tpope/vim-unimpaired", disable = false })
    use({ "tpope/vim-surround", disable = false })
    use({ "akinsho/toggleterm.nvim", disable = false })
    use({ "tpope/vim-dispatch", disable = false })
    use({ "dhruvasagar/vim-zoom", disable = false })

    -- Navigation
    -- use({ "ggandor/lightspeed.nvim", disable = false })
    use({ "justinmk/vim-sneak", disable = false })
    use({ "kyazdani42/nvim-tree.lua", disable = false })
    use({ "shatur/neovim-session-manager", disable = false })
    -- use({ "romgrk/barbar.nvim", disable = false })
    use({ "tpope/vim-obsession", disable = false })
    use({ "dhruvasagar/vim-prosession", disable = false })

    -- Telescope
    use({ "nvim-telescope/telescope.nvim", disable = false })
    use({ "nvim-telescope/telescope-file-browser.nvim", disable = false })
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", disable = false })
    use({ "nvim-telescope/telescope-ui-select.nvim", disable = false })

    -- Formatting
    use({ "windwp/nvim-autopairs", disable = false })
    use({ "lukas-reineke/indent-blankline.nvim", disable = false })
    use({ "numToStr/Comment.nvim", disable = false })
    use({ "alvan/vim-closetag", disable = false })

    -- Treesitter
    use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", disable = false })
    use({ "nvim-treesitter/nvim-treesitter-textobjects", disable = false })
    use({ "JoosepAlviste/nvim-ts-context-commentstring", disable = false })
    use({ "nvim-treesitter/playground", disable = false })
    use({ "davidgranstrom/nvim-markdown-preview", disable = false })

    -- LSP
    use({ "williamboman/nvim-lsp-installer", disable = false })
    use({ "neovim/nvim-lspconfig", disable = false })
    use({ "nvim-lua/lsp-status.nvim", disable = false })
    use({ "hrsh7th/nvim-cmp", disable = false })
    use({ "hrsh7th/cmp-buffer", disable = false })
    use({ "hrsh7th/cmp-path", disable = false })
    use({ "hrsh7th/cmp-nvim-lsp", disable = false })
    use({ "hrsh7th/cmp-nvim-lua", disable = false })
    use({ "hrsh7th/cmp-cmdline", disable = false })
    use({ "hrsh7th/cmp-vsnip", disable = false })
    use({ "ray-x/cmp-treesitter", disable = false })
    use({ "quangnguyen30192/cmp-nvim-tags", disable = false })
    use({ "jose-elias-alvarez/null-ls.nvim", disable = false })
    use({ "RishabhRD/popfix", disable = false })
    use({ "RishabhRD/nvim-lsputils", disable = false })

    -- Snippets
    use({ "hrsh7th/vim-vsnip", disable = false })
    use({ "hrsh7th/vim-vsnip-integ", disable = false })
    use({ "rafamadriz/friendly-snippets", disable = false })

    -- Vim Dev
    use({ "folke/lua-dev.nvim", disable = false })
    use({ "bfredl/nvim-luadev", disable = false })
    use({ "wsdjeg/luarefvim", disable = false })
    use({ "rafcamlet/nvim-luapad", disable = false })
    use({ "lewis6991/impatient.nvim", disable = false })

    -- Dev
    use({ "vim-test/vim-test", disable = false })

    -- Ruby/Rails
    use({ "tpope/vim-rails", disable = false })
    use({ "tpope/vim-bundler", disable = false })

    -- Testing
    --[[ use({ "egresh/oleo", disable = false }) ]]
    -- use({ "egresh/telescope-prosession", disable = false })
end)
