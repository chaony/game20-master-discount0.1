---@class W_FuW_skill0 : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FuW_skill0", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
end

function M:canUse()
    if self.player.medCount ~= nil then
        if self.player.medCount < self.player.medMaxCount then
            return true
        end
    end
    return false
end

--技能释放
function M:skillStart()
    if self.skill1 ~= nil and self.player.medCount ~= nil then
        if self.player.medCount < self.player.medMaxCount then
            self.skill1:setMed(self.player.medCount + 1)
        end
    end
end

return M