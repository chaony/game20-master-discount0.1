--角色的专属装备
--唐门 所有蛇毒的伤害提升15%
---@class W_TangM_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TangM_Trait0", PlayerTrait)


M.atk = 0

M.skill1 = nil

function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)

    self.skill1 = self.player.plySkill:getSkillByName("skill1")
end


function M:spawn()
    M.super.spawn(self) 
--蛇毒伤害根据表改
--    self.player.skillImprove:addItem(v)

    self.skill1.cur_skill_config.feature.atk = self.skill1.cur_skill_config.feature.atk + self.atk 
end



function M:destroy()
   

    M.super.destroy(self)
end

return M