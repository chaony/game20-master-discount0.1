---@class W_FuW_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FuW_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    local sendForData = require("Battle.Ply.SkillFeaturesData.W_FuW_attack1_Data");
    self.sendForData = table.copy(sendForData)
end

function M:spawnFinish( )
    self:sendfor()
end

--召唤
function M:sendfor()
    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    local ply = self.player
    if ply.master ~= nil then
        ply = ply.master
    end
    SendForFuncframe:init(self.sendForData, ply)
end


return M