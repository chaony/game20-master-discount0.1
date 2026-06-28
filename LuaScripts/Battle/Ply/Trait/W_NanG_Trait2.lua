--角色的专属装备
--南宫 战斗中 当南宫的血量低于50%时，会立即释放一次必杀技，且本次必杀技不消耗能量
--释放必杀技所需的血量条件变为70%
--必杀技结束时，南宫会恢复已损失生命值得30%

local W_NanG_Trait1 = require("Battle.Ply.Trait.W_NanG_Trait1")

---@class W_NanG_Trait2 : W_NanG_Trait1 @
---@field super W_NanG_Trait1 @W_NanG_Trait1
local M = class("W_NanG_Trait2", W_NanG_Trait1)

M.cure = 0

function M:init()
    M.super.init(self) 
    self.cure = self:getValue(2)  --回血
    
end

function M:alterValue( ... )
	local cure = (self.playerBuf.player.data:get_hp() - self.playerBuf.player.data:get_curHp() ) * self.cure
	self.player:cure("fix", self.player, cure)

end



return M