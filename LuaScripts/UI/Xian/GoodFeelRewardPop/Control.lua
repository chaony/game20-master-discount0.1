local M = class("GoodFeelRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		--RewardUtil:rewardTipsByData(self.m_model.m_reard_data)
		self:closeView()
	end
end

return M