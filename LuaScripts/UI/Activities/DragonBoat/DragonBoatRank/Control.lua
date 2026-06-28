---@class DeliciousFeastRankControl: OOControlBase
---@field m_model DeliciousFeastRankModel
---@field m_view DeliciousFeastRankView
local M = class("DragonBoatRankControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("update_data", nil, "Activities.DragonBoat")
        self:closeView()
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = self.m_model.active_data.name, content = Language:getTextByKey("tid#MTDes1") })
    elseif msg == "rank_reward_btn" then
        self:openView("Activities.DeliciousFeast.DeliciousFeastRankRewardPop", {version = self.m_model.m_version})
    elseif msg == "time_over" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        self:closeView("Activities.DeliciousFeast.DeliciousFeastRankRewardPop")
        self:closeView()
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

