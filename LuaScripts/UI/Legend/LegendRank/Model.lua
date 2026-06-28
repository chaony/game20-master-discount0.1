local M = class("LegendRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("legend_select_rank", {start = 1, stop = 50})
end

function M:onEnter()
	self.m_data = self.m_data or {}
	self.m_stage_cfg = self.m_params.stage_cfg
end

function M:getRankData()
	return self.m_data.ranks or {}
end
return M
