local M = class("HeroFriendShipLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_HaoGanDu_Up")
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:closeView()
    elseif msg == "go_legend_btn" then
        self:openView("HeroBag.HeroLegend",{go_last = true, hero_id = self.m_model.hero_id,hero_data = self.m_model:getHeroCfg(self.m_model.hero_id)})
    end
end

return M