local M = class("NationalBeautifulBattleBreakControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_rank_info", nil, "Chivalry.ChivalryBattle")
        self:closeView()
    elseif msg == "box_reward" then  --领取
        if data.data.status == 1 then
            self.m_model:getNetData("common_train_challenge_recv_attack_reward", {open_id = self.m_model.m_open_id,version = self.m_model:getVersion(),quest_id = data.data.id}, function(response)
                if response then
                    RewardUtil:rewardTipsByData(response.reward)
                    --点击领取之后显示状态
                    self.m_model:netData(response)
                    self.m_view:refreshUI()
                end
            end, nil, nil, nil)
        end
    elseif msg == "box_click" then --展示奖励
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == 2})
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
