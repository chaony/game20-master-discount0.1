--战斗开始时，花荣会获得50%的暴击率和50%的暴击伤害提升，但战斗每过去5秒，暴击率和暴击伤害的加成效果会减少10%，最多减少至20%
--当花荣成功击杀敌人时，暴击率和暴击伤害加成会重置回初始状态
---@class W_HuaR_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill1 W_HuaR_skill0_1_Model
local M = class("W_HuaR_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- Buff[] 开场初始提升buff
    self.buffData2 = self:getParam(2) -- Buff[] 降低提升效果buff
    self.addBuffTime = self:getParam(3) -- Fix[] 降低提升效果时间间隔
    
    self.addDebuffTimer = TimeTools:startOneLoopTask(self.addBuffTime, handler(self, self.onAddDebuffTrigger))
    
    EventDispatcher:registerEvent("killPlayer", {self,self.PlayerDeadHandler})
end

function M:spawn()
    self.player.bufMgr:addBufById(self.buffData1,self.player)
    M.super.spawn(self)
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    if self.addDebuffTimer then
        self.addDebuffTimer:update_dt(dt)
    end
end

function M:onAddDebuffTrigger()
    self.player.bufMgr:addBufById(self.buffData2,self.player)
end

---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    -- 移除损失的效果
    self.player.bufMgr:removeBufById(self.buffData2, true)
    -- 重新计时
    self.addDebuffTimer = TimeTools:startOneLoopTask(self.addBuffTime, handler(self, self.onAddDebuffTrigger))
end

function M:destroy()
    self.addDebuffTimer = nil
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M