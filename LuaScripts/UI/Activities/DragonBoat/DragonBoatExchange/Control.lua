---@class DeliciousFeastExchangeControl: OOControlBase
---@field m_model DragonBoatExchangeModel
---@field m_view DragonBoatExchangeView
local M = class("DragonBoatExchangeControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self:updateTime()
    self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("update_data", nil, "Activities.DragonBoat")
        self:closeView()
    elseif msg == "eat_exchange" then
        self:activateExchange(data)
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = self.m_model.active_data.name, content = Language:getTextByKey("tid#MTDes1") })
    end
end

--满月兑换兑换奖励
function M:activateExchange(data)
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            if response.exchange then
                table.merge(self.m_model.m_exchange_data, response.exchange)
            end
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.gift_id = data.id
    params.vsn = data.version
    params.open_id = self.m_model.m_openId
    self.m_model:getNetData("active_common_exchange", params, callback, nil, true)
end

function M:netCheckEndTips(response)
    if response.update == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
    end
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self.m_view:refreshUI()
    end
end

function M:updateTime()
    self.m_view:updateTime()
end
function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M

