--被命中的敌人身上如果有慑服状态，则会清除所有慑服状态并使其伤害立刻生效
--若被命中的敌人身上同时有“慑服”和“审判”状态，则该技能造成的伤害会提升50%

---@class W_WuZT_skill3_4_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_skill3_4_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.addHurtRate = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local attackData = eventData.attackData
    if self.player:equal(attackData.player) and attackData.skillConfig and attackData.skillConfig.anim_name == "skill3" then
        local killer = eventData["killer"]
        local victim = eventData["victim"]
        local skillConfig = eventData["attackData"]["skillConfig"]
        if self.addHurtRate > 0  then
            local buffs = victim.bufMgr:findBufByTag("W_DiRJ_skill1")
            if #buffs > 0 then
                local buffs2 = victim.bufMgr:findBufByTag("W_WuZT_skill1")
                if #buffs2 > 0 then
                    eventData.wantdata.damage =  eventData.wantdata.damage + GlobalTools:Mul(eventData.wantdata.damage, self.addHurtRate)
                end
            end
        end
        if victim and victim.bufMgr then
            local buffs = victim.bufMgr:findBufByTag("W_WuZT_skill1")
            for k, v in ipairs(buffs) do
                v:triggerDelayBuffImmediately(true, false)
            end
        end
    end
end
--
-----技能增伤
--function M:killerBeforeAttack(attackData, victim)
--    if self.addHurtRate > 0 and self.player:equal(attackData.player) and attackData.skillConfig and attackData.skillConfig.anim_name == "skill3" then
--        local buffs = victim.bufMgr:findBufByTag("W_DiRJ_skill1")
--        if #buffs > 0 then
--            local buffs2 = victim.bufMgr:findBufByTag("W_WuZT_skill1")
--            if #buffs2 > 0 then
--                attackData.damageExtra = attackData.damageExtra + GlobalTools:Mul(attackData.damage, self.addHurtRate)
--            end
--        end
--    end
--end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M
