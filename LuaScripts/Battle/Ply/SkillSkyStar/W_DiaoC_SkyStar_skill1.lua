--每次普攻可以提高自身2.5%的攻速和攻击力，最多叠加10层

---@class W_DiaoC_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_DiaoC_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1)
end

---@param target PlayerModel
function M:skillEnd( ply, skill )
    if skill.anim_name == "attack1" then
        self.player.bufMgr:addBufById(self.buffId, self.player)
    end
end

return M;