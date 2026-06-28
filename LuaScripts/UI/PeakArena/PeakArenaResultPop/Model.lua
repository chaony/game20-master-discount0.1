local M = class("PeakArenaResultPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("season_top3")
end

function M:onEnter()
	self.m_callback = self.m_params.callback
    self.m_callback_new = self.m_params.callback_new
end

function M:getPlayerData(index)
	return self.m_data.top_n[tostring(index)] or {}
end

function M:getSeasonTime()
	return os.date("%m月%d日%H:%M",self.m_data.next_start) .." - "..os.date("%m月%d日%H:%M",self.m_data.next_end)
end

return M
