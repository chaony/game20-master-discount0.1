local M = class("UnionArtifactResetPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			if data.user_num < data.data_num then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
				self:closeView()
				return
			end
		end
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
	    self:closeView()
    end
end

return M;
