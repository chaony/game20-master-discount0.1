--玉女飞剑：
--当场上除天山外仍友方侠客存在，则天山永不落地

---@class W_TianS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TianS_SkyStar_skill1", SkillSkyStar)

function M:gameStart()
    local skill = self.player.plySkill:getSkillByName("skill2")
    ---@type W_TianS_skill2_1_Model
    local feature = skill and skill.cur_skill_config and skill.cur_skill_config.feature
    if feature then
        feature.landIfKillOne = false
    else
        Logger.logError("天命化星找不到天山技能skill2")
    end
end

return M;