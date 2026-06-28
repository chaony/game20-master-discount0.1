local M = class("EvilShadowExchangeShopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPointExchange", nil, "EvilShadow.EvilShadowMain")
        self:closeView()
    elseif msg == "btn_gotShopTaskBtn" then
        self.m_model:getNetData("evil_shadow_exchange", {version = self.m_model:getVersion(), gift_id = data.gift_id}, function(response)
            if response then
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:updateExchangeData(response.exchange_done)
                self.m_view:refreshTaskList()
            end
        end, nil, nil, nil)
    end
end

return M
