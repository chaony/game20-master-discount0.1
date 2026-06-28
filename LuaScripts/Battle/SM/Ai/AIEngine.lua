--AI系统其实就是一个数据计算系统
---@class AIEngine @AI系统
---@field player PlayerModel
---@field states table<string, AIState>
---@field skillConfig SkillDataConfig
local M = class("AIEngine")

--AI系统的所有者，基本上是Player
M.player = nil

--是否开始启动AI系统
M.enableAI = false

--所有状态
M.states = nil

--当前的状态
M.curState = nil
M.curConfig = nil
--初始化AI状态机
function  M:init( player )
	--绑定owner
	self.player = player
	--AI逻辑先不运行
	self.enableAI = false
	--状态管理A
	self.states = {}
end

--注册状态
function M:register( key, stateName )
	local stateCla = require("Battle.SM.Ai."..stateName)
	local stateIns = stateCla.new()
	stateIns:init( self.player, key, stateName )
	self.states[key] = stateIns
end

--Ai状态机切换状态
function M:changeState( key, data )
	
	if self.player.isInSkillState and key == "injureMove" then
		return
	end
	
	if self.states[key] == nil then
		Logger.log(key, self.player.plyType.." 状态不存在")
	else
		if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning and 
				self.player.data:get_curHp() <= GlobalTools.base0 and key ~= "die" then
			local buffs = self.player.bufMgr:findBufByType("NoDeath")
			if table.nums(buffs) <= 0 then
				return
			end
		end
		data = data or {}
		local changeKey = nil
		--当前状态结束事件
		if self.player:get_curSkillConfig() ~= nil then
			changeKey = self.player.curSkillConfig:skillEnd(data)
			EventDispatcher:dipatchEvent("SkillEnd",{ player = self.player, skillConfig = self.player.curSkillConfig, aiState = self.curState, param = data})
		end
		key = changeKey or key
		
		EventDispatcher:dipatchEvent("ChangeAiState",{ player = self.player, curState = self.curState, targetState = self.states[key]})
		self:toState(key, data)
	end
end

--状态机真正切换
function M:toState(key, data)
	if self.player:isDead() then
		if self.player.plyState == -2 and key == "over" then
			return
		end
		if key ~= "die" then
			key = "die"
		end
	end
	local targetState = self.states[key]
	if self.curState ~= nil then
		self.curState:exit()
	end
	self.curState = targetState
	self:changeStateFinish(key, data)
	self.curState:enter(data)
	EventDispatcher:dipatchEvent("AfterSkillEnter",{player = self.player})
end

--Ai状态机切换状态完成
function M:changeStateFinish(key, data)
	--if self.player:get_master() == nil then
		if key == "skill" or key == "attack" then
			if self.skillConfig ~= nil then
				local frame = GlobalTools:ToFloat( SceneManager:getCurSceneModel().loopTime );
				--Logger.logError( " F : "..frame.." 设定技能 ~~~~~~~~~~~~~~~~~~ 非空 ")
				self.player:set_curSkillConfig(self.skillConfig)
				self.skillConfig:skillStart(data)
				EventDispatcher:dipatchEvent("SkillEnter",{ player = self.player, skillConfig = self.skillConfig, aiState = self.curState, param = data})
			else
				--Logger.logError( " F : "..frame.." 设定技能 ~~~~~~~~~~~~~~~~~~ 空 ")
				self.player:set_curSkillConfig(nil)
			end
			self.skillConfig = nil
		else
			self.player:set_curSkillConfig(nil)
		end
	--end
end

--启动AI系统
function M:start()
	if self.enableAI == false then
		if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
			self:changeState("patrol")
		else
			if self.player.camp == 1 then
				if self.player.buzhengMove then
					self:changeState("spawn")
				else
					self:changeState("idle")
				end
			else
				self:changeState("idle")
			end
		end
		self.enableAI = true
	end
end

--AI系统更新
function  M:update(dt)
	if self.enableAI then
		if self.curState ~= nil then
			self.curState:update(dt)
		end
	end
end


function M:update_unsdt(unsdt )
	-- if self.enableAI then
		-- if self.curState ~= nil then
		-- 	self.curState:update_unsdt(unsdt)
		-- end
	-- end
end


function M:setPosition()
	for k,v in pairs(self.states) do
		v:setPosition()
	end
end

---@return AIState | AIStateRelive_Player | AIStateIntoDie_Player | AIStateDie_Player | AIStateAttack_Player
function M:getStateByName(key)
	return self.states and self.states[key]
end


function M:stop()
	self.enableAI = false
end

function M:destroy()
	self:stop()
	if self.curState ~= nil then
		self.curState:exit()
		self.curState = nil;
	end
end

return M