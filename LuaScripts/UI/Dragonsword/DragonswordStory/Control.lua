local M = class("DragonswordStoryControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "receive_btn" then
        self:receiveReward(data)
    elseif msg == "switch"  then --切换页签
        if data.index > self.m_model.m_current_start_day then --未解锁不切换页签
            local lock_time = Language:getTextByKey("dragonsword_text_0003",GameUtil:numberToChineseString(data.index - self.m_model.m_current_start_day))
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(lock_time), delay_close = 2})
        else
            if data.index == self.m_model.m_current_open_day then
                self.m_model.m_current_open_day = 0
            else
                self.m_model.m_current_open_day = data.index
            end
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then  --帮助
        local params = {}
            params.title = "tid#OpenConditionName_252"
            params.content = "tid#DragonDes_1"
            self:openView("Pops.CommonHelpPop", params)
    end
end

--领取奖励
function M:receiveReward(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        self.m_model:updateServerData(response)
        self.m_view:refreshUI()
        self:updateMsg("refresh_data", nil, "Dragonsword")
    end
    local param = {
        vsn = self.m_model.m_version,
        day = data.index
    }
    self.m_model:getNetData("active_dragonsword_recv_login_reward", param, netCallback)
end

return M;
