---@class PetBreedingInteractionView: OOPopBase
---@field m_model PetBreedingInteractionModel
local M = class("PetBreedingInteractionView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetBreedingInteraction"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("close_title_text", "pet_bag_text_0103")
    self:setTextByLanKey("reward_text", "pet_bag_text_0105")
    if self.m_model.m_oid then
        self:setObjectVisible("des_bg", true)
        local data,cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_oid)
        local name_img = self:findImage("name_img")
        GameUtil:updateResourcesImg(name_img, "Texture/HeroIcon/" .. cfg.pet_name_pic)
        self:setTextByLanKey("type_name_text", cfg.pet_des)
        self:setTextByLanKey("des_title_text", "pet_bag_text_0112")
        self:setTextByLanKey("des_text", cfg.pet_story)
    else
        self:setObjectVisible("des_bg", false)
    end
    self:updateDownTime()
end

function M:updateDownTime()
    if self.tick_id then
        self.m_control:removeTimer(self.tick_id)
        self.tick_id = nil
    end
    
    local function tick(dt)
        local cd_time = ConfigManager:getCommonValueById(740)[2]
        local interact_ts = self.m_model.m_data.interact_ts
        local down_time = cd_time*3600 - (UserDataManager:getServerTime() - interact_ts)
        if down_time >= 0 then
            self:setObjectVisible("down_time_text", true)
            self:setObjectVisible("UI_NewYearDailyshare_001", false)
            self:setObjectVisible("reward_finger_img", false)
            local text = GameUtil:formatTimeBySecond(down_time, 999)
            self:setText("down_time_text", text)
        else
            self:setObjectVisible("down_time_text", false)
            self:setObjectVisible("UI_NewYearDailyshare_001", true)
            self:setObjectVisible("reward_finger_img", true)
        end
    end
    self.tick_id = self.m_control:setTimer(1, tick)
    tick()
end

function M:destroy()
    M.super.destroy(self)
end

return M