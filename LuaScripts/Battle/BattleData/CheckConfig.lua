
---@class CheckConfig
local CheckConfig = {
    LogPath = "D:\\BattleData\\log\\check_log.log"
}

local __log = Logger.log
local __logError = Logger.logError

function CheckConfig.writeLog(var, msg)
    local log_path = CheckConfig.LogPath
    if type(var) == "table" then
        var = Json.encode(var)
    else
        var = tostring(var)
    end
    msg = tostring(msg) .. ":" .. tostring(var)

    local file = io.open(log_path, "a+")
    if file then
        file:write(string.format("%s\n", msg))
        file:close()
    end
end

function Logger.log(var, msg)
    CheckConfig.writeLog(var, msg)
    __log(var, msg)
end

function Logger.logError(var, msg)
    CheckConfig.writeLog(var, msg)
    __logError(var, msg)
end

function CheckConfig:prepare()
    local log_path = CheckConfig.LogPath
    if io.exists(log_path) then
        local file, result = io.open(log_path, "w")
        if file then
            file:write("")
            file:close()
        else
            __log(CheckConfig.LogPath, "????????" .. tostring(result))
        end
    else
        local file, result = io.open(log_path, "w")
        if file then
            file:write("")
            file:close()
        else
            __log(CheckConfig.LogPath, "??????????" .. tostring(result))
        end
    end
end

return CheckConfig