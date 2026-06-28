--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

--定点数
---@class ClassPathUtil
local M = class("ClassPathUtil")

function M:init()
    self.classPathConfig = require("Battle.Tool.ClassPathConfig")
end

--是否存在某个文件
function M:Exists( fileName )
    local value = self.classPathConfig[fileName]
    return value ~= nil;
end

return M