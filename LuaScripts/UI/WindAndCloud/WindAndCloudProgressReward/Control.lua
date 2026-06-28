local M = class("WindAndCloudProgressRewardControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudMain")
        self:closeView()
    elseif msg == "active_name_img" then --九天揽月
        self:openView("WindAndCloud.WindAndCloudMoon")
        self:setOnceTimer(0.5,function()
            self:closeView()
        end)
    elseif msg == "box_reward" then  --领取
        if data.data.status == 1 then
            self.m_model:getNetData("active_diamond_rebate_recv", {open_id = self.m_model.m_open_id,version = self.m_model:getVersion(),gift_id = data.data.id}, function(response)
                if response then
                    RewardUtil:rewardTipsByData(response.reward)
                    --点击领取之后显示状态
                    self.m_model:netData(response)
                    self.m_view:refreshUI()
                    self.m_view:showFireworks()
                end
            end, nil, nil, nil)
        end
    elseif msg == "receive_btn" then --奖励详情
        self:openView("WindAndCloud.WindAndCloudRewardTask",{version = self.m_model:getVersion(),open_id = self.m_model.m_open_id})
    elseif msg == "box_click" and data.data.status == 0 then --奖励详情
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "help_btn" then
        local params = {}
        params.title = self.m_model.active_data.name
        params.content = "tid#DiamondEvent_3"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
