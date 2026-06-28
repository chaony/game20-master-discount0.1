--护卫期间，护卫目标会获得展昭防御属性的50%，展昭会获得护卫目标攻击属性的50%
---@class W_ZhanZ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhanZ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.linkTarget = nil       -- 连接对象
    self.line = nil
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
end

function M:update(dt, unsdt)
    M.super.update(self,dt,unsdt)
    if self.linkTarget and self.linkTarget:isLive() and self.linkTarget.bufMgr then
        local buffs = self.linkTarget.bufMgr:findBufByTag("W_ZhanZ_skill1")
        if #buffs==0 then
            self:cancelConnectTarget(self.linkTarget)
        end
    end
end

-- 连接
function M:connectTarget(target)
    if target and self.player:equal(target) ~= true then
        local hookData
        hookData = self.player.evtMgr:getCommonEventByKey("Hook", 1)
        if hookData then
            local lineData = table.copy(hookData.data)
            --加载预制
            self.line = require("Battle.Line.Line_Model").new()
            self.line:init(lineData, self.player, self.player, target)
            --将连线加入到管理器
            self.player.lineMgr:addLine(self.line)
            self.linkTarget = self.line.target
            -- target.bufMgr:addBufById(self.buffId1, self.player, self.skill)
            -- self.player.bufMgr:addBufById(self.buffId2, target, self.skill)
        end
    end
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    if self.linkTarget then -- 有连接目标
        if self.linkTarget:equal(eventData.victim) or self.player:equal(eventData.victim) then      -- 双方有一方已经死亡
            self:cancelConnectTarget(eventData.victim)
            if self.linkTarget:equal(eventData.victim) then
            end
            self.linkTarget = nil
        end
    end
end

---@param deadPlayer PlayerModel
function M:cancelConnectTarget(deadPlayer)
    if self.line then
        self.player.lineMgr:removeLine(self.line)
        self.line:destroy()
        self.line = nil
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        self:connectTarget(eventData.buff.player)
    end
end

function M:destroy()
    self:cancelConnectTarget()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M