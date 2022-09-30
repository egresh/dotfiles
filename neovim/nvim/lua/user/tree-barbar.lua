local tree = {}

local offset = 31

tree.state = function()
    local buffers = vim.api.nvim_exec("ls!", true)
    local state

    if string.find(buffers, "NvimTree") then
        state = "opened"
    else
        state = "closed"
    end

    return state
end

tree.toggle = function()
    if tree.state() == "closed" then
        require("bufferline.state").set_offset(offset, "Nvim-Tree")
    else
        require("bufferline.state").set_offset(0)
    end

    require("nvim-tree").toggle()
end

tree.resize = function(new_offset)
    local _, _, sign, amount = string.find(new_offset, "([+-])(%d+)")

    if tree.state() == "opened" then
        if sign == "+" then
            offset = offset + amount + 2
        else
            offset = offset - amount - 1
        end

        if offset < 20 then offset = 21 end
        if offset > 60 then offset = 61 end

        print("New offset is " .. offset)
        vim.api.nvim_command("NvimTreeResize " .. offset)

        require("bufferline.state").set_offset(offset, "Nvim-Tree")
    end
end

return tree
