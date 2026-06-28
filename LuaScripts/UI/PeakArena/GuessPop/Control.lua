local M = class("GuessPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "sub_btn" then
        self.m_model:subNum()
        self.m_view:refreshUI()
    elseif msg == "add_btn" then
        if self.m_model.m_cur_num >= self.m_model.m_cost_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0049"), delay_close = 2})
            return
        end
        self.m_model:AddNum()
        self.m_view:refreshUI()
    elseif msg == "suib_more_btn" then
        self.m_model:subMoreNum()
        self.m_view:refreshUI()
    elseif msg == "add_more_btn" then
        if self.m_model.m_cur_num >= self.m_model.m_cost_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0049"), delay_close = 2})
            return
        end
        self.m_model:addMoreNum()
        self.m_view:refreshUI()
    elseif msg == "updateSliderValue" then
        self.m_model:setNumByValue(data)
        self.m_view:refreshUI()
    elseif msg == "buy_btn" then    
        self:guessPlayer(function ()
            self:updateMsg(99999)
        end)
     
    end
end

-- shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店
function M:guessPlayer(call_back)
    if self.m_model.m_cur_num <= 0 then
        call_back()
        return
    end
    local cost_data = RewardUtil:getProcessRewardData({135,0,0})
    if self.m_model.m_cur_num > cost_data.user_num then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("竞猜币不足"), delay_close = 2})
        return
    end
    local function netCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("押注成功"), delay_close = 2})
        self:updateMsg("updateGress",response, "PeakArena.PeakArenaMain")
        self:updateMsg("updateGress",response, "PeakArena.PeakMyGuessPop")
        call_back()
    end
    local params = {
        guess_user = self.m_model.m_play_data.user.uid,
        count = self.m_model.m_cur_num
    }
    self.m_model:getNetData("guess", params, netCallback)
end

return M
