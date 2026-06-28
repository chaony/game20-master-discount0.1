local M = class("TXRankMainPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_cur_rank_nums = 7
	self:getData("world_all_rank", {is_cross = 0})
end

function M:onEnter()
	self.m_rank_data = {}
	self.m_is_cross = 0
	self:initData()
end

function M:initData(response)
	if response then
		self.m_data = response
	end
	if self.m_rank_data[tostring(self.m_is_cross)] then
	else
		self.m_rank_data[tostring(self.m_is_cross)] = self.m_data.rank_data
		self.m_isOpenCrossServer = self.m_data.cross_open
	end
end

function M:getCurRankData()
	return self.m_rank_data[tostring(self.m_is_cross)]
end

function M:getCurLeftRankData(is_left)
	local rank_data = {}
	--local offset = is_left and 0 or 3
	local temp = self:getCurRankData()
	local index = 1
	local length = 10
	for i = 1, length do
		if temp[tostring(i)] then
			rank_data[index] = {}
			rank_data[index] = temp[tostring(i)]
			rank_data[index].sort = i
			index = index + 1
		end
	end
	--[[
	for i = 1, self.m_cur_rank_nums do
		rank_data[i] = {}
		if temp[tostring(i)] then
			rank_data[i] = temp[tostring(i)]
		end
	end
	]]--
	return rank_data
end

function M:needRequest(is_cross)
	if self.m_rank_data[is_cross] then
		return false
	end
	return true
end

function M:setCurCross(is_cross)
	self.m_is_cross = is_cross
end

return M
