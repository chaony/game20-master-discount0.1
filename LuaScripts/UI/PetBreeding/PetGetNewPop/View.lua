---@class PetGetNewPopView: OOPopBase
---@field m_model PetGetNewPopModel
local M = class("PetGetNewPop", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetGetNewPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_pet_obj = nil
    self:setObjectVisible("new_img", self.m_model.is_new == true)
    local pet_data, pet_cfg = self.m_model:getPetData()
    self:setTextByLanKey("name_text", pet_cfg.name)
    local name_img = self:findImage("pet_name_img")
    GameUtil:updateResourcesImg(name_img, "Texture/HeroIcon/" .. pet_cfg.pet_name_pic)
    local generation_data = GameUtil:getPetInfoByData(pet_data, pet_cfg)
    self:setTextByLanKey("generation_text", generation_data.evo_text)
    self:setImg(generation_data.evo_bar_bg, "main_ui2", "pet_info_img")
    self:setImg(generation_data.evo_bg, "main_ui2", "generation_bg")
    self:setImg(pet_cfg.icon, "main_ui2", "pet_img")
    local pet_info_node = self:findGameObject("pet_info_node")
    GameUtil:createPetGeneration(self.m_model.m_pet_id, pet_info_node.transform)
    self.m_go_3d = self:findGameObject("gameObject_3d")
    self.m_go_3d.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_go_3d.transform, 1, 1, 1)
    self.m_pet_parent = self:findGameObject("role_3d")
    self:updatePetModel()
    audio:SendEvtUI("UI_NewPat")
end


function M:updatePetModel()
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    if self.m_model.index_oid == 0 then
        return
    end
    local pet_data, pet_cfg = self.m_model:getPetData()
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