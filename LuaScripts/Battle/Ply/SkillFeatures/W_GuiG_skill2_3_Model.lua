--鬼谷 skill2被动
--开局将我方后排血量最多的队友和敌人后排血量最少的敌人互换位置
--被换过去的我方角色获得30%的伤害减免
--被缓过来的敌方角色将获得30%的伤害加深

local W_GuiG_skill2_2_Model = require("Battle.Ply.SkillFeatures.W_GuiG_skill2_2_Model")
---@class W_GuiG_skill2_3_Model : W_GuiG_skill2_2_Model @
---@field super W_GuiG_skill2_2_Model @W_GuiG_skill2_2_Model
local M = class("W_GuiG_skill2_3_Model", W_GuiG_skill2_2_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId2 = self:getParam(2)
end


function M:addcamp_Buf(player)
     M.super.addcamp_Buf(self, player)
    if player.camp ~= 1 then
        player.bufMgr:addBufById(self.buffId2, self.player)
    end
end


return M