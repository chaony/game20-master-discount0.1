local M = class("LanternFestivalRiddlesControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

local btn_msg = {lantern_btn1 = 1, lantern_btn2 = 2, lantern_btn3 = 3, lantern_btn4 = 4, lantern_btn5 = 5, lantern_btn6 = 6, lantern_btn7 = 7 }
function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "refresh_data" then
        if data then
            self.m_model:initData(data)
            self:updateMsg("refresh_data",data,"LanternFestival")
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "lantern_festival_text_0003"
        params.content = self.m_model.m_help_id
        self:openView("Pops.CommonHelpPop", params)
    elseif btn_msg[msg] then
        local index = btn_msg[msg]
        local status, status_data = self.m_model:getLatternStatusByIndex(index)
        if status_data then
            local riddle_rewards = self.m_model:getRiddleRewardByDay(index)
            self:openView("LanternFestival.LanternFestivalRiddlesPop", {riddle_rewards = riddle_rewards,
                                                                        version = self.m_model.m_version,
                                                                        status_data = status_data,
                                                                        cur_day = self.m_model.m_cur_day,
                                                                        question_index = index})
        end
    end
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

function M:requestIndexData()
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("active_lantern_index", {}, netCallback)
end

return M;
