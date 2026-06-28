--该技能至少击中了一名敌人，则随后释放的“战八方”的冷却时间会大幅度缩短 
---@class W_TianC_skill1_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianC_skill1_2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.coldTime = self:getParam(1)
end


--查找敌人
function M:findPlayer(data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        if data.Count > 0 then
            self.skill.cur_post_cd = self.skill.cur_post_cd - self.coldTime
        end
    end
    return data
end


function M:destroy()
	M.super.destroy(self)
end

return M