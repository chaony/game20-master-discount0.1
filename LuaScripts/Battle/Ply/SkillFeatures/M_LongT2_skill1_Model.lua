--每过15s，会给随机一个敌人施加一个标记，被施加标记的敌人会额外受到20%的伤害，标记会持续8s；
---@class M_LongT2_skill1 : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("M_LongT2_skill1", SkillFeatures_Model)

M.buffData = require("Battle.Ply.SkillFeaturesData.M_LongT2_skill1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.initCd = self:getParam(1)
    self.duration = self:getParam(2)
    self.buff = self:getParam(3)
    self.timer = 0
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.timer = self.initCd
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            local enemys = SelectTargetTool:findPlayerByType(self.buffData["count"], self.player)
            for i = 1,enemys.Count do
                local ply = enemys:get(i-1)
                ply.bufMgr:addBufById(self.buff, self.player)
            end
            self.timer = self.duration
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end


return M