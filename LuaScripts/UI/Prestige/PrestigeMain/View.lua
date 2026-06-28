---@class PrestigeMainView : OOPopBase
local M = class("PrestigeMainView", LikeOO.OOPopBase)

M.m_uiName = "Prestige/PrestigeMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

-- 1金 2火 3木 4水
local __BOARD_TAB_BTN_NODE = {
    {race = "gold", btn_key = "toggle_gold", effect_key = "selected_effect_gold", locked_key = "locked_gold"},  -- 代表 race 1
    {race = "wood", btn_key = "toggle_wood", effect_key = "selected_effect_wood", locked_key = "locked_wood"},  -- 代表 race 3
    {race = "water", btn_key = "toggle_water", effect_key = "selected_effect_water", locked_key = "locked_water"},  -- 代表 race 4
    {race = "fire", btn_key = "toggle_fire", effect_key = "selected_effect_fire", locked_key = "locked_fire"},  -- 代表 race 2
    {race = "yang", btn_key = "toggle_yang", effect_key = "selected_effect_yang", locked_key = "locked_yang"},  -- 代表 race 5
    {race = "yin", btn_key = "toggle_yin", effect_key = "selected_effect_yin", locked_key = "locked_yin"},  -- 代表 race 6
    {race = "yuan", btn_key = "toggle_yuan", effect_key = "selected_effect_yuan", locked_key = "locked_yuan"},  -- 代表 race 7
}
local _extra1_atts_ui = {{text_name = "extra1_text",text_num = "extra1_num"},{text_name = "extra2_text",text_num = "extra2_num"}}

function M:onEnter()
    local init_board_type = PrestigeUtil.cur_board_type
    self.m_grid_obj = self:findGameObject("grid")
    self.m_hero_spine_obj = self:findGameObject("hero_spine")
    self.m_skeleton_graphic = self:findSkeletonGraphic("hero_spine")
    self.m_slot_parent_obj = self:findGameObject("slots")
    self.m_level_text = self:findText("board_level_text")
    self:setTextByLanKey("bag_text", "prestige_text_014")
    self:setTextByLanKey("hero_lv_text", "new_str_0436")
    self:setTextByLanKey("edit_text", "prestige_text_015")
    self:setTextByLanKey("upgrade_btn_text", "prestige_text_016")
    self:setTextByLanKey("fetter_text", "prestige_jiban_text_001")
    self:setObjectVisible("hero", true)
    self:setObjectVisible("board_complete_effect", false)
    self:initSlots()
    self:initTabNodeState(init_board_type)
    self:refreshUI(init_board_type, self.m_model.is_from_editor, self.m_model.is_just_complete)
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 43})
    
end

function M:refreshUI(board_type, is_from_editor, is_just_complete)
    self:switchTabNode(board_type)
    self:updateBoardInfo(board_type)
    self:updateBoardView(board_type, is_from_editor, is_just_complete)
end

-- 棋盘类型按钮
function M:initTabNodeState(board_type)
    for k,v in pairs(__BOARD_TAB_BTN_NODE) do
        local is_on = k == board_type
        self:setObjectVisible(v.effect_key, is_on)
        local is_unlocked = PrestigeUtil:isBoardUnlocked(k)
        self:setObjectVisible(v.locked_key, not is_unlocked)
        local toggle_btn = self:findToggle(v.btn_key)
        local function updateToggle(is_on)
            self:switchTabUpdate(is_on, k)
        end
        UIUtil.addToggleListener(toggle_btn, updateToggle, nil, self.m_uiName)
    end
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:switchTabNode(board_type)
    for k,v in pairs(__BOARD_TAB_BTN_NODE) do
        local is_on = k == board_type
        self:setObjectVisible(v.effect_key, is_on)
    end
end

-- 盘面显示
function M:initSlots()
    self.slots = {}
    self.m_slot_cls = CustomRequire("UI.Prestige.PrestigeMainSlot")
    for i = 1, PrestigeUtil.slot_count_per_line do
        for j = 1, PrestigeUtil.slot_count_per_line do
            local slot = self.m_slot_cls.new(self.m_control, {parent = self.m_slot_parent_obj})
            table.insert(self.slots, slot)
        end
    end
end

