local M = class("SevenDayPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point",nil,"Activities")
        self:closeView()
    elseif msg == "receive_btn" then
    	self:requestReceive(data.day)
    end
end

function M:requestReceive(data)
	local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response.seven_tour_received)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("active_receive_seven_tour", params, receivetCallback)
end

return M;
