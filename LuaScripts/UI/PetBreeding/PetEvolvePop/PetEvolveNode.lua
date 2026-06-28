---@class PetEvolveNode: OOUIbase
---@field m_model PetEvolvePopModel
local M = class("PetEvolveNode",LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetEvolveNode"

function M:onEnter()
    self:setTextByLanKey("tips_text1", "pet_evo_lv_0027")
    self:setTextByLanKey("tips_text2", "pet_evo_lv_0028")
    self:setTextByLanKey("show_text", "")
    self:setTextByLanKey("tips_text3", "")
    self:setTextByLanKey("main_type_text", "pet_evo_lv_0014")
    self:setTextByLanKey("second_type_text", "pet_evo_lv_0015")
    self:setTextByLanKey("tips_text", "pet_evo_lv_0039")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    
    self:updateTagLoopScroll()
    self:refreshUI()
end
--a_xk_xiangqing

--[[	
	宠物品级列表
]]
function M:updateTagLoopScroll()
    local data = {0,1,2,3,4,5}
    if self.m_tog_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("tag_list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            ui_name = self.m_uiName,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local str = "%s代"
                    local str2 = string.format( str, Language:getTextByKey("num_str_000"..cell_data))
                    if cell_data == 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_sort_1","new_str_0065")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_sort_1", str2)
                    end
                end   
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_evolv_index", cell_data)
                self:setObjectVisible("btn_sort_close", false)
                self:setObjectVisible("sort_list", false)
            end
        }
        self.m_tog_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_tog_loop_scroll_view:reloadData(data,true)
    end
end


function M:refreshUI()
    self:updateLoopScroll()
    self:creatShowPets()
    self:refreshTips()
end

function M:refreshTips()
    local slot_0 = self.m_model.m_slot[1]
    local is_slot0 = slot_0 and slot_0 ~= "" and slot_0 ~= 0
    local is_show = self.m_model:checkIsHasLvList() and is_slot0
    self:setObjectVisible("tips_text", is_show)
end

--左侧选中信息
function M:creatShowPets()
    local slot_0 = self.m_model.m_slot[1]
    local evo_cfg,evo_next_cfg = self.m_model:getEvoCfg()
    if slot_0 and slot_0 ~= "" and slot_0 ~= 0 then
        local skill_limit = evo_next_cfg.skill_limit - evo_cfg.skill_limit
        local lock_skill_num = evo_next_cfg.lock_skills - evo_cfg.lock_skills
        local item_obj = self:setObjectVisible("pet_cell3", true)
        self:setObjectVisible("no_img", false) 
        self:setNextItem(item_obj, slot_0)
        local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_slot[1])
        local evo = pet_hero.evo
        local lv = 1
        local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
        if upgradeCfg[evo_cfg.min_condition] then
            lv = upgradeCfg[evo_cfg.min_condition].display_level
        end
        self:setTextByLanKey("show_text", "pet_evo_lv_0004",GameUtil:numberToChineseString(evo), lv)
    else
        self:setObjectVisible("no_img", true) 
        self:setObjectVisible("pet_cell3", false)
        self:setTextByLanKey("show_text", "")
    end
    local slot_1 = self.m_model.m_slot[1]
    if slot_1 and slot_1 ~= "" and slot_1 ~= 0 then
        self:setObjectVisible("add_go1", false)
        local item_obj = self:setObjectVisible("pet_cell1", true) 
        GameUtil:updatePetElement(item_obj,{oid = slot_1}, true, true, true)
    else
        self:setObjectVisible("add_go1", true)
        self:setObjectVisible("pet_cell1", false) 
    end
    local slot_2 = self.m_model.m_slot[2]
    if slot_2 and slot_2 ~= "" then
        self:setObjectVisible("add_go2", false)
        local item_obj = self:setObjectVisible("pet_cell2", true) 
        GameUtil:updatePetElement(item_obj,{oid = slot_2}, true, true, true)
    else
        self:setObjectVisible("add_go2", true)
        self:setObjectVisible("pet_cell2", false) 
    end
