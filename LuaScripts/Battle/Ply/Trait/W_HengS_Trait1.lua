--角色的专属装备
--恒山
--普通攻击命中敌人会随机为一名友军回复80%攻击力的生命值
--治疗效果提升至100%生命值

local W_HengS_Trait0 = require("Battle.Ply.Trait.W_HengS_Trait0")
---@class W_HengS_Trait1 : W_HengS_Trait0 @
---@field super W_HengS_Trait0 @W_HengS_Trait0
local M = class("W_HengS_Trait1", W_HengS_Trait0)


function M:init()
    M.super.init(self)
    self.hp = self:getValue(1)
end

return M