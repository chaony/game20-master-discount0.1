--胜天半子：
--被技能“奇门遁甲”换位的敌方侠客，将眩晕3秒。

---@class W_GuiG_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_GuiG_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.addBuff = self:getParam(1, 0)   --Buf[] -- 提升buff
end

---@param target PlayerModel
function M:triggerStart(target)
    if target then
        target.bufMgr:addBufById(self.addBuff, self.player)
    end
end

return M;