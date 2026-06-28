local M = class("DepositorySkillUpgradeView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "SutraDepository/MysticSkillUpgrade"

function M:onEnter()
	self:setTextByLanKey("jiefang_text", "mystic_str_0095")
	self:setCurMystic()
end


function M:setCurMystic()
	if self.m_model.m_mystic_cfg then
		local name = Language:getTextByKey(self.m_model.m_mystic_cfg.name)
		self:setTextByLanKey("name_text", "mystic_str_0096", name)

		local group_cfg = self.m_model:getMysticBuffGroup()
		if group_cfg and table.nums(group_cfg) > 0 then
			local group_skill_title_text = self:findText("group_skill_title_text")
			local mysticCfg = group_cfg[1] or {}
			group_skill_title_text.text = Language:getTextByKey(mysticCfg.name)
			self:setImg( mysticCfg.icon,"skill_icon","group_skill_img")
		end
		
		self:updateInsetSkillAttrLoopScroll()
	end
end

-- 奥义解放
function M:updateInsetSkillAttrLoopScroll()
	local data = self.m_model:getInsetSkillAttr()
	if next(data) == nil then
		self:setObjectVisible("inset_skill_attr_node", false)
	else
		self:setObjectVisible("inset_skill_attr_node", true)
	end
	if self.m_Inset_skill_attrs_scroll_view == nil then
		local loopscroll = self:findGameObject("inset_skill_attrs_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				local num = cell_data.num
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "vein_desc", cell_data.des)
				if num >= cell_data.condition[2] then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"jiaotou_img", true)
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 107/255, 243/255, 28/255, 1))
				else
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 1, 1, 1, 0.3))
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"jiaotou_img", false)
				end
			end,
		}
		self.m_Inset_skill_attrs_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_Inset_skill_attrs_scroll_view:reloadData(data)
	end
end

return M