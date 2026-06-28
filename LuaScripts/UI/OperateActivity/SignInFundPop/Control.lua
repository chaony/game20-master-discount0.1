local M = class("SignInFundPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "get_sign_fund" then -- 签到基金
        self:getSignFund(data)
    end
end

--领取签到基金基金
function M:getSignFund(data)
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
        RewardUtil:rewardTipsByData(response.reward)
        if self.m_model.m_high == 1 then
            self.m_model.m_sign_data = response.high_sign_fund
        else
            self.m_model.m_sign_data = response.normal_sign_fund
        end
        self:updateMsg("updateFundData2", response, "OperateActivity")
        self.m_view:refreshUI()
    end
    local params = {
        day = data.day,
        high = data.high,
        incr_vsn = data.version
    }
    self.m_model:getNetData("sign_fund_receive", params, receivetCallback)
end

return M
