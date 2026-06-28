--该技能每成功命中一个敌人，自身便恢复5%最大生命值的血量，最多恢复15%
---@class W_TianXH_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill1_3_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --特效buff
    self.effectBuff = self:getParam(1)
    self.cureRate = self:getParam(2)
    self.maxCount = self:getParam(3)
end

--查找敌人
function M:findPlayer(data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then

        local count = data.Count
        if count > self.maxCount then
            count = self.maxCount
        end
        if count > 0 then
            self.player.bufMgr:addBufById(self.effectBuff)
            local rate = GlobalTools:Mul(self.cureRate, GlobalTools:ToFix(count))
            self.player:cure("fix", self.player, GlobalTools:Mul(rate, self.player.data:get_hp()), self.skill)
        end
    end
    return data
end

function M:destroy()
    M.super.destroy(self)
end

return M