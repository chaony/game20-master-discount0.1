---@class PetFreeView: OOPopBase
---@field m_model PetFreeModel
local M = class("PetFreeView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetFree"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    self.m_pet_obj = nil
    self.m_pet_ab_name = nil
    self.m_gray_img = self:findImage("gray_img")
    self:setTextByLanKey("close_title_text", "pet_evo_lv_0019")
    self:setTextByLanKey("free_btn_text", "pet_evo_lv_0016")
    self:setTextByLanKey("free_tips_text", "pet_evo_lv_0017")
    self:setTextByLanKey("msg_text", "pet_evo_lv_0018")
    self:setTextByLanKey("tab_free_btn_text", "pet_evo_lv_0016")
    self:setTextByLanKey("free_all_text", "pet_evo_lv_0041")
    self:setTextByLanKey("quality_btn_text1", "pet_evo_lv_0043")
    self:setTextByLanKey("quality_btn_text2", "pet_evo_lv_0044")
    self:setTextByLanKey("quality_btn_text3", "pet_evo_lv_0045")
    self:setTextByLanKey("quality_btn_text4", "pet_evo_lv_0046")
    self:setTextByLanKey("quality_btn_text5", "pet_evo_lv_0047")
    self:setTextByLanKey("quality_btn_text6", "pet_evo_lv_0052")
    
    self:setObjectVisible("level_btn", false)
    self.m_go_3d = self:findGameObject("gameObject_3d")
    self.m_go_3d.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_go_3d.transform, 1, 1, 1)
    self.m_pet_parent = self:findGameObject("role_3d")
    self.m_sift_panel = self:findGameObject("sift_node")
    self.m_sift_mask = self:findGameObject("mask_img")
    self:hideSift(true)
    self:refreshUI(true)
end

function M:refreshUI(isKeepOffset)
    self:setCheckImg()
    self:updateListScroll(isKeepOffset)
    local rewards = self.m_model:getReturnCons()
    local return_node = self:findGameObject("return_node")
    local function callFun()
        audio:SendEvtUI("Play_UI_Tab")
    end
    GameUtil:createRewards(return_node.transform, rewards,true,true,callFun,0.9)
    self:updatePetModel()
    local freet_btn = self:findImage("freet_btn")
    if self.m_model:checkIsEgg(self.m_model.index_oid) == true then
        freet_btn.material = self.m_gray_img.material
        self:setObjectVisible("dan_img",true)
        self:setObjectVisible("pet_img",false)
    else
        if self.m_model.index_oid == 0 then
            freet_btn.material = self.m_gray_img.material
        else
            freet_btn.material = nil
        end
        self:setObjectVisible("dan_img",false)
        self:setObjectVisible("pet_img",true)
    end
end


function M:updateListScroll(isKeepOffset)
    local data = self.m_model.m_pets or {}
    self:setObjectVisible("no_pets_tips_text", #data <= 0)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItem(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_index", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
        local init_index = self.m_model:getInitIndex()
        if init_index > 6 then
            self.m_list_scroll:moveToCellIndex(init_index)
        end
    else
        self.m_list_scroll:reloadData(data, isKeepOffset)
    end
end


function M:updateItem(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(data)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", false)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", "a_ui_currency_dj_lan", "equip_icon")
        if table.indexof(self.m_model.m_free_pets, data) then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", true)
        end
        GameUtil:updatePetElement(obj,{oid = data}, true, true, true)
        if self.m_model:checkIsEgg(data) then
            local icon = self.m_model:getEggIcon(data)
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", icon, "main_ui2")
        end
    end    
end

function M:updatePetModel()
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    if self.m_model.index_oid == 0 then
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
        self.m_pet_ab_name = pet_cfg.prefab
        obj.transform:SetParent(self.m_pet_parent.transform, false)
        obj.transform.localPosition = Vector3(0, 0, 0);
        obj.transform.localRotation = Quaternion.Euler(0, pet_cfg.package_y, 0);
        obj.transform.localScale = Vector3(pet_cfg.interact_scale, pet_cfg.interact_scale, pet_cfg.interact_scale);
        GlobalTools:CloseShadow(obj.transform)
    else
        Logger.logError(pet_cfg.prefab, "LoadRole3d failed : ")
    end
end

function M:setCheckImg()
    local is_select = self.m_model:getAllSelectState()
    self:setObjectVisible("check_img", is_select)
end

function M:showSift()
    self.m_sift_mask:SetActive(true)
    self.m_sift_panel:SetActive(true)
    local sift_index = self.m_model.m_select_sift
    local is_select = false
    for  i = 1, 6 do
        is_select = i == sift_index and true or false
        self:setObjectVisible("select_bg" ..i, is_select)
    end
end

function M:hideSift(isFirst)
    self.m_sift_panel:SetActive(false)
    self.m_sift_mask:SetActive(false)
    if isFirst then
        self:setTextByLanKey("sift_text", "pet_evo_lv_0048")
        return
    end
    local sift_index = self.m_model.m_select_sift
    local show_text = ""
    if sift_index == 1 then
        show_text = Language:getTextByKey("pet_evo_lv_0043")
    elseif sift_index == 2 then
        show_text = Language:getTextByKey("pet_evo_lv_0044")
    elseif sift_index == 3 then
        show_text = Language:getTextByKey("pet_evo_lv_0045")
    elseif sift_index == 4 then
        show_text = Language:getTextByKey("pet_evo_lv_0046")
    elseif sift_index == 5 then
        show_text = Language:getTextByKey("pet_evo_lv_0047")
    elseif sift_index == 6 then
        show_text = Language:getTextByKey("pet_evo_lv_0052")
    end
    self:setText("sift_text",  show_text)
end

function M:destroy()
    if self.m_pet_ab_name then
        ResourceUtil:UnLoadBundle(self.m_pet_ab_name, false)
    end
    M.super.destroy(self)
end

return M