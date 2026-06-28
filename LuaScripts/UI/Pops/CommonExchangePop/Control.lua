local M = class("CommonExchangePopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
		self:closeView()
	elseif msg == "ok_btn" then
		if self.m_model.m_click_buy ~= nil then
			self.m_model.m_click_buy( self.m_model.m_buyNum )
		end
		self:closeView()
	elseif msg == "add_btn" then
		self.m_model.m_buyNum = self.m_model.m_buyNum + 1;
		if self.m_model.m_buyNum >= self.m_model.m_max_buyNum then
			self.m_model.m_buyNum = self.m_model.m_max_buyNum;
		end
		self:updateMsg("refreshData", { num = self.m_model.m_buyNum }, self.m_model.m_className )
		self.m_view:refreshUI();
	elseif msg == "max_btn" then
		self.m_model.m_buyNum = self.m_model.m_max_buyNum
		self:updateMsg("refreshData", { num = self.m_model.m_buyNum }, self.m_model.m_className )
		self.m_view:refreshUI();
	elseif msg == "reduce_btn" then
		self.m_model.m_buyNum = self.m_model.m_buyNum - 1;
		if self.m_model.m_buyNum <= self.m_model.m_min_num then
			self.m_model.m_buyNum = self.m_model.m_min_num;
		end
		self:updateMsg("refreshData", { num = self.m_model.m_buyNum }, self.m_model.m_className )
		self.m_view:refreshUI();
	elseif msg == "updateMsgInfo" then
		self.m_model.m_msg = data.msg;
		self.m_model.m_cost = data.cost;
		self.m_view:refreshUI();
    end
end

return M;
