--- 技能信息展示
local M = class("SkillImproveInfo",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/SkillImproveInfo"
M.m_sortOrder = 9999

function M:onCreate()
	self.m_content = self:findGameObject("content")
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	elseif name == "change_btn" then
		local function callfunc()
			UserDataManager.skillImprove_data:setCurId(self.m_params.heroId, self.m_params.groupId)
			self:setObjectVisible("change_btn", false)
			self.m_control.m_view.m_cur_tab_node:setSkillInfo()
			self:destroy()
		end
		self.m_model:getNetData("choose_improve",{ hero_id = self.m_params.heroId, group_id = self.m_params.groupId }, callfunc)
	end
end

function M:onEnter()
	local groupTable = ConfigManager:getCfgByName("skill_improve_group")
	self.data = groupTable[self.m_params.groupId]
	
	self:refreshUI()
end

function M:refreshUI()
	--self.m_des_text = self:setTextByLanKey("des_text", msg)
	self:setTextByLanKey("skill_title_text", self.data.name)
	self:setTextByLanKey("content_text", self.data.des)
	local skillImprove = UserDataManager.skillImprove_data.m_skillImprove[self.m_params.heroId]
	if skillImprove ~= nil and skillImprove.cur_id == self.m_params.groupId then
		self:setObjectVisible("state_text", true)
		self:setObjectVisible("change_btn", false)
	else
		self:setObjectVisible("state_text", false)
		if skillImprove == nil or table.indexof(skillImprove.groups, self.m_params.groupId) == false then
			self:setObjectVisible("change_btn", false)
		else
			self:setObjectVisible("change_btn", true)
		end
	end
	
	self.m_click_transform = self.m_params.click_transform
	if self.m_click_transform then
		local mousePosition = U3DUtil:GetMousePosition()
		mousePosition.x = mousePosition.x / U3DUtil:Screen_Width() * 1280 - 640 - self.m_content.transform.rect.width/2
		mousePosition.y = mousePosition.y / U3DUtil:Screen_Height() * 720 - 360 + self.m_content.transform.rect.height/2
		self.m_content.transform.localPosition = mousePosition
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M