local M = class("GuJianQiTanMazeModel", LikeOO.OODataBase)

--- 网络数据回调
function M:netData(data, tag)
	if tag ~= "ancient_sword_and_wonderland_enter_next" then
		table.merge(self.m_data.cells or {}, data.cells or {})
		data.cells = nil
		if data.passed ~= nil and self.m_data.passed ~= nil then
			for k,v in ipairs(data.passed) do
				table.insert(self.m_data.passed, v)
			end
			data.passed = nil;
		end
	else
		self.m_data.passed = {}
	end
	table.merge(self.m_data, data)
	self:initData(self.m_data)
end

function M:onCreate()
	M.super.onCreate(self)
	if self.m_params.data == nil then
		self:getData("ancient_sword_and_wonderland_akuma_index", nil, nil,nil,{forceBack = true})
	else
		self.m_data = self.m_params.data
		self:getData()
	end
	-- self:getData("maze_choose_floor",nil,nil,nil,{forceBack = true })
end

function M:onEnter() 
	self:initData(self.m_data)
	--奖励数据
	self.m_maze_reward_data = ConfigManager:getCfgByName("maze_reward")
	--self.m_maze_map_group = ConfigManager:getCfgByName("maze_map_group");
	self.m_hm_open_status = self.m_data.hm_open_status or 0 -- 0未开启   1已开启 战令
	self.m_current_round_end_time = 0
	self:initCurrentRoundEndTime()
end

--  status 格子状态 0：默认，1：完成，2：有宝箱未领取
function M:initData(data)
	self.m_data = data or self.m_data
	UserDataManager:setTempData("gu_jian_maze_mver", self.m_data.mver)
	self:initMap()
	self.m_version = self.m_data.version
	self.m_cur_round = self.m_data.cur_round
	local cell_id = self.m_data.cell_id or -1
	self.m_start_cell_index = -1 --开始下标
	self.m_end_cell_index = -1 --结束下标
	local floor_id = self.m_data.floor_id or -1
	local double_floors = self.m_data.double_floors or {};
	self.doubleReward = self:isDouble(double_floors, floor_id)
	local cells = self.m_data.cells or {}
	for k,v in pairs(cells) do
		if v.status == 0 and cell_id == tonumber(k) then
			v.status = 3 -- 当前格子已是前往状态
		end
		if self.m_start_cell_index == -1 then
			self.m_start_cell_index = tonumber(k)
		end
		if v.type == 9 then --出生点
			self.m_start_cell_index = tonumber(k)
		end
		--self.m_start_cell_index = math.min(self.m_start_cell_index, tonumber(k))
		if self.m_end_cell_index == -1 then
			self.m_end_cell_index = tonumber(k)
		end
		self.m_end_cell_index = math.max(self.m_end_cell_index, tonumber(k))
	end

	self.m_cur_floor = 1 --当前在哪一小层
	local cur_cell_index = -1
	for k,v in pairs(self.m_map) do
		for k1,v1 in pairs(v) do
			if v1 == cell_id then
				self.m_cur_floor = k
				cur_cell_index = k1
				break
			end
		end
	end

	if self.m_data.cells ~= nil then
		local cur_cell = self.m_data.cells[tostring(cell_id)]
		if cur_cell == nil then
			self.m_cur_cell_finish = 1
		else
			self.m_cur_cell_finish = cur_cell.status == 1
		end
	end

	-- for i = 1, self.m_cur_floor do
	-- 	local cur_floor_cells = self.m_map[i] or {}
	-- 	for k,v in pairs(cur_floor_cells) do
	-- 		if v ~= 0 then
	-- 			local cell_data = self.m_data.cells[tostring(v)]

	-- 			if cell_data == nil then 
	-- 				Logger.log("标记")
	-- 			end
	-- 			if v ~= cell_id and cell_data.status == 0 then
	-- 				cell_data.status = 4 --不能点击
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if self.m_cur_cell_finish then
	-- 	local cur_floor_cells = self.m_map[self.m_cur_floor + 1] or {}
	-- 	for k,v in pairs(cur_floor_cells) do
	-- 		if v ~= 0 and (k > (cur_cell_index + 1) or k < (cur_cell_index - 1)) then
	-- 			local cell_data = self.m_data.cells[tostring(v)]
	-- 			cell_data.status = 4 --不能点击
	-- 		end
	-- 	end
	-- end
