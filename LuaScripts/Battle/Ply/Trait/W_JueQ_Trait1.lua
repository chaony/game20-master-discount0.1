--角色的专属装备
--绝情 若被技能“十面埋伏”命中的敌人在5秒内死亡，则绝情会恢复已损失生命值的30%，并额外获得100点能量
--我方友军会获得血量和能量的恢复效果的50%

local W_JueQ_Trait0 = require("Battle.Ply.Trait.W_JueQ_Trait0")

---@class W_JueQ_Trait1 : W_JueQ_Trait0 @
---@field super W_JueQ_Trait0 @W_JueQ_Trait0
local M = class("W_JueQ_Trait1", W_JueQ_Trait0)

M.value = 0

function M:init()
    M.super.init(self) 
    self.value = self:getValue(3)  --恢复效果
end


function M:alterValue(cure,anger )
	local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
	for i = 1,friends.Count do
		local ply = friends:get(i-1)
		if ply:equal(self.player) == false then
			ply:cure("fix", self.player, cure * self.value)
			ply.angerData:addAnger(anger * self.value)
		end
	end
end



return M