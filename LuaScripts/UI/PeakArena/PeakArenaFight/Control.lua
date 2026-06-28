local M = class("PeakArenaFightControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()
        self.m_view:updateTime()
    end)
    self.m_view:updateTime()
end

function M:onHandle(msg , data)
    if self.m_model:checkCanClick() == false then
        self:checkIsClose()
        return
    end
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = Language:getTextByKey("peak_str_0006") 
        params.content = Language:getTextByKey("tid#Top_Arena_001")
        self:openView("Pops.CommonHelpPop", params)  
    elseif msg == "refresh_ui" then    
        self.m_view:refreshUI()
    elseif msg == "left_btn" then
        self.m_view:clickLeft()
    elseif msg == "right_btn" then    
        self.m_view:clickRight()
    elseif msg == "look_hero" then
        audio:SendEvtUI("UI_Click_N3")
        self:openView("HeroBag", {player_data = {heros = data.data} , mode = 3, oid = data.oid})
    elseif msg == "team2_btn" then --布阵
        if self.m_model:checkTeamLock() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0007"), delay_close = 2})
            return 
        end
        self:openView("Arena.ArenaHigher.ArenaHigherDefendTeam", {top_arena = true,back_refresh = true})
    elseif msg == "zb_btn" then
        local m_top_data = table.copy(self.m_model.m_top_data)
        table.merge(m_top_data, self.m_model.m_data)
        self:openView("PeakArena.FightReportPop", m_top_data)
    end
end

function M:checkIsClose()
    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("战斗进行中"), delay_close = 2})
    self:closeView()
    return
end

return M
