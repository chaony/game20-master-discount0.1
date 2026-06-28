local M = class("HuntTreasuresAreaPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasures/HuntTreasuresAreaPop"
M.m_size_type = 2
local __flag_img = {is_guild = "a_mjxb_youfang", is_enemy = "a_mjxb_choujia"}
local __lan_atlas = ResourceUtil:getLanAtlas()
local _max_owners = 9
function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self:setTextByLanKey("common_title_text", "hunt_treasure_str_011")
    self:setTextByLanKey("big_map_btn_text", "hunt_treasure_str_029")
    self:setTextByLanKey("arena_btn_text", "hunt_treasure_str_011")
    self.m_toggle_btns = {}
    self.m_area_cell_tabs = {}
    self:updateLeftLoopScroll()
    self:refreshUI()
    self:refreshCellStatus()
    self.m_left_loop_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
    self.m_loop_scroll_view:moveToCellIndex(self.m_model.m_defautl_index)
    self.m_left_server_open_text = nil
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI(tips_str)
    self:setText("unlock_des_text", "")
    if tips_str then
        self:setObjectVisible("loopscroll", false)
        self:setObjectVisible("unlock_des_text", false)
    else
        self:setObjectVisible("loopscroll", true)
        self:setObjectVisible("unlock_des_text", false)
        self:updateLoopScroll()
        local guide_info = UserDataManager.guide_data:getCurGuideInfo()
        local data, jump_index = self.m_model:getLeftShowData()
        if UserDataManager.guide_data:isGuiding() and guide_info.key == "HuntTreasuresAreaPop" then
            jump_index = 1
        end
        self.m_loop_scroll_view:moveToCellIndex(jump_index)
    end
end
--[[
	创建列表
]]
local color_value = {  Color( 142/255, 92/255, 82/255, 1), Color( 81/255, 112/255, 153/255), Color( 88/255, 126/255, 127/255), Color( 71/255, 126/255, 172/255)}
local combat_bg_tab = {"a_mjmb_btn_xyzdl", "a_mjmb_btn_dhzdl", "a_mjmb_btn_nkzdl", "a_mjmb_btn_blzdl"}
function M:updateLeftLoopScroll()
    local data, jump_index = self.m_model:getLeftShowData()
    if self.m_left_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("left_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
               self:updateCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                local unlock_id = cell_data[1].unlock
                local type = cell_data[1].type -- 地区类型 1 自己 2 所有人 3 跨服
                local open_flag, tips_str = self.m_model:isOpenByStage(unlock_id)
                if type == 3 and open_flag then
                    local cross_team, cross_time = self.m_model:getCrossData()
                    if cross_team > 0  then
                        open_flag = true
                    elseif cross_time > 0 and cross_time - UserDataManager:getServerTime() > 0  then
                        local time = GameUtil:formatTimeBySecond(cross_time - UserDataManager:getServerTime())
                        tips_str = Language:getTextByKey("hunt_treasure_str_052", time)
                        open_flag = false
                    end
                end
                if open_flag then
                    self:updateMsg("left_item_click", {index = index,open_flag = open_flag, tips_str = tips_str})
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_left_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_left_loop_scroll_view:reloadData(data)
    end
end

function M:updateCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local back_img = luaBehaviour:FindImage("back_img")
    local combat_bg_img = luaBehaviour:FindImage("combat_bg_img")
    local img_name = self.m_model:getLeftImgName(index)
    local combat_bg_img_name = combat_bg_tab[self.m_model.m_region_id]
    if img_name ~= "" then
        GameUtil:updateResourcesImg(back_img, "Texture/hunt_treasures/" .. img_name)
    end
    LuaBehaviourUtil.setImg(luaBehaviour,"combat_bg_img", combat_bg_img_name, "mystic_ui")
   
    local open_flag, tips_str = self.m_model:isUnlockByAreaData(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "region_name_text", open_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_des_text", not(open_flag))
    local region_name = self.m_model:getRegionNameById(index)
    local name_text =  LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "region_name_text", region_name)
    local unlock_des_text = LuaBehaviourUtil.setText(luaBehaviour, "unlock_des_text", tips_str)
    name_text.color = color_value[self.m_model.m_region_id]
    unlock_des_text.color = color_value[self.m_model.m_region_id]
    local combat_des = Language:getTextByKey("new_str_0873") .. ":" ..  GameUtil:formatValueToString(cell_data[1].battle_nub)
    LuaBehaviourUtil.setText(luaBehaviour, "combat_text", combat_des)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image1", index == self.m_model.m_sel_tab_index)

    local type = cell_data[1].type -- 地区类型 1 自己 2 所有人 3 跨服
    if type == 3 and self.m_left_server_open_text == nil then
        self.m_left_server_open_text = unlock_des_text
    end
end

function M:refreshCellStatus()
    local cache_cells = self.m_left_loop_scroll_view.m_cache_cells or {}
    for i, cell_object in pairs(cache_cells) do
        local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image1", i == self.m_model.m_sel_tab_index)
    end
end

function M:updateTime()
    local cross_team, cross_time = self.m_model:getCrossData()
    if cross_team <= 0 and cross_time > 0 and cross_time -  UserDataManager:getServerTime() > 0 and self.m_left_server_open_text then
        local time = GameUtil:formatTimeBySecond(cross_time -  UserDataManager:getServerTime() )
        self.m_left_server_open_text = Language:getTextByKey("hunt_treasure_str_052", time)
    elseif cross_team <= 0 and cross_time > 0 and cross_time -  UserDataManager:getServerTime() <= 0 then
        self:updateMsg("refresh_index")
    end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getAreaByRegionId(self.m_model.m_sel_tab_index)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            --one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self.m_area_cell_tabs[index] = cell_object
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("item_click", {index = index})
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateItemInfo(obj, data, id)
    local location_data = self.m_model:getLocationNetData(data.id)
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local unlock_stage = data.unlock
    local open_flag, tips_str = self.m_model:isOpenByStage(unlock_stage)
    local Background = luaBehaviour:FindImage("Image")
    local quality_img = luaBehaviour:FindImage("quality_img")
    local gaung_img = luaBehaviour:FindImage("gaung_img")
    if open_flag then
        Background.material = nil
        quality_img.material = nil
        gaung_img.material = nil
    else
        Background.material = self.m_gray_image.material
        quality_img.material = self.m_gray_image.material
        gaung_img.material = self.m_gray_image.material
    end
    
    local produce = data.produce or 0
    produce = math.max(data.produce - 1, 0)
    produce = produce * 100;
    
    local int_num = math.floor(produce + 0.5)
    local quality_img_name = "a_mjmb_jiaobiao_zise"
    if self.m_model:getAreaQualityImg(id) ~= "" then
        quality_img_name = self.m_model:getAreaQualityImg(id)
    end
    produce = int_num .. "%"
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "area_add_text", "hunt_treasure_str_037")
    LuaBehaviourUtil.setText(luaBehaviour, "area_add_value_text", produce)
    if produce == "0%" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "area_add_text", "")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "area_add_value_text", "")
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "area_name_text", data.name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img_1", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img_2", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_flag_img", false)
    LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", quality_img_name, "mystic_ui")
    local cell_btn = luaBehaviour:FindButton("arena_cell_content")
    local function btns()
        self:updateMsg("item_click", {index = id, open_flag = open_flag, tips_str = tips_str})
    end
    UIUtil.setButtonClick(cell_btn, btns, id)
    local cur_nums = 0
    if location_data then
        cur_nums = location_data.num or 0
        if location_data.is_enemy == 1 and location_data.is_guild == 1 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img_1", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img_2", true)
            LuaBehaviourUtil.setImg(luaBehaviour,"icon_img_1","a_mjxb_choujia", __lan_atlas)
            LuaBehaviourUtil.setImg(luaBehaviour,"icon_img_2","a_mjxb_youfang", __lan_atlas)
            luaBehaviour:FindImage("icon_img_1"):setNativeSize()
            luaBehaviour:FindImage("icon_img_2"):setNativeSize()
        elseif location_data.is_enemy == 0 and location_data.is_guild == 0 then
       
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img_1", true)
            LuaBehaviourUtil.setImg(luaBehaviour,"icon_img_1",location_data.is_enemy == 1 and "a_mjxb_choujia" or "a_mjxb_youfang", __lan_atlas)
        end
        if location_data.team_id and location_data.team_id > 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_flag_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_flag_img", false)
        end
    end
    local owern_nums = cur_nums .. "/" .. _max_owners
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "owner_nums_text","hunt_treasure_str_013", owern_nums)

end

return M