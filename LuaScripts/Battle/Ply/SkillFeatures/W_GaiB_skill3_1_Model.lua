--丐帮向前方打出一记强力掌法，造成300%攻击力的外功伤害和击退效果，如果改技能只命中了一个敌人，则造成的伤害提高50%
---@class W_GaiB_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GaiB_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --伤害提升
    self.dmg = self:getParam(1)
    self.enemyCount = 0
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        self.enemyCount = data.Count
    end
    return data
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local skill = data.attackData["skillConfig"]
    if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill3" then
        if self.enemyCount == 1 then
            data["damage"] = dmg + GlobalTools:Mul(dmg, self.dmg)
        end
    end
end

--技能结束(仅当前技能调用)
function M:skillEnd(data)
    M.super.skillEnd(self, data)
    self.enemyCount = 0
end

--销毁
function M:destroy()
    M.super.destroy(self)
end
return M