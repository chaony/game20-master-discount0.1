--月寒宫召唤飞剑攻击水平方向上的敌人，对其造成200%攻击力的伤害，当月寒宫的伤害造成暴击时，会额外触发一次，但会有5秒钟的冷却时间
--lv2释放时若自身有3把飞剑，则会使技能范围扩大
---@class W_YueHG_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YueHG_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    self.cdTimes = self:getParam(1)--cd
    self.costNums = self:getParam(2) --消耗飞剑数量
    self.minNums = self:getParam(3) --触发飞剑数量
    self.cd_flag = false
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

--技能释放,只有当前技能会调用
function M:skillStart(data)
    if self.skill2 == nil then
        return
    end
    if self.costNums >= 0 and self.skill2 ~= nil  then
        if self.skill2:getFeiJianBuffNums() >= self.minNums then
            self.skill.extra_anim_name = "skill1_1"
        end
    end
end

---@param afterAttackData Battle_HandleData_Attack
function M:killerAfterAttack(afterAttackData)
    if afterAttackData.isCrit then
        if self.player.aiEngine ~= nil and not self.cd_flag then
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")
            self.cd_flag = true
            -- 开始内部冷却
            TimeTools:delayTime(self.cdTimes, function()
                self.cd_flag = false
            end)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M