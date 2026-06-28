---@class PetSpawnView: OOPopBase
---@field m_model PetSpawnModel
local M = class("PetSpawnView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetSpawn"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    self:adaptScreen()
    self.m_pet_obj = nil
    self.m_pet_obj2 = nil
    self.m_pet_ab_name1 = nil
    self.m_pet_ab_name2 = nil
    self:setTextByLanKey("close_title_text", "pet_bag_text_0110")
    self:setTextByLanKey("main_type_text", "pet_evo_lv_0014")
    self:setTextByLanKey("second_type_text", "pet_evo_lv_0015")
    self:setTextByLanKey("l_no_skill_tips", "pet_evo_lv_0026")
    self:setTextByLanKey("r_no_skill_tips", "pet_evo_lv_0026")

    self:setTextByLanKey("comprehead_des_text", "pet_evo_lv_0029")
    self:setTextByLanKey("add_go_text1", "pet_evo_lv_0030")
    self:setTextByLanKey("add_go_text2", "pet_evo_lv_0031")

    self.m_go_3d1 = self:findGameObject("pet_left_3d")
    self.m_go_3d2 = self:findGameObject("pet_right_3d")
    self.m_go_3d1.transform:SetParent(self.m_rootView.transform, false)
    self.m_go_3d2.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_go_3d1.transform, 1, 1, 1)
    UIUtil.setScale(self.m_go_3d2.transform, 1, 1, 1)
    self.m_left_pet_parent = self:findGameObject("role_3d1")
    self.m_right_pet_parent = self:findGameObject("role_3d2")
    self.m_left_info_node = self:findRectTransform("left_pet_info_node")
    self.m_right_info_node = self:findRectTransform("right_pet_info_node")
    self.m_left_pet = self:findRectTransform("left_pet")
    self.m_right_pet = self:findRectTransform("right_pet")
    self.m_calc_desc_text = self:findText("calc_desc_text")
    self.m_calc_desc_rt = self:findRectTransform("calc_desc_text")
    self.m_cell_rt = self:findRectTransform("cell")
    self.m_left_all_cell_size = {}
    self.m_right_all_cell_size = {}
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, { mode = 38 })
    self:setObjectVisible("dan_bg", false)
    self:InitPlaySpine()
    self:refreshUI()
end

function M:adaptScreen()
    local bg_rt = self:findRectTransform("bg_obj")
    local rect = bg_rt.rect
    self.m_bg_scale_w = rect.width/GlobalConfig.UI_DESIGN_WIDTH
    self.m_bg_scale_h = rect.height/GlobalConfig.UI_DESIGN_HEIGHT
    self.m_bg_scale = math.max(self.m_bg_scale_w , self.m_bg_scale_h)
    local bg_rect_tran = self:findRectTransform("petBag_bg")
    UIUtil.setScale(bg_rect_tran, self.m_bg_scale)
end

function M:refreshUI()
    if self.m_model:checkIsEgg() == true then
        self:spawnEggUI()
        self:updateTime()
    else
        self:setObjectVisible("add_go_text1", true)
        self:setObjectVisible("add_go_text2", true)
        self:setObjectVisible("left_pet", true)
        self:setObjectVisible("right_pet", true)
        self:setObjectVisible("left_attr_bg", true)
        self:setObjectVisible("right_attr_bg", true)
        self:setObjectVisible("spwan_btn", true)
        self:setObjectVisible("quick_btn", false)
        self:setObjectVisible("dan_bg", false)
        self:updateLeftPetModel()
        self:updateRightPetModel()
        self:refreshLeftUI()
        self:refreshRightUI()
        self:refreshRateUI()
        local lock_max_num =self.m_model:getlockSkillNums()
        if lock_max_num > 0 then
            self:setObjectVisible("pet_lock_btn", true)
        else
            self:setObjectVisible("pet_lock_btn", false)    
        end
        if self.m_model.m_select_oid and self.m_model.m_select_oid ~= 0 and self.m_model.m_select_oid ~= "" and
            self.m_model.index_oid and self.m_model.index_oid ~= 0 and self.m_model.index_oid ~= "" then
            self:setObjectVisible("comprehend_panel", true)
            self:setObjectVisible("UI_SimulateLift_SG001", true)
        else
            self:setObjectVisible("comprehend_panel", false)
            self:setObjectVisible("UI_SimulateLift_SG001", false)
        end
    end
    local is_has_red = RedPointUtil:checkPetEvoRedPoint()
    self:setObjectVisible("red_point_img1", is_has_red)
    self:setObjectVisible("red_point_img2", is_has_red)
end

