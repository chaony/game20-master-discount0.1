---@class PetEvolveSucceedView: OOPopBase
---@field m_model PetEvolveSucceedModel
local M = class("PetEvolveSucceedPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetEvolveSucceedPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    local pet_data, pet_cfg = self.m_model:getPetData()
    if pet_data == nil then
        return
    end
    self:setTextByLanKey("name_text", pet_cfg.name)
    local generation_data  = GameUtil:getPetInfoByData(pet_data)
    self:setTextByLanKey("generation_text", generation_data.evo_text)
    self:setImg(generation_data.evo_bar_bg, "main_ui2", "pet_info_img")
    self:setImg(generation_data.evo_bg, "main_ui2", "generation_bg")
    local master_data,master_cfg =self.m_model:getPetDataById()
   
    self.m_go_3d = self:findGameObject("gameObject_3d")
    self.m_go_3d.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_go_3d.transform, 1, 1, 1)
    self.m_pet_parent = self:findGameObject("role_3d")
    self:initCellSize()
    self:updateSkillLoopScroll(master_data.skills)
    self:refreshUI()
end

function M:refreshUI()
    self:setObjectVisible("variation_img", self.m_model:checkVariation())
    self:updatePetModel()
end

function M:initCellSize()
    local skill_desc_text = self:findText("skill_desc_text")
    local data = self.m_model:getSkills()
    self.all_cell_size = {}
    for i,v in pairs(data) do
        if v.type == 1 then
            local variation_cfg = self.m_model:getVariationCfgById(v.id)
            local skill_des = Language:getTextByKey(variation_cfg.description)
            skill_desc_text.text = skill_des
            skill_desc_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
            local sizeDelta = skill_desc_text.transform.sizeDelta
            self.all_cell_size[i] = Vector2(510, sizeDelta.y + 42)
        else
            local random_cfg, skill_cfg = self.m_model:getMinLvByEvo(v.id)
            local skill_des = Language:getTextByKey(random_cfg.skill_des)..(random_cfg.random_max == 1 and Language:getTextByKey("pet_evo_lv_0010") or "")
            skill_desc_text.text = skill_des
            skill_desc_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
            local sizeDelta = skill_desc_text.transform.sizeDelta
            if random_cfg.skill_jump == 1 or v.type == 2 then
                self.all_cell_size[i] = Vector2(510, sizeDelta.y + 42)
            else
                self.all_cell_size[i] = Vector2(510, sizeDelta.y + 25)
            end
        end
    end
end

function M:updateSkillLoopScroll()
    local data = self.m_model:getSkills()

    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("skill_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = self.all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                local cur_cell_rt = cell_object.transform
                cur_cell_rt.sizeDelta = Vector2(510, self.all_cell_size[index].y)
                self:PreCell(cell_object,index,cell_data)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data,true, all_cell_size)
    end
end