end

--当前迷宫是否通关过
function M:isFirstComplete()
	local cur_group = self.m_data.group_id
	if self.m_data.finished_groups and next(self.m_data.finished_groups) then
		for i, v in pairs(self.m_data.finished_groups) do
			if tonumber(v) == tonumber(cur_group) then
				return true
			end
		end
	end
	return false
end

function M:isDouble(double_floors, floor_id)
	for k,v in pairs(double_floors) do
		if v == floor_id then
			return true;
		end
	end
	return false;
end

function M:initMap()
	self.m_map = {}
	local maze_cell = ConfigManager:getCfgByName("maze_cell")
	local floor_id = self.m_data.floor_id or -1
	local maze_cell_item = maze_cell[floor_id] or {}
	for k, v in pairs(maze_cell_item) do
		self.m_map[k] = v.cell_count
	end
end


--1.小怪 2.精英 3.boss 4.客栈 5.医馆 6.药王庙 7.商铺 8.空格 9.起点 10.怨灵马车 11.宝藏洞窟
function M:getMazeCellDataById(id, real)
	--99990000 1 - 15
	-- if not real then
	-- 	id = id * 100
	-- 	id = self.m_start_cell_index + id - 100
	-- end
	local cells = self.m_data.cells or {}
	local cell_data = cells[tostring(id)]
	if cell_data == nil then
		Logger.log(" id == "..id )
	end
	if cell_data ~= nil then
		cell_data.id = id
	end
	return cell_data
end

function M:getMazeCellIsOpen(id, real)

	-- if not real then
	-- 	id = id * 100
	-- 	id = self.m_start_cell_index + id - 100
	-- end
	-- local floor = -1
	-- for k,v in pairs(self.m_map) do
	-- 	for k1,v1 in pairs(v) do
	-- 		if v1 == id then
	-- 			floor = k
	-- 			break
	-- 		end
	-- 	end
	-- end
	-- if self.m_cur_cell_finish then
	-- 	return (self.m_cur_floor + 1) >= floor
	-- else
	-- 	return self.m_cur_floor >= floor
	-- end
	return false
end

function M:getFloorIsOver()
	local cell_data = self:getMazeCellDataById(24)
	return cell_data.status == 1
end

--function M:getNextFloorIds()
--	local floor_id = self.m_data.floor_id
--	local maze_map = ConfigManager:getCfgByName("maze_map")
--	local maze_map_item = maze_map[floor_id] or {}
--	local next_id = maze_map_item.next_id or {}
--	return next_id
--end

function M:getRefreshRemainingTime()
	local end_time = self.m_data.end_time or 0
	return end_time - UserDataManager:getServerTime()
end

function M:getTeamCombat()
	local combat_value = 0
	local team = UserDataManager.hero_data:getTeamByKey("ancient_sword_akuma") or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	for k, v in pairs(team) do
		local hero_data = assist_heros[v] or UserDataManager.hero_data:getHeroDataById(v)
		if hero_data then
			combat_value = combat_value + hero_data.combat
		end
	end
	return combat_value
end

function M:needAddBlood()
	local flag = false
	local dyns = self.m_data.dyns or {} -- 战斗开始我方英雄数据动态信息
	for k,v in pairs(dyns) do
		local hp_pct = v.hp_pct or 0
		if hp_pct > 0 and hp_pct < GlobalTools.base10000 then
			flag = true
		end
	end
	return flag
end

function M:getHeirloomNum()
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomNum(heirlooms)
end

-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio()
	local team = UserDataManager.hero_data:getTeamByKey("ancient_sword_akuma") or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

function M:getRoleCurCellId()
	local path = self.m_data.path or {}
	local cell_id = self.m_data.cell_id
	return cell_id
end

