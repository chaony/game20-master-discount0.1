local M = class("JuBaoShanBuyPopModel", LikeOO.OODataBase)

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
	--最大购买数量
	self.m_max_buyNum = self.m_params.m_max_buyNum
	--点击购买回调
	self.m_click_buy = self.m_params.clickBuy;
	--类名
	self.m_className = self.m_params.className
	
	if self.m_max_buyNum > 0 then
		--初始购买数量
		self.m_min_num = 1
	else
		--初始购买数量
		self.m_min_num = 0
	end
	self.m_buyNum = self.m_min_num
	--获取消耗货币种类
	self.m_cost_data = RewardUtil:getProcessRewardData( self.m_params.cost_data )
	--消耗数量
	self.m_cost = self.m_params.cost;
end

--获取消耗
function M:getCost()
		
end


--获取 title 名字
function M:getTitleName()
	return self.m_title or "~~";
end

return M
