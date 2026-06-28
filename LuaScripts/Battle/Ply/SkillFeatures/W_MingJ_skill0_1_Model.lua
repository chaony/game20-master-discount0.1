--当明教死亡时，会在自身周围降下圣火，对范围内的敌人造成
--200%攻击力的伤害，并使命中的敌人在后续5秒内，受到的伤害提升20%
---@class W_MingJ_skill0_1_Model : SkillFeatures_Model
local M = class("W_MingJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end


--死亡回调
function M:deadHandler( eventName, data )
	local player = data["data"]
	if player ~= nil and player:equal(self.player) then
		self.player.keepMgrAfterDead = self.__cname		-- 角色死亡后，要释放事件，不能清理Mgr
		TimeTools:delayTime( GlobalTools.base1_7, function()
			if self.player.evtMgr then
				self.player:set_curSkillConfig(self.skill)
				self.player.evtMgr:commonEventWork("Hit",self.skill.level );
				self.player.keepMgrAfterDead = nil
				--self.player:clearMgr()
			end
		end)
	end
end


function M:destroy()
    M.super.destroy(self)
	EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end


return M