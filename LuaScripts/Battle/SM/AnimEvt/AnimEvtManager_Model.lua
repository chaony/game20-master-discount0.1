--人物动画关键帧事件管理器
--类似是挂在动画上的关键帧的管理
--用于实现各种人物的技能
---@class AnimEvtManager_Model @人物动画关键帧事件管理器
---@field player PlayerModel
---@field ms_data Battle_MS_Data
---@field ch_data Battle_CH_Data
---@field cx_data Battle_CX_Data
---@field actionNames string[]
---@field actions table<string, AnimEvtAction_Model>
---@field common_event table<string, AnimEvtAction_Model>
local M = class("AnimEvtManager_Model")

--美术配置数据
M.ms_data = nil
--策划配置数据
M.ch_data = nil
--程序配置数据
M.cx_data = nil
--动作数据
M.actions = nil
--我的事件所有者
M.player = nil

--根据动画名称， 加载帧表
---@param player_name string 角色当前皮肤名
---@param player_name string 角色原皮肤名
function  M:init( player, player_name, default_skin_name )
	self.actions = {}

	self.common_event = {}
	--self.common_event["ms"] = {}
	--self.common_event["ch"] = {}
	--self.common_event["cx"] = {}
	
	self.actionNames = {}
	self.player = player
	self.animNameData = Battle.BattleGlobalConfig.AnimEvtKeys;

	local ch_name = "Battle.SM.AnimData."..default_skin_name.."_ch_evt"
	if not Battle.ClassPathUtil:Exists(ch_name) then
		ch_name = "Battle.SM.AnimData."..string.gsub(default_skin_name,"%d+","").."_ch_evt"
	end
	if Battle.ClassPathUtil:Exists(ch_name) then
		--加载策划事件文件
		self.ch_data = require(ch_name)
		for i, v in ipairs(self.animNameData) do
			if self.ch_data[v] ~= nil then
				if v ~= "common"  then
					table.insert(self.actionNames, v)
				end
			--else
				--Logger.logError(" 动画文件中的 key = "..v.." 没有在配置文件中找到，请重新生成 AnimEvtKeys" )
			end
		end

		-- 开发环境下，检查动作是否没有加入列表
		if GameVersionConfig.Debug then
			local keyDict = {}
			for i, v in ipairs(self.animNameData) do
				keyDict[v] = true
			end
			for k, v in pairs(self.ch_data) do
				if not keyDict[k] then
					Logger.logError(string.format(ch_name.." 动画文件中的 key(%s)没有在配置文件中找到，请重新生成 AnimEvtKeys", tostring(k)))
				end
			end
		end
		
		--for k,v in pairs(self.ch_data) do
		--	if k ~= "common" then
		--		self.actionNames:add(k)
		--	end
		--end
	else
		Logger.logError("加载的文件 "..ch_name.." 不存在")
	end

	local cx_name = "Battle.SM.AnimData."..default_skin_name.."_cx_evt"
	if not Battle.ClassPathUtil:Exists(cx_name) then
		cx_name = "Battle.SM.AnimData."..string.gsub(default_skin_name,"%d+","").."_cx_evt"
	end
	if Battle.ClassPathUtil:Exists(cx_name) then
		--加载策划事件文件
		self.cx_data = require(cx_name)
	else
		Logger.logError("加载的文件 "..cx_name.." 不存在")
	end
	
	--if GameVersionConfig.IS_SERVER == false then
		--加载美术表
		--local ms_name = "BattleView.SM.AnimData."..player_name.."_ms_evt"
	local ms_name = "Battle.SM.AnimData."..player_name.."_ms_evt"
	if Battle.ClassPathUtil:Exists(ms_name) then
		--加载美术事件文件
		self.ms_data = require(ms_name)
	else
		Logger.logError("加载的文件 "..ms_name.." 不存在")
	end
	--end
	
   	self:parse()
	if GameVersionConfig.Debug then
		Battle.BattleGlobalConfig:checkAnimEvtKeys()
	end
end

