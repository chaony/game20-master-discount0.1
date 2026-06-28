---@class HalfAnniversaryLotteryControl: OOControlBase
---@field m_model HalfAnniversaryLotteryModel
---@field m_view HalfAnniversaryLotteryView
local M = class("HalfAnniversaryLotteryControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        self:closeView()
    elseif msg == "result_btn" then
        --查看结果
        self:openView("HalfAnniversary.HalfAnniversaryLotteryPop", self.m_model.m_data)
    elseif msg == "lottery_btn" then
        --抽取号码
        self:getLotteryNum()
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0004"), content = Language:getTextByKey("tid#_lottery_ticket_can") })
    elseif msg == "time_over" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        self:closeView("HalfAnniversary.HalfAnniversaryLotteryPop")
        self:updateMsg(99999)
    elseif msg == "update_data" then
        self:updateData()
    end
end

function M:getLotteryNum()
    if self.m_model.m_data.stage == 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("half_year_text_0040"), delay_close = 2 })
        return
    end
    
    if self.m_model.m_data.self_number and self.m_model.m_data.self_number ~= "" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("half_year_text_0027"), delay_close = 2 })
        return
    end
    
    local params = { vsn = self.m_model.m_version}
    self.m_model:getNetData("lottery_tiket_lottery_tiket_get_number", params, function(response)
        if response then
            if self:activityOverExamine(response) then
                return
            end
            self.m_model:updateData(response)
            self.m_view:playAnim()
            self.m_view:refreshUI()
        end
    end)
end

function M:updateData()
    self.m_model:getNetData("lottery_tiket_lottery_tiket_index", nil, function(response)
        if response then
            if self:activityOverExamine(response) then
                return
            end
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

function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
