local json = require 'dkjson'

local Yabai = {
    bin = '/opt/homebrew/bin/yabai',
    config_home = os.getenv('HOME') .. '/.config/yabai',
    queries = {
        getWindows = ' -m query --windows',
        getCurrentWindow = ' -m query --windows --window',
        getCurrentSpace = ' -m query --spaces --space',
        getDisplays = ' -m query --displays'
    },
}

local function execute_read(self, query)
    local to_execute = self.bin .. query
    local fh = assert(io.popen(to_execute, 'r'))
    local output = fh:read("*all")
    fh:close()
    return json.decode(output)
end

function Yabai:getWindows()
    return execute_read(self, self.queries.getWindows)
end

function Yabai:getCurrentWindow()
    return execute_read(self, self.queries.getCurrentWindow)
end

function Yabai:getCurrentSpaceLabel()
    return execute_read(self, self.queries.getCurrentSpace)["label"]
end

function Yabai:getCurrentSpace()
    return execute_read(self, self.queries.getCurrentSpace)
end

function Yabai:getDisplays()
    return execute_read(self, self.queries.getDisplays)
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

return Yabai
