local M = class("GuJianQiTanShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end
function M:onEnter()
	self.m_main_data = self.m_params.main_data or {}
	self.m_activityData = UserDataManager:getActivesDataByOpenId(280)
	self.m_start_ts = self.m_activityData.start_ts or 0
	self.m_uid = UserDataManager.user_data:getUid()
	self.m_stage_id_selected = 0
	self.m_stage_btns = {
		[101] = "stage_btn_101",
		[201] = "stage_btn_201",
		[202] = "stage_btn_202",
		[203] = "stage_btn_203",
		[204] = "stage_btn_204",
		[205] = "stage_btn_205",
		[301] = "stage_btn_301",
		[302] = "stage_btn_302",
		[303] = "stage_btn_303",
		[304] = "stage_btn_304",
	}

	self.m_stage_id_done = {}
	self:initStageDone()
	self.m_open_stage_cur = 0 --当前的开启阶段，即sword_main的open_stage
	self:initCurrentOpenCondition()

	self.m_stage_data = {}
	self:initStageData()
	
	self.m_stage_path_data = {}
	self:initStagePathData()
	
end

function M:getStageTab()
	if self.m_stage_tab == nil then
		self.m_stage_tab = {}
		local stage_tab = ConfigManager:getCfgByName("sword_main")
		for k ,v in pairs(stage_tab) do
			table.insert(self.m_stage_tab, {id = k, cfg = v})
		end
		table.sort(self.m_stage_tab, function(item1, item2) return item1.id < item2.id  end)
	end
	return self.m_stage_tab
end
-- {101, 201, 202, 203, 204, 205, 301, 302, 303, 304}--
function M:initStageDone()
	self.m_stage_id_done = self.m_main_data.finish_level_ids or {}
end

function M:initCurrentOpenCondition()
	table.sort(self.m_stage_id_done, function(id1, id2) return id1 < id2  end)
	
	local stage_tab = self:getStageTab()
	local done_flag
	for k, v in pairs(stage_tab) do
		self.m_open_stage_cur = v.cfg.open_stage
		done_flag = false
		for kk, vv in pairs(self.m_stage_id_done) do
			if v.id == vv then
				done_flag = true
				break
			end
		end
		if done_flag == false then
			break
		end
	end
end

function M:initStageData()
	self.m_stage_data = {}
	local stage_tab = self:getStageTab()
	--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
	local battle_item
	local enemy_item, enemy_data
	for k, v in pairs(stage_tab) do
		battle_item = ConfigManager:getCfgStageBattle(v.cfg.battle_id[1]) or {}-- stage_battle_tab[v.cfg.battle_id[1]] or {}
		enemy_data = {}
		for kk, vv in pairs(battle_item.monster or {}) do
			enemy_item = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, vv.id, 0})
			enemy_item.quality = vv.evo
			enemy_item.hero_data = vv
			enemy_item.dyns = {}
			table.insert(enemy_data, enemy_item)
		end
		self.m_stage_data[v.id] = {id = v.id, pre_id = v.cfg.pre_id, name = Language:getTextByKey(v.cfg.name), reward = v.cfg.reward, enemy = enemy_data, open_stage = v.cfg.open_stage,
								   visible_flag = v.cfg.open_stage <= self.m_open_stage_cur, open_flag = self:checkStageOpen(v.cfg.pre_id),
									open_event = v.cfg.event1, win_event = v.cfg.event2}
	end
end

function M:initStagePathData()
	self.m_stage_path_data = {}
	local path_effect_stage = UserDataManager.local_data:getLocalDataByKey("GuJianQiTanShow_stage_effect" .. self.m_uid .. self.m_start_ts, -1)
	--首次进入该功能，不初始化这路径，这样就可以动态展示路径
	if path_effect_stage ~= -1 then
		for k, v in pairs(self.m_stage_data) do
			if v.visible_flag == true then
				table.insert(self.m_stage_path_data, {id = k})
			end
		end
		table.sort(self.m_stage_path_data, function(a, b) return a.id < b.id end)
	end
