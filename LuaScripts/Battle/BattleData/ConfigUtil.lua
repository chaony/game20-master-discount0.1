---@class ConfigUtil 工具配置读取工具类
local M = {}
M.CONFIG_PATH = "C:/Users/Administrator/AppData/LocalLow/DefaultCompany/ResProject/LuaScripts/DataCenter/Config/" -- 配置路径

function M:init()
    local versionData = self:readConfigFile("game_config_version.txt")
    self.gameVersion = Json.decode(versionData) or {};
    self.loadedConfig = {}
    self.languageData = {}
    self:loadLocalizeConfig()
end


function M:readConfigFile(file)
    local config_path = M.CONFIG_PATH;
    local fileHandler = io.open(config_path .. file, "r")
    if fileHandler then
        local content = fileHandler:read("a")
        fileHandler:close()
        return content
    end
    return nil
end

function M:getCfgByName(cfgName)
    if self.loadedConfig[cfgName] == nil then
        local fileName = self.gameVersion[cfgName]
        local data = dofile(string.format("%s/%s__%s.lua", M.CONFIG_PATH, cfgName, fileName))
        self.loadedConfig[cfgName] = data or {}
    end
    return self.loadedConfig[cfgName]
end

function M:loadLocalizeConfig()
    for i, v in pairs(self.gameVersion) do
        if string.find(i, "ZH_CN") == 1 then
            local config = self:getCfgByName(i)
            table.merge(self.languageData, config)
        end
    end
end

return M