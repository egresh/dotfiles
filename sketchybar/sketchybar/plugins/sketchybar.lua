local json = require 'dkjson'

local SketchyBar = {
    bin = '/opt/homebrew/bin/sketchybar',
    queries = {
        get_item = function(item)
            return " --query " .. item
        end
    }
}

function SketchyBar:get_item(item)
    local fh = io.popen(self.bin .. self.queries.get_item(item))
    local data = fh:read("*all")
    fh:close()
    return json.decode(data)
end

return SketchyBar
