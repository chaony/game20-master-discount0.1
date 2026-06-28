local M = class("ThreeHeroesFiveGallantsLuckDrawControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPoint", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMain")
        self:closeView()
    elseif msg == "luck_draw_btn" then
        audio:SendEvtUI("UI_Click_N1")
        local isRewardClear = self.m_model:isRewardClear()
        local todayIsCharge = self.m_model:todayIsCharge()
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
             self.m_model:getNetData("user_payment_common_lottery", { open_id = self.m_model.m_open_id, vsn = self.m_model.m_version }, netCallback)
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "raccon_text_0007"
        local content = self.m_model:getMainCfgVByK("raccoon_des") or "tid#XiaoHuanXiongDes_1"
        params.content = content
        self:openView("Pops.CommonHelpPop", params)  
    end
end

return M
