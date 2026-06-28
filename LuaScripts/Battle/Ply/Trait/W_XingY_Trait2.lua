--角色的专属装备
--形意
--每次切换拳意的时候，会获得1秒的霸体效果，霸体效果下免疫一切控制效果

--霸体持续时间提升至2秒

--霸体状态会获得30%的伤害减免
local W_XingY_Trait1 = require("Battle.Ply.Trait.W_XingY_Trait1")
---@class W_XingY_Trait2 : W_XingY_Trait1 @
---@field super W_XingY_Trait1 @W_XingY_Trait1
local M = class("W_XingY_Trait2", W_XingY_Trait1)

M.buffId2 = nil

function M:init()
    M.super.init(self)
    self.buffId2 = self:getValue(2)
    
end

function M:rest_func( )
  self.player.bufMgr:addBufById(self.buffId2,self.player)
end


return M