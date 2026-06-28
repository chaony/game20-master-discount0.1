local M = class("QiXiGiftMoonControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "QiXi.QiXiMain")
        self:closeView()
    elseif msg == "shoping_btn" then --超值团购
        local function netCallback(response)
            if response.update then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            if response["end"] then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                self:closeView()
                return
            end
            response.is_token = self.m_model:getTokenFlag()
            response.version = self.m_model:getVersion()
            self:openView("QiXi.QiXiShopping", response)
            self:setOnceTimer(0.5,function()
                self:closeView()
            end)
        end
        self.m_model:getNetData("valentine_festival_box_index", nil, netCallback)
    elseif msg == "receive_btn" then  --领取
        if self.m_model:getIsReceive() == 0 then
            self.m_model:getNetData("valentine_festival_receive_moon_reward", {vsn = self.m_model:getVersion()}, function(response)
                if response then
                    RewardUtil:rewardTipsByData(response.reward)
                    --点击领取之后显示状态
                    self.m_model:setIsReceive(response.received)
                    self.m_view:refreshUI()
                end
            end, nil, nil, nil)
        end
    elseif msg == "help_btn" then
        self.avtive_data = self.m_model:getActiveData()
        local params = {}
        params.title = self.avtive_data.name
        params.content = "tid#ValentineFestival_4"
        self:openView("Pops.CommonHelpPop", params)
    end
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
