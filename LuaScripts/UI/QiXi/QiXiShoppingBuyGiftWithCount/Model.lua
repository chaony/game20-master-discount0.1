local M = class("QiXiShoppingBuyGiftWithCountModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--显示信息
	self.m_msg = self.m_params.msg;
	--标题 
	self.m_title = self.m_params.title;
	--点击购买回调
	self.m_click_buy = self.m_params.clickBuy;
	--类名
	self.m_className = self.m_params.className
	self.m_min_num = 1
	self.m_buyNum = self.m_min_num
	--消耗数量
	self.m_cost = self.m_params.cost;
	--拥有的元宝数量
	local item_data = RewardUtil:getProcessRewardData({107, 0, 0})
	self.m_yuanbao_count = item_data.user_num
end

return M
