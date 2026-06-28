--万兽庄 skill2 普通攻击暴击时，将为敌人附加一层“撕裂”状态
---@class W_WanShou_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanShou_attack1_Model", SkillFeatures_Model)

M.sendForData = require("Battle.Ply.SkillFeaturesData.W_WanShou_attack1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className) 
end

--function M:spawnFinish( )
--    self:sendfor()
--end
--
----召唤
--function M:sendfor()
--    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
--    local ply = self.player
--    if ply.master ~= nil then
--        ply = ply.master
--    end
--    if self.player.camp ==-1 then
--        self.sendForData["distance"] = "-2"
--    else
--        self.sendForData["distance"] = "2"
--    end
--    SendForFuncframe:init(self.sendForData, ply)
--end

return M