end

--[[	
	宠物列表
]]
function M:updateLoopScroll()
    self.m_model:InitData()
    local data = self.m_model.m_evo_lv_pets or {}
    if self.m_model.m_select_evo1 > 0 then
        data = self.m_model:getEvolvListByEvo(self.m_model.m_evo_lv_pets)
    end
    if self.m_model.m_slot[1] and self.m_model.m_slot[1] ~= "" and self.m_model.m_slot[1] ~= 0 then
        self.m_model:refreshEvolvMaterialList()
        data = self.m_model.pet_material_list  or {}
    end
    if next(data) == nil then
        self:setObjectVisible("empty_node", true)
    else
        self:setObjectVisible("empty_node", false)    
    end
    self.m_model:equipIdsSort(data)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 4,
            ui_name = self.m_uiName,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItem(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_cell", cell_data)
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data,false)
    end
end


function M:updateItem(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(data)
        local gou_bl = self.m_model:checkInSlot(data)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", gou_bl == true)
        GameUtil:updatePetElement(obj,{oid = data}, true, true, true)
        
        local no_res = self.m_model:checkIsInNoResList(data)
        local is_can_lv = self.m_model:checkIsInLvList(data)
        local generation_bg = luaBehaviour:FindImage("pet_evo_bg") 
        local pet_icon = luaBehaviour:FindImage("pet_icon")

        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_res", no_res)
        if not no_res then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "level_up", is_can_lv)
        end
        if no_res or is_can_lv then
            generation_bg.material = self.m_gray_material
            pet_icon.material = self.m_gray_material
        else
            generation_bg.material = nil
            pet_icon.material = nil
        end
    end
    
end

function M:updatePetObj(obj,oid)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", "a_ui_currency_dj_lan", "equip_icon")
        local level = pet_data.lv
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
        local generation_data  = GameUtil:getPetInfoByData(pet_data)
        LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", pet_cfg.icon, "hero_head_ui")
        
       
    end  
end

function M:setNextItem(obj,oid)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
        GameUtil:updatePetElement(obj,{oid = oid}, true, true)
        local temp_data = table.copy(pet_data)
        temp_data.evo = temp_data.evo + 1
        local generation_data  = GameUtil:getPetInfoByData(temp_data)
        local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
        local evo_cfg = pet_evolution[temp_data.evo] or pet_evolution[#pet_evolution]
        local icon = LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", evo_cfg.egg_pic, "main_ui2")
        LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", 1)
        if self.m_model.m_slot[2] and self.m_model.m_slot[2] ~= "" and self.m_model.m_slot[2] ~= 0 then
            icon.material = nil
        else
            icon.material = self.m_gray_material
        end
    end  
end

function M:onButtonClick(obj, name)
    if name == "help_btn" then
        -- GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("提示信息 --- "), delay_close = 2})
    elseif name == "preview_btn" then
        self:updateMsg("preview_btn")
    elseif name == "evolve_btn" then
        self:updateMsg("evolve_btn")
    elseif name == "pet_cell1" then
        audio:SendEvtUI("Play_UI_Tab")
        local slot_1 = self.m_model.m_slot[1]
        if slot_1 and slot_1 ~= "" then
            self:updateMsg("click_cell", slot_1)
        end
    elseif name == "pet_cell2" then
        audio:SendEvtUI("Play_UI_Tab")
        local slot_2 = self.m_model.m_slot[2]
        if slot_2 and slot_2 ~= "" then
            self:updateMsg("click_cell", slot_2)
        end
    elseif name == "pet_cell3" then
        audio:SendEvtUI("Play_UI_Tab")
        -- self:updateMsg("preview_btn")
    elseif name == "btn_sort_close" then
        self:setObjectVisible("btn_sort_close", false)
        self:setObjectVisible("sort_list", false)
    elseif name == "img_sort_select" then
        audio:SendEvtUI("UI_NormalClick1")
        self:setObjectVisible("btn_sort_close", true)
        self:setObjectVisible("sort_list", true)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M