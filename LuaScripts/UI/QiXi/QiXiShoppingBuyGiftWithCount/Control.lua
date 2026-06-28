local M = class("QiXiShoppingBuyGiftWithCountControl", LikeOO.OOControlBase)

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "ok_btn" then
		if self.m_model.m_cost * self.m_model.m_buyNum > self.m_model.m_yuanbao_count then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_038"), delay_close = 2})
			return
		end
		if self.m_model.m_click_buy ~= nil then
			self.m_model.m_click_buy(self.m_model.m_buyNum)
		end
		self:closeView()
		return
	elseif msg == "add_btn" then
		if self.m_model.m_cost * (self.m_model.m_buyNum + 1) > self.m_model.m_yuanbao_count then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_038"), delay_close = 2})
			return
		end
		self.m_model.m_buyNum = self.m_model.m_buyNum + 1;
	elseif msg == "reduce_btn" then
		if self.m_model.m_buyNum <= 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_039"), delay_close = 2})
			return
		end
		self.m_model.m_buyNum = self.m_model.m_buyNum - 1;
	elseif msg == "max_btn" then
		if self.m_model.m_cost * (self.m_model.m_buyNum + 10) > self.m_model.m_yuanbao_count then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_038"), delay_close = 2})
			return
		end
		self.m_model.m_buyNum = self.m_model.m_buyNum + 10;
	elseif msg == "min_btn" then
		if self.m_model.m_buyNum <= 10 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_039"), delay_close = 2})
			return
		end
		self.m_model.m_buyNum = self.m_model.m_buyNum - 10;
	end
	self.m_view:refreshUI()
end

return M;
