--战斗中，白驼的最大生命值增加15%
---@class W_BaiT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiT_skill0_1_Model", SkillFeatures_Model)

M.hp = nil

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    local hpRate = self.player.data:get_hpRate();
    self.player.data.hp:addToMulList(self.hp)
    local hp_value = GlobalTools:Mul( self.player.data:get_hp(), hpRate )
    self.player.data:set_curHp( hp_value )
end

function M:destroy()
	M.super.destroy(self)
end

return M