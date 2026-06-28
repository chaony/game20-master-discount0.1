--当月寒宫受到致命伤害时，会消耗3把飞剑，使自身免疫本次的伤害并无敌1秒，并恢复20%最大血量，该技能有5秒cd
---@class W_YueHG_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YueHG_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    self.costNums = self:getParam(1)--消耗飞剑数量
    self.buffId1 = self:getParam(2) --无敌buff
    self.delayTime = self:getParam(3)-- cd时间
    self.buffId2 = self:getParam(4)-- 触发后增加的buff
    self.m_cd_flag = false
    self.can_use_flag = true
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    local skill2Item = self.player.plySkill:getSkillByName("skill2") -- 技能2可能未解锁
    if skill2Item ~= nil then
        self.skill2 = skill2Item.cur_skill_config.feature
    end
    M.super.spawn(self)
end

function M:canUse()
    return self.can_use_flag
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) and self:canUse() and not self.m_cd_flag and self.skill2 then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
            local canRemove = self.skill2:removeFeiJianBuff(self.costNums)
            if canRemove then
                self.m_cd_flag = true
                self.can_use_flag = false
                -- 免疫本次伤害
                eventData.wantdata.damage = 0
                self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
                self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                -- 开始内部冷却
                TimeTools:delayTime(self.delayTime, function()
                    self.m_cd_flag = false
                    self.can_use_flag = true
                end)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M