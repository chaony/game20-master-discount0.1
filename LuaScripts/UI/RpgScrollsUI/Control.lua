local M = class("RpgScrollsUIControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select" then
        self:openView("RpgScrollsUI.RpgSelectChapter", data)
    elseif msg == "unlock" then
        if data then
            self:resetUnlock(data.id)
        end
    elseif msg == "unopen" then
        if data then
            self:resetUnlock(data.id)
        end
    end
end

function M:resetUnlock(t_id)
    local function receivetCallback(response)
        self.m_model.team_datas = response.team_data
        self.m_view:openLockSpine(t_id)
    end
    if self.m_model:canlock(t_id) == true then
        self.m_model:getNetData("rpg_unlock", {team_id = t_id}, receivetCallback)
    else
        local names = self.m_model:getHeroNames(t_id)
        local params = {
            no_close_btn = true,
            text = Language:getTextByKey("rpg_scroll_7") ..names, 
        }
        self:openView("Pops.CommonPop",params) 
    end
end

return M;
