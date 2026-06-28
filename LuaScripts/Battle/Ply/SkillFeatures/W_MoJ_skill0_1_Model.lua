--当墨家和机关塔同时存在在战场上时，两者受到的伤害都会减少40%，若有任何一人从战场上消失，减伤效果也会随之消失
---@class W_MoJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MoJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --减伤比例
    self.buff = self:getParam(1)
    --延迟
    self.delay = self:getParam(2)
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
end

function M:addBuff()
    if self.skill1 ~= nil and self.skill1.summon ~= nil then
        self.skill1.summon.bufMgr:addBufById(self.buff, self.player)
        self.player.bufMgr:addBufById(self.buff, self.player)
    end
end

function M:removeBuff()
    local function removeBuffFunc()
        if self.skill1 ~= nil and self.skill1.summon ~= nil then
            self.skill1.summon.bufMgr:removeBufById(self.buff)
            self.player.bufMgr:removeBufById(self.buff)
        end
    end
    if self.delay > 0 then
        TimeTools:delayTime(self.delay, removeBuffFunc)
    else
        removeBuffFunc()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M