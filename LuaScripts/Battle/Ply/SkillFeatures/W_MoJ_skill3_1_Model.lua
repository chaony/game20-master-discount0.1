--使自己和机关塔进入狂暴模式6秒，狂暴模式下，墨家和机关塔的最大生命值翻倍，攻速增加60点,攻击力增加30%,狂暴模式结束时，墨家和机关塔会保持当前生命比例不变,若机关塔已经死亡，则会复活机关塔并恢复其60%最大生命值后进入狂暴模式
---@class W_MoJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MoJ_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureHp = self:getParam(1)
    self.buff = self:getParam(2)
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        self.skill0 = skill0.cur_skill_config.feature
    end
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.skill1 ~= nil then
        self.skill.extra_anim_name = "skill3_1"
    else
        self.skill.extra_anim_name = "skill3_2"
    end
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" and self.player:equal(victim.master) == true then
        local attack1_item = victim.plySkill:getSkillByName("attack1")
        local attack1 = attack1_item.cur_skill_config.feature
        if attack1.isDead == true then
            attack1:reSpawn(self.cureHp)
        end 
        victim.bufMgr:addBufById(self.buff, self.player)
    end
end

--技能事件
function M:skillDispatch(data)
    if data.eventName == "skill3_fire" then
        self.player.bufMgr:addBufById(self.buff, self.player)
        if self.player.skyStar ~= nil then
            self.player.skyStar:triggerStart(self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M