end

function M:checkStageOpen(pre_id)
	if pre_id == nil or pre_id == 0 then
		return true
	end
	for k, v in pairs(self.m_stage_id_done) do
		if v == pre_id then
			return true
		end
	end
	return false
end

function M:updateNetData(data)
	table.merge(self.m_main_data, data)
	self:initStageDone()
	self:initCurrentOpenCondition()
	self:initStageData()
	self:initStagePathData()
end

function M:getStageData()
	return self.m_stage_data
end

function M:getStageDataWithPhase()
	local stage_data = {}
	local path_effect_stage = UserDataManager.local_data:getLocalDataByKey("GuJianQiTanShow_stage_effect" .. self.m_uid .. self.m_start_ts, -1)
	if path_effect_stage < self.m_open_stage_cur then
		for k, v in pairs(self.m_stage_data) do
			if self.m_open_stage_cur == v.open_stage then
				table.insert(stage_data, v)
			end
		end
		table.sort(stage_data, function(a, b) return a.id < b.id end)

		UserDataManager.local_data:setLocalDataByKey("GuJianQiTanShow_stage_effect" .. self.m_uid .. self.m_start_ts, self.m_open_stage_cur)
	end
	return stage_data
end

--当前所处的阶段
--阶段 	关卡
--1, 	101
--2,	201--208
--3, 	301
function M:getOpenStageCurrent()
	return self.m_open_stage_cur
end

function M:checkStageDone(stage_id)
	stage_id = stage_id or self.m_stage_id_selected
	for kk, vv in pairs(self.m_stage_id_done) do
		if stage_id == vv then
			return true
		end
	end
	return false
end

function M:checkAllStageDone()
	for kk, vv in pairs(self.m_stage_id_done) do
		if 301 == vv then
			return true
		end
	end
	return false
end

function M:setSelectedStage(stage_id)
	self.m_stage_id_selected = stage_id
end

function M:getSelectedStage()
	return self.m_stage_id_selected
end

function M:getSelectedStageData()
	return self.m_stage_data[self.m_stage_id_selected]
end

function M:getSelectedStageName()
	return self.m_stage_data[self.m_stage_id_selected].name
end

function M:getSelectedStageUnlockName()
	local stage_name = ""
	--if self.m_stage_id_selected == 301 then
	--	stage_name = Language:getTextByKey(self.m_stage_data[204].name) .. Language:getTextByKey("gu_jian_qi_tan_str_040")
	--	stage_name = stage_name .. Language:getTextByKey(self.m_stage_data[208].name)
	--elseif self.m_stage_id_selected == 201 or self.m_stage_id_selected == 205 then
	--	stage_name = Language:getTextByKey(self.m_stage_data[101].name)
	--else
		stage_name = Language:getTextByKey(self.m_stage_data[self.m_stage_id_selected - 1].name)
	--end
	return stage_name
end

function M:stageCheck()
	return self.m_stage_data[self.m_stage_id_selected].open_flag and self.m_stage_data[self.m_stage_id_selected].visible_flag
end

function M:getStageBtns()
	return self.m_stage_btns
end

function M:getAssistHeros()
	return self.m_main_data.assist_heros[tostring(self.m_stage_id_selected)]
end

function M:getCurrentStageData()
	return self.m_stage_data[self.m_stage_id_selected]
end

function M:getCurrentStageTargetText()
	local stage_target_tab = ConfigManager:getCfgByName("sword_main_group") or {}
	local target_item = stage_target_tab[self.m_open_stage_cur] or {}
	return target_item.stage_des or ""
end

function M:getStagePathData()
	return self.m_stage_path_data
end

function M:canStartBattle()
	if self:getSelectedStage() ~= 0 and self:stageCheck() == true then
		return true
	end
	return false
end


return M
