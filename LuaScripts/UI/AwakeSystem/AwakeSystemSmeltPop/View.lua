---
---@class AwakeSystemSmeltPopView:OOPopBase
---@field m_model AwakeSystemSmeltPopModel
local M = class("AwakeSystemSmeltPopView",LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemSmeltPop"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

local eqp_list = {} --材料列表緩存

local __TAB_BTN_NODE = {
    {btn_key = "items_togglebtn", lua_name = "", btn_text = "items_btn_text", text_key = "new_str_0041", open = true, red_point = "items_red_point_img", red_point_id = 1002}, -- 道具
    {btn_key = "equips_togglebtn", lua_name = "", btn_text = "equips_btn_text", text_key = "new_str_0042", open = true, open = true, red_point = "equips_red_point_img" }, -- 装备
    {btn_key = "pieces_togglebtn", lua_name = "", btn_text = "pieces_btn_text", text_key = "new_str_0043", open = false, red_point = "pieces_red_point_img", red_point_id = 1001 }, -- 灵魂石
    {btn_key = "all_togglebtn", lua_name = "", btn_text = "all_btn_text", text_key = "new_str_0044", open = true, red_point = "all_red_point_img", red_point_id = 1 }, -- 全部
    --{btn_key = "mystices_togglebtn", lua_name = "", btn_text = "mystices_btn_text", text_key = "new_str_0816", open = true, red_point = "mystices_red_point_img", red_point_id = 1003}, -- 秘籍
}


function M:onEnter()
    self:setTextByLanKey("close_title_text", "awake_system_text_005")
    self:setTextByLanKey("complete_text", "awake_system_text_009")
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, v.text_key)
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.gameObject:SetActive(v.open)
        self.m_toggle_btns[k] = tog_btn
        if k == self.m_model.m_open_tab_index then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
        self:setObjectVisible(v.red_point, false)
    end
    self.m_model:refreshListData(self.m_model.m_open_tab_index)
    self:switchTabNode(self.m_model.m_open_tab_index)
    self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:refreshUI()
    self:updateMaterialLoopScroll()
    self:updateResultLoopScroll()
    self:setObjectVisible("empty_bg_img",table.nums(self.m_model.m_material_data_list) == 0)
end

function M:switchTabNode(index, keep_offset)
    --self.m_select_cell_index = 1
    self:updateLoopScroll(keep_offset)
end

--[[
	创建列表
]]
function M:updateLoopScroll(keep_offset)
    eqp_list = {}
    local data = self.m_model:getShowData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("select_prop_node")
        local params = {
            show_data = data,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "sub_btn" then
                    self:updateMsg("remove_item", cell_data)
                else
                    self:updateMsg("add_item", cell_data)
                end
                if self.m_select_cell_object then
                    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell_object)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", false)    
                end 
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", true)
                self.m_select_cell_object = cell_object
                self.m_select_cell_index = index
                self.m_select_cell_data = cell_data
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, keep_offset)
    end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local user_num = data.data_type ~= RewardUtil.REWARD_TYPE_KEYS.EQUIPS and data.user_num or 1
    GameUtil:updateItemElementByData(cell_object, data, user_num > 1, false)
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_select_cell_index == index)
    local sub_btn = luaBehaviour:FindGameObject("sub_btn")
    local eqp_num = self.m_model:checkNumInList(data)
    if eqp_num > 0 then
        sub_btn:SetActive(true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"duigoudi_img",true)
        local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", eqp_num.."/"..user_num)
    else
        sub_btn:SetActive(false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"duigoudi_img",false)
        local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", user_num)
    end
    table.insert(eqp_list,{data = cell_data, obj = cell_object})
end

--更新选中装备信息
function M:setEqpCell()
    for k,v in pairs(eqp_list) do
        local eqp_num = self.m_model:checkNumInList(v.data)
        local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
        local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
        local sub_btn = luaBehaviour:FindGameObject("sub_btn")
        local user_num = v.data.data_type ~= RewardUtil.REWARD_TYPE_KEYS.EQUIPS and v.data.user_num or 1
        sub_btn:SetActive(false)
        if eqp_num > 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"duigoudi_img",true) 
            local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", eqp_num.."/"..user_num)
            sub_btn:SetActive(true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"duigoudi_img",false)
            local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", user_num)
            sub_btn:SetActive(false)
        end
        count_text_bg_img:SetActive(true)
    end
    self:refreshUI()
end

function M:updateMaterialLoopScroll(keep_offset)
    local data = self.m_model.m_material_data_list
    local can_show_data = {}
    for k,v in pairs(data) do
        table.insert(can_show_data,k)
    end
    if self.m_material_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("material_loopscroll")
        local params = {
            show_data = can_show_data,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end,
            ui_name = self.m_uiName
        }
        self.m_material_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_material_loop_scroll_view:reloadData(can_show_data, keep_offset)
    end
end

function M:updateResultLoopScroll(keep_offset)
    local reward_node = self:findGameObject("result_loopscroll")
    GameUtil:createRewards(reward_node.transform,self.m_model.m_result_data_list , true, false, nil, 1)
end

function M:updateCell(index, cell_object, cell_data)
    local data = cell_data
    local eqp_num = self.m_model:checkNumInList(cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    GameUtil:updateItemElementByData(cell_object, data, eqp_num > 1, false)
    LuaBehaviourUtil.setText(luaBehaviour, "count_text", eqp_num)
  
end

function M:destroy()
    M.super.destroy(self)
end

return M
