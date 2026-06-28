--当藏剑处于“重剑决”姿态时，会获得30%的伤害减免且免疫控制效果，当藏剑处于“轻剑决”姿态时，会获得30%的伤害和攻速提升效果
--藏剑切换姿态时，会保留上一个姿态的强化效果3秒
---@class W_CangJ_skill1_1 : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangJ_skill1_1", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --概率
    self.atdBuff = self:getParam(1)
    self.immunityBuff = self:getParam(2)
    self.dmgBuff = self:getParam(3)
    self.speedBuff = self:getParam(4)
    self.delayTime = self:getParam(5)
end

function M:changeState(state)
    if state == 1 then
        self.player.bufMgr:addBufById(self.atdBuff, self.player)
        self.player.bufMgr:addBufById(self.immunityBuff, self.player)
        TimeTools:stopTask(self.timeTask)
        self.timeTask = TimeTools:delayTime(self.delayTime, function()
            self.player.bufMgr:removeBufById(self.dmgBuff)
            self.player.bufMgr:removeBufById(self.speedBuff)
        end)

    elseif state == 2 then
        self.player.bufMgr:addBufById(self.dmgBuff, self.player)
        self.player.bufMgr:addBufById(self.speedBuff, self.player)
        TimeTools:stopTask(self.timeTask)
        self.timeTask = TimeTools:delayTime(self.delayTime, function()
            self.player.bufMgr:removeBufById(self.atdBuff)
            self.player.bufMgr:removeBufById(self.immunityBuff)
        end)
    end
end

function M:destroy()
    TimeTools:stopTask(self.timeTask)
    M.super.destroy(self)
end
return M