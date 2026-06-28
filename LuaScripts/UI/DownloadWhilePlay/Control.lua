local M = class("DownloadWhilePlayControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 or msg == "btn_close" then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "btn_get" then
        local download_play_stage = UserDataManager:getDownloadWhilePlayStage()
        if download_play_stage == 0 then --未开始阶段
            UserDataManager:setDownloadWhilePlayStage(1)
            UserDataManager:setDownloadWhilePlayRemainTime(60 * 10) --10分钟 
            self:updateMsg(99999)
        elseif download_play_stage == 1 then --倒计时阶段
        
        elseif download_play_stage == 2 then --待领奖阶段
            if self.m_model.m_get_flag == false then
                self.m_model.m_get_flag = true
                self:getReward()
            end
        end
    end
end

--领取奖励
function M:getReward()
    local function receivetCallback(response)
        UserDataManager:setPlayAndDownloadStatus(1) --设置为以领取状态
        RewardUtil:rewardTipsByData(response.reward or {}, nil, function()
            self:updateMsg(99999)
        end)
        --self:tryDownloadResource()
    end
    self.m_model:getNetData("download_play_recv", nil, receivetCallback)
end

function M:tryDownloadResource()
    SDKUtil:tryDownloadResourceWithLeBianSDK()
end

return M
