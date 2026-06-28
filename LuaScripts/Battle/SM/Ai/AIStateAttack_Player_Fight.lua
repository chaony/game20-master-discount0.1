---@class AIStateAttack_Player_Fight : AIStateAttack_Player @
---@field super AIStateAttack_Player @AIStateAttack_Player
local M = class("AIStateAttack_Player_Fight",Battle.AIStateAttack_Player)

--进入移动状态
function M:enter()
	M.super.enter(self)
	if self.player.isBoss == false then
		self.player:lockEnemyDir()
	end
	local cfg = self.player.curSkillConfig
	--先将动作切换到站立
	if cfg ~= nil then
		-- 播放技能音效	
		local skill_name,r = cfg:getAnimName()
		cfg:use()
		--StateSoundManager:playSound(cfg, self.player)
		self.player.animator:changeState(skill_name)
	else
		self.player.aiEngine:changeState("idle")
	end
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
end

--退出当前状态
function M:exit()
	M.super.exit(self)
end



return M