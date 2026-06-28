--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 15:30:35
]]

---@class PlayerAnimator_Model @动画
---@field player PlayerModel
---@field animList Battle_List
---@field states table<string, PlayerAnimStateBase_Model>
---@field stateData PlayerAnimator_Model_StateData
---@field isPause boolean 是否暂停
local M = class("PlayerAnimator_Model")

---@class PlayerAnimator_Model_StateData
---@field stateName string
---@field clearList table
---@field offset table

--设定动画状态机
---@param player PlayerModel
function  M:init( player )
	--模式
	self.mode = 0;
	--所有动画状态
	self.states = {}
	--玩家数据对象
	self.player = player
	--动画列表
	self.animList = Battle.List.new()
	--状态数据
	self.stateData = {}
	--状态结束数据
	self.stateExitData = {}
	--设定模式数据
	self.setModeData = {}
	--当前循环次数
	self.curExtraLoopCount = 0;
	--最大循环次数
	self.extraLoopCount = 0;
	
	self.loopCount = 0;
	--设定初始化动画速度
	self.animSpeed = GlobalTools.base1;
	--循环人物的动画名称
	for i, v in ipairs(self.player.evtMgr.actionNames) do
		self:setState(v);
	end
end

--设定动画速度
function M:set_animSpeed( animSpeed )
	self.animSpeed = animSpeed;
	self.setModeData.animSpeed = animSpeed;
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorSetAnimSpeed, self.setModeData);
end

---暂停自身的动作
function M:pause()
	self.isPause = true

	-- 同时暂停动画表现
	self.setModeData.animSpeed = 0
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorSetAnimSpeed, self.setModeData);
end

---恢复自身的动作
function M:resume()
	self.isPause = false

	-- 同时恢复动画表现
	self.setModeData.animSpeed = self.animSpeed
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorSetAnimSpeed, self.setModeData);
end

--获取动画速度
function M:get_animSpeed()
	return self.animSpeed
end

--返回循环Count
function M:get_loopCount()
	return self.loopCount
end

function M:reset()
	if self.player.playerType == "pet" then
		--循环人物的动画名称
		for i, v in ipairs(self.player.evtMgr.actionNames) do
			self:setState(v);
		end
	end
end

function M:reset2()
	--循环人物的动画名称
	for i, v in ipairs(self.player.evtMgr.actionNames) do
		self:setState(v);
	end
end

-- Normal = 0,
-- AnimatePhysics = 1,
-- UnscaledTime = 2
function M:setAnimUnscale( mode )
	self.mode = mode
	self.setModeData.mode = mode;
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorSetMode, self.setModeData);
end

--设定动画状态
function  M:setState( clipName )
	--找到状态类
	local stateCls = require("Battle.SM.Anim.PlayerAnimStateBase_Model")
	--实例化状态类
	local stateIns = stateCls.new()
	--初始化状态
	stateIns:init( self.player, clipName )
	--把状态存起来
	self.states[ clipName ] = stateIns
end

--是否有某个状态
function  M:hasState( name )
	if self.states[name] ~= nil then
		return true
	else
		return false
	end
end

--上一个动画播放完成之后，才会切换到下一个动画
function  M:changeStateUtilEnd( name, exitHandler )
	if self.curState ~= nil then
		self.curState.onCompleteHandler = 
		function()
			self:stateExit(name)
			if exitHandler ~= nil then
				exitHandler()
			end
		end
	end
end

--某个动作播放完成之后才执行切换
function M:stateExit( name )
	if self.states[name] ~= nil then
		self.curState = self.states[name]
		self.curState:enter()

		self.stateExitData.stateName = name;
		self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorStateExit, self.stateData);
	end
end


--强制切换状态,不管上一个装填目前到什么程度额，直接切换
function  M:changeState(name, clearList, offset )
	offset = offset or 0;
	if clearList == nil or clearList == true then
		self.animList:clear()
	end
	--如果当前的状态不是空，退出当前状态
	if self.curState ~= nil then
		self.curState:exit()
	end

	if self.states[name] ~= nil then
		self.curState = self.states[name]
		self.curState:enter()
		--发送事件切换状态了 
		self.stateData.stateName = name;
		self.stateData.clearList = clearList;
		self.stateData.offset = offset
		--Logger.logError("<[PlayerAnimator_Model]> 切换到动画 "..name )
		self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerAnimatorChangeState, self.stateData);
	else
		--Logger.logError(name, self.player.plyType.." 你想切换的状态没有找到")
	end
end

function M:startAnimList(list)
	self.animList = list
	if self.animList.Count > 0 then
		self:nextAnim(true)
	end 
end

function M:insertAnim(anim)
	self.animList:insert(0, anim)
	self:nextAnim(true)
end

--下一个动画
function M:nextAnim(isStart)
	if isStart ~= true then
		self.animList:removeAt(0)
	end
	
	local next = self.animList:get(0)
	if next ~= nil then
		self:changeState(next.name, false)
		if self.curState ~= nil then
			if self.curState.isLooping then
				self.curState.loopEndTime = next.time
			end
		end
		return true
	else
		return false
	end
end

--更新状态
function M:update( dt )

	if self.curState ~= nil and self.isPause ~= true then
		self.curState:update(dt)
	end
end

--更新
function M:update_unsdt( unsdt )
	if self.curState ~= nil then
		self.curState:update_unsdt( unsdt )
	end
end

--销毁
function M:destroy()
	self.states = {}
	self.player = nil
	self.curState = nil
	self.animList = Battle.List.new()
end

return M