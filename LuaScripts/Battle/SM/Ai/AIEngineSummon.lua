---@class AIEngineSummon :AIEngine @特殊召唤物的AI状态机基础类
local M = class("AIEngineSummon",Battle.AIEngine)

--初始化AI状态机
function  M:init( player )
	M.super.init( self, player )
	--移动
	if self.player.summonAiType == "command" then
		self:register("spawn", "SummonAi.AIStateSpawn_Summon")
		self:register("move", "SummonAi.AIStateMove_Summon")
		self:register("idle", "SummonAi.AIStateIdle_Summon")
		self:register("skill", "SummonAi.AIStateSkill_Summon")
		self:register("die","AIStateDie_Player")
		self:register("die_into","AIStateIntoDie_Player")
		self:register("relive","AIStateRelive_Player")
	elseif self.player.summonAiType == "commandThenReturn" then
		self:register("return", "SummonAi.AIStateReturn_Summon")
		self:register("spawn", "SummonAi.AIStateSpawn_Summon_Return")
		self:register("move", "SummonAi.AIStateMove_Summon")
		self:register("idle", "SummonAi.AIStateIdle_Summon")
		self:register("skill", "SummonAi.AIStateSkill_Summon_Return")
		self:register("die","AIStateDie_Player")
		self:register("die_into","AIStateIntoDie_Player")
		self:register("relive","AIStateRelive_Player")
	elseif self.player.summonAiType == "ShootThenStop" then
		self:register("spawn", "SummonAi.AIStateSpawn_Summon_ShootStop")
		self:register("idle", "SummonAi.AIStateIdle_Summon_ShootStop")
		self:register("fire", "SummonAi.AIStateFire_Summon_ShootStop")
		self:register("stay", "SummonAi.AIStateStay_Summon_ShootStop")
		self:register("return", "SummonAi.AIStateReturn_Summon_ShootStop")
		self:register("skill", "SummonAi.AIStateSkill_Summon_ShootStop")
		self:register("die","AIStateDie_Player")
		self:register("die_into","AIStateIntoDie_Player")
		self:register("relive","AIStateRelive_Player")
	elseif self.player.summonAiType == "MoJ" then
		self:register("spawn", "SummonAi.AIStateSpawn_Summon")
		self:register("idle", "SummonAi.AIStateIdle_Summon_MoJ")
		self:register("skill", "SummonAi.AIStateSkill_Summon_MoJ")
		self:register("die", "SummonAi.AIStateDie_Summon_MoJ")
		self:register("die_into","AIStateIntoDie_Player")
		self:register("reSpawn", "SummonAi.AIStateReSpawn_Summon_MoJ")
		self:register("relive","AIStateRelive_Player")
	elseif self.player.summonAiType == "JiuL" then
		self:register("spawn", "SummonAi.AIStateSpawn_Summon")
		self:register("idle", "SummonAi.AIStateIdle_Summon")
		self:register("skill", "SummonAi.AIStateSkill_Summon_JiuL")
		self:register("move", "SummonAi.AIStateMove_Summon")
		self:register("die", "AIStateDie_Player")
		self:register("die_into","AIStateIntoDie_Player")
		self:register("relive","AIStateRelive_Player")
	end
end

--启动AI系统
function M:start()
	M.super.start(self)
end


--停止AI系统
function M:stop()
	M.super.stop(self)
end

return M