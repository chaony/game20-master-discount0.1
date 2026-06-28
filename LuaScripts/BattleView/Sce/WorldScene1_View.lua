--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class WorldScene1_View : WorldSceneBase_View @
---@field super WorldSceneBase_View @WorldSceneBase_View
local M = class("WorldScene1_View",Battle.WorldSceneBase_View)

function M:getCurSceneObjName()
    return "";
end

return M;