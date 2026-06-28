local M = class("EverydayRechargePopModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("user_payment_daily_charge_index")
end

function M:onEnter()
	self.m_price = self.m_data.price
	self.m_version = self.m_data.version
	self.m_status = self.m_data.status
	self.m_incr_vsn = self.m_data.incr_vsn
end

--更新服务器数据
function M:updateServerData( serverData )
	self.m_status = serverData.status
	self.m_version = serverData.version
	self.m_incr_vsn = serverData.incr_vsn
	self.m_price = serverData.price
end


--获取配置数据
function M:getRechargeData()
	local verson = self.m_version 
	local show_data = {}
	local daily_charge = ConfigManager:getCfgByName("daily_charge")
	show_data = daily_charge[verson].reward
	local price = daily_charge[verson].price
	return show_data,GameUtil:switchMoneyType(price)
end

return M
