local M = class("MagicWeaponSkillLvUpPopView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/MagicWeaponSkillLvUpPop"
M.m_size_type = true

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
	if self.m_model.l_wea_cfg == nil or self.m_model.m_wea_cfg == nil then
		return
	end
	local l_skill_icon, l_skill_name, l_skill_des = self.m_model:getSkillDataById(self.m_model.l_wea_cfg.skill_id)
	local m_skill_icon, m_skill_name, m_skill_des = self.m_model:getSkillDataById(self.m_model.m_wea_cfg.skill_id)
	self:setTextByLanKey("lv_text", self.m_model.m_c_lv)
	self:setTextByLanKey("lv_text2", self.m_model.m_c_lv+1)
	self:setTextByLanKey("skill_name_text", m_skill_name)
	self:setTextByLanKey("skill_des_text2", m_skill_des)
	self:setTextByLanKey("skill_des_text", l_skill_des)
	self:setTextByLanKey("common_title_text", "weapon_str_0010")
	self:setImg(l_skill_icon, "skill_icon", "skill_img")
	self:setImg(m_skill_icon, "skill_icon", "skill_img2")
	self:updateScroll()
end

function M:updateScroll()
    local data = self.m_model:getWeaAttr() or {}
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
            loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateItem(index, cell_object, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end

function M:updateItem(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		local next_num = self.m_model:getAttrNextById(cell_data[1])
		local atr_key = GameUtil:getAttrsKey(cell_data[1])
		local atr_name = GameUtil:getAttrsName(atr_key)
		local cur_num = cell_data[2] or 0
		if GameUtil:canPerAttrTransition(atr_key) == true then
			cur_num = cur_num*100
			next_num = next_num*100
		end
		local num2_text = nil
		if GameUtil:attrTransition(atr_key) == true then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", GameUtil:formatNum(cur_num).. "%")
			num2_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", GameUtil:formatNum(next_num).. "%")
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", GameUtil:formatNum(cur_num))
			num2_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", GameUtil:formatNum(next_num))
		end
		if next_num > cur_num then
			num2_text.color = Color.New(64/255, 118/255, 17/255)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
		else
			num2_text.color = Color.New(19/255, 27/255, 39/255)	
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", atr_name)
	
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M