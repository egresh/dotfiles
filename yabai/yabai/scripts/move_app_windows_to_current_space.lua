local yabai = require 'yabai'

if arg[1] == nil then
    os.exit(1)
end

local app = arg[1]

local ids = yabai:getWindowIdsForApp(app)
local space = yabai:getCurrentSpaceLabel()

for _, v in pairs(ids) do
    local command = '/opt/homebrew/bin/yabai -m window ' .. v .. ' --space ' .. space
    os.execute(command)
end
