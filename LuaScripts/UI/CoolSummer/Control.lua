---@class CoolSummerMainControl: OOControlBase
---@field m_model  CoolSummerMainModel
---@field m_view  CoolSummerMainView
local M = class("CoolSummerMainControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "open_btn1" then
        --清凉消暑
        self:openViewByIndex(1)
    elseif msg == "open_btn2" then
        --守卫清凉
        self:openViewByIndex(2)
    elseif msg == "open_btn3" then
        --夏日夺宝
        self:openViewByIndex(3)
    elseif msg == "open_btn4" then
        --清凉小镇
        self:openViewByIndex(4)
    elseif msg == "refresh_ui" then 
        self.m_view:refreshUI()
    end
end

function M:openViewByIndex(index)
--[[    local activityState, start_time = self.m_model:getOpenStateActiveByIndex(index)
    if activityState == 3 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        return
    elseif activityState == 2 then
        local starT = TimeUtil.gmTime(start_time)
        local timerFormat = Language:getTextByKey("achievement_text14", starT.year, starT.month, starT.day)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("half_year_text_0010", timerFormat), delay_close = 2 })
        return
    end]]
    local config = self.m_model:getTabConfigByIndex(index)
    if config then
        if config.open_id == 368 then
            --self:openView("Activities.ActiveBoss.ActiveBossCoolRankPop")
            QuickOpenFuncUtil:openFunc(100001, { open_id = config.open_id or 368,level_up = 1 })
        else
            local params = { openId = config.open_id }
            
            self:openView(config.lua_name, params)
        end
    end
end
--计时器
function M:UpdateTime()
    self.m_view:updateActivityTimer()
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
