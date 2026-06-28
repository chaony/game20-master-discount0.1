local M = class("ActiveBossCoolRankPopPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("common_world_boss_select_combat_rank", {open_id = 368,vsn = self.m_params.version or 3,start = 1, stop = 20})
end

function M:onEnter()
	--Logger.log(self.m_data,"enjoy_spring_rank_info ======")
	self.m_task_data = {}
	self.m_version = self.m_params.version
	self.m_force = self.m_params.force
	self.m_sel_tab_index = 1
	self.open_id = 368
	self.ranks_rewards = self:getRankRewards()
	--self:InitWarriorData()
	self:InitTaskData(self.m_params.data.daily_quests)
end

--初始奖励 任务界面
function M:InitTaskData(data)
	if not data then return end
	self.m_params.data.daily_quests = data
	--任务数据
	local TaskCfg = ConfigManager:getCfgByName("active_world_quest")
	if TaskCfg then
		--self.m_task_data = TaskCfg[self.m_data.open_id][self.m_data.m_version]
		TaskCfg = TaskCfg[self.open_id][self.m_version] or {}
		self.m_task_data ={}
		for k,v in ipairs(TaskCfg) do
			local data_ = {}
			data_.id = k
			data_.name1 = TaskCfg[k].name1 or ""
			data_.name2 = TaskCfg[k].name2 or ""
			data_.reward = TaskCfg[k].reward
			data_.status = data[tostring(k)].status
			data_.value = data[tostring(k)].value
			data_.target_type = TaskCfg[k].target_type
			data_.target_value = TaskCfg[k].target_value
			data_.real_value =  data[tostring(k)].target_value or 0
            data_.war_order = TaskCfg[k].war_order
			table.insert(self.m_task_data,data_)
		end
	end
end

--初始任务界面数据  占令 和 任务
function M:InitWarriorData(data)
	--战令
	--local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	--self.enjoy_spring_force = enjoy_spring_force[self.m_data.version]
	--self.enjoy_spring_force = enjoy_spring_force[2]
	--local enjoy_spring_task = ConfigManager:getCfgByName("enjoy_spring_task")
	--self.enjoy_spring_task = enjoy_spring_task[self.m_data.version]
	--self.enjoy_spring_task = enjoy_spring_task[2]
	self.war_order_data = data
	local war_order = ConfigManager:getCfgByName("war_order")
	self.war_order = war_order[self.open_id]
	local tongyong_warrior_reward = ConfigManager:getCfgByName("tongyong_warrior_reward")
	if tongyong_warrior_reward[self.open_id] then
		if self.war_order_data and self.war_order_data.war_order and self.war_order_data.war_order.cur_version then
			self.tongyong_warrior_reward = tongyong_warrior_reward[self.open_id][self.war_order_data.war_order.cur_version]
		end
	end
	self.tongyong_warrior_reward = tongyong_warrior_reward[self.open_id][self.m_version]
end

function M:GetNetDataWarrior()
	if self.war_order_data  then return end
	local callback = function(response)
		self:InitWarriorData(response)
	end
	local params = {}
	params.open_id = self.open_id
	params.vsn = self.m_version
	self:getNetData("war_order_common_war_order_index",params,callback)
end

function M:getWarriorCfg()
	return self.war_order, self.tongyong_warrior_reward
end

function M:getWrriorValue()
	local value = 0
	if self.war_order_data and self.war_order_data.war_order then
		value = self.war_order_data.war_order.ms or 0
	end
	return value
end

function M:getwrriorPayStatus()
	if self.war_order_data and self.war_order_data.war_order then
		return self.war_order_data.war_order.pay_status
	else
		return 0
	end
end

--判断是否能领取 不管锁定状态
function M:getWrriorRewardStatus(id)
	local status = 0
	if self.war_order_data and self.war_order_data.war_order then --已经领取的付费奖励和免费奖励
		if table.keyof(self.war_order_data.war_order.free_received, tonumber(id)) then
			status = 2
		elseif table.keyof(self.war_order_data.war_order.pay_received, tonumber(id)) then
			status = 2
		else --未领取的免费和付费奖励
			if self.tongyong_warrior_reward then
				local cfg = self.tongyong_warrior_reward[id]
				if cfg then
					--是付费奖励
					if cfg.fee_incentives and next(cfg.fee_incentives) ~= nil then
						local pay_status = self:getwrriorPayStatus()
						if pay_status > 0 and self.war_order_data.war_order.ms and self.war_order_data.war_order.ms >= cfg.condition then
							status = 1
						end
					else --不是付费奖励
						if self.war_order_data.war_order.ms and self.war_order_data.war_order.ms >= cfg.condition then
							status = 1
						end
					end
				end
			end
		end
	end
	return status
end



-------------------任务数据
--获取任务数据
function M:getQuestList()
	return self.m_task_data or {}
end

--刷新任务数据
function M:updateQuests(data)
	self.m_task_data = data.daily_quest
end

------------------任务数据
--------占令----------------------------------------------------
--------排行----------------------------------------------------
function M:getRanks()
	return self.m_data and self.m_data.ranks or {}
end

function M:getRankNums()
	return #self.m_data.ranks, self.m_data.count
end

function M:updateRank(data)
	if data then
		if data.ranks then
			for i=1, #data.ranks do
				table.insert(self.m_data.ranks, data.ranks[i])
			end
		end
		self.m_data.rank = data.rank or self.m_data.rank
		self.m_data.score = data.score or self.m_data.score
		self.m_data.count = data.count or self.m_data.count
	end
end

function M:myRanks()
	return self.m_data.self_rank or {}
end

function M:getRankRewards()
	local reward_tab = ConfigManager:getCfgByName("active_world_rank")
	local version_reward_tab = reward_tab[self.open_id or 368][self.m_version or 3] or {}
	local new_tab = {}
	for k,v in pairs(version_reward_tab) do
		v.id = k
		table.insert(new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
	end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getRankScope(index)
	if index > 1 then
		local last_rank = self.ranks_rewards[index-1]
		if last_rank then
			return last_rank.id + 1
		end
	end
	return 0
end

function M:getActStatus()
	local active = UserDataManager:getActivesDataByOpenId(self.open_id)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

--红点
function M:isPointHaveRed()
	local data = self.m_params.data.daily_quests
	local TaskCfg = ConfigManager:getCfgByName("active_world_quest")
	if not TaskCfg or not data then return false end
	for k,v in ipairs(TaskCfg[self.open_id][self.m_version]) do 
		if data[tostring(k)].status == 1 then 
			return true
		end
	end
	local red_flag = RedPointUtil:hasRedPointById(371,nil)
	return red_flag
end

return M
