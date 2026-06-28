--沈嫣立即为我方最虚弱的一名敌人施加治疗效果，为其恢复300%攻击力的生命值，并使其受到的伤害减少20%,持续5秒。
--若该侠客的血量已满，则溢出部分的治疗效果的60%会转化为护盾，持续5秒

---@class W_ShenY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.shieldPercent = self:getParam(1)    -- Fix[] 治疗量转护盾
    self.buffId = self:getParam(2)    -- Buff[] 护盾buff

    EventDispatcher:registerEvent("cureOverflow", {self,self.cureOverflowHandler})
end

---@param eventData Battle_HandleData_CureOverFlow
function M:cureOverflowHandler(eventName, eventData)
    if eventData.sourceBuff and self.skill == eventData.sourceBuff.sourceSkill then -- 是本技能造成的治疗
        local buffData = table.copy(self.player.bufMgr.bufData[self.buffId])
        if buffData then
            --local targets = SelectTargetUtil:findPlayerByParam(self.player, {
            --    camp = "friend",
            --    ignoreSummon = true,
            --    pos = "hpRateLeast",
            --    --priority = true,
            --})
            local target = eventData.player
            if target then
                local guard_value = GlobalTools:Mul(eventData.overflow, self.shieldPercent)
                BattleTool:addFixedShield(self.player, target, buffData, guard_value, self.skill, self.buffId)
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("cureOverflow", {self,self.cureOverflowHandler})
    M.super.destroy(self)
end

return M