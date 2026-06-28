local M = class("NewPlayerRegressControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "close_btn" then    -- 返回
		self:updateMsg("refresh_red_point", nil, "parent")
		if self.m_model.m_callback then
			self.m_model.m_callback(self.m_model.m_callback_new)
		end
		self:closeView()
	elseif msg == "get_btn" then
		self:getRewards(data)
	end
end

function M:getRewards(data)
    local function readCallback(response)
		if response then
			UserDataManager.comeback_rcvd = response.comeback_rcvd
			self.m_model:updateRewardData()
			self.m_view:refreshUI()
            if next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
            end
        end
    end
    self.m_model:getNetData("user_receive_comeback", {day = data.day}, readCallback)
end

return M