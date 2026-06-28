local M = class("ExclusiveWeaponsPopView",LikeOO.OOPopBase)

M.m_uiName = "ExclusiveWeapons/ExclusiveWeaponsPop"
M.m_size_type = 2
function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
    self.m_icon_node = self:findGameObject("icon_node")
	local go = GameUtil:createItemElement()
	GameUtil:updateExclusiveWeaponsInfo(go, self.m_model.m_heroid)
	go.transform:SetParent(self.m_icon_node.transform, false)
    self:setTextByLanKey("common_title_text", self.m_model.m_eqp_cfg.name)
    self:setTextByLanKey("hero_text", Language:getTextByKey(self.m_model.hero_cfg.name) .."-专属")
    self:setTextByLanKey("combat_text", "99999")
    self:setTextByLanKey("shuxing_text","专属装备属性 (动态)")
    self:setTextByLanKey("skill_name","专属装备技能：幽魂治愈")
    self:setTextByLanKey("skill_desc","专属装备技能：幽魂治愈幽魂治愈幽魂治愈幽魂治愈幽魂治愈幽魂治愈幽魂治愈幽")
    self:setTextByLanKey("eqp_info_text","专属装备描述")
    self:setTextByLanKey("intensify_text","强化")
    self:setTextByLanKey("eqp_count_text","专属装备描述信息")
    self:setTextByLanKey("skill_desc_1","专属装备技能描述信息")
    self:setTextByLanKey("skill_desc_2","专属装备技能描述信息")
	self:setTextByLanKey("skill_desc_3","专属装备技能描述信息")
    self:updateLoopScroll(self.m_model:getAttrs())
    if self.m_model.m_eqp_lv >= 30 then
        self:setObjectVisible("btns_node", false)
    else
        self:setObjectVisible("btns_node", true) 
    end
end


--[[	
	属性列表
]]
function M:updateLoopScroll(attrs)
    local data = UserDataManager:appendAttrs(attrs)
	local tab = {}
	for i, v in pairs(data) do
		table.insert(tab, {i, v})
	end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = tab,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local cp = GameUtil:getAttrsName(cell_data[1])
                local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
                local attr_add_value = UIUtil.setObjectVisible(transform, false, "attr_add_value_text")
				-- 四舍五入保留小数点后一位
				local attr_value = cell_data[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = UIUtil.setText(transform, tostring(attr_value), "attr_value_text")
				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

return M