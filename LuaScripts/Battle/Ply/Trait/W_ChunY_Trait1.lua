--角色的专属装备
--纯阳 场上每有一个被施加了“流血”效果的敌方武神，纯阳便获得5%的暴击率提升  当敌人流血buf消失 或者 死亡 清除效果
--还会使纯阳的暴击伤害提升10%

local W_ChunY_Trait0 = require("Battle.Ply.Trait.W_ChunY_Trait0")

---@class W_ChunY_Trait1 : W_ChunY_Trait0 @
---@field super W_ChunY_Trait0 @W_ChunY_Trait0
local M = class("W_ChunY_Trait1", W_ChunY_Trait0)


M.crit = 0


function M:init()
    M.super.init(self)
    self.crit = self:getValue(2)  
   
end

function M:addCrit( ... )
	self.player.data.crit:addToAddList(self.crit)
end

function M:removeCrit( ... )
	self.player.data.crit:removeFromAddList(self.crit)
end

return M