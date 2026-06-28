---@class G_FuW_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("G_FuW_attack1_Model", SkillFeatures_Model)

M.sendForData = require("Battle.Ply.SkillFeaturesData.G_FuW_attack1_Data");

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className) 
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