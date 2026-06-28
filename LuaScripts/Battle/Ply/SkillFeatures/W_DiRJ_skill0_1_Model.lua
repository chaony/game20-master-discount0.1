-- 战斗中，当狄仁杰首次死亡时，会以最大生命值30%的内力和血量复活并使自身无敌2秒，
--复活时，狄仁杰还会对自身周围造成一次200%攻击力的伤害并使命中的侠客眩晕2秒

---@class W_DiRJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill0_1_Model", SkillFeatures_Model)

local EDiRJStatus = {
    Alive = 0,
    WillNirvana = 1,
    Nirvana = 2,
}

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpBaseRate = self:getParam(1)--复活时候的血量百分比
    self.buffId = self:getParam(2)  -- 回内无敌
    self.buffId2 = self:getParam(3)  -- 伤害buffid
    self.buffId3 = self:getParam(4)  -- 清怒气buff
    self.reenterTime = GlobalTools.base3
    self.reliveCount = 0 -- 复活次数
    self.curLeaveTime = 0
    self.isLeaveField = false   -- 离开战场
    self.selfStatus = EDiRJStatus.Alive
    self.curHpRate = self.hpBaseRate -- 实际复活是恢复血量
    EventDispatcher:registerEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
end


function M:spawn()
    M.super.spawn(self)
    --local hpRate = self.hpBaseRate 
    --self.curHpRate = math.min(GlobalTools.base1, hpRate)
    self.selfStatus = EDiRJStatus.Alive
end

function M:dead(data)
    if self.reliveCount == 0 then
        if self.selfStatus == EDiRJStatus.Alive or self.selfStatus == EDiRJStatus.Nirvana then -- 可以一直复活
            self:willNirvana(data)
        end
    else
        self.player.canRelive = false
        self.player:realDead()
    end
    return M.super:dead(self,data)
end

--function M:update(dt, unsdt)
--    if self.selfStatus == EDiRJStatus.WillNirvana then
--        self.curLeaveTime = self.curLeaveTime + dt
--        if self.isLeaveField then
--            if self.curLeaveTime >= self.reenterTime and self:haveLiveFriend() then -- 计时结束或没有队友
--                self:intoNirvana()
--            end
--        end
--    end
--end

-- 进入涅槃
function M:intoNirvana()
    self.player.canRelive = true
    self.selfStatus = EDiRJStatus.Nirvana
    self.player.data:set_curHp(GlobalTools:Mul(self.player.data:get_hp(), self.curHpRate))   -- 复活生命恢复
    self.player.aiEngine:changeState("relive")
    self.reliveCount = self.reliveCount + 1
end

-- 进入涅槃状态
function M:willNirvana(data)
    self.selfStatus = EDiRJStatus.WillNirvana
   
    self.player.canRelive = true
    self.player.bufMgr:addBufById(self.buffId3, self.player)

    -- 设置死亡动画
    local dieState = self.player.aiEngine:getStateByName("die_into")
    dieState.disappearTime = GlobalTools.base1
    -- 设置复活动画
    local dieState = self.player.aiEngine:getStateByName("relive")
    dieState.extra_anim_name = "jumpin2"
    dieState.reliveTime = GlobalTools.base1
    TimeTools:delayTime( GlobalTools.base2, function()
        self:intoNirvana()
    end)
   
  
end

---@return boolean 是否处于涅槃状态
function M:isInNirvana()
    return self.selfStatus == EDiRJStatus.Nirvana
end

---@param data Battle_HandleData_Relive
function M:reliveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = false
        self:onRelive()
        self.player:removeDelayTimeBufEffect()
    end
end

-- 复活后

function M:onRelive()
    if self.player.skyStar then
        self.player.skyStar:triggerStart()
    else
        self.player.bufMgr:addBufById(self.buffId, self.player)
    end
    self.player.bufMgr:addBufById(self.buffId2, self.player)
    self.selfStatus = EDiRJStatus.Alive
    self.player.canRelive = false
end

---@param data Battle_HandleData_LeaveField
function M:leaveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = true
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
    M.super.destroy(self)
end

return M