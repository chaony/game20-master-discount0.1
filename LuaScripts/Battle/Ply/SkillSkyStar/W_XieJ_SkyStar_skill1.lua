--极阴之煞：
--邪极开场时获得2层邪灵效果。

---@class W_XieJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_XieJ_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.addRes = self:getParam(1, 0)   --int[]
end

function M:gameStart()
    local skill = self.player.plySkill:getSkillByName("skill1")
    ---@type W_XieJ_skill1_1_Model
    local feature = skill and skill.cur_skill_config and skill.cur_skill_config.feature
    if feature then
        feature:improveResStack(self.addRes)
    else
        Logger.logError("天命化星找不到邪极技能skill1")
    end
end

return M;