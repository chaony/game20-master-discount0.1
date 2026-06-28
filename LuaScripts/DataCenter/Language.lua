------------ Language
---@class Language
local M = {}

function M:init()
    self.m_lang = require("DataCenter.Language.Language_zh_CN")
    self.m_system_language = U3DUtil:Get_SystemLanguage():ToString()
    self.m_cur_language = nil
    if self.m_system_language == "ChineseSimplified" or self.m_system_language == "Chinese" then
        self.m_cur_language = "zh_cn"
        local lang = ConfigManager:getCfgByName("ZH_CN")
        for k,v in pairs(lang) do
            self.m_lang[k] = v
        end
        CS.LuaGameLaunch.Instance.battleNumAtlasName = "language_zh_cn"
    else
        --TODO : 之后添加相关处理
        self.m_cur_language = "zh_cn"
        local lang = ConfigManager:getCfgByName("ZH_CN")
        for k,v in pairs(lang) do
            self.m_lang[k] = v
        end
        CS.LuaGameLaunch.Instance.battleNumAtlasName = "language_zh_cn"
    end
end

function M:changeLanguage()
    -- TODO : 改变语言
    -- self.m_lang = require("DataCenter.Language.Language_zh_CN")
end

function M:getTextByKey( key, arg1, ... )
    key = tostring(key)
    if arg1 then
        local format = self.m_lang[key]
        if format then
            return string.format( format, arg1, ... )
        else
            return key
        end
    else
        return self.m_lang[key] or key
    end
end

function M:getSystemLanguage()
    return self.m_system_language
end

function M:getCurLanguage()
    return self.m_cur_language or "zh_cn"
end

return M