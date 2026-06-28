-- lv2 当“邪灵”层数达到10层和20层时，邪极会额外获得一个傀儡

local W_XieJ_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_XieJ_skill0_1_Model")
---@class W_XieJ_skill0_2_Model : W_XieJ_skill0_1_Model @
---@field super W_XieJ_skill0_1_Model @W_XieJ_skill0_1_Model
local M = class("W_XieJ_skill0_2_Model", W_XieJ_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)


    self.isSummon2 = false  -- 是否召唤了第二个
    self.isSummon3 = false  -- 是否召唤了第二个

    EventDispatcher:registerEvent("XieJ_ResLevel_Changed", {self, self.onResLevelChanged})
end

---@class Battle_HandleData_XieJResChanged
---@field player PlayerModel
---@field feature W_XieJ_skill1_1_Model

---@param eventData Battle_HandleData_XieJResChanged
function M:onResLevelChanged(eventName, eventData)
    if self.player:equal(eventData.player) then
        local resLevel = eventData.feature:getResLevel()
        if not self:haveSummonPuppet(2) then
            if self.summonLevel2 > 0 and resLevel >= self.summonLevel2 then
                self:summonPuppet(2)
            end 
        end

        if not self:haveSummonPuppet(3) then
            if self.summonLevel3 > 0 and resLevel >= self.summonLevel3 then
                self:summonPuppet(3)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("XieJ_ResLevel_Changed", {self, self.onResLevelChanged})
    M.super.destroy(self)
end

return M