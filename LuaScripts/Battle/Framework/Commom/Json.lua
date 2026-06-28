-- rapidjson
local rapidjson = rapidjson
if rapidjson == nil then
    rapidjson = require("rapidjson")
end

local Json = {}

function Json.encode(val)
    return rapidjson.encode(val)
end

function Json.decode(str)
    return rapidjson.decode(str)
end

return Json
