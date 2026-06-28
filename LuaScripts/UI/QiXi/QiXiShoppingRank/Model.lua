---@class QiXiShoppingRankModel:OODataBase
local M = class("QiXiShoppingRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	local params = {}
	params.is_cross = 1 --0 本服，1 跨服，
	params.ver = self.m_params.version or 1
	params.sort = 8
	params.start = 1
	params.stop = 20
	self:getData("valentine_festival_box_rank", params)
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.m_rank_data = {}
	self:initRankData()
end

function M:initRankData()
	self.m_rank_data = {}
	local rank_tab = ConfigManager:getCfgByName("treasure_rank") or {}
	local rank_version_tab = rank_tab[self.m_version] or {}
	local rank_version_tab_array = {}
	for k, v in pairs(rank_version_tab) do
		table.insert(rank_version_tab_array, v)
	end
	table.sort(rank_version_tab_array, function(a, b) return a.rank[1] < b.rank[1]  end)
	
	for k, v in pairs(self.m_data.ranks) do
		local pay_back = 0
		for kk, vv in pairs(rank_version_tab_array) do
			local rank_up = 1
			for kkk, vvv in pairs(vv.rank) do
				rank_up = vvv
			end
			if v.rank <= rank_up then
				pay_back = vv["return"]
				break
			end
		end
		table.insert(self.m_rank_data, {cfg = v, pay_back = pay_back})
	end
end

function M:getMyInsideRankData()
	local data = {}
	data.rank = self.m_data.rank or 0
	data.score = self.m_data.score or 0
	data.time = self.m_data.time or 0
	data.user = UserDataManager.user_data.user_status
	
	local pay_back = 0
	if data.rank > 0 then
		local rank_tab = ConfigManager:getCfgByName("treasure_rank") or {}
		local rank_version_tab = rank_tab[self.m_version] or {}
		local rank_version_tab_array = {}
		for k, v in pairs(rank_version_tab) do
			table.insert(rank_version_tab_array, v)
		end
		table.sort(rank_version_tab_array, function(a, b) return a.rank[1] < b.rank[1]  end)
		for kk, vv in pairs(rank_version_tab_array) do
			local rank_up = 1
			for kkk, vvv in pairs(vv.rank) do
				rank_up = vvv
			end
			if data.rank <= rank_up then
				pay_back = vv["return"]
				break
			end
		end
	end
	
	return {cfg = data, pay_back = pay_back}
end

function M:getInsideRankData()
	return self.m_rank_data
end

return M
