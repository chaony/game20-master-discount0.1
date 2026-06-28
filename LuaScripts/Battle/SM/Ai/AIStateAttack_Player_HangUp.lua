--挂机场景中玩家的攻击
---@class AIStateAttack_Player_HangUp : AIStateAttack_Player @
---@field super AIStateAttack_Player @AIStateAttack_Player
local M = class("AIStateAttack_Player_HangUp",Battle.AIStateAttack_Player)
-- local __AudioHelper = CS.wt.framework.AudioHelper.Instance
--进入移动状态
function M:enter()
	M.super.enter(self)
	if self.player.isBoss == false then
		self.player:lockEnemyDir()
	end
	
	local cfg = self.player.curSkillConfig
	--先将动作切换到站立
	if  cfg ~= nil then
		-- 播放技能音效
		local se_id = tonumber(cfg.data.use_se)
		if se_id ~= 0 then
            -- __AudioHelper:PlaySound(se_id)
		end
		cfg:use()
		local skill_name = self.player.curSkillConfig:getAnimName()
		self.player.animator:changeState(skill_name)
		--StateSoundManager:playSound(self.player.curSkillConfig, self.player)
	else
		self.player.aiEngine:changeState("idle")
		--if self.player.animator:hasState("attack1") then
		--	self.player.animator:changeState("attack1")
		--	local skill = self.player.plySkill:getSkillByName('attack1')
		--	if skill ~= nil then
		--		self:set_curSkillConfig(skill.cur_skill_config)
		--		StateSoundManager:playSound(self.curSkillConfig, self.player)
		--	end
		--	-- if self.curSkillConfig.data.use_se[1] == 1 then
		--	-- 	audio:SendEvtSkill('attack1',self.player.plyType)
		--	-- end
		--else
		--	self.player.animator:changeState("attack1_1")
		--	local skill = self.player.plySkill:getSkillByName('attack1')
		--	if skill ~= nil then
		--		self:set_curSkillConfig(skill.cur_skill_config)
		--		StateSoundManager:playSound(self.curSkillConfig, self.player)
		--	end
		--	-- if self.curSkillConfig.data.use_se[1] == 1 then
		--	-- 	audio:SendEvtSkill('attack1_1',self.player.plyType)
		--	-- end
		--end
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