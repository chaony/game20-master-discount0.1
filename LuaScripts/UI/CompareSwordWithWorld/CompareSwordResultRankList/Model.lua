local M = class("CompareSwordResultRankListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_race_type = 1 -- 1积分赛 2晋级赛
	self.m_type_type = 1 --1 天 2 地
	self.raceType = self.m_params.raceType or 2 -- 2 积分赛 3 晋级赛
	self.m_race_type = self.raceType == 2 and 1 or 2 -- 1积分赛 2晋级赛
	self.round_stage = self.m_params.phase_day or 1
	--self.m_real_type = self.m_race_type + self.m_type_type
	if self.raceType == 2 then
		self:getData("full_service_point_race_ranks",{typ =self.m_type_type,start = 1,stop = 10 })
	else
		self:getData("full_service_top_rank_info",{typ =self.m_type_type,start = 1,stop = 10 })
	end
	
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	local netData = self.m_data  --获取服务器数据
	self.type_count = {{[1]= 0,[2] = 0},{[1]=0,[2] = 0}}
	self.jifen_rank_list = {[1]={},[2]={}}
	self.jinji_rank_list = {[1]={},[2]={}}
	self.type_count[self.m_race_type][self.m_type_type] = self.m_data and self.m_data.count or 0
	self:insertRankData(self.m_data)
end

function M:insertRankData(response)
	self.self_rank = response.self_rank or 0
	self.self_score = response.self_score 
	self.self_best_stage = response.self_best_stage
	if self.m_race_type == 1 then
		self:insertJifenRankData(response.ranks)
	else
		self:insertJinjiRankData(response.ranks)
	end
end

function M:insertJifenRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.jifen_rank_list[self.m_type_type], new_rank_data[i])
	end
end

function M:insertJinjiRankData(new_rank_data)
	for i = 1, #new_rank_data do
		local data = new_rank_data[i]
		--data.rank = i
		if data.user.uid == UserDataManager.user_data:getUid() then
			--self.self_rank = i
		end
		table.insert(self.jinji_rank_list[self.m_type_type], data)
	end
end

function M:getRankList()
	if self.m_race_type == 1 then
		return self.jifen_rank_list[self.m_type_type] or {}
	else
		return self.jinji_rank_list[self.m_type_type] or {}
	end
end

function M:getLoadIndex()
	local max_rank_count = self.type_count[self.m_race_type][self.m_type_type]
	local cur_rank_nums = table.nums(self:getRankList())
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end


function M:destroy()

	M.super.destroy(self)
end

return M