local M = class("HeroSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pops.HeroSelectPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_select then
    	    local params = {}
            params.param = self.m_model.m_param
            params.oid = self.m_model.m_select
            if type(self.m_model.m_callfunc) == "function" then
                self.m_model.m_callfunc(params)
            end
        end
        self:closeView()
	elseif msg == "select_hero" then
		self.m_model:setSelectHero(data)
		self.m_view:refreshUI()
    elseif msg == "tab_btn" then
        self.m_model:setMartial(data)
        self.m_view:refreshUI()
    elseif msg == "race_toggle_btn" then
        self.m_view:setToggleActive(not self.m_view.m_race_toggle_flag)
    elseif msg == "race_toggle_bg" then
        self.m_view:setToggleActive(false)
    end
end

return M;
