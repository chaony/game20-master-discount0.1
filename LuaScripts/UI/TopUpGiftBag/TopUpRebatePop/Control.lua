local M = class("TopUpRebatePopControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "getReward_btn" then
        self:requestGetReward()
    end
end

function M:requestGetReward()
    if self.isGet then
        GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0058"), delay_close = 2})
        return
    end
    local function callBack(response)
        self.m_view:refreshUI()
        self.isGet = true
        RewardUtil:rewardTipsByData(response.reward)
    end
    self.m_model:getNetData("sea_rebate_award",nil,callBack)
end

return M