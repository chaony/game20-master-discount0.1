local M = class("DepositoryGropSkillTipsView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticGropSkillTips"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("ok_btn_text", "mystic_str_0042")
	self:refreshUI()	
end

function M:refreshUI()
	local buff_cfg = {}
	local buff_ids = {}
	local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
	buff_ids = UserDataManager.mystic_data:getMysticEfficientSkill(self.m_model.m_id)
	for m, n in pairs(buff_ids) do
		if mystic_buff_cfg[n] then
			table.insert(buff_cfg, mystic_buff_cfg[n])
		end
	end

	if #buff_ids == 1 then
		self:setTextByLanKey("skill_name_text", buff_cfg[1].name)
		local text = Language:getTextByKey(buff_cfg[1].des)
		self:setTextByLanKey("skill_des_2", text)
		self:setObjectVisible("skill_des_1", false)
		self:setObjectVisible("skill_des_2", true)
	else
		self:setTextByLanKey("skill_name_text", buff_cfg[1].name)
		for i = 1, 2 do
			local buff_des = buff_cfg[i].des
			if i == 1 then
				buff_des = Language:getTextByKey(buff_cfg[i].des).."\n"..Language:getTextByKey(buff_cfg[i].des_class)
			end
			self:setTextByLanKey("skill_des_"..i, buff_des)
			self:setObjectVisible("skill_des_1", true)
			self:setObjectVisible("skill_des_2", false)
		end
	end
	
	self:findGameObject("skill_des_1"):GetComponent('ContentSizeFitter'):SetLayoutVertical();
	self:findGameObject("skill_des_2"):GetComponent('ContentSizeFitter'):SetLayoutVertical();
	self:findGameObject("content_node"):GetComponent('ContentSizeFitter'):SetLayoutVertical();
end

return M