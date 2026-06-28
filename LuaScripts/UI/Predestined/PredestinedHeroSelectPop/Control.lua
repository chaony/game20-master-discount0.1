local M = class("PredestinedHeroSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Predestined.PredestinedHeroSelectPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "ok_btn" then
        self:updateMsg("set_hero", self.m_model.m_arm_hero, "Predestined")
        self:closeView()
    elseif msg == "select_hero" then
        self.m_model:setHero(data)
        self.m_view:refreshUI()
    elseif msg == "tab_btn" then
        self.m_model:setMartial(data)
        self.m_view:refreshUI()
    end
end

return M;
