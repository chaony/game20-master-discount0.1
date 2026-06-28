-- lv4 累计收到80%伤害时，最多消耗4个枪头,每消耗1个枪头获得伤害减免20%，持续8秒

local W_BaWQ_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_BaWQ_skill1_3_Model")

---@class W_TangBH_skill1_4_Model : W_BaWQ_skill1_3_Model @
---@field super W_BaWQ_skill1_3_Model @W_BaWQ_skill1_3_Model
local M = class("W_TangBH_skill1_4_Model", W_BaWQ_skill1_3_Model)
 
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    
    self.takeTotalDamage = 0  -- 受到伤害
    EventDispatcher:registerEvent("injure", {self, self.injureHandle})
end

---@param eventData Battle_HandleData_Injure    
function M:injureHandle(eventName, eventData)
    if self.player:equal(eventData.victim) then
        self.takeTotalDamage = self.takeTotalDamage + eventData.wantdata.damage
        if self.takeTotalDamage >= GlobalTools:Mul(self.player.data:get_hp(), self.triggerHpRate) then
            self.takeTotalDamage = 0 -- 重新累计伤害
            local costLv = self:willCostResLv(self.triggerUseResLv)
            for i = 1, costLv do
                self.player.bufMgr:addBufById(self.triggerAddBuff, self.player, self.skill)
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandle })
    M.super.destroy(self)
end

return M