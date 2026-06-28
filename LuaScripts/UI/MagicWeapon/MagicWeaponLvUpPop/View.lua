local M = class("MagicWeaponLvUpPopView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/MagicWeaponLvUpPop"
M.m_size_type = true

function M:onEnter()
    
end

function M:refreshUI()
	-- if self.m_model.l_wea_cfg == nil or self.m_model.m_wea_cfg == nil then
	-- 	return
	-- end
	-- self:setTextByLanKey("wea_skill_text", self.m_model.l_wea_cfg.name)
	-- self:setTextByLanKey("wea_skill_text2", self.m_model.m_wea_cfg.name)
	-- self:setTextByLanKey("skill_des_text", self.m_model.l_wea_cfg.skill_des)
	-- self:setTextByLanKey("skill_des_text2", self.m_model.m_wea_cfg.skill_des)
	-- local l_skill_icon, l_skill_name = self.m_model:getSkillDataById(self.m_model.l_wea_cfg.skill_id)
	-- local m_skill_icon, m_skill_name = self.m_model:getSkillDataById(self.m_model.m_wea_cfg.skill_id)
	-- self:setTextByLanKey("wea_skill_text", l_skill_name)
	-- self:setTextByLanKey("wea_skill_text2", m_skill_name)
	-- self:setImg(l_skill_icon, "skill_icon", "skill_icon")
	-- self:setImg(m_skill_icon, "skill_icon", "skill_icon2")
	-- self:updateScroll()
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
		if GameUtil:attrTransition(atr_key) == true then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", GameUtil:formatNum(cur_num).. "%")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", GameUtil:formatNum(next_num).. "%")
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", GameUtil:formatNum(cur_num))
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", GameUtil:formatNum(next_num))
		end
		if next_num > cur_num then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"add_img", true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"add_img", false)	
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", atr_name)
	
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M