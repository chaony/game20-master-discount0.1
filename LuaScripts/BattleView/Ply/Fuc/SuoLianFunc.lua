--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-06 15:59:48
]]

--锁链功能
---@class SuoLianFunc @
local M = class("SuoLianFunc")

M.obj = nil
--初始化
function M:init( prefabName, parent)
    self.obj = ResourceUtil:GetItem( prefabName, parent, "role3d_"..string.lower( self.player.prefabRoot ) )
end

--更新
function M:update(dt, unsdt)
    
end

return M