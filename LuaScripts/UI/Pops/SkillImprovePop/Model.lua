local M = class("SkillImprovePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_skill_group = self.m_params.skill_improve
	self.m_click_transform = self.m_params.click_transform

	self.skillImproveGroup = ConfigManager:getCfgByName("skill_improve_group")
end

--获取技能信息
function M:getSkillById()
	return self.skillImproveGroup[self.m_skill_group]
end

return M