function M:getBoxData()
	local show_data = {}
	local explore_recvd = self.m_data.explore_recvd or {}
	local win_times = self.m_data.win_times or 0
	local explore_group = self.m_data.explore_group or 0
	local maze_reward_item = self.m_maze_reward_data[explore_group] or {}
	local maze_reward_detail = maze_reward_item.detail or {}
	--设定奖励数字
	for k,v in ipairs(maze_reward_detail) do
		local status = 0-- 未完成
		if win_times >= v.num then
			local index = table.indexof(explore_recvd, k)
			if index then
				status = -1-- 已领取
			else
				status = 2 -- 可领取	
			end
		end
		local rewards = v.reward or {}
		if self.m_hm_open_status then
			rewards = table.copy(rewards)
			local reward_vip = v.reward_vip or {}
			table.insertto(rewards, reward_vip)
		end
		table.insert(show_data, {id = k, cfg = v, status = status, rewards = rewards})
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.num < data2.cfg.num
	end)
	return show_data, win_times
end

function M:getNotExploredCellNum(cell_type)
	local num = 0
	local cells = self.m_data.cells or {}
	for k,v in pairs(cells) do
		if cell_type == 7 then
			local goods_num = v.goods_num or 0
			if v.type == cell_type and goods_num > 0 then
				num = num + 1
			end
		else
			if v.type == cell_type and v.status == 0 then
				num = num + 1
			end
		end
	end
	return num
end

--是否有已死亡的英雄
function M:checkisDie()
	local dyns = self.m_data.dyns or {} -- 战斗开始我方英雄数据动态信息
	local is_die = false
	for k,v in pairs(dyns) do
		local hp_pct = v.hp_pct or 0
		if hp_pct <= 0 then
			is_die = true
			break
		end
	end
	if is_die == true then
		local cost = ConfigManager:getCommonValueById(47)
		local cost_data = RewardUtil:getProcessRewardData(cost[1])
		if cost_data.user_num <= 0 then
			is_die = false
		end
	end
	return is_die
end

--献祭的英雄
function M:getDeathHeroOids()
	return self.m_data.death_hero_oids or {}
end

--当前的钥匙数量
function M:getKeyCount()
	return self.m_data.keys or 0
end

--当前祝福信息
function M:getBlessInfo()
	local buff_data = self:getBlessData() or {}
	local buff_item = buff_data[1]
	local buff_info = Language:getTextByKey("gu_jian_qi_tan_str_055")
	if buff_item then
		buff_info = Language:getTextByKey("gu_jian_qi_tan_str_054", buff_item.title or "", buff_item.time or 0)
	end
	return buff_info
end

--当前的buff数据
function M:getBlessData()
	local buff_server_data = self.m_data.buffs or {}
	local buff_tab = ConfigManager:getCfgByName("sword_akuma_buff")
	local buff_data = {}
	local buff_cfg
	for k, v in pairs(buff_server_data) do
		buff_cfg = buff_tab[tonumber(k)]
		if buff_cfg then
			table.insert(buff_data, {id = buff_cfg.buff_id, title = buff_cfg.title, detail = buff_cfg.detail, time = v})
		end
	end
	return buff_data
end

--当前的buff加成
function M:getBuffValue()
	return (self.m_data.evo_sum or 0) * 100
end

function M:initCurrentRoundEndTime()
	self.m_current_round_end_time = 0

	local unit_min = 60
	local unit_hour = unit_min * 60
	local unit_day = unit_hour * 24
	local unit_day_7 = unit_day * 7

	local activity_data = UserDataManager:getActivesDataByOpenId(280)
	if activity_data then
		local start_time_activity = activity_data.start_ts
		local server_time_cur = UserDataManager:getServerTime()
		local delta_time = server_time_cur - start_time_activity
		self.m_current_round_end_time = start_time_activity + (math.floor(delta_time / unit_day_7) + 1) * unit_day_7
	end
end

--获取本轮剩余时间
function M:getRemainTimeInRound()
	return self.m_current_round_end_time - UserDataManager:getServerTime()
end



return M
