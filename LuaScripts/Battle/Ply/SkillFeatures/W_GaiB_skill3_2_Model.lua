--等级2:伤害提升至350%攻击力，该技能每命中一个敌方侠客，丐帮就回复5%最大生命值的血量，最多恢复15%
local W_GaiB_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_GaiB_skill3_1_Model")
---@class W_GaiB_skill3_2_Model : W_GaiB_skill3_1_Model @
---@field super W_GaiB_skill3_1_Model @W_GaiB_skill3_1_Model
local M = class("W_GaiB_skill3_2_Model", W_GaiB_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --回血比例
    self.cureRate = self:getParam(2)
    self.maxRate = self:getParam(3)
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        local rate = GlobalTools:Mul(GlobalTools:ToFix(data.Count), self.cureRate)
        if rate > self.maxRate then
            rate = self.maxRate
        end
        self.player:cure("fix", self.player, GlobalTools:Mul(rate, self.player.data:get_hp()), self.skill)
    end
    return data
end

--销毁
function M:destroy()
    M.super.destroy(self)
end
return M