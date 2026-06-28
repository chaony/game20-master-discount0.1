--释放技能时，若场上有狼王存在，则该技能的伤害额外提升20%
local W_WanS_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_WanS_skill3_1_Model")
---@class W_WanS_skill3_2_Model : W_WanS_skill3_1_Model @
---@field super W_WanS_skill3_1_Model @W_WanS_skill3_1_Model
local M = class("W_WanS_skill3_2_Model", W_WanS_skill3_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.atk2 = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
end


function M:getAtkUp(victim, data)
    local atk = M.super.getAtkUp(self, victim, data)
    for i = 1, self.player.summonList.list.Count do
        local key = self.player.summonList.list:get(i-1)
        local plys = self.player.summonList:get(key)
        for i, v in ipairs(plys) do
            if v ~= nil and v:isLive() == true then
                atk = atk + self.atk2
                return atk
            end
        end
    end

    return atk
end

function M:destroy()
    M.super.destroy(self)
end

return M