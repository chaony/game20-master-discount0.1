---@class CoolSummerSignControl: OOControlBase
---@field m_model CoolSummerSignModel
---@field m_view CoolSummerSignView
local M = class("CoolSummerSignControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        self:updateMsg("refresh_ui", nil, "CoolSummer")
        self:closeView()
    elseif msg == "btn_closeBtn" then
        self:closeView()
    elseif self.m_view.btn_tab[msg] then
        local day = self.m_view.btn_tab[msg]
        local day_status = self.m_model:getStatusByDay(day)
        if day_status == 1 then
            self:requestSign(day)
        end
    elseif msg == "help_btn" then
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0007"), content = Language:getTextByKey("tid#half_year_Des") })
    end
end

function M:requestSign(day)
    --在线奖励
    local function receivetCallback(response)
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
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model:updateNetData(response)
        self.m_view:refreshUI()
    end
    local params = {vsn = self.m_model.m_vsn, open_id = self.m_model.m_open_id, day = day}
    self.m_model:getNetData("common_login", params, receivetCallback)
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