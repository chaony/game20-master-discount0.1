local M = class("DaySevenPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
       --self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_red_point",nil,"parent")
        self:closeView()
    elseif msg == "get_day_btn_1" then
        self:overTaskEvent(self.m_model.m_task_data[1].id)
    elseif msg == "get_day_btn_2" then
        self:overTaskEvent(self.m_model.m_task_data[2].id)
    elseif msg == "get_day_btn_3" then
        self:overTaskEvent(self.m_model.m_task_data[3].id)
    elseif msg == "go_to_btn_3" then
        static_rootControl:updateMsg("goto_recharge", 143) --137跳转至活动-签到基金
        self:closeView()
    elseif msg == "look_hero_btn" then
        local id = tonumber(TONGYONG_ZHAOYUN[self.m_model.is_open_type].hero_id or 717)
        self:openView("Pops.HeroLookInfo", {hero_id = id, is_new = false,is_open_type = 1})
    elseif msg == "get_day_btn"  then
        local params = {open_id = self.m_model.m_open_id, vsn = self.m_model.m_version}
        self.m_model:getNetData("common_quest_recv_union", params, function(response)
            if response then
                self.m_model:refreshData(response)
                self.m_view:refreshUI()
                self:updateMsg("refresh_red_point",nil,"parent")
                self:closeView()
                RewardUtil:rewardTipsByData(response.reward)
            end
        end, nil, nil, nil)
    end
end

--领取任务
function M:overTaskEvent(quest_id)
    local params = {open_id = self.m_model.m_open_id, vsn = self.m_model.m_version, quest_id = quest_id}
    self.m_model:getNetData("common_quest_recv_task", params, function(response)
        if response then
            self.m_model:refreshData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
        end
    end, nil, nil, nil)
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
