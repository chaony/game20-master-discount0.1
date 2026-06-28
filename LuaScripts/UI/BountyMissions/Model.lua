local M = class("BountyMissionsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData("bounty_info")
end

function M:onEnter()
	self.cur_type = 1 --当前页签
	self:initData()
	self:chechMasterStatue()
end

function M:initData(data)
	if data then 
		self.m_data = data
	end
	self.self_hero = {} --己方已上阵英雄
	self.resh_tim = self.m_data.next_time
	self.now_tim = UserDataManager:getServerTime()
	self.dataTime =  self.resh_tim - self.now_tim --刷新的倒计时
	self.bounty_lv = self.m_data.level
	self.m_master_info = self.m_data.master_info or {}
	self:initSingleData()
	self:initMasterApprenticeData()
	self:init_Rank()
end

function M:initSingleData()
	local single = self.m_data.single_quest or {}
	local TEST_TAB = {}
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	for k,v in pairs(single) do
		local task = {}
		task.id = tonumber(k)
		task.data = v
		task.cfg = quest_main[task.id]
		if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
			local start_ts = task.data.start_ts
			local task_tim = self.now_tim - start_ts--任务进行的时间
			task.count_down = task.cfg.duration_time * 60 - task_tim
		end
		if v.self_hero then
			for k,vv in pairs(v.self_hero) do
				table.insert(self.self_hero, vv)
			end
			
		end
		table.insert(TEST_TAB, task)
	end
	self:listSort(TEST_TAB)
	self.single_data = TEST_TAB
end

function M:initMasterApprenticeData()
	local team = self.m_data.master_quests or {}
	local TEST_TAB = {}
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	for k,v in pairs(team) do
		local task = {}
		if self:chechMasterStatue() == true then
			task.id = v.quest_id
		else
			task.id = tonumber(k)
		end	
		task.data = v
		task.cfg = quest_main[task.id]
		if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
			local start_ts = task.data.start_ts
			local task_tim = self.now_tim - start_ts--任务进行的时间
			task.count_down = task.cfg.duration_time * 60 - task_tim
		end
		table.insert( TEST_TAB, task)
	end
	self.team_data = TEST_TAB
	
end

--任务完成品质计数
function M:init_Rank()
	self.quests_counter = self.m_data.quests_counter --任务计数器  {任务id: 次数}
	self.single_rank = self.m_data.single_rank -- 个人任务品质计数器   {品质: 次数}
	self.team_rank = self.m_data.team_rank -- # 团队任务品质计数器   {品质: 次数}
end

--获取悬赏的数量
function M:getListCount()
	if self.cur_type == 1 then --个人悬赏
		return #self.single_data
	elseif self.cur_type == 2 then --团队悬赏
		return #self.team_data
	end
end

function M:getTaskList()
	if self.cur_type == 1 then
		return self.single_data
	elseif self.cur_type == 2 then
		return self.team_data
	end
end

--悬赏任务排序
function M:listSort(list)
    list = list or {}
	local function sortFunc(id_one, id_two)
		local id_1 = id_one.id
		local id_2 = id_two.id
		local rank_1= id_one.cfg.rank
		local rank_2= id_two.cfg.rank
		if rank_1 == rank_2 then
			return id_1 > id_2
		else
			return rank_1 > rank_2
		end
	
    end
    table.sort(list, sortFunc)
end

function M:checkDeadTime(tim)
	if self.cur_type  == 1 then
		local dead_tim = tim - self.now_tim
		local dead_day = math.ceil(dead_tim / 86400) 
		if dead_day <= 0 then
			return ""
		end
		local str = Language:getTextByKey("mail_str_0009", dead_day) 
		return  str
	else
		return ""
	end
	
end


function M:getBountyBuId(id)
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	return quest_main[id]
end

function M:chechMasterStatue()
	local open_flag, tips = BtnOpenUtil:isBtnOpen(52)
	return open_flag
end


--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "bounty_refresh" then
		if data == {} then
			return
		end
		self:initData(data)
	elseif tag == "bounty_receive" then
		
	elseif tag == "bounty_info" then
		self:initData(data)
	end
end


return M
