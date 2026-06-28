local M = class("DownloadWhilePlayModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_get_flag = false
	self.m_gift_data = {}
	self:initGiftData()
end

function M:initGiftData()
	self.m_gift_data = ConfigManager:getCommonValueById(774, {})
end

function M:getGiftData()
	return self.m_gift_data or {}
end

return M
