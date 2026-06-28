---@class W_JueZ_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JueZ_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    local useSkill2 = false
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        local skill2Prob = skill2.cur_skill_config.feature.prop * 100
        local value = WRandom:randomNum(0, 100)
        useSkill2 = (value <= skill2Prob)
    end
    if useSkill2 then
        self.player:set_curSkillConfig(skill2.cur_skill_config)
    end
end

return M