function M:refreshRateUI()
    if self.m_model.index_oid == 0 or self.m_model.index_oid == "" then
        self:setTextByLanKey("comprehead_num", "pet_evo_lv_0040", "0%")
        return
     end
    local cur_rate,next_rate = self.m_model:getCompreheadRate()
    self:setTextByLanKey("comprehead_num", "pet_evo_lv_0040", (next_rate*100).."%")
    self:setTextByLanKey("num_text", self.m_model.m_buy_lv)
    self:updateCons()
end

--刷新道具
function M:updateCons()
    local cons_coin, cons_exp= self.m_model:getCompreheadCons()
    self:setImg(cons_coin.icon_name, cons_coin.atlas_name, "money_img")
    if cons_coin.user_num < cons_coin.data_num then
        self:setTextByLanKey("money_text" , "equip_str_033" ,GameUtil:formatValueToString(cons_coin.user_num), GameUtil:formatValueToString(cons_coin.data_num))
    else
        self:setTextByLanKey("money_text" , GameUtil:formatValueToString(cons_coin.user_num).."/"..GameUtil:formatValueToString(cons_coin.data_num))
    end
    self:setImg(cons_exp.icon_name, cons_exp.atlas_name, "jingyan_img")
    if cons_exp.user_num < cons_exp.data_num then
        self:setTextByLanKey("jingyan_text" , "equip_str_033" ,GameUtil:formatValueToString(cons_exp.user_num), GameUtil:formatValueToString(cons_exp.data_num))
    else
        self:setTextByLanKey("jingyan_text" , GameUtil:formatValueToString(cons_exp.user_num).."/"..GameUtil:formatValueToString(cons_exp.data_num))
    end
end



function M:refreshLeftUI()
    if self.m_model.index_oid == 0 or self.m_model.index_oid == "" then
       self:setObjectVisible("left_attr_bg", false)
       self:setObjectVisible("add_go1", true)
       self:setObjectVisible("left_pet", false)
    --    self:setObjectVisible("left_pet_effect", false)
       return
    end
    self:setObjectVisible("add_go1", false)
    self:setObjectVisible("left_pet", true)
    local oid = self.m_model.index_oid
    self:setObjectVisible("left_attr_bg", true)
    GameUtil:createPetGeneration(oid, self.m_left_info_node)
    self:creatPetItem(oid, self.m_left_pet)

    -- self:setObjectVisible("left_pet_effect", true)
    local attrs = self.m_model:getAttrs(oid)
    local talent_data = self.m_model:getTalentData(oid)
    self:setText("l_hp_num", GameUtil:formatValueToString(math.round(attrs["hp"])))
    self:setText("l_attack_num", GameUtil:formatValueToString(math.round(attrs["atk"])))
    self:setText("l_def_num", GameUtil:formatValueToString(math.round(attrs["def"])))
    self:setText("l_anger_num", GameUtil:formatValueToString(math.round(attrs["power"])))
    for i = 1, 4 do
        self:setText("l_talent_num" .. i, GameUtil:formatValueToString(math.round(talent_data[i].num)))
        local text = Language:getTextByKey("pet_bag_text_0008")
        self:setText("l_talent_text" .. i, talent_data[i].attr_text .. text)
    end
    self:refreshLeftSkillLoopScroll(oid)
end

function M:refreshRightUI()
    if self.m_model.m_select_oid == 0 or self.m_model.m_select_oid == "" then
       self:setObjectVisible("right_attr_bg", false)
       self:setObjectVisible("add_go2", true)
       self:setObjectVisible("right_pet", false)
       self:creatPetItem(0, self.m_right_pet)
       return
    end

    local oid = self.m_model.m_select_oid
    self:setObjectVisible("right_attr_bg", true)
    self:setObjectVisible("right_pet", true)
    -- self:setObjectVisible("right_pet_effect", true)
    self:setObjectVisible("add_go2", false)
    self:creatPetItem(oid, self.m_right_pet)
    GameUtil:createPetGeneration(oid, self.m_right_info_node)
    local attrs = self.m_model:getAttrs(oid)
    local talent_data = self.m_model:getTalentData(oid)
    self:setText("r_hp_num", GameUtil:formatValueToString(math.round(attrs["hp"])))
    self:setText("r_attack_num", GameUtil:formatValueToString(math.round(attrs["atk"])))
    self:setText("r_def_num", GameUtil:formatValueToString(math.round(attrs["def"])))
    self:setText("r_anger_num", GameUtil:formatValueToString(math.round(attrs["power"])))
    for i = 1, 4 do
        self:setText("r_talent_num" .. i, GameUtil:formatValueToString(math.round(talent_data[i].num)))
        local text = Language:getTextByKey("pet_bag_text_0008")
        self:setText("r_talent_text" .. i, talent_data[i].attr_text .. text)
    end
    self:refreshRightSkillLoopScroll(oid)
