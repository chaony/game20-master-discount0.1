--每拥有最大生命值的18%，还将额外提升6的暴击率，至多提升30暴击率
local W_WuD_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_WuD_skill0_1_Model")

---@class W_WuD_skill0_2_Model : W_WuD_skill0_1_Model @
---@field super W_WuD_skill0_1_Model @W_WuD_skill0_1_Model
local M = class("W_WuD_skill0_2_Model", W_WuD_skill0_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.crit = self:getParam(4)
    self.critMaxCount = self:getParam(5)
    self.curCritCount = 0
    self.last_cirt_value = 0
end

function M:change(count)
    M.super.change(self, count)
    if count ~= self.curCritCount then
        if count > self.critMaxCount then
            count = self.critMaxCount
        end
        self.curCritCount = count
        self.player.data.critrate:removeFromAddList( self.last_cirt_value)
        local crit_value = GlobalTools:Mul(self.curCritCount, self.crit)
        self.last_cirt_value = crit_value;
        self.player.data.critrate:addToAddList(crit_value)
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M