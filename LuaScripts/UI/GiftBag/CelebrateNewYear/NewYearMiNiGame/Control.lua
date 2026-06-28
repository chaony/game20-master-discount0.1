local M = class("NewYearMiNiGameControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
        self:updateMsg("refresh_red_point",nil,"GiftBag.CelebrateNewYear")
    elseif msg == "jump" then
        audio:SendEvtUI("UI_Tab_N5")
        RedPointUtil:saveLocalRedPointFreshTime("mult_game_street_"..data)
        local cell_game_active = self.m_model:getMiniGameActives(data)
        self:openView("LittleGames",{mult = true,version = data, recv = self.m_model:getRecv(data), end_ts = cell_game_active.end_ts or 0})
        self.m_view:refreshUI()
    elseif msg == "updateData" then
        table.merge(self.m_model.m_data, data)
        self.m_view:refreshUI()
    elseif msg == "updateScore" then
        if self.m_model.m_data.scores[tostring(data.id)] then
            if data.num > self.m_model.m_data.scores[tostring(data.id)] then
                self.m_model.m_data.scores[tostring(data.id)] = data.num    
            end
        else
            self.m_model.m_data.scores[tostring(data.id)] = data.num    
        end
        self.m_view:refreshUI()
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.m_version] or {}
        local content = versionData.des
        local open_data = self.m_model:getActiveCfgByOpenId(261)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
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
