local M = class("ServiceGetRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:updateMsg("get_reward_btn")
	elseif msg == "get_reward_btn" then
		if self.m_model.m_callback then
			self.m_model.m_callback()
		end
		self:closeView()
	end
end

return M