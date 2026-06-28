--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class WorldScene2_Model : WorldSceneBase_Model @
---@field super WorldSceneBase_Model @WorldSceneBase_Model
local M = class("WorldScene2_Model",Battle.WorldSceneBase_Model)

function M:getCurSceneName()
    self:createSceneConfig(116)
    return self.scene_info.resource;
end

return M;