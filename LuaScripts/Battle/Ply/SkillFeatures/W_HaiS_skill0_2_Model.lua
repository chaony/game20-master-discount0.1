--当自身血量首次低于50%时，会额外获得一个相当于自身生命值40%的护盾，持续8秒
local W_HaiS_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_HaiS_skill0_1_Model")
---@class W_HaiS_skill0_2_Model : W_HaiS_skill0_1_Model @
---@field super W_HaiS_skill0_1_Model @W_HaiS_skill0_1_Model
local M = class("W_HaiS_skill0_2_Model", W_HaiS_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpValue = self:getParam(3) -- 护盾触发的血量比例
    self.shieldBuff = self:getParam(4) -- 护盾buff
    
end

function M:spawn()
    M.super.spawn(self)
    self.first = true
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.first == true and self.player.data:get_hpRate() <= self.hpValue then
        self.player.bufMgr:addBufById(self.shieldBuff, self.player, self.skill)
        self.first = false
    end
end

function M:destroy()
    M.super.destroy(self)
end

   

return M