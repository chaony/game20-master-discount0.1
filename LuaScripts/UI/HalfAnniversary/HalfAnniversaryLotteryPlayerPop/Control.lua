---@class HalfAnniversaryLotteryPlayerPopControl: OOControlBase
---@field m_model HalfAnniversaryLotteryPlayerPopModel
---@field m_view HalfAnniversaryLotteryPlayerPopView
local M = class("HalfAnniversaryLotteryPlayerPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        self:closeView()
    elseif msg == "open_btn1" then
        --任务
        self:openViewByIndex(1, false)
    elseif msg == "open_btn2" then
        --制作
        self:openViewByIndex(2, false)
    elseif msg == "open_btn3" then
        --礼包
        self:openViewByIndex(3, false)
    elseif msg == "open_btn4" then
        --兑换
        self:openViewByIndex(4, true)
    elseif msg == "open_btn5" then
        --排行
        self:openViewByIndex(5, true)
    elseif msg == "meituanH5_btn" and self.m_model:checkIsOfficial() then
        -- 美团H5入口
        CS.UnityEngine.Application.OpenURL(meituan_url)
    elseif msg == "refreshRedPoint" then
        -- 刷新红点
        self.m_model:checkTaskRed()
        self.m_model:checkCookRed()
        self.m_view:refreshRedPoint()
    elseif msg == "updata_task" then
        --刷新任务数据 for 红点
        self.m_model:updateTaskData(data)
        self.m_model:checkTaskRed()
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0007"), content = Language:getTextByKey("tid#half_year_Des") })
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

function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
