local M = class("MartialSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--self.m_martial = ConfigManager:getCommonValueById(34)
	self.m_martial = {3,4,5,6}
	self.m_callback = self.m_params.callback
	self:updateData(self.m_params)
end

function M:updateData(data)
	self.m_select = data.martial or 3
	self.m_cur_martial = self.m_select
	--self.m_open = data.openMartial
	self.m_open = {3,4,5,6}
	self.m_end_ts = data.end_ts
end

function M:setSelect(index)
	self.m_select = self.m_martial[index]
end

function M:updateOpen(data)
	self.m_open = data
end

function M:isOpened(martial)
	for i,v in ipairs(self.m_open) do
		if v == martial then
			return true
		end
	end
	return false
end

return M
