---@class PetBreedingMainView: OOPopBase
---@field m_model PetBreedingMainModel
local M = class("PetBreedingMainView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetBreedingMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("close_title_text", "pet_bag_text_0104")
    self:setTextByLanKey("penglai_btn_text", "pet_bag_text_0107")
    self:setTextByLanKey("pk_btn_text", "pet_bag_text_0108")
    self:setTextByLanKey("shop_btn_text", "pet_bag_text_0109")
    self:setTextByLanKey("show_btn_text", "pet_bag_text_0110")
    self:setTextByLanKey("pet_btn_text", "pet_bag_text_0111")
    self:refreshShowList()
end

function M:refreshRedPointAndBtnStates()
    self:updatePetFactoryBtnStatus()
    local is_have_evo_red = RedPointUtil:checkPetEvoRedPoint()
    local is_have_bag_red = RedPointUtil:checkPetBagRedPoint()
    local is_have_arena_red = UserDataManager:getRedDotByKey("pet_pvp") > 0
    self:setObjectVisible("pet_btn_point_img",  is_have_bag_red)
    self:setObjectVisible("evolve_btn_point_img", is_have_evo_red)
    self:setObjectVisible("pk_btn_point_img", is_have_arena_red)
end

function M:updatePetFactoryBtnStatus() 
    local isShowIdleImg = self.m_model:checkPetFactoryBtnImageStatus()
    self:setObjectVisible("penglai_btn_idle_img", isShowIdleImg)
    local isMaxReward = UserDataManager:getRedDotByKey("pet_factory") == 1
    local isBestTeam = UserDataManager:getRedDotByKey("pet_factory_best_team") ==1
    local isShowRed = isMaxReward or isBestTeam
    self:setObjectVisible("box_reward_red_point", isMaxReward == true)
    self:setObjectVisible("penglai_btn_point_img", isShowRed == true)
end

function M:refreshShowList()
    local first_pet = 0
    for i=1, 4 do
        local obj = self:findGameObject("show_cell_" .. i)
        local luaBehaviour = obj:GetComponent("LuaBehaviour")
        local pet_obj = luaBehaviour:FindGameObject("pet_cell")
        local pet_luaBehaviour = pet_obj:GetComponent("LuaBehaviour")
        local pet_oid = self.m_model.m_data.pet_view[i]
        if pet_oid and pet_oid ~= "" then
            LuaBehaviourUtil.setObjectVisible(pet_luaBehaviour,"pet_cell", true)
            LuaBehaviourUtil.setObjectVisible(pet_luaBehaviour,"no_panel", false)
            local pet_cell = pet_luaBehaviour:FindGameObject("pet_cell")
            local pet_data = UserDataManager.pet_data:getPetDataById(pet_oid)
            if pet_data then
                local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PETS, pet_data.id, 1, pet_oid})
                GameUtil:updatePetElement(pet_cell, reward_data, true, true)
            end
            pet_luaBehaviour:RegistButtonClick(function()
                self:updateMsg("show_btn")
            end)
            if first_pet == 0 then
                first_pet = i
            end 
        else
            LuaBehaviourUtil.setObjectVisible(pet_luaBehaviour,"pet_cell", false)
            LuaBehaviourUtil.setObjectVisible(pet_luaBehaviour,"no_panel", true)
            luaBehaviour:RegistButtonClick(function()
                self:updateMsg("show_btn")
            end)
        end
        self:setObjectVisible("show_cell_" .. i, self.m_model.m_list_show)
    end
    first_pet = first_pet == 0 and 1 or first_pet
    self:setObjectVisible("show_cell_" .. first_pet, true)
    self:setObjectVisible("list_show_bg", self.m_model.m_list_show)
    self:setObjectVisible("list_hide_btn_img", self.m_model.m_list_show)
    self:setObjectVisible("hide_list_btn", self.m_model.m_list_show)
    self:setObjectVisible("list_one_bg", not self.m_model.m_list_show)
    self:setObjectVisible("list_show_btn_img", not self.m_model.m_list_show)
    self:setObjectVisible("show_list_btn", not self.m_model.m_list_show)

    self:refreshRedPointAndBtnStates()
end

function M:destroy()
    M.super.destroy(self)
end

return M