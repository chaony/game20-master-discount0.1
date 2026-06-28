--"折梅：
--印记触发间隔减少至4秒，且引爆印记时，将眩晕目标1秒。"

---@class W_HengS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HengS_SkyStar_skill1", SkillSkyStar)

function M:gameStart()
    local skill = self.player.plySkill:getSkillByName("skill0")
    if skill and skill.cur_skill_config then
        -- 前置cd为0
        skill.cur_skill_config.pre_cd = 0
        skill.cur_skill_config.auto_pre_cd = 0
        skill.cur_skill_config.cur_pre_cd = 0       
    else
        Logger.logError("天命化星找不到恒山技能skill0")
    end    
end

return M;