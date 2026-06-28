local M = class("LuckyRabbitHutRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.rank_list = {}
	self.m_version = self.m_params.version
	
	self:getData("rabbit_rank_info",{version = self.m_version,start = 1,stop = 10 })
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	local netData = self.m_data  --获取服务器数据
	self.self_rank = self.m_data.rank
	self.self_score = self.m_data.score
	self:insertRankData(self.m_data.ranks)
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.rank_list, new_rank_data[i])
	end
end

function M:getRankList()
	return self.rank_list or {}
end

function M:getLoadIndex()
	local max_rank_count = self.m_data.count
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