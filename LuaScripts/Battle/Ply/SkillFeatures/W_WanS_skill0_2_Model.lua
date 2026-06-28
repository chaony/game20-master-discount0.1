--狼王的攻击造成暴击时，会使万兽和狼王的攻速提升30%，持续5秒
local W_WanS_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_WanS_skill0_1_Model")

---@class W_WanS_skill0_2_Model : W_WanS_skill0_1_Model @
---@field super W_WanS_skill0_1_Model @W_WanS_skill0_1_Model
local M = class("W_WanS_skill0_2_Model", W_WanS_skill0_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    
    self.speedBuff = self:getParam(2)
end

--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    local isCrit = data["isCrit"]
    local ply = data["killer"]
    local victim = data["victim"]
    local skill_cofig = data["attackData"]["skillConfig"]
    if ply ~= nil and self.player:equal(ply.master) then
        if victim ~= nil and victim:isLive() and isCrit == true then
            self.player.bufMgr:addBufById(self.speedBuff, self.player)
            ply.bufMgr:addBufById(self.speedBuff, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M