function M:updateBoardView(board_type, is_from_editor, is_just_complete)
    local is_complete = PrestigeUtil:isBoardComplete(board_type)
    self:updateHeroSpine(board_type, is_complete)
    self:setObjectVisible("grid", not is_complete)
    
    if is_from_editor then
        if is_just_complete then
            self:setObjectVisible("board_complete_effect", true)
        end
        
        local index = 0
        local available_slots = PrestigeUtil:getAvailableSlots(board_type)
        local locked_slots = PrestigeUtil:getLockedSlots(board_type)
        local pre_board_data = PrestigeUtil:getBoardDataBeforeEdit(board_type)
        local cur_board_data = PrestigeUtil:getBoardData(board_type)
        local pre_coordinate_data = pre_board_data.coordinate
        local cur_coordinate_data = cur_board_data.coordinate
        for i = 1, PrestigeUtil.slot_count_per_line do
            for j = 1, PrestigeUtil.slot_count_per_line do
                index = index + 1
                local slot = self.slots[index]
                if not available_slots[i] or not available_slots[i][j] then
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.UNAVAILABLE)
                elseif locked_slots[i] and locked_slots[i][j] then
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.LOCKED)
                    slot:setUnlockLevel(locked_slots[i][j])
                elseif cur_coordinate_data[i][j] then
                    if pre_coordinate_data[i][j] then
                        slot:setState(PRESTIGE_MAIN_SLOT_STATE.OCCUPIED)
                    else
                        slot:animToUnlock()
                    end
                else
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.UNOCCUPIED)
                end
            end
        end
    else
        local index = 0
        local available_slots = PrestigeUtil:getAvailableSlots(board_type)
        local locked_slots = PrestigeUtil:getLockedSlots(board_type)
        local board_data = PrestigeUtil:getBoardData(board_type)
        local coordinate_data = board_data.coordinate
        -- 遍历棋盘网格
        for i = 1, PrestigeUtil.slot_count_per_line do
            for j = 1, PrestigeUtil.slot_count_per_line do
                index = index + 1
                local slot = self.slots[index]
                if not available_slots[i] or not available_slots[i][j] then
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.UNAVAILABLE)
                elseif locked_slots[i] and locked_slots[i][j] then
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.LOCKED)
                    slot:setUnlockLevel(locked_slots[i][j])
                elseif coordinate_data[i][j] then
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.OCCUPIED)
                else
                    slot:setState(PRESTIGE_MAIN_SLOT_STATE.UNOCCUPIED)
                end
            end
        end
    end
end

-- 英雄 Spine
function M:updateHeroSpine(board_type, is_complete)
    local hero_cfg = self.m_model:getHeroCfg(board_type)
    local spine_name = "RoleSpine/" .. hero_cfg.hero_spine
    GameUtil:updateSpineLoadSet(self.m_hero_spine_obj, spine_name, "idle", 0, true)
    if is_complete then
        self.m_skeleton_graphic.AnimationState:SetAnimation(0, "idle", true)
    else
        self.m_skeleton_graphic.AnimationState:ClearTracks()    
    end
end

-- 棋盘属性
function M:updateBoardInfo(board_type)
    self.m_model:getPrestigeAttr()
    local board_data = PrestigeUtil:getBoardData(board_type)
    self.m_level_text.text = tostring(board_data.level)
    local board_name = self.m_model:getBoardTitle(board_type)
    self:setTextByLanKey("board_title", board_name)
    local cost_item1, cost_item2,attr,score,max_level = self.m_model:getUpgradeCost()
    self:setObjectVisible("res_blue_block", cost_item1 ~= nil)
    self:setObjectVisible("res_purple_block", cost_item2.data_num ~= 0)
    if max_level == board_data.level then
        self:setObjectVisible("board_upgrade",false)
        self.m_level_text.text = Language:getTextByKey("prestige_up_text_001")
    else
        self:setObjectVisible("board_upgrade",true)
    end
    self:setText("blue_block_text", cost_item1.data_num)
    if cost_item2.data_num ~= 0 then
        self:setText("purple_block_text", cost_item2.data_num)
    end
    --hp_num  attack_num  def_num  
    score = score + self.m_model.m_pieces_score + self.m_model.m_fetter_score
    local board_attrs = UserDataManager:newAppendAttrs(attr)
    self:setTextByLanKey("attack_text", "new_str_0392")
    self:setTextByLanKey("hp_text", "fb_str_0028")
    self:setTextByLanKey("def_text", "new_str_0505")
    self:setTextByLanKey("hp_num", board_attrs[902])
    self:setTextByLanKey("attack_num", board_attrs[901])
    self:setTextByLanKey("def_num", board_attrs[903])
    self:setTextByLanKey("score_text", score)
    local m_hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    local extra_attrs = {}
    local extra_name = {}
    if board_attrs[1901] then
        table.insert(extra_name,m_hero_enumeration_cfg[1901].name)
        table.insert(extra_attrs,board_attrs[1901])
    end
    if board_attrs[1902] then
        table.insert(extra_name,m_hero_enumeration_cfg[1902].name)
        table.insert(extra_attrs,board_attrs[1902])
    end
    if board_attrs[1903] then
        table.insert(extra_name,m_hero_enumeration_cfg[1903].name)
        table.insert(extra_attrs,board_attrs[1903])
    end
    for k,v in ipairs(_extra1_atts_ui) do
        if extra_attrs[k] ~= nil then
            self:setObjectVisible(_extra1_atts_ui[k].text_name,true)
            self:setObjectVisible(_extra1_atts_ui[k].text_num, true)
            self:setTextByLanKey(_extra1_atts_ui[k].text_num,extra_attrs[k] .."%")
            self:setTextByLanKey(_extra1_atts_ui[k].text_name, extra_name[k])
        else
            self:setObjectVisible(_extra1_atts_ui[k].text_name,false)
            self:setObjectVisible(_extra1_atts_ui[k].text_num, false)
        end
       
    end
    
end

function M:getGridObj()
    return self.m_grid_obj
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M