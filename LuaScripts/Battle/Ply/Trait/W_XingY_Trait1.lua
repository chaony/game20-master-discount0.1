--角色的专属装备
--形意
--每次切换拳意的时候，会获得1秒的霸体效果，霸体效果下免疫一切控制效果
--霸体持续时间提升至2秒
local W_XingY_Trait0 = require("Battle.Ply.Trait.W_XingY_Trait0")
---@class W_XingY_Trait1 : W_XingY_Trait0 @
---@field super W_XingY_Trait0 @W_XingY_Trait0
local M = class("W_XingY_Trait1", W_XingY_Trait0)



function M:init()
    M.super.init(self)
    self.buffId = self:getValue(1)
   
end

return M