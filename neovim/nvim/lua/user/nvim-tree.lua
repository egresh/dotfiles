-- [NvimTree] unknown option: show_icons | unknown option: git_hl | unknown option: disable_window_picker | unknown option: indent_mark
-- ers | unknown option: auto_close | unknown option: quit_on_open | unknown option: view.auto_resize

-- vim.g.nvim_tree_icons = {
--     default = "",
--     symlink = "",
--     git = {
--         unstaged = "",
--         staged = "S",
--         unmerged = "",
--         renamed = "➜",
--         deleted = "",
--         untracked = "U",
--         ignored = "◌",
--     },
--     folder = {
--         arrow_open = "",
--         arrow_closed = "",
--         default = "",
--         open = "",
--         empty = "",
--         empty_open = "",
--         symlink = "",
--         symlink_open = "",
--     },
-- }

-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`
require("nvim-tree").setup({
    auto_reload_on_write = true,
    disable_netrw = true,
    hijack_cursor = false,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = false,
    ignore_buffer_on_setup = false,
    ignore_ft_on_setup = {},
    open_on_setup = false,
    open_on_setup_file = false,
    open_on_tab = false,
    sort_by = "name",
    update_cwd = false,
    respect_buf_cwd = false,
    view = {
        width = 30,
        hide_root_folder = false,
        side = "left",
        preserve_window_proportions = false,
        number = false,
        relativenumber = false,
        signcolumn = "yes",
        mappings = {
            custom_only = false,
            list = {
                -- user mappings go here
            },
        },
    },
    renderer = {
        indent_markers = {
            enable = false,
            icons = {
                corner = "└ ",
                edge = "│ ",
                none = "  ",
            },
        },
        icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    deleted = "",
                    untracked = "U",
                    ignored = "◌",
                },
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
            }
        },
    },
    hijack_directories = {
        enable = true,
        auto_open = true,
    },
    update_focused_file = {
        enable = true,
        update_cwd = false,
        ignore_list = {},
    },
    system_open = {
        cmd = "",
        args = {},
    },
    diagnostics = {
        enable = true,
        show_on_dirs = false,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
    filters = {
        dotfiles = false,
        custom = {},
        exclude = {},
    },
    git = {
        enable = true,
        ignore = true,
        timeout = 400,
    },
    actions = {
        use_system_clipboard = true,
        change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
        },
        open_file = {
            quit_on_open = false,
            resize_window = false,
            window_picker = {
                enable = true,
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                exclude = {
                    filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                    buftype = { "nofile", "terminal", "help" },
                },
            },
        },
    },
    trash = {
        cmd = "trash",
        require_confirm = true,
    },
    log = {
        enable = false,
        truncate = false,
        types = {
            all = false,
            config = false,
            copy_paste = false,
            diagnostics = false,
            git = false,
            profile = false,
        },
    },
})
-- vim.cmd([[
--     let g:nvim_tree_respect_buf_cwd = 0 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
-- ]])

-- vim.cmd([[
-- let g:nvim_tree_quit_on_open = 1 "0 by default, closes the tree when you open a file
-- let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
-- let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
-- let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
-- let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
-- let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
-- let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
-- let g:nvim_tree_disable_window_picker = 1 "0 by default, will disable the window picker.
-- let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
-- let g:nvim_tree_symlink_arrow = ' >> ' " defaults to ' ➛ '. used as a separator between symlinks' source and target.
-- let g:nvim_tree_respect_buf_cwd = 1 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
-- let g:nvim_tree_create_in_closed_folder = 0 "1 by default, When creating files, sets the path of a file when cursor is on a closed folder to the parent folder when 0, and inside the folder when 1.
-- let g:nvim_tree_refresh_wait = 500 "1000 by default, control how often the tree can be refreshed, 1000 means the tree can be refresh once per 1000ms.
-- let g:nvim_tree_window_picker_exclude = {
--     \   'filetype': [
--     \     'notify',
--     \     'packer',
--     \     'qf'
--     \   ],
--     \   'buftype': [
--     \     'terminal'
--     \   ]
--     \ }
-- " Dictionary of buffer option names mapped to a list of option values that
-- " indicates to the window picker that the buffer's window should not be
-- " selectable.
-- let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
-- "If 0, do not show the icons for one of 'git' 'folder' and 'files'
-- "1 by default, notice that if 'files' is 1, it will only display
-- "if nvim-web-devicons is installed and on your runtimepath.
-- "if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
-- "but this will not work when you set indent_markers (because of UI conflict)
--
-- " default will show icon by default if no icon is provided
-- " default shows no icon by default
-- ]])
