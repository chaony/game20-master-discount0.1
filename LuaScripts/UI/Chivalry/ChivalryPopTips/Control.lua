local M = class("ChivalryPopTipsControl",LikeOO.OOControlBase)

function M:onEnter()
	
end


function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		self:updateMsg("refreshRedPoint", nil, "Chivalry.ChivalryMain")
		self:closeView()
    elseif msg == "cost_btn" then
		if self.m_model.m_receive_stage == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0080"), delay_close = 2})
			return
		end
		self:receiveReward()
	end
end

--领取奖励
function M:receiveReward()
	local function netCallback(response)
		self:updateMsg("update_data", nil, "Chivalry.ChivalryFill")
		RewardUtil:rewardTipsByData(response.reward) --展示奖励
		self.m_model.m_receive_stage = 1
		self.m_view:refreshUI()
	end
	self.m_model:getNetData("", {}, netCallback)
end

function M:destroy()
	M.super.destroy(self)
end


return M;
