--当姬霜受到致命伤害烟雾隐藏自身期间，随机魅惑敌方1名侠客3秒

---@class W_JiS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JiS_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --随机魅惑敌方1名侠客3秒
    self.buffId = self:getParam(1, 0)    --Buff[]
end
---@param player PlayerModel
function M:triggerStart(player)
    if player and player.bufMgr then
        player.bufMgr:addBufById(self.buffId, self.player)
    end
end

return M;