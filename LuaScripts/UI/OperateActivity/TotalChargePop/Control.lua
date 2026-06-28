local M = class("TotalChargePopControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    self:updateTime()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getCmltReward(data)
    elseif msg == "get_net" then
        self.m_model:initData(function ()
            self.m_view:refreshUI()
            self:updateTime()
        end)
    elseif msg == "check_tag" then
        self.m_model.m_select_index = data
        self.m_model:switchTag()
        self.m_view:refreshEndTs()
        self.m_view:createLoopScroll()
        self:updateTime()
    end
end

--领取累计充值
function M:getCmltReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_data, response)
        self.m_model:refreshData()
        self.m_view:refreshUI()
        self:updateMsg("refreshUI", nil, "TopUpGiftBag")
    end
    local params = {
        gift_id = data,
        incr_vsn = self.m_model.m_cmlt_recharge_data.incr_vsn or self.m_model.m_cmlt_recharge_data.version or 1
    }
    self.m_model:getNetData("receive_cmlt_recharge", params, receivetCallback)
end

function M:updateTime()
    self.m_view:updateTime()
end

return M
