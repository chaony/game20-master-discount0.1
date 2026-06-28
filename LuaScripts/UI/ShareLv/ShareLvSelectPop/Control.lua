local M = class("ShareLvSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.ShareLv.ShareLvSelectPop.Guide"
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_select then
    	    local params = {}
            params.pos = self.m_model.m_pos
            params.hero_oid = self.m_model.m_select
            if type(self.m_model.m_callfunc) == "function" then
                self.m_model.m_callfunc(params)
            end
        end
        self:updateMsg("guide_check", nil, "ShareLv")
        self:closeView()
	elseif msg == "select_hero" then
		self.m_model:setSelectHero(data)
        self.keep_offset = true
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
