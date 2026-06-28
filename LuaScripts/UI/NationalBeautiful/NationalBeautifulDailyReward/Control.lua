local M = class("NationalBeautifulDailyRewardControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_data", nil, "NationalBeautiful.NationalBeautifulHeroesList")
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:requestReward()
    end
end

function M:requestReward()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        RewardUtil:rewardTipsByData(response.reward) --展示奖励
        self.m_model:updateServer(response)
        self.m_view:refreshUI(true)
    end
    local params = {}
    params.reward_id = self.m_model:getCurReceiveId()
    params.open_id = self.m_model.m_open_id
    params.version = self.m_model.m_version
    self.m_model:getNetData("active_common_favor_recv",params, netCallback)
end


return M
