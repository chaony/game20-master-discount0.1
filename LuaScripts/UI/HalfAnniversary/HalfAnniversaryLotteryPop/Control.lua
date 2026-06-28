---@class HalfAnniversaryLotteryPopControl: OOControlBase
---@field m_model HalfAnniversaryLotteryPopModel
---@field m_view HalfAnniversaryLotteryPopView
local M = class("HalfAnniversaryLotteryPopControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("refresh_ui", nil, "HalfAnniversary.HalfAnniversaryLottery")
        self:updateMsg("refresh_ui", nil, "CelebrateOneYear.CelebrateOneYearLottery")
        self:closeView()
    elseif msg == "tab_index" then
        if self.m_model.m_last_stage >= data then
            self.m_model:setTabIndex(data)
            self.m_view:refreshUI()
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("half_year_text_0036"), delay_close = 2 })
        end
    elseif msg == "recv_award_btn" then
        self:receiveReward()
    elseif msg == "time_over" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        self:closeView()
    end
end

function M:openViewByIndex(index, isShowTime)
    if not self.m_model:isOpenActiveByIndex(index, isShowTime) then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        return
    end
    local config = self.m_model:getTabConfigByIndex(index)
    if config then
        local params = { openId = config.open_id, versionId = self.m_model:getVersion(), isOfficial = self.m_model:checkIsOfficial(), spineName = self.m_model:getSpineName() }
        self:openView(config.lua_name, params)
    end
end

function M:receiveReward()
    local params = {}
    params.vsn = self.m_model.m_version
    params.stage = self.m_model.m_stage
    self.m_model:getNetData("lottery_tiket_lottery_tiket_recv", params, function(response)
        if response then
            if self:activityOverExamine(response) then
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end)
end

function M:activityOverExamine(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0085"), delay_close = 2 })
        static_rootControl:closeAllViewPop()
        return true
    end
    return false
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
