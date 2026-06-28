local M = class("ActiveCurrentLuckDrawControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPoint", nil, "ActiveCurrent.ActiveCurrentMain")
        self:closeView()
    elseif msg == "luck_draw_btn" then
        local todayIsCharge = self.m_model:todayIsCharge()
        local isRewardClear = self.m_model:isRewardClear()
        if todayIsCharge == 0 then
            GameUtil:lookInfoTips(self, {msg = "active_current_str_0006", delay_close = 2})
        elseif todayIsCharge == 2 then
            GameUtil:lookInfoTips(self, {msg = "active_current_str_0007", delay_close = 2})
        elseif isRewardClear then
            GameUtil:lookInfoTips(self, {msg = "raccon_text_0020", delay_close = 2})
        else
            local function netCallback(response)
                if response then
                    self.m_model:updataServerData(response)
                    self.m_view:refreshUI()
                    RewardUtil:rewardTipsByData(response.reward) --展示奖励
                end
            end
            self.m_model:getNetData("hero_event_lottery_draw", { version = self.m_model.m_version }, netCallback)
        end
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)  
    end
end

return M
