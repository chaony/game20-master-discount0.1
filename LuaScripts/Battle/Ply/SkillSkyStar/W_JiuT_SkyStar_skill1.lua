--道生一：
--当场上有阴、阳系角色上阵时，九天生命值提高20%，攻击力提高10%，并获得100点坚韧值。

---@class W_JiuT_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JiuT_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    self.addBuff = self:getParam(1, 0)   --Buf[] -- 提升buff
end

function M:gameStart()
    self.player.bufMgr:addBufById(self.addBuff, self.player)
end

return M;