local M = class("MythArenaShowRankModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self:updateData(self.m_params)
end

function M:updateData(data)
	if self.m_data == nil then self.m_data = {} end
	if data then
		table.merge(self.m_data, data)
	end
	self.m_big_stage = self.m_data.big_stage or 1
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_reward_Exhibition") or {}
	self.m_ranks = self.m_data.ranks or {}
	if next(self.m_ranks) then
		table.sort(self.m_ranks, function(a, b)  return a.rank < b.rank end)
	end
end

function M:getRankTitleDes(rank)
	local rank = tonumber(rank)
	if self.m_myth_times_cfg[rank] and self.m_myth_times_cfg[rank].show_name_1 then
		return self.m_myth_times_cfg[rank].show_name_1
	end
	return nil
end
return M
