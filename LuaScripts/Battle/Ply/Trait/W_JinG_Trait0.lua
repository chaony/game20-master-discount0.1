--角色的专属装备
-- 金刚 每场战斗第一次释放绝技时，技能蓄力期间金刚不会死亡

---@class W_JinG_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_JinG_Trait0", PlayerTrait)


M.buffId = 0

M.maxCount = 0

function M:init()
    M.super.init(self)
	self.buffId = self:getValue(1) -- 免疫死亡buf
    self.maxCount = self:getValue(2) -- 次数
    self.count =  self.maxCount
end




return M