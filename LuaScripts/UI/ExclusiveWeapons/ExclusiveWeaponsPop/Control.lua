local M = class("ExclusiveWeaponsPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "intensify_btn" then
        self:openView("ExclusiveWeapons", {hero_id = self.m_model.m_heroid, lv = self.m_model.m_eqp_lv})
        self:closeView()
    elseif msg == "check1_btn" then
        self:openView("ExclusiveWeapons.ExclusiveHintPop")
    elseif msg == "check2_btn" then
        self:openView("ExclusiveWeapons.ExclusiveSkillPop")
	end
end

return M