function M:PreCell(cell_object, index, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local new_img = luaBehaviour:FindGameObject("new_img")
        local variation_img = luaBehaviour:FindGameObject("variation_img") 
        local skill_name_bg1 = luaBehaviour:FindGameObject("skill_name_bg1") --技能 底
        local skill_name_bg2 = luaBehaviour:FindGameObject("skill_name_bg2") --变异 底
        local skill_name_text1 = luaBehaviour:FindGameObject("skill_name_text1") --技能标题
        local skill_name_text2 = luaBehaviour:FindGameObject("skill_name_text2") --变异标题
        local skill_desc_text = luaBehaviour:FindGameObject("skill_desc_text") --描述
        local skill_type_img = luaBehaviour:FindGameObject("skill_type_img") -- 技能类型
        new_img:SetActive(false)
        variation_img:SetActive(false)
        skill_name_bg1:SetActive(false)
        skill_name_bg2:SetActive(false)
        skill_type_img:SetActive(false)
        if cell_data.type == 1 then --属性、宠物、变异
            variation_img:SetActive(true)
            skill_name_bg2:SetActive(true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_name_text2", "pet_evo_lv_0011")
            local variation_cfg = self.m_model:getVariationCfgById(cell_data.id)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_desc_text", variation_cfg.description)
        elseif cell_data.type == 2 then --技能变异
            variation_img:SetActive(true)
            skill_name_bg2:SetActive(true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_name_text2", "pet_evo_lv_0011")
            local random_cfg, skill_cfg = self.m_model:getMinLvByEvo(cell_data.id)
            local skill_des = Language:getTextByKey(random_cfg.skill_des)..(random_cfg.random_max == 1 and Language:getTextByKey("pet_evo_lv_0010") or "")
              --如果不需要跳转 就代表没有名称 只显示技能描述即可
            if random_cfg.skill_jump == 1 then --显示技能名称
                skill_name_bg1:SetActive(true)
                local name = Language:getTextByKey(skill_cfg.name)
                local skill_name_tab = string.split(name, "】")
                skill_name_tab = string.split(skill_name_tab[2], "（")
                LuaBehaviourUtil.setText(luaBehaviour, "skill_name_text2", skill_name_tab[1])
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_desc_text", skill_des)
            local skill_type = random_cfg.type --:1=斗技技能 2=协战技能 3=根骨技能
            local type_name = ""
            if skill_type == 1 then
                type_name = "斗"
            elseif skill_type == 2 then
                type_name = "协"
            elseif skill_type == 3 then
                type_name = "根"    
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_type_text", type_name)
            skill_type_img:SetActive(true)
            local skill_bg_str = GameUtil:getPetSkillBg(cell_data.id)
            LuaBehaviourUtil.setImg(luaBehaviour,"skill_type_img", skill_bg_str, "main_ui2")
        elseif cell_data.type == 3 then -- 普通技能   
            local is_new = self.m_model:checkIsNewSkill(cell_data.id) --新获得的技能
            new_img:SetActive(is_new)
            local random_cfg, skill_cfg = self.m_model:getMinLvByEvo(cell_data.id)
            local skill_des = Language:getTextByKey(random_cfg.skill_des)..(random_cfg.random_max == 1 and Language:getTextByKey("pet_evo_lv_0010") or "")
              --如果不需要跳转 就代表没有名称 只显示技能描述即可
            if random_cfg.skill_jump == 1 then --显示技能名称
                skill_name_bg1:SetActive(true)
                local name = Language:getTextByKey(skill_cfg.name)
                local skill_name_tab = string.split(name, "】")
                skill_name_tab = string.split(skill_name_tab[2], "（")
                LuaBehaviourUtil.setText(luaBehaviour, "skill_name_text1", skill_name_tab[1])
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_desc_text", skill_des)
            local skill_type = random_cfg.type --:1=斗技技能 2=协战技能 3=根骨技能
            local type_name = ""
            if skill_type == 1 then
                type_name = "斗"
            elseif skill_type == 2 then
                type_name = "协"
            elseif skill_type == 3 then
                type_name = "根"    
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_type_text", type_name)
            skill_type_img:SetActive(true)
            local skill_bg_str = GameUtil:getPetSkillBg(cell_data.id)
            LuaBehaviourUtil.setImg(luaBehaviour,"skill_type_img", skill_bg_str, "main_ui2")
        end



    end
end

function M:updatePetModel()
    if self.m_model.m_pet_id == 0 then
        return
    end
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_pet_id)
    local obj = ResourceUtil:LoadRole3d(pet_cfg.prefab)
    self.m_pet_obj = obj
    if not IsNull(obj) then
        local luaViewHelper = obj:GetComponent("LuaViewHelper")
        if luaViewHelper then
            luaViewHelper.enabled = false
        end
        obj.transform:SetParent(self.m_pet_parent.transform, false)
        obj.transform.localPosition = Vector3(0, 0, 0);
        obj.transform.localRotation = Quaternion.Euler(0, pet_cfg.package_y, 0);
        obj.transform.localScale = Vector3(pet_cfg.interact_scale, pet_cfg.interact_scale, pet_cfg.interact_scale);
        GlobalTools:CloseShadow(obj.transform)
    else
        Logger.logError(pet_cfg.prefab, "LoadRole3d failed : ")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
