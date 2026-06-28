-- 通用天命3，加buff

---@class SkyStar_Skill3_AddBuff : SkillSkyStar
---@field super SkillSkyStar
local M = class("SkyStar_Skill3_AddBuff", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.addBuff = self:getParam(1, 0)          --Buff[]   -- 添加buff
end

-- 激活化解伤害能力
function M:gameStart()
    self.player.bufMgr:addBufById(self.addBuff, self.player)
end

return M;