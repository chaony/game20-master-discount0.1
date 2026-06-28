---@class W_XingY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingY_skill3_1_Model", SkillFeatures_Model)

M.extraName = "skill3"

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil then
        self.attack1 = attack1.cur_skill_config.feature
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    M.super.killerAfterAttack(self, data)
    if self.attack1 ~= nil and self.attack1.state == self.skill then
        self.player.bufMgr:addBufById(self.buffId, self.player,self.skill)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M