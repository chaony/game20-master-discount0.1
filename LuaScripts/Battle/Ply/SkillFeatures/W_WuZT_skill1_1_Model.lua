--武则天在敌方阵营中召唤牡丹，牡丹会在短暂延迟后炸开，对范围内的敌人造成200%攻击力的伤害，并为其施加一层“慑服”状态，处于慑服状态中的敌人每秒会受到60%攻击力的伤害，持续8秒，最多叠加5层
--lv3慑服状态每叠加一层，改状态造成的伤害便会提升20%

---@class W_WuZT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model

local M = class("W_WuZT_skill1_3_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffEffectTab = {}
    for i = 1, 5 do
        self.buffEffectTab[i] = self:getParam(i)
    end
    EventDispatcher:registerEvent("add_W_WuZT_skill1", {self,self.addBuffHandler})
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local target = buff.player
        if target and target.bufMgr then
            local buffs = target.bufMgr:findBufByTag("W_WuZT_skill1")
            local buffNums = #buffs
            if self.buffEffectTab[buffNums] then
                target.bufMgr:removeBufByTag("W_WuZT_skill1_effect", true)
                target.bufMgr:addBufById(self.buffEffectTab[buffNums], self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_WuZT_skill1", {self, self.addBuffHandler})
    M.super.destroy(self)
end

return M
