--当天墉城的生命值首次低于50%时，将召唤煞魄护体，获得30%的伤害减免效果，持续8秒
---@class W_TianYC_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianYC_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpRate = self:getParam(1) -- 召唤触发生命比例
    self.useFlag = false -- 该被动只能触发一次
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if not self.useFlag then
        local rate = self.player.data:get_hpRate();
        if rate <= self.hpRate then
            self.useFlag = true
            self.player:useSkill("skill0",true) -- 强制用一次skill0
        end
    end 
end


function M:destroy()
    M.super.destroy(self)
end

return M