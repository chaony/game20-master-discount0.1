--九黎虎
---@class W_JiuL2_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuL2_attack1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawn()
    local attack1 = self.player.master.plySkill:getSkillByName("attack1")
    if attack1 ~= nil then
        self.attack1 = attack1.cur_skill_config.feature
    end
end

--角色死亡
function M:dead(data)
    self.player.data:set_curHp(GlobalTools.base1)
    self.attack1:deactive()
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M