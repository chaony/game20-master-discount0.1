--战斗开始时，吉祥创造1个分身继承随机一位射手侠客25%攻击力，该分身可以攻击敌方侠客，且自身免疫侠客伤害。
--当分身暴击时，对敌方全体侠客追加一次基于侠客最大生命值3%的伤害。当击败敌方宠物后，吉祥会加强分身，加强后：分身可继承该场选定射手侠客30%的攻击力。当吉祥本体死亡后分身消失。

---@class P_Long_xiezhanskill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_xiezhanskill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addSummonBuff = self:getParam(1) -- Buff[] 分身buff
    self.atkPercent = self:getParam(2) -- Fix[0-1] 继承百分比
    self.atkPercent2 = self:getParam(3) -- Fix[0-1] 升级后继承百分比

    --- 召唤龙
    self.summon = nil

    self.isUpgrade = false -- 是否击杀敌方宠物
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self:callSummon()
end

function M:callSummon()
    if self.summon ~= nil then
        return
    end

    local friends = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "friend",
        ignoreSummon = true,
        roleType = 4,   --射手
        priority = true,
    })
    if friends.Count == 0 then
        return
    end

    local target = friends:get(0)
    self.selectTarget = target  -- 选定的目标
    -- 宠物配置
    local frame = self.player.evtMgr:getActionFrameByKey("xiezhanskill1", "Sendfor", 1)
    local summonData = table.copy(frame.data)

    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    SendForFuncframe:init(summonData, self.player)
    self.summon = SendForFuncframe.player
    if self.summon ~= nil then
        self.summon.data:set_level(target.data:get_level())
        self.summon.data:set_evo(target.data:get_evo())
        self.summon.plySkill:refreshSkill(nil)
        self.summon.bufMgr:addBufById(self.addSummonBuff, self.player, self.skill)

        self.summon.data.hp:setInitialValue(self.summon.data:getCopyData(target.data.hp, true, self.atkPercent))
        self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(target.data.atk, true, self.atkPercent))
        self.summon.data:set_curHp(self.summon.data:get_hp())
        self.summon:setPos(self.player.position + self.player:getForward() * GlobalTools.base2);
        self.summon:ShowHpBar(false)
    end
end

---@param eventData Battle_HandleData_PlayerDead
function M:PlayerDeadHandler(eventName, eventData)
    if (not self.isUpgrade) and self.player:isXiaKe() then      -- 宠物不走本逻辑
        if eventData.data.playerType == "pet" and BattleTool:killerIsMe(self.player, eventData.data) then
            self.isUpgrade = true
            if self.selectTarget then
                self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(self.selectTarget.data.atk, true, self.atkPercent2))
            end
        end
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    -- 分身暴击逻辑 暴击效果由策划配置
    if eventData.attackData.isCrit and (not self.player:isXiaKe()) and self.player:equal(eventData.killer) then
        BattleTool:safeTriggerActionEventWork(self.player, "xiezhanskill1", "Hit", 1)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M