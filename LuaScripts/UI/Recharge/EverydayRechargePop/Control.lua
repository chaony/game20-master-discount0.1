local M = class("EverydayRechargePopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg,date)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "close_btn" then
        self:closeView()
    elseif msg == "goto_btn" then
        QuickOpenFuncUtil:openFunc(10010)
        self:closeView()
    elseif msg == "get_btn" then
        self:receiveReward()
    end
end

--领取奖励
function M:receiveReward()
    local function netCallback(response)
        Logger.logError(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        elseif response.update == 1 then --活动奖励过期提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("奖励已过期"), delay_close = 2})
            self.m_model:updateServerData(response)
            self.m_view:refreshUI()
        else --可领取
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg(99999)
            self.m_model:updateServerData(response)
        end
    end
    local params = {incr_vsn = self.m_model.m_incr_vsn}
    self.m_model:getNetData("user_payment_daily_charge_receive", params, netCallback)
end

return M;
	