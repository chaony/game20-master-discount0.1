local M = class("commonExchangeShopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:updateMsg("refresh_red_point", nil, "QiXi.QiXiMain")
        self:closeView()
    elseif msg == "reward_btn" then
        self.m_model:getNetData("active_common_exchange", {vsn = self.m_model:getVersion(), gift_id = data.gift_id,open_id = self.m_model.open_id}, function(response)
            if response then
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:updateExchangeData(response.exchange)
                self.m_view:refreshUI()
            end
        end, nil, nil, nil)
    elseif msg == "help_btn" then  --帮助
        self.avtive_data = self.m_model:getActiveData()
        local params = {}
        params.title = self.avtive_data.name
        params.content = "tid#ValentineFestival_7"
        self:openView("Pops.CommonHelpPop", params)
    end
end

return M
