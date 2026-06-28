---@class PrestigeBlockManager
local M = class("PrestigeBlockManager")
local __STEP_LENGTH = 50.4
local __BG_IMG_NAME = {
    "a_jhww_bjms_qizi_zi",
    "a_jhww_bjms_qizi_hong",
    "a_jhww_bjms_qizi_bai",
    "a_jhww_bjms_qizi_cai",
    "a_jhww_bjms_qizi_cai",
}

function M:init()
    self.prestige_blocks = {}
    self.m_block_cls = CustomRequire("UI.Prestige.PrestigeBlock")
    self.m_unit_cls = CustomRequire("UI.Prestige.PrestigeBlockUnit")
    self.m_block_shape_cfg = ConfigManager:getCfgByName("prestige_piece_shape")
end

function M:setData(control)
    self.m_control = control
end

function M:generateNormalBlock(block_data, grid_obj)
    return self:generateBlock(block_data, grid_obj, false)
end

function M:generateMiniBlock(block_data, grid_obj)
    return self:generateBlock(block_data, grid_obj, true)
end

function M:generateBlock(block_data, grid_obj, is_mini_shape)
    local params = {
        block_data = block_data,
        is_mini_shape = is_mini_shape,
        shape = block_data.shape,
    }
    local block = self.m_block_cls.new(self.m_control, {parent = grid_obj, data = params })
    local block_luaBehaviour = block.m_luaBehaviour
    local block_btn_obj = block_luaBehaviour:FindGameObject("block_btn")
    local shape_cfg = self.m_block_shape_cfg[block_data.shape]
    local all_units = {}
    
    for i = 0,5 do
        all_units[i] = {}
    end
    for _,v in ipairs(shape_cfg.block_id) do
        local pos_index_x = v[1]
        local pos_index_y = v[2]
        local unit = {}
        unit.pos = Vector2(pos_index_x, pos_index_y)
        all_units[pos_index_x][pos_index_y] = unit
    end

    local check_list = {}
    local cur_check_index = 1
    local unit_id_num = 1
    
    local anchor_unit = all_units[shape_cfg.anchor_point[1]][shape_cfg.anchor_point[2]]
    local anchor_id = tostring(unit_id_num)
    local anchor_unit_obj = block_luaBehaviour:FindGameObject("anchor_unit")
    anchor_unit.id = anchor_id
    anchor_unit.obj = anchor_unit_obj
    anchor_unit.luaBehaviour = anchor_unit_obj:GetComponent("LuaBehaviour")
    table.insert(check_list, anchor_unit)
    unit_id_num = unit_id_num + 1
    
    local cur_unit = check_list[cur_check_index]
    while cur_unit ~= nil do
        if not is_mini_shape then
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "hero_img", true)
            LuaBehaviourUtil.setImg(cur_unit.luaBehaviour, "hero_img", "TX_" .. block_data.hero, "hero_head_ui")
        else
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "hero_img", false)
        end
        local star = self.m_block_shape_cfg[block_data.shape].star
        LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "bg_img", true)
        LuaBehaviourUtil.setImg(cur_unit.luaBehaviour, "bg_img", __BG_IMG_NAME[star], "maze_stage_ui")
        
        local cur_unit_position = cur_unit.obj.transform.localPosition
        local up_unit = all_units[cur_unit.pos.x - 1][cur_unit.pos.y]
        local down_unit = all_units[cur_unit.pos.x + 1][cur_unit.pos.y]
        local left_unit = all_units[cur_unit.pos.x][cur_unit.pos.y - 1]
        local right_unit = all_units[cur_unit.pos.x][cur_unit.pos.y + 1]

        if up_unit ~= nil then
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "edge_up", false)
            if up_unit.obj == nil then
                table.insert(check_list, up_unit)
                local id = tostring(unit_id_num)
                up_unit.id = id
                local unit_instance = self.m_unit_cls.new(self.m_control, { parent = block_btn_obj})
                up_unit.obj = unit_instance.m_rootView
                up_unit.obj.transform.localPosition = Vector3(cur_unit_position.x, cur_unit_position.y + __STEP_LENGTH, cur_unit_position.z)
                up_unit.luaBehaviour = up_unit.obj:GetComponent("LuaBehaviour")
                unit_id_num = unit_id_num + 1
            end
        end
        
        if down_unit ~= nil then
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "edge_down", false)
            if down_unit.obj == nil then
                table.insert(check_list, down_unit)
                local id = tostring(unit_id_num)
                down_unit.id = id
                local unit_instance = self.m_unit_cls.new(self.m_control, { parent = block_btn_obj})
                down_unit.obj = unit_instance.m_rootView
                down_unit.obj.transform.localPosition = Vector3(cur_unit_position.x, cur_unit_position.y - __STEP_LENGTH, cur_unit_position.z)
                down_unit.luaBehaviour = down_unit.obj:GetComponent("LuaBehaviour")
                unit_id_num = unit_id_num + 1
            end
        end
        
        if left_unit ~= nil then
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "edge_left", false)
            if left_unit.obj == nil then
                table.insert(check_list, left_unit)
                local id = tostring(unit_id_num)
                left_unit.id = id
                local unit_instance = self.m_unit_cls.new(self.m_control, { parent = block_btn_obj})
                left_unit.obj = unit_instance.m_rootView
                left_unit.obj.transform.localPosition = Vector3(cur_unit_position.x - __STEP_LENGTH, cur_unit_position.y, cur_unit_position.z)
                left_unit.luaBehaviour = left_unit.obj:GetComponent("LuaBehaviour")
                unit_id_num = unit_id_num + 1
            end
        end
        
        if right_unit ~= nil then
            LuaBehaviourUtil.setObjectVisible(cur_unit.luaBehaviour, "edge_right", false)
            if right_unit.obj == nil then
                table.insert(check_list, right_unit)
                local id = tostring(unit_id_num)
                right_unit.id = id
                local unit_instance = self.m_unit_cls.new(self.m_control, { parent = block_btn_obj})
                right_unit.obj = unit_instance.m_rootView
                right_unit.obj.transform.localPosition = Vector3(cur_unit_position.x + __STEP_LENGTH, cur_unit_position.y, cur_unit_position.z)
                right_unit.luaBehaviour = right_unit.obj:GetComponent("LuaBehaviour")
                unit_id_num = unit_id_num + 1
            end
        end

        cur_check_index = cur_check_index + 1
        cur_unit = check_list[cur_check_index]
    end

    if is_mini_shape then
        local transform = block:getTransform()
        transform.localScale = Vector3(0.5, 0.5, 1)
    else
        local transform = block:getTransform()
        transform.localScale = Vector3(0.9, 0.9, 1)
        self.prestige_blocks[block.id] = block
    end
    block:initBlockUnitData(check_list)
    return block
end

function M:getBlockByID(id)
    return self.prestige_blocks[id]
end

function M:resetBlockData(blocks_data)
    for id,_ in pairs(self.prestige_blocks) do
        local block_data = blocks_data[id]
        if block_data then
            local block = self.prestige_blocks[id]
            block:resetData(block_data)
        else 
            self:clearBlock(id)
        end
    end
end

function M:clearBlock(id)
    local block = self.prestige_blocks[id]
    if block then
        block:destroy()
        self.prestige_blocks[id] = nil
    end
end

function M:clearExpiredBlocks(expired_block_ids)
    for _, id in ipairs(expired_block_ids) do
        self:clearBlock(id)
    end
end

function M:clearAllBlocks()
    for id, block in pairs(self.prestige_blocks) do
        block:destroy()
        self.prestige_blocks[id] = nil
    end
end

return M
