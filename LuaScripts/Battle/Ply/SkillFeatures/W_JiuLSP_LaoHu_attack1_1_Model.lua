--Sp九黎虎
---@class W_JiuLSP_LaoHu_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuLSP_LaoHu_attack1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawn()
    local skill2 = self.player.master.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        self.skill2 = skill2.cur_skill_config.feature
    end
end

function M:killerAfterAttack(data)
    M.super:killerAfterAttack(data)
    if  self.player.master ~= nil and self.player.master:isLive() and  self.player.master.skyStar then
        self.player.master.skyStar:triggerStart(data)
    end

end

--角色死亡
function M:dead(data)
    self.player.data:set_curHp(GlobalTools.base1)
    self.skill2:changeToCat()
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M