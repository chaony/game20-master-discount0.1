--朝前方喷出一道直的火焰攻击敌方宠物单位，对直线上的所有宠物单位造成200%的伤害，所有被火焰击中的敌方被挂上火种并进入灼烧状态（类似裂伤），
--火种与裂伤效果持续5S。若在斗气阶段胜出，技能效果强化为：可造成220%的伤害。
---@class P_Long_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.battleWin = self.player.power_win == 1 -- 比斗气是否胜出
end

function M:spawn()
    M.super.spawn(self)
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end
end

function M:skillStart(data)
    if self.battleWin then
        self.skill.extra_anim_name = "skill3_1"
    else
        self.skill.extra_anim_name = "skill3"
    end
    M.super.skillStart(self, data)
end

function M:skillEnd(data)
    if self.skill0 and self.skill0.buffData then
        self.player.bufMgr:addBufById(self.skill0.buffData, self.player) -- 有skill0，再触发skill0效果
    end
    M.super.skillEnd(self,data)
end


function M:destroy()
    M.super.destroy(self)
end

return M