---@class AIEnginePlayer : AIEngine @玩家的AI状态机基础类
local M = class("AIEnginePlayer",Battle.AIEngine)

--初始化AI状态机
function  M:init( player )
	M.super.init( self, player )
	--1 挂机场景  2 战斗场景 3 Boss场景
	if self.player.plyMgr.scene.sceneId == SceneManager.SceneID.HangUpScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_HangUp")
		--移动
		self:register("move", "AIStateMove_Player_HangUp")
		--攻击
		self:register("attack", "AIStateAttack_Player_HangUp")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player")
		self:register("skill","AIStateSkill_Player")
	elseif self.player.plyMgr.scene.sceneId == SceneManager.SceneID.VoyageScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_HangUp")
		--移动
		self:register("move", "AIStateMove_Player_HangUp")
		--攻击
		self:register("attack", "AIStateAttack_Player_HangUp")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player_Voyage")
		self:register("skill","AIStateSkill_Player")
	elseif self.player.plyMgr.scene.sceneId == SceneManager.SceneID.FightScene or 
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.TianjiLouFightScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.MiGongFightScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.WuXingZhenFightScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.LegendScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.LegendScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.GhostsShowSkillScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_Fight")
		--移动
		self:register("move", "AIStateMove_Player_Fight")
		--攻击
		self:register("attack", "AIStateAttack_Player_Fight")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player")
		self:register("skill","AIStateSkill_Player")
		
	elseif self.player.plyMgr.scene.sceneId == SceneManager.SceneID.BossScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.ActiveBossScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.HeroTrainScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.UnionBossScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_Fight")

		self:register("in", "AIStateShow_Player_Boss")

		--移动
		self:register("move", "AIStateMove_Player_Boss")
		--攻击
		self:register("attack", "AIStateAttack_Player_Fight")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player")
		self:register("skill","AIStateSkill_Player")
	elseif self.player.plyMgr.scene.sceneId == SceneManager.SceneID.TianJiLouScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_TianJi")
		--移动
		self:register("move", "AIStateMove_Player_TianJi")
		--攻击
		self:register("attack", "AIStateAttack_Player_Fight")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player")
		self:register("skill","AIStateSkill_Player")
	elseif self.player.plyMgr.scene.sceneId == SceneManager.SceneID.MiGongScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.JuBaoShanScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.QiMenDunJiaScene or
			self.player.plyMgr.scene.sceneId == SceneManager.SceneID.GuJianQiTanScene then
		--巡逻状态
		self:register("patrol", "AIStatePatrol_Player_MiGong")
		--移动
		self:register("move", "AIStateMove_Player_MiGong")
		--攻击
		self:register("attack", "AIStateAttack_Player_Fight")
		--defuff
		self:register("debuff", "AIStateDebuff_Player")
		self:register("idle", "AIStateIdle_Player")
		self:register("skill","AIStateSkill_Player")
	end
	self:register("injureMove","AIStateInjureMove_Player")
	self:register("getup","AIStateGetUp_Player")
	self:register("die","AIStateDie_Player")
	self:register("spawn","AIStateSpawn_Player")
	self:register("over","AIStateOver_Player")
	self:register("followPart","AIStateFollowPart_Player")
	self:register("storySpawn","AIStateStorySpawn_Player")
	self:register("storySpawnNew","AIStateStorySpawnNew_Player")
	self:register("legendSpawn","AIStateLegendSpawn_Player")
	if self.player.plyMgr.scene.sceneId == SceneManager.SceneID.LegendScene and player.camp == -1 then
		self:register("die_into","AIStateLegendLeave_Enemy")
		self:register("relive","AIStateLegendReEnter_Enemy")
	else
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