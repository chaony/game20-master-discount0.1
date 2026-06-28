--狄仁杰先为所有敌方侠客施加一层断狱状态，随后对其进行审判，敌人身上每有一层“断狱”状态，便会被施加一层“伏刑”状态，
--“伏刑”状态会持续3秒，且每秒会发作一次，每次发作时会造成100%攻击力的伤害和0.5秒的眩晕效果，该技能施加的眩晕效果可以叠加
--lv4 被叠加三层伏刑状态的敌方侠客将会立即被眩晕2秒
---@class W_DiRJ_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 3 do
        self.buffEffectTab[i] = self:getParam(i)
    end
    self.fuXingBuff = self:getParam(4)--服刑buff
    self.triggerNums = self:getParam(5)--触发层数
    self.buffId = self:getParam(6)--眩晕buff
    EventDispatcher:registerEvent("add_W_DiRJ_skill1", {self, self.addBuffHandler2})
    EventDispatcher:registerEvent("add_fuxing", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

---@param eventData Battle_HandleData_SkillEnter
function M:SkillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3_plus" then
        local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true, priority = true})
        for i = 1, targets.Count do
            local player = targets:get(i - 1)
            if player and player.bufMgr then
                local buffs = player.bufMgr:findBufByTag("W_DiRJ_skill1")
                local buffNums = #buffs
                buffNums = buffNums > 5 and 5 or buffNums
                for j = 1, buffNums do
                    player.bufMgr:addBufById(self.fuXingBuff, self.player, self.skill)
                end
            end
        end
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if self.triggerNums > 0 and eventData.buff and self.player:equal(eventData.buff.source) then     -- 自己加的buff
        local target = eventData.buff.player
        -- 符合条件立刻眩晕
        if target and #target.bufMgr:findBufByTag("fuxing") >= self.triggerNums then
            target.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    end
end

function M:addBuffHandler2(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local target = buff.player
        if target and target.bufMgr then
            local buffs = target.bufMgr:findBufByTag("W_DiRJ_skill1")
            local buffNums = #buffs
            buffNums = buffNums > #(self.buffEffectTab) and #(self.buffEffectTab) or buffNums
            if self.buffEffectTab[buffNums] then
                target.bufMgr:removeBufByTag("W_DiRJ_skill3_effect", true)
                target.bufMgr:addBufById(self.buffEffectTab[buffNums], self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_DiRJ_skill1", {self, self.addBuffHandler2})
    EventDispatcher:unRegisterEvent("add_fuxing", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end

return M