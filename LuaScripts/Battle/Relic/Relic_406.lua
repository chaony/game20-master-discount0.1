--幻翎扇
--战斗开始时释放，“放逐”敌方当前攻击力最高的侠客x秒，被放逐的侠客无法攻击也无法被攻击，该效果无法被免疫，放逐结束后，该侠客的攻击力还会降低x%，持续X秒

---@class Relic_406 : Relic @
---@field super Relic @Relic
local M = class("Relic_406", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.disappearBuff = self:getValue(1) --放逐buff  tag Relic_406_Disappear
	self.defBuff = self:getValue(2)--降低敌人攻击buff
	EventDispatcher:registerEvent("remove_Relic_406_Disappear", {self,self.removeBuffHandler})
end

function M:gameStart()
	M.super.gameStart(self)
	local player = self.mgr.plyMgr:getPlayers(self.mgr.camp):get(0)
	if player == nil then
		return
	end
	local enemies = SelectTargetUtil:findPlayerByParam(player, {
		camp = "enemy",
		ignoreSummon = true,
		pos = "forceMax",
		--priority = true,
	})
	if enemies.Count > 0 then
		local target = enemies:get(0)
		if target and target:isLive()  and target.bufMgr ~= nil then
			target.bufMgr:addBufById(self.disappearBuff, target)
		end
	end
end
---@param eventData Battle_HandleData_RemoveBuff
function M:removeBuffHandler(eventName, eventData)
	local buff = data["buff"]
	if buff ~= nil and buff.player ~= nil and buff.player:isLive()  and buff.player.bufMgr ~= nil then
		buff.player.bufMgr:addBufById(self.defBuff, buff.player)
	end
end

function M:gameover()
	EventDispatcher:unRegisterEvent("remove_Relic_406_Disappear",{self,self.removeBuffHandler})
	M.super.gameover(self)
end

return M