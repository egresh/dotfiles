-- Set barbar's options
vim.g.bufferline = {
    -- Enable/disable animations
    animation = true,

    -- Enable/disable auto-hiding the tab bar when there is a single buffer
    auto_hide = true,

    -- Enable/disable current/total tabpages indicator (top right corner)
    tabpages = true,

    -- Enable/disable close button
    closable = false,

    -- Enables/disable clickable tabs
    --  - left-click: go to buffer
    --  - middle-click: delete buffer
    clickable = true,

    -- Excludes buffers from the tabline
    exclude_ft = { "javascript", "qf", "fugitive", "gitcommit" },
    exclude_name = { "package.json" },

    -- Enable/disable icons
    -- if set to 'numbers', will show buffer index in the tabline
    -- if set to 'both', will show buffer index and icons in the tabline
    icons = 'both',

    -- If set, the icon color will follow its corresponding buffer
    -- highlight group. By default, the Buffer*Icon group is linked to the
    -- Buffer* group (see Highlighting below). Otherwise, it will take its
    -- default value as defined by devicons.
    icon_custom_colors = false,

    -- Configure icons on the bufferline.
    icon_separator_active = "▎",
    icon_separator_inactive = "▎",
    icon_close_tab = "",
    icon_close_tab_modified = "●",
    icon_pinned = "車",

    -- If true, new buffers will be inserted at the start/end of the list.
    -- Default is to insert after current buffer.
    insert_at_end = false,
    insert_at_start = false,

    -- Sets the maximum padding width with which to surround each tab
    maximum_padding = 1,

    -- Sets the maximum buffer name length.
    maximum_length = 30,

    -- If set, the letters for each buffer in buffer-pick mode will be
    -- assigned based on their name. Otherwise or in case all letters are
    -- already assigned, the behavior is to assign letters in order of
    -- usability (see order below)
    semantic_letters = true,

    -- New buffer letters are assigned in this order. This order is
    -- optimal for the qwerty keyboard layout but might need adjustement
    -- for other layouts.
    letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",

    -- Sets the name of unnamed buffers. By default format is "[Buffer X]"
    -- where X is the buffer number. But only a static string is accepted here.
    no_name_title = nil,
}

--     *Current: current buffer
--     *Visible: visible but not current buffer
--    *Inactive: invisible but not current buffer
--        *Icon: filetype icon
--       *Index: buffer index
--         *Mod: when modified
--        *Sign: the separator between buffers
--      *Target: letter in buffer-picking mode

vim.cmd([[
highlight TablineFill guibg=#000000
highlight link BufferCurrent        GruvboxRed
highlight link BufferCurrentMod     BufferCurrent
highlight link BufferCurrentSign    BufferCurrent
highlight link BufferCurrentIndex   BufferCurrent
highlight link BufferCurrentTarget  BufferCurrent
highlight link BufferVisible        BufferCurrent
highlight link BufferVisibleMod     BufferVisible
highlight link BufferVisibleSign    BufferVisible
highlight link BufferVisibleIndex   BufferVisible
highlight link BufferVisibleTarget  BufferVisible
highlight link BufferInactive       GruvboxOrangeSign
highlight link BufferInactiveMod    BufferInactive
highlight link BufferInactiveSign   BufferInactive
highlight link BufferInactiveIndex  BufferInactive
highlight link BufferInactiveTarget BufferInactive
highlight BufferTabpages            guibg=#000000 guifg=#ff0000
]])
