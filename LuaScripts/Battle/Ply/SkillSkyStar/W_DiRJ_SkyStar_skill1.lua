--料事如神：狄仁杰复活并使自身无敌时间提升至3秒

---@class W_DiRJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_DiRJ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1)
end

---@param target PlayerModel
function M:triggerStart()
    self.player.bufMgr:addBufById(self.buffId, self.player)
end

return M;