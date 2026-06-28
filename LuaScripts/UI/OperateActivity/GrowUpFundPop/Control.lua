local M = class("GrowUpFundPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "get_fund" then --成长基金
        self:getFund(data)
    elseif msg == "go_to" then
        static_rootControl:closeAllViewPop()
        local go_type = data or {}
        QuickOpenFuncUtil:openFunc(go_type)
    end
end

--领取基金
function M:getFund(data)
    local function receivetCallback(response)
        if response.update == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg("buy_sdk_update", nil, "OperateActivity")
            self:updateMsg(99999)
        end
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg("buy_sdk_update", nil, "OperateActivity")
            self:updateMsg(99999)
            return
        end
        self:updateMsg("updateFundData", response, "OperateActivity")
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model.m_war_fund_receiced_data = response
        self.m_view:refreshUI()
    end
    if self.m_model.m_war_fund_receiced_data.fund_status == 1 then
        self.m_model:getNetData("receive_fund_reward", {reward_id = data.reward_id}, receivetCallback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0542"), delay_close = 2})
    end
end

return M
