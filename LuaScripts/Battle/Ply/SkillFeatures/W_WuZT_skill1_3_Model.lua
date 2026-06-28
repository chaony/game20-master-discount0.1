--武则天在敌方阵营中召唤牡丹，牡丹会在短暂延迟后炸开，对范围内的敌人造成200%攻击力的伤害，并为其施加一层“慑服”状态，处于慑服状态中的敌人每秒会受到60%攻击力的伤害，持续8秒，最多叠加5层
--lv3慑服状态每叠加一层，改状态造成的伤害便会提升20%
local W_WuZT_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_WuZT_skill1_1_Model")

---@class W_WuZT_skill1_3_Model : W_WuZT_skill1_1_Model @
---@field super W_WuZT_skill1_1_Model @W_WuZT_skill1_1_Model

local M = class("W_WuZT_skill1_3_Model", W_WuZT_skill1_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.unitFloores = self:getParam(6)       --Fix[] 单位层数
    self.addHurtRate = self:getParam(7) --伤害便会提升20%
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.killer) then
        local attackData = eventData.attackData
        if attackData.sourceBuff and attackData.sourceBuff:checkTag("W_WuZT_skill1") then
            local victim = eventData["victim"]
            if victim and victim.bufMgr then
                local buffs = victim.bufMgr:findBufByTag("W_WuZT_skill1")
                local buffNums = #buffs
                if buffNums > 0 then
                    local addDamageRate = GlobalTools:Mul(self.addHurtRate, GlobalTools:ToFix(buffNums))
                    eventData.wantdata.damage = eventData.wantdata.damage + GlobalTools:Mul(addDamageRate, eventData.wantdata.damage)
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M
