local M = class("FormationSetControl",LikeOO.OOControlBase)

function M:onEnter()
    self:switchTabBtn(self.m_model.m_open_tab_index)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "switch_hero_type" then
        self:switchHeroTypeBtn(data)
    end
end

-- tab按钮切换
function M:switchTabBtn(index, first_enter)
	if self.m_model.m_sel_tab_index ~= index then
        self.m_view:switchTabNode(index, first_enter)
		self.m_model.m_sel_tab_index = index
    end
end

-- tab按钮切换
function M:switchHeroTypeBtn(index)
	if self.m_model.m_sel_her_index ~= index then
        self.m_view:switchHeroTypeBtn(index)
		self.m_model.m_sel_her_index = index
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
