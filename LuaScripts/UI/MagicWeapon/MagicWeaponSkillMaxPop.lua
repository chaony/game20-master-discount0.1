--- 法宝等级属性信息
local M = class("MagicWeaponSkillMaxPopNode",LikeOO.OOUIbase)

M.m_uiName = "MagicWeapon/MagicWeaponSkillMaxPop"
M.m_sortOrder = 19999

function M:onCreate()
	self.m_content = self:findGameObject("content_node")
	self.m_content:SetActive(false)
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	local lv = self.m_params.lv or 1
	local m_wea_id = self.m_params.wea_id
	self.m_call_func = self.m_params.call_func
	self:setTextByLanKey("next_text", "weapon_str_0013")
	self:setTextByLanKey("max_text", "weapon_str_0014")
	local wea_cfg = self:getTreasureConfig(m_wea_id)
	local next_wea_cfg = wea_cfg.detail[lv+1] or wea_cfg.detail[1]
	local max_wea_cfg = wea_cfg.detail[next_wea_cfg.skill_limit] or wea_cfg.detail[1]
	local next_skill_cfg = self:getSkillDataById(next_wea_cfg.skill_id)
	local max_skill_cfg = self:getSkillDataById(max_wea_cfg.skill_id)
	self:setTextByLanKey("next_skill_name_text", next_skill_cfg.name)
	self:setTextByLanKey("next_skill_lv", lv+1)
	self:setTextByLanKey("next_skill_des_text", next_skill_cfg.des)
	self:setImg(next_skill_cfg.icon, "skill_icon", "next_skill_icon")
	self:setTextByLanKey("max_skill_name_text", max_skill_cfg.name)
	self:setTextByLanKey("max_skill_lv", next_wea_cfg.skill_limit)
	self:setTextByLanKey("max_skill_des_text", max_skill_cfg.des)
	self:setImg(max_skill_cfg.icon, "skill_icon", "max_skill_icon")
	if next_wea_cfg.att then
		for i = 1,3 do
			if next_wea_cfg.att[i] then
				local cur_atr_data = next_wea_cfg.att[i]
				self:updateAttrItem(i, cur_atr_data)
			end
		end
	end
	if max_wea_cfg.att then
		for i = 1,3 do
			if max_wea_cfg.att[i] then
				local cur_atr_data  = max_wea_cfg.att[i]
				self:updateAttrItem(i+3, cur_atr_data)
			end
		end
	end
	self:refreshUI()
end

function M:refreshUI()
	self.m_content:SetActive(true)
end


--属性信息
function M:updateAttrItem(index, cell_data)
	local atr_key = GameUtil:getAttrsKey(cell_data[1])
	local atr_name = GameUtil:getAttrsName(atr_key)
	local cur_num = cell_data[2] or 0
	if GameUtil:canPerAttrTransition(atr_key) == true then
		cur_num = cur_num*100
	end
	if GameUtil:attrTransition(atr_key) == true then 
		self:setTextByLanKey("next_attr_num_text"..index, GameUtil:formatNum(cur_num).."%")
	else
		self:setTextByLanKey("next_attr_num_text"..index, GameUtil:formatNum(cur_num))
	end
	self:setTextByLanKey("next_attr_name_text"..index, atr_name)
end

--法宝信息
function M:getTreasureConfig(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_config")
	return tab_cfg[index]
end

--技能信息
function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[id]
end

function M:destroy()
	if self.m_call_func then
		self.m_call_func()
	end
	M.super.destroy(self)
end

return M