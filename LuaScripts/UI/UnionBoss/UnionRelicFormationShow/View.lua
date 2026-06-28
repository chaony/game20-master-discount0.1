local M = class("UnionRelicFormationShowView",LikeOO.OOPopBase)

M.m_uiName = "UnionBoss/UnionRelicFormationShow"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("tips_text", "new_str_0162")
	self:setTextByLanKey("tips_text2", "new_str_0162")
	self:setTextByLanKey("title_text", "new_str_0182")
	self:setTextByLanKey("detail_text", "new_str_0183")
	self:setTextByLanKey("attr_add_title_text", "new_str_0274")
	self.person_obj = self:findGameObject("person_item_cell");
	self.union_obj = self:findGameObject("union_item_cell");
	local relic_combat_title_img = self:findGameObject("relic_combat_title_img")
	GameUtil:setLanImgText(relic_combat_title_img, "ui_zhan")
	self:refreshUI()
end

function M:refreshUI()
	local heirloom_num = self.m_model:getHeirloomNum()
	for k,v in pairs({7,5,3}) do
		local heirloom_num_item = heirloom_num[v] or {}
		self:setTextByLanKey("relic_num_text_" .. k, tostring(heirloom_num_item.num or 0))	
		local atkrating_ratio = heirloom_num_item.atkrating_ratio or 0
		local atkrating_ratio_str = tostring(atkrating_ratio or 0) .. "%"
		if atkrating_ratio >= 0 then
			atkrating_ratio_str = "+" .. atkrating_ratio_str
		end
		self:setTextByLanKey("attr_add_text_" .. k, atkrating_ratio_str)	
	end
	self:creatRelicList()
end

function M:creatRelicList()
	for k,v in pairs(self.m_model.m_heirlooms_data) do
		local item = self:ceratItem(v)
		item.transform:SetParent(self.person_obj.transform, false)
	end
	for k,v in pairs(self.m_model.m_guild_heirlooms) do
		local item = self:ceratItem(v)
		item.transform:SetParent(self.union_obj.transform, false)
	end
end

function M:ceratItem(data)
	local item = ResourceUtil:LoadUIGameObject("UnionBoss/UnionRelicItem", Vector3.zero, nil)
	UIUtil.setLocalScale(item.transform, 0.7, 0.7, 0.7)
	self:updateScrollViewCell(item, data)
	return item
end

function M:updateScrollViewCell(cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local cfg = data.cfg
	CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "combat_node", true)
	local atkrating_ratio = cfg.atkrating_ratio or 0
	local atkrating_ratio_str = tostring(atkrating_ratio) .. "%"
	if atkrating_ratio > 0 then
		atkrating_ratio_str = "+" .. atkrating_ratio_str
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", atkrating_ratio_str)
	local combat_title_img = luaBehaviour:FindGameObject("combat_title_img")
	GameUtil:setLanImgText(combat_title_img, "a_ui_zhanli")
end

return M