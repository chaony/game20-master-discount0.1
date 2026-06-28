--重剑决：藏剑横向挥舞重剑，对身前大范围内的敌人造成200%攻击力的伤害并将其击退，释放该技能后，藏剑会切换为“轻剑决”姿态；
--轻剑决：藏剑连续挥出多段斩击，对身前小范围内的敌人造成共计300%攻击力的外功伤害，释放完该技能后，藏剑会切换为“重剑决”姿态
---@class W_CangJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangJ_skill3_1_Model", SkillFeatures_Model)
--当前状态，1位重剑，2为轻剑

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.skill0 = self.player.plySkill:getSkillByName("skill0")
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
    self.skill2 = self.player.plySkill:getSkillByName("skill2")
    self.state = 0
    self:changeState()
    EventDispatcher:registerEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
end

--技能释放
function M:skillStart(data)
    M.super.skillStart(self, data)
    self.skill.extra_anim_name = "skill3_"..self.state
end

function M:changeState()
    --原本是重剑，切换为轻剑
    if self.state == 1 then
        self.state = 2
        --重置技能2的cd
        if self.skill0 ~= nil then
            self.skill0.cur_skill_config:use()
        end
    --原本是轻剑，切换为重剑
    else
        self.state = 1
        --重置技能1的cd
        if self.skill2 ~= nil then
            self.skill2.cur_skill_config:use()
        end
    end
    
    self:dispatchEvent_Local(Battle.SkillEventType.W_CangJ_skill3_1_Model_ChangeState, {state = self.state})

    if self.skill1 ~= nil then
        self.skill1.cur_skill_config.feature:changeState(self.state)
    end
end

--技能结束
function M:skillEnd(data)
    M.super.skillStart(self, data)
    self:changeState()
    --每次切换至“重剑决”姿态时，会立即释放一次技能1
    if self.player.aiEngine ~= nil then
        if self.state == 1 then
            if self.skill2 ~= nil and self.skill2.cur_skill_config.feature.useImmediately == true then
                self.player.aiEngine.skillConfig = self.skill2.cur_skill_config
                return "attack"
            end
            --每次切换至“重剑决”姿态时，会立即释放一次技能2
        elseif self.state == 2 then
            if self.skill0 ~= nil and self.skill0.cur_skill_config.feature.useImmediately == true then
                self.player.aiEngine.skillConfig = self.skill0.cur_skill_config
                return "attack"
            end
        end
    end
end

--ai状态切换
function M:ChangeAiStateHandler( eventName, data )
    local player = data.player
    local curState = data.curState
    local targetState = data.targetState

    if self.player:equal(player) == true and self.state == 2 then
        if targetState.anim_name == "idle" then
            targetState.extra_anim_name = "idle"..self.state
        elseif targetState.anim_name == "battle_idle" then
            targetState.extra_anim_name = "battle_idle"..self.state
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    M.super.destroy(self)
   
end
return M