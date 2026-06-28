local M = class("MultiFormationControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("reset_mult_edit_flag",nil, "Formation")
        self:closeView()
    elseif msg == "race_toggle_btn" then
        self.m_view:setToggleActive(not self.m_race_toggle_flag)
    elseif msg == "race_toggle_bg" then
        self.m_view:setToggleActive(false)
    elseif msg == "close_btn" or msg == "big_close_btn" then
        self:updateMsg("hide_multi_formation_btn",nil, "Formation")
    elseif msg == "tab_btn" then
        --self.m_model:setMartial(data)
        --self.m_view:updateHerosScroll()
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "showFormationList" then
        self.m_view:showFormationList()
    elseif msg == "formation_edit_btn" then
        audio:SendEvtUI("Play_UI_BuZhen")
        self:closeView()
        self:updateMsg("formation_edit_btn",data, "Formation")
    elseif msg == "formation_rename_btn" then
        --self:updateMsg("formation_rename_btn",data, "Formation")
    elseif msg == "set_team" then
        self:updateMsg("set_team",data, "Formation")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
