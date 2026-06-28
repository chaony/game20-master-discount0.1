local M = class("MeridianSkillPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_desc = self.m_params.desc
	self.m_click_transform = self.m_params.click_transform
end



--技能描述
function M:getSkillBaseDesc()
	local lv_desc = ""

	return lv_desc
end

return M
