--吕布“天下无双”状态每秒消耗内力降低为80，且每秒增加1%暴击抵抗

---@class W_LvB_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LvB_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --self.costAnger = self:getParam(1)
    --buffid
    self.bufId = self:getParam(1)
end

function M:triggerStart(skill)
    if skill then
        self.player.bufMgr:addBufById(self.bufId, self.player,skill)
        --if self.costAnger > 0 then
        --    skill.costAngerUnit = self.costAnger
        --end
        --skill.buffId3 = self.bufId
    end
end

return M;