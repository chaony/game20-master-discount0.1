--悲魔山庄	烈火情天
--lv4 释放该技能后3秒内，破天劲的层数不会减少

local W_BeiMSZ_skill3_2_Model = require("Battle.Ply.SkillFeatures.W_BeiMSZ_skill3_2_Model")
---@class W_BeiMSZ_skill3_4_Model : W_BeiMSZ_skill3_2_Model @
---@field super W_BeiMSZ_skill3_2_Model @W_BeiMSZ_skill3_2_Model
local M = class("W_BeiMSZ_skill3_2_Model", W_BeiMSZ_skill3_2_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.avoidPtReduceTime = self:getParam(3) -- Fix[0-10] 破天劲层数不减少时间

    self.curDuration = 0    -- 当前持续时间
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self:startAvoidPtReduce()
end

function M:startAvoidPtReduce()
    self.curDuration = 0
    local feature = self:getSelfSkill1()
    if feature then
        feature.avoidReduce = true
    end
    self.isAvoidReduce = true
end

function M:stopAvoidPtReduce()
    self.curDuration = 0
    local feature = self:getSelfSkill1()
    if feature then
        feature.avoidReduce = false
    end
    self.isAvoidReduce = false
end

function M:update(dt, unsdt)
    if self.isAvoidReduce then
        self.curDuration = self.curDuration + dt
        if self.curDuration >= self.avoidPtReduceTime then
            self:stopAvoidPtReduce()
        end
    end
end

return M