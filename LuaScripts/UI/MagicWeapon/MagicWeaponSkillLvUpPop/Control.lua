local M = class("MagicWeaponSkillLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "ok_btn" then
		if self.m_model.m_call_func then
			self.m_model.m_call_func()
		end
		self:closeView()
	end
end


return M