end


function M:updateLeftPetModel()
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    if self.m_model.index_oid == 0 or self.m_model.index_oid == "" then
        return
    end
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.index_oid)
    local obj = ResourceUtil:LoadRole3d(pet_cfg.prefab)
    self.m_pet_obj = obj
    if not IsNull(obj) then
        local luaViewHelper = obj:GetComponent("LuaViewHelper")
        if luaViewHelper then
            luaViewHelper.enabled = false
        end
        self.m_pet_ab_name1 = pet_cfg.prefab
        obj.transform:SetParent(self.m_left_pet_parent.transform, false)
        obj.transform.localPosition = Vector3(0, 0, 0);
        obj.transform.localRotation = Quaternion.Euler(0, pet_cfg.package_y, 0);
        obj.transform.localScale = Vector3(pet_cfg.interact_scale, pet_cfg.interact_scale, pet_cfg.interact_scale);
        GlobalTools:CloseShadow(obj.transform)
    else
        Logger.logError(pet_cfg.prefab, "LoadRole3d failed : ")
    end
end


function M:refreshLeftSkillLoopScroll(oid)
    local data = self.m_model:getSkillList(oid)
    if #data <= 0 then
        self:setObjectVisible("l_no_skill_tips", true)
        self:setObjectVisible("l_skill_loopscroll", false)
        return
    end
    self:setObjectVisible("l_no_skill_tips", false)
    self:setObjectVisible("l_skill_loopscroll", true)
    self.m_calc_desc_text.gameObject:SetActive(true)
    self.m_left_all_cell_size = self:calcCellSize(data)
    self.m_calc_desc_text.gameObject:SetActive(false)
    if self.m_left_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("l_skill_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = self.m_left_all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data, self.m_left_all_cell_size)
            end,
        }
        self.m_left_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_left_loop_scroll_view:reloadData(data, false, self.m_left_all_cell_size)
    end
end

function M:refreshRightSkillLoopScroll(oid)
    local data = self.m_model:getSkillList(oid)
    if #data <= 0  then
        self:setObjectVisible("r_no_skill_tips", true)
        self:setObjectVisible("r_skill_loopscroll", false)
        return
    end
    self:setObjectVisible("r_no_skill_tips", false)
    self:setObjectVisible("r_skill_loopscroll", true)
    self.m_calc_desc_text.gameObject:SetActive(true)
    self.m_right_all_cell_size = self:calcCellSize(data)
    self.m_calc_desc_text.gameObject:SetActive(false)
    if self.m_right_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("r_skill_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = self.m_right_all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data, self.m_right_all_cell_size)
            end,
        }
        self.m_right_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_right_loop_scroll_view:reloadData(data, false, self.m_right_all_cell_size)
    end
end

function M:updateScrollViewCell(index, cell_object, cell_data, all_cell_size)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local pet_skill_id = cell_data
    local data = self.m_model:getSkillDataByPetSkill(pet_skill_id)
    if not data then
        return
    end
    local cell_size = all_cell_size[index]
    local cur_cell_rt = cell_object.transform
    cur_cell_rt.sizeDelta = Vector2(self.m_cell_rt.rect.width, cell_size.y)
    LuaBehaviourUtil.setText(luaBehaviour,"skill_name_text", data.name_text)
    LuaBehaviourUtil.setText(luaBehaviour,"skill_desc_text", data.desc_text)
    LuaBehaviourUtil.setText(luaBehaviour,"skill_type_text", data.type_text)
    local skill_bg_str = GameUtil:getPetSkillBg(pet_skill_id)
    LuaBehaviourUtil.setImg(luaBehaviour,"skill_type_img", skill_bg_str, "main_ui2")
end

function M:calcCellSize(ids)
    local all_cell_size = {}
    local desc = ""
    local height = 0
    local cell_width =  self.m_cell_rt.rect.width
    for k,v in ipairs(ids) do
        desc = self.m_model:getDescByPetSkillId(v)
        self.m_calc_desc_text.text = desc
        self.m_calc_desc_rt:GetComponent("ContentSizeFitter"):SetLayoutVertical()
        height = self.m_calc_desc_rt.rect.height
        all_cell_size[k] = Vector2(cell_width, height)
    end
    return all_cell_size
end

