local json = require 'dkjson'

local Yabai = {
    bin = '/opt/homebrew/bin/yabai',
    config_home = os.getenv('HOME') .. '/.config/yabai',
    queries = {
        getWindows = ' -m query --windows'
    },
    space_definitions = require 'space_definitions'
}

function Yabai:getWindows()
    local fh = io.popen(self.bin .. self.queries.getWindows, 'r')
    local windows = fh:read("*all")
    return json.decode(windows)
end

function Yabai:getWindowIdsForApp(appName)
    local windowIds = {}
    local json = self:getWindows()

    for _, v in pairs(json) do
        if v.app == appName then
            table.insert(windowIds, v.id)
        end
    end
    return windowIds
end

function Yabai:getCurrentSpaceLabel()
    local fh = io.popen(self.bin .. ' -m query --spaces --space', 'r')
    local windows = fh:read("*all")
    return json.decode(windows)["label"]
end

return Yabai
