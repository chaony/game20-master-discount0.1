local M = class("CompareSwordFightReportPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.active_data = UserDataManager:getActivesDataByOpenId(414)
	self.version = self.active_data.version or 1
	
	local cfg = ConfigManager:getCfgByName("full_service_phase")
	self.point_race_start_day = cfg[self.version][4].start_day or 13	--阶段4积分赛比赛 活动开启时间
	self.phase_round = cfg[self.version][4].phase_round or {10,10}  --第4阶段 获取配置
	self.stage_round = cfg[self.version][6].phase_round or {6}
	self.active_day = self.m_params.active_day 
	if self.m_params.open_type == 1 then	--积分赛比赛界面 全部战报
		self.typ = self.m_params.typ or 1 --1天赛 2 地赛
		self.sel_group = self.m_params.group or 1
		self.sel_round = self.m_params.round or 1
		self.sel_day = self.point_race_start_day	--

		local params = {}
		params.active_day = self.sel_day
		params.typ = self.typ or 1
		params.group_id = self.sel_group - 1 
		params.rounds = self.sel_round - 1
		params.start = 0
		params.stop = 10
		self:getData("full_service_point_race_battle_log" , params)
		--self:getData()
	elseif self.m_params.open_type == 2 then 		--积分赛获取个人战报
		self.uid = self.m_params.uid or UserDataManager.user_data:getUid()
		self.current_day = 1
		local params = {}
		params.uid = self.uid
		params.active_day = self.current_day + (self.point_race_start_day - 1)
		self:getData("full_service_point_race_user_battle_log", params)
	elseif self.m_params.open_type == 3 then --晋级赛总战报
		self.current_day = self.m_params.round_stage
		self.typ = self.m_params.typ or 1 --1天赛 2 地赛
		self.round_stage = self.m_params.round_stage
		local params = {}
		params.typ = self.typ
		params.round_stage = self.round_stage
		self:getData("full_service_top_battle_log", params)
	elseif self.m_params.open_type == 4 then --晋级赛个人战报 
		self.uid = self.m_params.uid or UserDataManager.user_data:getUid()
		self.typ = self.m_params.typ or 1 --1天赛 2 地赛
		self.round_stage = self.m_params.round_stage
		self.current_round = 1
		self.current_day = self.round_stage
		local params = {}
		params.uid = self.uid
		params.typ = self.typ
		params.round_stage = self.round_stage
		self:getData("full_service_top_personal_battle_log", params)
	end
	
end

function M:onEnter()
	local netData = self.m_data  --获取服务器数据
	
	self.max_count = self.m_data.count
	self.day_data = {}
	self.round_data = {}
	self.rank_data = {}
	self.open_type = self.m_params.open_type or 1	--1全部战报 2个人战报
	self:initData()
	self:updateData(self.m_data)
end

function M:initData()
	--init net data
    for i=1,self.phase_round[1] do 
		table.insert(self.day_data,i)
	end
	for i=1,self.stage_round[1] do
		table.insert(self.round_data,i)
	end
end

function M:updateData( response )
	if not self.rank_data[self.open_type] then
		self.rank_data[self.open_type] = {}
	end
	if response then
		if response.logs and self.open_type == 1 then
			for i = 1 ,#response.logs do
				table.insert(self.rank_data[self.open_type] , response.logs[i])
			end
		elseif self.open_type == 2 then
			self.rank_data[self.open_type] = response
		elseif self.open_type == 3 or self.open_type == 4 then
			self.rank_data[self.open_type] = response.battle_logs
		end

	end
	
end

function M:getRankNums()
	local rankNum = #self.rank_data[self.open_type]
	local totalNum = self.m_data.count 
	if not totalNum then totalNum = 30 end --todo: 临时限制代码
	return rankNum ,totalNum
end

function M:getListData()
	return self.rank_data[self.open_type]
end

function M:getLoadIndex()
	local max_rank_count = self.max_count
	local cur_rank_nums = self:getRankNums() --table.nums(self:getRankNums())
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums --+ 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums --+ 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

function M:destroy()

	M.super.destroy(self)
end

return M