function M:updateRightPetModel()
    if not IsNull(self.m_pet_obj2) then
        U3DUtil:Destroy(self.m_pet_obj2)
        self.m_pet_obj2 = nil
    end
    if self.m_model.m_select_oid == 0 or self.m_model.m_select_oid == "" then
        return
    end

    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_select_oid)
    local obj = ResourceUtil:LoadRole3d(pet_cfg.prefab)
    self.m_pet_obj2 = obj
    if not IsNull(obj) then
        local luaViewHelper = obj:GetComponent("LuaViewHelper")
        if luaViewHelper then
            luaViewHelper.enabled = false
        end
        self.m_pet_ab_name2 = pet_cfg.prefab
        obj.transform:SetParent(self.m_right_pet_parent.transform, false)
        obj.transform.localPosition = Vector3(0, 0, 0);
        obj.transform.localRotation = Quaternion.Euler(0, pet_cfg.package_y, 0);
        obj.transform.localScale = Vector3(pet_cfg.interact_scale, pet_cfg.interact_scale, pet_cfg.interact_scale);
        GlobalTools:CloseShadow(obj.transform)
    else
        Logger.logError(pet_cfg.prefab, "LoadRole3d failed : ")
    end
end

function M:creatPetItem(oid, parent)
    UIUtil.destroyAllChild(parent.transform)
    GameUtil:createPetElement(oid, parent, true, true, function ()
        self:updateMsg("click_pet")
    end)
end

function M:spawnEggUI()
    self:setObjectVisible("left_pet", false)
    self:setObjectVisible("add_go_text1", false)
    self:setObjectVisible("add_go_text2", false)
    self:setObjectVisible("right_pet", false)
    self:setObjectVisible("left_attr_bg", false)
    self:setObjectVisible("right_attr_bg", false)
    self:setObjectVisible("pet_lock_btn", false)
    self:setObjectVisible("spwan_btn", false)
    self:setObjectVisible("comprehend_panel", false)
    self:setObjectVisible("UI_SimulateLift_SG001", false)
    self:setObjectVisible("quick_btn", true)
    self:setObjectVisible("dan_bg", true)
    self:setObjectVisible("add_go2", true)
    self:setObjectVisible("add_go1", true)
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    if not IsNull(self.m_pet_obj2) then
        U3DUtil:Destroy(self.m_pet_obj2)
        self.m_pet_obj2 = nil
    end
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.index_oid)
    local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
    if pet_evolution[pet_data.evo].egg_spine then
        local dan_img = self:findSkeletonGraphic("dan_img")
        GameUtil:updateSpineLoadSet(dan_img, "RoleSpine/" .. tostring(pet_evolution[pet_data.evo].egg_spine), "idle", 0, true)
    end
end

function M:updateTime()
    if self.m_model.egg_oid then
        local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.egg_oid)
        if pet_data and pet_data.egg_ets then
            local tim =  (pet_data.egg_ets - UserDataManager:getServerTime())
            if tim > 0 then
                self:setTextByLanKey("spawn_down_time",  "pet_bag_text_0035", GameUtil:formatTimeBySecond(tim,999))
            elseif tim == 0 then
                self:updateMsg("pet_egg_success")
            else
                self:setTextByLanKey("spawn_down_time",  "pet_bag_text_0035","00:00")
            end
        else
            self:updateMsg("pet_egg_success")
        end
    end
end

function M:playSpineAnim(callback)
    audio:SendEvtUI("UI_FYan")
    self:setObjectVisible("fy_001_spine", true)
	local fy_sp = self:findSkeletonGraphic("fy_001_spine")    
    fy_sp.AnimationState:ClearTracks()
	fy_sp.AnimationState:SetAnimation(0, "PetSpawn_FanYan_001", false)
    self:lockTouch()
    self.m_control:setOnceTimer(1.6,function ()
        self:unlockTouch()
        self:setObjectVisible("fy_001_spine", false)
        if callback then
            callback()
        end
    end)
end

--spine第一次播放第一帧会闪一下 所以进入界面后先播放一次
function M:InitPlaySpine()
    local spine_obj = self:setObjectVisible("fy_001_spine", true)
    UIUtil.setLocalPosition(spine_obj.transform,10000,10000,0)
	local fy_sp = self:findSkeletonGraphic("fy_001_spine")    
	fy_sp.AnimationState:SetAnimation(0, "PetSpawn_FanYan_001", false)
    self.m_control:setOnceTimer(1.5,function ()
        UIUtil.setLocalPosition(spine_obj.transform,0,0,0)
        local spine_obj = self:setObjectVisible("fy_001_spine", false)
    end)
end


function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    if self.m_pet_ab_name1 then
        ResourceUtil:UnLoadBundle(self.m_pet_ab_name1, false)
    end
    if self.m_pet_ab_name2 then
        ResourceUtil:UnLoadBundle(self.m_pet_ab_name2, false)
    end
    M.super.destroy(self)
end

return M
