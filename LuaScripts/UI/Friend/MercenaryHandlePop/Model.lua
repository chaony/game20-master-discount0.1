local M = class("MercenaryHandlePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("apostle_apply_info")
end

function M:onEnter()
	self.m_tab_index = 1
	self:setApplayListData(self.m_data.apply_list)
end

function M:setApplayListData(data)
	self.m_applay_list = data
end

function M:setOutListData(data)
	self.m_out_list = data
end

function M:setTabIndex(index)
	self.m_tab_index = index
end

function M:isHaveData()
	if self.m_tab_index == 1 then
		if self.m_applay_list then
			return true
		end
	else
		if self.m_out_list then
			return true
		end
	end
end

return M
