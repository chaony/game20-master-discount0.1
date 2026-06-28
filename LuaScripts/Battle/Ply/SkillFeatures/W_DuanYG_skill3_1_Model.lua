--段瑛谷
--锻瑛谷消耗所有内力，立即恢复最大生命值30%的血量并使自身进入“阎魔”状态6秒，阎魔状态持续期间，锻瑛谷每秒会对自身周围的敌人造成100%攻击力的伤害且攻击力会提升50%
---@class W_DuanYG_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanYG_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(2) --大招buff
   
    self.lineTab = {}
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("add_W_DuanYG_skill3", {self,self.addBuffHandler})
    --EventDispatcher:registerEvent("afterAddBuff", {self,self.afterAddBuffHandler})
end 

function M:spawnFinish()
    M.super.spawnFinish(self)
    local skill1Item = self.player.plySkill:getSkillByName("skill2") -- 技能1可能未解锁
    if skill1Item ~= nil then
        self.skill2 = skill1Item.cur_skill_config.feature
    end
end

function M:update(dt, unsdt)
    M.super.update(self,dt,unsdt)
    for i = #self.lineTab, 1, -1 do
        local line = self.lineTab[i]
        local linkTarget = line.target
        if linkTarget and linkTarget:isLive() and linkTarget.bufMgr then
            local buffs = linkTarget.bufMgr:findBufByTag("W_DuanYG_skill3")
            if #buffs==0 then
                self:removeLinesByIndex(i)
            end
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
            local line = require("Battle.Line.Line_Model").new()
            line:init(lineData, self.player, self.player, target)
            --将连线加入到管理器
            self.player.lineMgr:addLine(line)
            self.lineTab[#self.lineTab + 1] = line
        end
    end
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        self:destroyAllLine()
    elseif #self.lineTab > 0 then
        for i = 1, #self.lineTab do
            if self.lineTab[i] and self.lineTab[i].target then
                local line = self.lineTab[i]
                local linkTarget = line.target
                if linkTarget and linkTarget:equal(eventData.victim) then      -- 双方有一方已经死亡
                    self:removeLinesByIndex(i)
                    break
                end
            end
        end
    end
end

---@param deadPlayer PlayerModel
function M:removeLinesByIndex(index)
    local line = self.lineTab[index]
    if line then
        self.player.lineMgr:removeLine(line)
        line:destroy()
        line = nil
        table.remove(self.lineTab, index)
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        self:connectTarget(eventData.buff.player)
    end
end

---@param data Battle_BeHitDirectData
function M:afterAddBuffHandler(eventName, data)
    --local victim = data.victim
    --if self.player:equal(data.killer) == true and victim ~= nil then -- 攻击者是自己
    --    local buffs = victim.bufMgr:findBufByTag("W_DuanYG_skill3")
    --    if table.nums(buffs) > 0 then
    --        local xd = 1
    --        --self:connectTarget(victim)
    --    end
    --end
end

function M:destroyAllLine()
    if #self.lineTab > 0 then
        for i = 1, #self.lineTab do
            local line = self.lineTab[i]
            self.player.lineMgr:removeLine(line)
            line:destroy()
            line = nil
        end
    end
    self.lineTab = {}
end

function M:skillStart(data)
    M.super.skillStart(self)
    if self.skill2 and self.skill2.skill.level >= 2 then
        self.skill2:addShiledBuff()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("add_W_DuanYG_skill3", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M