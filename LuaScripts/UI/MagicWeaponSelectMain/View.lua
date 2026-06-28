local M = class("MagicWeaponSelectMainView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeaponSelectMain/MagicWeaponSelectMain"
M.m_iphoneXAdapter = true
M.m_size_type = 2 -- 1隐藏下层ui，2不隐藏
M.TAB_BTN = {
    {node = "magic_weapon_node",open_id = 190, bnt_key = "magic_weapon_btn", red_point_img = "m_w_red_point", name_key = "m_w_name", name_text = "weapon_str_0002", open = true},--法宝 古物殿
    {node = "equip_awaken_node",open_id = 220, bnt_key = "equip_awaken_btn", red_point_img = "e_a_red_point", name_key = "e_a_name", name_text = "art_str_004", open = true},--觉醒 神兵殿
   -- {node = "artifact_node", bnt_key = "artifact_btn", red_point_img = "art_red_point", name_key = "art_name", name_text = "art_str_002", open = false},--神兵
    {node = "mystic_node",open_id = 147, bnt_key = "mystic_btn", red_point_img = "mystic_red_point", name_key = "mystic_name", name_text = "mystic_str_0001", open = false},--秘籍
    {node = "destinyStar_node",open_id = 256, bnt_key = "destinyStar_btn", red_point_img = "destinyStar_red_point", name_key = "destinyStar_name", name_text = "destinyStar_text_0001", open = false},--天命化星
    {node = "heavenEarth_node",open_id = 338, bnt_key = "heavenEarth_btn", red_point_img = "heavenEarth_red_point", name_key = "heavenEarth_name", name_text = "heavenEarth_text_001", open = false},--天命化星
    {node = "echo_node",open_id = 0, bnt_key = "echo_btn", red_point_img = "echo_red_point", name_key = "echo_name", name_text = "echo_text_001", open = true},--共鸣斋
}

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 16})
    for k,v in pairs(self.TAB_BTN) do
        if v.open_id then
            local red_flag = v.open_id > 0 and RedPointUtil:isFuncRedPointById(v.open_id) or false
            local open_flag = v.open_id > 0 and BtnOpenUtil:isBtnOpen(v.open_id) or true
            self:setObjectVisible(v.node, open_flag == true)
            self:setObjectVisible(v.red_point_img, red_flag == true and open_flag == true)
        end
        self:setText(v.name_key,Language:getTextByKey(v.name_text))
    end
    self:setTextByLanKey("close_title_text", "new_str_0420")
    self:setObjectVisible("mystic_btn_finger_sp", false)
    --快速导航
    self:setObjectVisible("guide_btn", true)

    self:refreshUI()
end

function M:refreshUI()
    for k,v in pairs(self.TAB_BTN) do
        if v.open_id then
            local red_flag = RedPointUtil:isFuncRedPointById(v.open_id)
            self:setObjectVisible(v.red_point_img, red_flag == true)
        end
    end

    local mystic_inset = BtnOpenUtil:isBtnOpen(337)
    if mystic_inset then
        local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_magic_finger", 1)
        self:setObjectVisible("mystic_btn_finger_sp", show_finger == 1)
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