local M = class("RpgEndPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "click" then
        self:openView("Shiguang.ShiguangEventLog", {chapter_id = self.m_model.m_chapter_id, event_done = data.cfg.end_event})
    elseif msg == "unclick" then
        GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("rpg_scroll_10"), delay_close = 2})
    end
end

function M:resetChapter(c_id)
    local function receivetCallback(response)
     
    end
    self.m_model:getNetData("rpg_reset_chapter", {team_id = self.m_model.m_team_id, chapter_id = c_id}, receivetCallback)
end

function M:enterChapter(c_id)
    local function receivetCallback(response)
     
    end
    self.m_model:getNetData("rpg_enter_chapter", {team_id = self.m_model.m_team_id, chapter_id = c_id}, receivetCallback)
end

return M
