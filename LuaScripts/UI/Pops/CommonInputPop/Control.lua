local M = class("CommonPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if not self.m_model.m_is_free and self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			if data.user_num < data.data_num then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
				self:closeView()
				return
			end
		end
		if self.m_model.m_on_ok_call then
			local text = self.m_view:getText()
			local curName, isPass = text, nil
			if self.m_model.m_popType == 1 then
				curName, isPass = string.filterInvalidChars(curName)
				if not isPass then
					GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0006"), delay_close = 2})
					return
				end
				if curName == "" then
					GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#Rename_01"), delay_close = 2})
					return
				end
			else
				if (string.find(curName, "%%")) then
					GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0037"), delay_close = 2})
					return
				end
			end
			self.m_model.m_on_ok_call(curName)
		end
		if not self.m_model.m_no_close_btn then
			self:closeView()
		end
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
	    self:closeView()
	elseif msg == "reset_input_text" then
		self.m_view:setInputText("")
    end
end

return M;
