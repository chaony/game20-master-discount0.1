
--玩家player 假死，陷入死亡（不是真正死亡，可能处于假死） AI基类  江湖传奇敌方假死
-- 江湖传奇的敌人死亡的时候，不会真正的销毁，而是等待后续有需要重复出现
---@class AIStateLegendDie_Enemy : AIState @
---@field super AIState @AIState
local M = class("AIStateLegendLeave_Enemy", Battle.AIState)

M.extra_anim_name = nil
M.anim_name = "die";
-- 消失的时间点
M.disappearTime = GlobalTools.base0_0_1	-- 下一帧消失

--进入移动状态
function M:enter()
	M.super.enter(self)
	self.disappearTime = GlobalTools.base0_0_1
	-- 移除目标
	self.player.data:clearAllData()
	self.player.plyMgr:addHide(self.player)
	self.player:ShowHpBar(false)        -- 隐藏血条
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelLeaveBattle, {})
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.disappearTime > 0 then
		self.disappearTime = self.disappearTime - dt
		if self.disappearTime <= 0 then
			self.player:hideBody(false)     -- 隐藏本体，回收
			EventDispatcher:dipatchEvent("leave_battlefield", {player = self.player}) -- 离开战场
		end
	end
end

return M