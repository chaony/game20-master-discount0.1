--角色的专属装备
--绝情 若被技能“十面埋伏”命中的敌人在5秒内死亡，则绝情会恢复已损失生命值的30%，并额外获得100点能量
---@class W_JueQ_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_JueQ_Trait0", PlayerTrait)

M.hp = 0
M.anger = 0

function M:init()
    M.super.init(self) 
    self.hp = self:getValue(1)  --回血
    self.anger = self:getValue(2)  --会怒
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end


function M:playerDeadHandler(eventName, data)
	local ply = data["data"]

	if ply ~= nil and ply.camp ~= self.player.camp  then
		local buffs = ply.bufMgr:findBufByTag("W_JueQ_skill3")
		if table.nums(buffs) > 0 then
			local cure = (self.playerBuf.player.data:get_hp() - self.playerBuf.player.data:get_curHp() ) * self.hp
			self.player:cure("fix", self.player, cure)
			self.player.angerData:addAnger(self.anger)
			self:alterValue(cure,self.anger)
		end
	end

end

function M:alterValue(cure,anger )
	-- body
end


function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    M.super.destroy(self)
end

return M