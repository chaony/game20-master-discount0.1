---@class HalfAnniversaryMainControl: OOControlBase
---@field m_model HalfAnniversaryMainModel
---@field m_view HalfAnniversaryMainView
local M = class("HalfAnniversaryMainControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "open_btn1" then
        --蓬莱集市
        self:openViewByIndex(1)
    elseif msg == "open_btn2" then
        --日历签到
        self:openViewByIndex(2)
    elseif msg == "open_btn3" then
        --庆典装扮 任务
        self:openViewByIndex(3)
    elseif msg == "open_btn4" then
        --锦鲤 彩票
        self:openViewByIndex(4)
    elseif msg == "open_btn5" then
        --商店 
        self:openViewByIndex(5)
    elseif msg == "open_btn6" then
        -- 神兽来袭
        self:openViewByIndex(6)
    elseif msg == "open_btn7" then
        --神兽秘境
        self:openViewByIndex(7)
    elseif msg == "refresh_entrances" then
        -- 刷新红点和入口状态
        self.m_view:refreshActivityEntrances()
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0007"), content = Language:getTextByKey("tid#half_year_Des") })
    end
end

function M:openViewByIndex(index)
    local activityState, start_time = self.m_model:getOpenStateActiveByIndex(index)
    if activityState == 3 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        return
    elseif activityState == 2 then
        local starT = TimeUtil.gmTime(start_time)
        local timerFormat = Language:getTextByKey("achievement_text14", starT.year, starT.month, starT.day)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("half_year_text_0010", timerFormat), delay_close = 2 })
        return
    end
    local config = self.m_model:getTabConfigByIndex(index)
    if config then
        if config.open_id == 327 then
            QuickOpenFuncUtil:openFunc(100001, { open_id = 327, level_up = 1 })
        else
            local params = { openId = config.open_id }
            self:openView(config.lua_name, params)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
