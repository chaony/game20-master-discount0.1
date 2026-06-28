local M = class("ServiceMailDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:closeView()
	elseif msg == "yes_btn"	then
		local function readCallback(response)
			if response then
				self:updateMsg("updateData", {id = self.m_model.m_mail_data.id, data = response.mail } , "Xian.ServiceMailPop")
				self:updateMsg("updateOneMail", {id = self.m_model.m_mail_data.id, data = response.mail } , "Xian")
				if next(response.reward) then
					RewardUtil:rewardTipsByData(response.reward)
				end
			end
			self:closeView()
		end
		local params = {}
		params.mail_id = self.m_model.m_mail_data.id
		self.m_model:getNetData("receive_mail", params, readCallback)
	end
end


return M