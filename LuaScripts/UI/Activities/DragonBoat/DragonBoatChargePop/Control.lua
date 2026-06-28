local M = class("DragonBoatChargePopControl", LikeOO.OOControlBase)

function M:onEnter()
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

--领取奖励
function M:getCmltReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.milepost_reward, response.got_milepost_reward)
        self.m_view:refreshUI()
        self:updateMsg("refresh_milepost", response.got_milepost_reward , "Activities.DragonBoat.DragonBoatCookThree")
    end
    local params = {
        reward_id = data,
        vsn = self.m_model.version
    }
    self.m_model:getNetData("meituan_get_milepost_reward", params, receivetCallback)
end

return M
