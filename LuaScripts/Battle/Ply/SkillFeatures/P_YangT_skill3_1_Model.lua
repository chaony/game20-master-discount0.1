--阿驼将会持续嘲讽大范围内的敌方6秒,并且在嘲讽敌方时，阿驼自身将获得40%的伤害减免
---@class P_YangT_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end

    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
    end
end

function M:skillEnd(data)
    if self.skill0 and self.skill0.buffData then
        self.player.bufMgr:addBufById(self.skill0.buffData, self.player) -- 有skill0，再触发skill0效果
    end

    if self.skill1 and self.skill1.buffData then
        self.player.bufMgr:addBufById(self.skill1.buffData, self.player) -- 有skill1，再触发skill1效果
    end
    M.super.skillEnd(self,data)
end


function M:destroy()
    M.super.destroy(self)
end

return M