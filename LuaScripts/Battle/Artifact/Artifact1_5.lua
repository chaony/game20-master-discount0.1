
--三级复苏之佑 护盾抵消的伤害量提升至220% 攻击力伤害 并提供三秒的控制免疫
local Artifact1_2 = require("Battle.Artifact.Artifact1_2")
---@class Artifact1_5 : Artifact1_2 @
---@field super Artifact1_2 @Artifact1_2
local M = class("Artifact1_5", Artifact1_2)

--伤害buf
M.atkBuffid = 0
--初始化
function M:init(player,data)
    M.super.init(self, player, data)
    self.atkBuffid = self:getValue(2)

end

function M:gameStart()
    M.super.gameStart(self)
end

function M:addSkillBuf()
	M.super.addSkillBuf(self)
    local buff1 = self.player.bufMgr:findBufById(self.atkBuffid)
    if table.nums(buff1) <= 0 then
       self.player.bufMgr:addBufById(self.atkBuffid, self.player)
    end
	
end

return M