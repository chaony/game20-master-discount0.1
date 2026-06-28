--被挂上火种的单位攻速减少10%
---@class P_Long_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- 减攻速
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local killer = eventData["killer"]
    local skill = eventData.attackData["skillConfig"]
    local victim = eventData["victim"]
    if self.player:equal(killer) and skill ~= nil and skill.anim_name == "skill3" and victim and victim.bufMgr and
            victim.bufMgr:hasBufByTag("P_Long_skill3") then
        victim.bufMgr:addBufById(self.buffData1, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M