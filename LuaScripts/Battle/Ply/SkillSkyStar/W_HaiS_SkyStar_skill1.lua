--铁布衫：
--战斗开始时，海沙的防御力提升50%，受到的暴击伤害降低50%，持续10秒。

---@class W_HaiS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HaiS_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.addBuff = self:getParam(1, 0)   --Buf[] -- 提升buff
end

function M:gameStart()
    self.player.bufMgr:addBufById(self.addBuff, self.player)
end

return M;