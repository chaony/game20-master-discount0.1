local M = class("LuckyRabbitHutTimesPopModel", LikeOO.OODataBase)

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

	self.m_version = self.m_params.version
	--当前显示的数量
	self.m_cur_num = self.m_params.num or 1
	
	--限制次数
	self.m_limit_num =self.m_params.limit_num or 999999999

	self.gacha_cfg =  ConfigManager:getCfgByName("rabbit_gacha")
	self.rabbit_ticket_data = self.gacha_cfg[self.m_version].gacha[1]
end

function M:getMaxItemNum()
	local item_data = RewardUtil:getProcessRewardData(self.rabbit_ticket_data)
	local item_num = item_data.user_num
	
	return item_num
end

return M
