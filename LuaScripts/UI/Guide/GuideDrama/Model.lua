---@class GuideDramaModel:OODataBase
local M = class("GuideDramaModel", LikeOO.OODataBase)

function M:onCreate()
	self:getData()
	
end

function M:onEnter()
	local ids = self.m_params.dialogs
	local is_guide = self.m_params.guide or false
	self.m_is_delay_close = self.m_params.is_delay_close or false
	self.is_world_memory = self.m_params.worldMemory or false
	self.is_guide = is_guide ~= false
	self.dialogue_type = self.m_params.dialogue_type or 0
	self.m_bgm = ""
	if not ids then
		local dialog_id = self.m_params.dialog_id or 101
		self.m_dialog_id = dialog_id
		if is_guide then
			self.m_dialogue_team_name = "dialogue_guide_team"
		else
			if self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.LIMIT_TIME_EVENT then -- 地图限时事件对话
				self.m_dialogue_team_name = "deadline_event_team"
			elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then -- 地图奇遇事件对话
				self.m_dialogue_team_name = "dialogue_encounter_team"
			elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.NORMAL_EVENT then -- 地图普通事件对话
				self.m_dialogue_team_name = "dialogue_event_team"
			elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then -- 地图普通事件对话
				self.m_dialogue_team_name = "regional_event"
				if self.is_world_memory then
					self.m_dialogue_team_name = "new_regional_event"
				end
			elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY then -- 传记
				self.m_dialogue_team_name = "dialogue_biography_team"
			else
				self.m_dialogue_team_name = "dialogue_story_team"
			end
		end
		local dialogue_event_team = ConfigManager:getCfgByName(self.m_dialogue_team_name)
		local dialogue_event_team_item = dialogue_event_team[dialog_id] or {}
		if self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then -- 地图限时事件对话
			ids = dialogue_event_team_item
		else
			ids = dialogue_event_team_item.dialogue_id or {}
		end
		self.m_bgm = dialogue_event_team_item.bgm or ""
	end
	local dialogue_event = {}
	if is_guide then
		dialogue_event = ConfigManager:getCfgByName("dialogue_guide")
		self.is_dialogue_story = true
	else
		if self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.LIMIT_TIME_EVENT then -- 地图限时事件对话
			dialogue_event = ConfigManager:getCfgByName("deadline_event")
		elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then -- 地图奇遇事件对话
			dialogue_event = ConfigManager:getCfgByName("dialogue_encounter")
		elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.NORMAL_EVENT then -- 地图普通事件对话
			dialogue_event = ConfigManager:getCfgByName("dialogue_event")
		elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then -- 地图普通事件对话
			--dialogue_event = ConfigManager:getCfgByName("regional_event")
		elseif self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY then -- 传记
			dialogue_event = ConfigManager:getCfgByName("dialogue_biography")
			self.is_biography_story = true
		else
			dialogue_event = ConfigManager:getCfgByName("dialogue_story")
			self.is_dialogue_story = true
		end
	end
	local dialogs = {}
	if self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then -- 地图限时事件对话
		local list = Battle.List.new()
		for k,v in pairs(ids) do
			if v ~= nil then
				list:add(k)
			end
		end
		list:sort(function(a, b) 
			return a > b
		end)
		for i = 1, list.Count do
			local id = list:get(i - 1)
			table.insert(dialogs, {dialogue_cfg = ids[id], id = id})
		end
	else
		for i, id in ipairs(ids) do
			local cfg = dialogue_event[id]
			if cfg then
				table.insert(dialogs, {dialogue_cfg = cfg})
			end
		end
	end
	self.m_dialogs = dialogs
	self.m_dialog_index = 1
	self.m_talking = false
	local can_choise = self.m_params.can_choise or {}
	local no_choise_tips = self.m_params.no_choise_tips or {}
	self.waitForChoise = self.m_params.waitForChoise or false
	self.m_select_drama_data = {}
	--if self.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then -- 地图限时事件对话
	--	local option = self.m_params.choise_id or {}
	--	if #option > 1 then
	--		local article_option = ConfigManager:getCfgByName("regional_article_option")
	--		for k,v in pairs(option) do
	--			local opt_id = tonumber(v)
	--			table.insert(self.m_select_drama_data, {des = article_option[opt_id].option_text, id = opt_id, can_choise = can_choise[i] == nil or can_choise[i] == true, no_choise_tips = no_choise_tips[i] or Language:getTextByKey("tid#point_out_1")})
	--		end
	--	end
	--else
		local choise = self.m_params.choise or {}
		local choise_id = self.m_params.choise_id or {}
		for i, v in ipairs(choise) do
			if v ~= nil and v ~= "" then
				local flag, tips, move_tips = self:checkWorldMemoryChoiseAttr(choise_id[i])
				local text = v
				if not flag then
					text = v..tips
				end
				table.insert(self.m_select_drama_data, {des = text, id = choise_id[i], can_choise = can_choise[i] == nil or can_choise[i] == true, 
														no_choise_tips = no_choise_tips[i] or 0, choose_flag = flag, move_tips = move_tips})
			end
		end
	--end
	
	--自动状态，0为手动，1为3秒切换，2为1.5秒切换
	self.m_auto_state = UserDataManager.local_data:getUserDataByKey("GuideDrama_auto_state", 0)
