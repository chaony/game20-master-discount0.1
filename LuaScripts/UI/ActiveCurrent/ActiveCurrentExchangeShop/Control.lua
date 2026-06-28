local M = class("ActiveCurrentExchangeShopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPoint", nil, "ActiveCurrent.ActiveCurrentMain")
        self:closeView()
    elseif msg == "btn_gotShopTaskBtn" then
        self.m_model:getNetData("hero_event_exchange", {version = self.m_model:getVersion(), gift_id = data.gift_id}, function(response)
            if response then
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:updateExchangeData(response.exchange_done)
                self.m_view:refreshTaskList()
            end
        end, nil, nil, nil)
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    end
end

return M
