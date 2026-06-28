local M = class("CompareSwordDefendPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	local netData = self.m_data  --获取服务器数据
end

function M:initData()
	--init net data

	-- self.m_something = self.data.netData
end

function M:updateData( response )
	-- use mothed in control , for update from net 
	table.merge(self.m_data , response)
	self:initData()
end

function M:destroy()

	M.super.destroy(self)
end

return M