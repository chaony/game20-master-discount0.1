local M = class("FivelinesModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self:getData("five_element_index", nil, nil,nil,{forceBack = true})
	self:getData("mood_shadow_train_index", nil, nil,nil,{forceBack = true})
end

function M:onEnter()
	self.m_reward = {}
	self:updateData()
	self:getTowerReward()
end

function M:updateData()
	--当前的层数
	self.cur_floor = self.m_data.floor
	--四象符 个数
	self.remain_times = self.m_data.remain_times
	self.finish = self.m_data.finish;
	--活动时间
	self.day = self.m_data.cur_day;
	self.open_times = self.m_data.open_times
	--当前的元素
	self.cur_element = self.m_data.element
	--死亡数
	self.battle_logs = self.m_data.battle_logs
	--是否激活
	self.floor = self.m_data.status or 1
	--四象阵奖励
	self.four_tower_id = self.m_data.four_tower_id;
	--完成奖励
	self.finish_gift = self.m_data.finish_gift;
	
	self.four_tower_config = ConfigManager:getCfgByName("four_tower");
	self.four_tower_data = {}
	for i, v in pairs(self.four_tower_config) do
		table.insert(self.four_tower_data , i)
	end
	table.sort(self.four_tower_data, function(data1, data2)
		return data2 < data1;
	end)
	
	--奖励
	--self.m_data.reward = self:getRewards()
	--self.tower_cfg = self:getTowerCfg()
	self.tower_cfg = {}
	self.m_five_element_auto = UserDataManager.local_data:getUserDataByKey("five_element_auto", 0)
	--通过vip获取,额外购买次数
	self.m_ex_buy_time = ConfigManager:getVipValueByKey("four_tower_challenge_times",1)
	local renovate = ConfigManager:getCfgByName("renovate")
	self.m_buy_data = renovate[14];
	
	self.version = self.m_data.version;
	--SceneManager:setData("Fivelines", self.m_data) 
	
	local hero_data_oid_list = UserDataManager.hero_data:getHerosIdByFilterFunc(function(hero_data, hero_cfg)
		if hero_cfg.id == 607 then
			return true;
		end
	end)
	
	self.mood_shadow = ConfigManager:getCfgByName("mood_shadow")
	self.cur_verson_mood_shadow = self.mood_shadow[self.version]
	UserDataManager.hero_data:heroIdsSort(hero_data_oid_list)
	self.cur_hero_id = hero_data_oid_list[1]
	if self.cur_hero_id ~= nil then
		self.cur_hero = UserDataManager.hero_data:getHeroDataById(self.cur_hero_id);
	end
end


function M:updateTimeData( data )
	--四象符 个数
	self.remain_times = data.remain_times
	self.open_times = data.open_times
end


--获取免费次数
function M:getFreeTime()
	local free = self.remain_times or 1;
	if free <= 0 then
		free = 0;
	end
	return free;
end

--获取额外开启次数
--扫荡次数
function M:getBuyTime()
	local buy_time = self.m_ex_buy_time - self.open_times;
	if buy_time <= 0 then
		buy_time = 0;
	end
	return buy_time;
end

--获取消耗数据
--额外购买次数 buyTime
function M:getCostData( buyTime )
	if buyTime <= 0 then
		return self.m_buy_data.cost[1]
	else
		local num = self.m_buy_data.count_list[buyTime]
		if num == nil then
			buyTime = self.m_buy_data.count_list[#self.m_buy_data.count_list]
		end
		return self.m_buy_data.cost[buyTime]
	end
end


function M:getLevelFourTowerData()
	--当前的关卡
	local cur_stage = UserDataManager:getCurStage();
	local max_stage = 0;
	for i, v in ipairs(self.four_tower_data) do
		if max_stage < v then
			max_stage = v;
		end
		if cur_stage >= v then
			return self.four_tower_config[v];
		end
	end
	return self.four_tower_config[max_stage];
end


--获取五行阵奖励
function M:getRewards()
	if self.m_data.floor == 0 then
		--没有激活
		self.m_reward = self:getLevelFourTowerData();
	else
		--已经激活
		--直接取服务器数据
		if self.four_tower_id == 0 then
			self.m_reward = self:getLevelFourTowerData();
		else
			self.m_reward = ConfigManager:getCfgByName("four_tower")[self.four_tower_id];
			if self.m_reward == nil then
				Logger.logErrorAlways(self.four_tower_id, "four_tower not found id : ")
				return {}
			end
		end
	end
	
	--获取到服务器时间
	local timeData = TimeUtil.gmTime(UserDataManager:getServerTime())
	if timeData.wday == 0 then
		--取周的数
		timeData.wday = 7;
	end
	--通過周去获取奖励
	return self.m_reward.reward[timeData.wday] or {}
end


function M:getDefByFloor(index, floor)
	--local tab = ConfigManager:getCfgByName("stage_battle")
	local tower_tab = ConfigManager:getCfgByName("five_element_tower")
	local b_ids= tower_tab[floor+1]["battle_id_list"]
	local elem_list = tower_tab[floor+1]["element_list"]
	self.cur_element = elem_list[index] or 1
	self.m_battle_id = b_ids[index]
end

function M:getDataByFloor(index)
	local tower_tab = ConfigManager:getCfgByName("five_element_tower")
	local elem_tab = ConfigManager:getCfgByName("five_element_allelopathy")
	local b_ids= tower_tab[self.cur_floor+1]["battle_id_list"]
	local elem_list = tower_tab[self.cur_floor+1]["element_list"]
	local element = elem_list[index] or 1
	for k,v in pairs(elem_tab) do
		if element == v.enemy_type then
			return v
		end
	end
end

function M:getDefCount()
	local tower_tab = ConfigManager:getCfgByName("five_element_tower")
	local elem_list = tower_tab[self.cur_floor+1]["element_list"]or {}
	return #elem_list
end

function M:getTowerCfg()
	local cfg = ConfigManager:getCfgByName("five_element_tower")
	if table.nums(cfg) > self.cur_floor then
		return cfg[self.cur_floor + 1]
	end
	return cfg[self.cur_floor]
end

function M:getTowerReward()
	if self.tower_cfg then
		if self.m_data.next_receive_count == 0 then
			return self.tower_cfg.rewards1
		elseif self.m_data.next_receive_count == 1 then
			return self.tower_cfg.rewards3
		elseif self.m_data.next_receive_count == 3 or self.m_data.next_receive_count == 5 then
			return self.tower_cfg.rewards5
		else
			return self.tower_cfg.rewards1
		end
	else
		return {}	
	end
end

function M:getElemCfgByIndex(index)
	if self.tower_cfg then
		return self.tower_cfg.element_list[index]
	else
		return nil	
	end
end

function M:getElemCount()
	if self.tower_cfg then
		return #self.tower_cfg.element_list
	else
		return 0
	end
end

function M:checkIsCapture(index)
	for k,v in pairs(self.battle_logs) do
		if index == v then
			return true
		end
	end
	return false
end

return M
