--战斗开始时，飞龙堡身边会环绕一个水环，当水环存在时，飞龙堡会获得20点急速，
--当受到致命伤害时，水环会消失并抵消本次伤害，之后飞龙堡会恢复30%最大生命值的伤害和200点内力

---@class W_FeiLB_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FeiLB_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addBuff1 = self:getParam(1)       -- Buff[]  水环buff
    self.addCure = self:getParam(2)       -- Fix[]  额外恢复生命

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)   -- 战斗开始时环绕一个水环
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then
            if self.player.bufMgr:hasBufByTag("W_FeiLB_SH_skill2") then
                eventData.wantdata.damage = 0   -- 免受本次伤害
                self.player.bufMgr:removeBufByTag("W_FeiLB_SH_skill2", false)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M
