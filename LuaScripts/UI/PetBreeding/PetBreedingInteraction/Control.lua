---@class PetBreedingInteractionControl: OOControlBase
---@field m_model PetBreedingInteractionModel
---@field m_view PetBreedingInteractionView
local M = class("PetBreedingInteractionControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        if SceneManager:getCurSceneModel().closeInteractPet then
            SceneManager:getCurSceneModel():closeInteractPet()
        end
        self:closeView()
    elseif msg == "box_btn" then
        audio:SendEvtUI("UI_Tab_N6")
        self:openView("PetBreeding.PetBreedingInteractionRewards")
    elseif msg == "interact_pet" then
        audio:SendEvtUI("UI_HDong_Pat")
        self:requestInteract()
    end
end

function M:requestInteract()
    local cd_time = ConfigManager:getCommonValueById(740)[2]
    local interact_ts = self.m_model.m_data.interact_ts
    local down_time = cd_time*3600 - (UserDataManager:getServerTime() - interact_ts)
    if down_time >= 0 then
        return
    end
    
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
    end
    self.m_model:getNetData("pet_interact", nil, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M
