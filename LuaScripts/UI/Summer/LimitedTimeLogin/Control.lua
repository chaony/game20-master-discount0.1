local M = class("LimitedTimeLoginControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:closeView()
    elseif msg == "close_btn" or msg == "btn_close" then
        self:closeView()
    elseif msg == "TreasureChest_Img" then
        if self.m_view.day > 7 then
            if self.m_model:hasDay(0) then --已领取
                --self:openView("Item.ItemDetail", {show_data = self.m_view.rewardCfg, display = true})
                GameUtil:clickItemByData(self.m_view.rewardCfg)
            else
                self:receivedReward(0)
            end
        else
            --self:openView("Item.ItemDetail", {show_data = self.m_view.rewardCfg, display = true})
            GameUtil:clickItemByData(self.m_view.rewardCfg)
        end
    elseif msg == "btn_bigGiftBag_bg" then
        -- else
        -- self:openView("Item.ItemDetail", {show_data = self.m_view.rewardCfg, display = true})
        -- end
        -- if self.m_view.rewardStatus then
        self:receivedReward(0)
    elseif msg == "Day_1" then
        self:receivedReward(1)
    elseif msg == "Day_2" then
        self:receivedReward(2)
    elseif msg == "Day_3" then
        self:receivedReward(3)
    elseif msg == "Day_4" then
        self:receivedReward(4)
    elseif msg == "Day_5" then
        self:receivedReward(5)
    elseif msg == "Day_6" then
        self:receivedReward(6)
    elseif msg == "Day_7" then
        self:receivedReward(7)
    end
end

--领取奖励
function M:receivedReward(date)
    local function netCallback(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateServerData(response)
        self.m_view:updateDayReward()
        self:updateMsg("refreshUI_dayReward", response, "Summer.SummerMain")
        self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
    end
    local params = {day = date, version = self.m_model.m_verson}
    self.m_model:getNetData("hero_chest_receive_login", params, netCallback)
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

return M
