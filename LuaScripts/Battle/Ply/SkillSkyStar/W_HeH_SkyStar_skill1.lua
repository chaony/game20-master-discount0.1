--镜里观花：
--“镜花水月”将可额外召唤一个幻影

---@class W_HeH_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HeH_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    self.extraSummon = self:getParam(1, 0)    --number[]    -- 额外召唤幻影

    self.extraSummon = math.min(self.extraSummon, 3)
end

function M:gameStart()
    local skill = self.player.plySkill:getSkillByName("skill3")
    ---@type W_HeH_skill3_1_Model
    local feature = skill and skill.cur_skill_config and skill.cur_skill_config.feature
    if feature then
        feature.maxSummon =feature.maxSummon + self.extraSummon
    else
        Logger.logError("天命化星找不到天山技能skill2")
    end
end

return M;