end
-- 检查属性是否符合条件
function M:checkWorldMemoryChoiseAttr(id)
	local flag = true
	local tips = ""
	local move_tips = ""
	local new_regional_article_option_cfg = ConfigManager:getCfgByName("new_regional_article_option")
	local option_cfg = new_regional_article_option_cfg[id]
	local attr_list = UserDataManager:getNewMapAttrsData()
	if self.is_world_memory and option_cfg then
		if option_cfg.attr and _G.next(option_cfg.attr) then
			tips = tips .. Language:getTextByKey("world_memory_str_007")
			local needAttr = option_cfg.attr
				for i, v in pairs(needAttr) do
					local group, attrId, cfg = self:getAttrGroupById(v)
					local my_attr_id = attr_list[tostring(group)].id
					if my_attr_id < v then
					flag = false
					tips = tips .. Language:getTextByKey("world_memory_str_006",cfg.name_lv)
					move_tips = move_tips .. Language:getTextByKey("world_memory_str_004",cfg.name, cfg.name_lv)
				end
			end
			tips = tips .. ")"
		elseif option_cfg.time then
			local timeId = UserDataManager:getNewMapHourData()
			local remaining_time = 24 - tonumber(timeId)
			if remaining_time < option_cfg.time then
				flag = false
				move_tips = Language:getTextByKey("world_memory_str_012")
			end
		end
	end
	return flag, tips, move_tips
end

function M:getAttrGroupById(id)
	if not id then return end
	local new_regional_attr_cfg = ConfigManager:getCfgByName("new_regional_attr")
	for i, v in pairs(new_regional_attr_cfg) do
		for m, n in pairs(v) do
			if m == id then
				return i, m, n -- i == group m == id n ==cfg
			end
		end
	end
	return
end

function M:setChoise(data)
	--local choise = data.choise or {}
	--local choise_id = data.choise_id or {}
	--local no_choise_tips = data.no_choise_tips or {}
	----self.m_select_drama_data = {}
	--for k1,v1 in ipairs(self.m_select_drama_data) do
	--	v1.can_choise = false
	--end
	--for k1,v1 in ipairs(choise_id) do
	--	local has = false
	--	for k2, v2 in ipairs(self.m_select_drama_data) do
	--		if v1 == v2.id then
	--			v2.can_choise = true
	--			has = true
	--			break
	--		end
	--	end
	--	if has == false then
	--		table.insert(self.m_select_drama_data, {des = choise[k1], id = v1, can_choise = true, no_choise_tips = no_choise_tips[k1]})
	--	end
	--end

	local can_choise = data.can_choise or {}
	local no_choise_tips = data.no_choise_tips or {}
	self.m_select_drama_data = {}
	local choise = data.choise or {}
	local choise_id = data.choise_id or {}
	for i, v in ipairs(choise) do
		if v ~= nil and v ~= "" then
			local flag, tips, move_tips = self:checkWorldMemoryChoiseAttr(choise_id[i])
			local text = v
			if not flag then
				text = v..tips
			end
			table.insert(self.m_select_drama_data, {des = text, id = choise_id[i], can_choise = can_choise[i] == nil or can_choise[i] == true,
													no_choise_tips = no_choise_tips[i] or 0, choose_flag = flag, move_tips = move_tips})
		end
	end
end

function M:getDialogs()
	return self.m_dialogs
end

function M:getLastDialog()
	return self.m_dialogs[self.m_dialog_index - 1]
end

function M:getCurDialog()
	return self.m_dialogs[self.m_dialog_index]
end

function M:nextDialog()
	self.m_dialog_index = self.m_dialog_index + 1
	return self:getCurDialog() ~= nil
end

function M:setTalking(flag)
    self.m_talking = flag
end

function M:getTalking()
    return self.m_talking
end

function M:getSelectDramaData()
	return self.m_select_drama_data or {}
end

function M:getNpcCfg()
	local npc_cfg = nil
	if self.is_dialogue_story then
		npc_cfg = ConfigManager:getCfgByName("dialogue_npc")
	elseif self.is_biography_story then
		npc_cfg = ConfigManager:getCfgByName("dialogue_biography_npc")
	else
		npc_cfg = ConfigManager:getCfgByName("regional_npc")
		if self.is_world_memory then
			npc_cfg = ConfigManager:getCfgByName("new_regional_npc")
		end
	end
	return npc_cfg
end

function M:sendPointLog(status)
	StatisticsUtil:sendDialoguePointLog(self.m_dialogue_team_name, self.m_dialog_id, status)
end

function M:setAutoState()
	self.m_auto_state = self.m_auto_state + 1
	if self.m_auto_state > 2 then
		self.m_auto_state = 0
	end
	UserDataManager.local_data:setUserDataByKey("GuideDrama_auto_state", self.m_auto_state)
end

function M:getAutoTime()
	if self.m_auto_state == 0 then
		return 0
	elseif self.m_auto_state == 1 then
		return 1
	elseif self.m_auto_state == 2 then
		return 0.5
	end
end

return M