--解析帧表
--根据解析的帧表，来初始化EvtFrame
function  M:parse()
	local action = require("Battle.SM.AnimEvt.AnimEvtAction_Model")
	--在加入策划的帧
	if self.ch_data ~= nil then
		for i,k in ipairs(self.actionNames) do
			local v = self.ch_data[k]
			if v then
				if self.actions[k] ~= nil then
					self.actions[k]:load(v,self.player)
				else
					local actionIns = action.new()
					actionIns:load(v,self.player)
					self.actions[k] = actionIns
				end
			end
		end

		local v = self.ch_data["common"]
		if v ~= nil then
			if self.common_event["ch"] ~= nil then
				self.common_event["ch"]:load(v,self.player)
			else
				local actionIns = action.new()
				actionIns:load(v,self.player)
				self.common_event["ch"] = actionIns
			end
		end
	end
	
	--在加入程序的帧
	if self.cx_data ~= nil then
		for i,k in ipairs(self.actionNames) do
			local v = self.cx_data[k]
			if v then
				if self.actions[k] ~= nil then
					self.actions[k]:load(v,self.player)
				else
					local actionIns = action.new()
					actionIns:load(v,self.player)
					self.actions[k] = actionIns
				end
			end
		end

		local v = self.cx_data["common"]
		if v ~= nil then
			if self.common_event["cx"] ~= nil then
				self.common_event["cx"]:load(v,self.player)
			else
				local actionIns = action.new()
				actionIns:load(v,self.player)
				self.common_event["cx"] = actionIns
			end
		end
	end

	--在加入美术的帧
	if self.ms_data ~= nil then
		for k, v in pairs(self.ms_data) do
			if k == "common" then
				if self.common_event["ms"] ~= nil then
					self.common_event["ms"]:load(v,self.player)
				else
					local actionIns = action.new()
					actionIns:load(v,self.player)
					self.common_event["ms"] = actionIns
				end
			else
				if self.actions[k] ~= nil then
					self.actions[k]:load(v,self.player)
				else
					local actionIns = action.new()
					actionIns:load(v,self.player)
					self.actions[k] = actionIns
				end
			end
		end
	end

	if self.common_event["ms"] ~= nil then
		if self.common_event["ch"] ~= nil then
			self.common_event["ch"].shootEffectFrames = self.common_event["ms"].shootEffectFrames
			self.common_event["ch"].hitEffectFrames = self.common_event["ms"].hitEffectFrames
		end
		if self.common_event["cx"] ~= nil then
			self.common_event["cx"].shootEffectFrames = self.common_event["ms"].shootEffectFrames
			self.common_event["cx"].hitEffectFrames = self.common_event["ms"].hitEffectFrames
		end
	end
end


--执行common事件的帧
function M:commonEventWork(eventName, index )
	local frame = self:getCommonEvent(eventName, index )
	if frame ~= nil then
		frame.isWork = true
		frame:work()
	else
		Logger.logError(" 没有找到 commonFrame "..eventName.." index "..index )
	end
end

--获取common事件的帧
function M:getCommonEvent(eventName, index )
	for k,v in pairs(self.common_event) do
		local frame = v:getFrameByIndex(eventName, index)
		if frame ~= nil then
			return frame
		end
	end
	return nil
end

--执行common事件的帧
function M:commonEventWorkByKey(eventName, key)
	local frame = self:getCommonEventByKey(eventName, key)
	if frame ~= nil then
		frame.isWork = true
		frame:work()
	else
		Logger.logError(" 没有找到 commonFrame "..eventName.." key "..key )
	end
end

--获取common事件的帧
---@return AnimEvtFrame_Model
function M:getCommonEventByKey(eventName, key)
	for k,v in pairs(self.common_event) do
		local frame = v:getFrameByKey(eventName, key)
		if frame ~= nil then
			return frame
		end
	end
	return nil
end

--执行action事件的帧
function M:triggerActionEventWork(action, eventName, index )
	local actionModel = self:getAction(action)
	local frame = actionModel and actionModel:getFrameByIndex(eventName, index)
	if frame ~= nil then
		frame.isWork = true
		frame:work()
	else
		Logger.logError(action.." 没有找到 action eventFrame "..eventName.." index "..index )
	end
end

--执行action事件的帧美术脚本通过key去找配置
function M:triggerActionEventWorkByKey(action, eventName, index )
	local actionModel = self:getAction(action)
	local frame = actionModel and actionModel:getFrameByKey(eventName, index)
	if frame ~= nil then
		frame.isWork = true
		frame:tryWork()
	else
		Logger.logError(action.." 没有找到 action eventFrame "..eventName.." index "..index )
	end
end

--执行action事件的帧美术脚本通过key去找配置
---@return AnimEvtFrame_Model
function M:getActionFrameByKey(action, eventName, key)
	local actionModel = self:getAction(action)
	return actionModel and actionModel:getFrameByKey(eventName, key)
end

--获取某个动作所有的帧
function M:getAction( key )
	return self.actions[key]
end

function M:destroy()
	self.actions = {}
	self.common_event = {}
	self.player = nil
end

return M