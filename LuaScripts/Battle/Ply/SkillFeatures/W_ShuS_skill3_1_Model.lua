-- 蜀山扇动翅膀飞到空中每秒消耗250内力，期间无法被选为攻击目标，且暴击率和攻速提高50%

---@class W_ShuS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShuS_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.angerCost = self:getParam(1)   -- Fix[0-200]  -- 持续消耗怒气
    self.addBuff1 = self:getParam(2)    -- Buff[] -- 无敌buff
    self.addBuff2 = self:getParam(3)    -- Buff[] -- 期间增益buff
    
    self.player.skill3ClearAnger = false -- 释放技能3不会消耗怒气
    self.isFlying = false
    EventDispatcher:registerEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
end

function M:skillStart(data)
    if self.player.data:isMax_anger() then
        self:flyUp()
    end
    M.super.skillStart(self, data)
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt)
    if self.isFlying == true then
        if self.player.plyMgr.blackTimeManager.curBlackTime <= GlobalTools.base0 then       -- 黑屏时间不计时能量消耗
            self.costTask:update_dt(dt)
        end
    end
end

function M:onCostAngerTick()
    local anger = self.player.data:get_curAnger() - self.angerCost
    if anger <= GlobalTools.base0 then
        self.player.data:set_anger(GlobalTools.base0)
        self:flyDown()
    else
        self.player.data:set_anger(anger)
    end
end

function M:flyUp()
    self.isFlying = true
    self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    self.player.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
    self.costTask = TimeTools:startOneLoopTask(GlobalTools.base1, handler(self, self.onCostAngerTick))
    self.player.plyMgr:addHide(self.player)
    --self.skill.extra_anim_name = "skill3_start"
end

function M:flyDown()
    self.isFlying = false
    self.costTask = nil
    self.player.bufMgr:removeBufById(self.addBuff1, self.player, self.skill)
    self.player.bufMgr:removeBufById(self.addBuff2, self.player, self.skill)
    self.player.aiEngine.skillConfig = self.skill
    self.player.aiEngine.skillConfig.extra_anim_name = "skill3_end"
    self.player.aiEngine:changeState("attack")
    SceneManager.curScene.plyMgr:removeHide(self.player)
end

function M:isInAir()
    return self.isFlying == true
end

--ai状态切换,保持空中待机
---@param eventData Battle_HandleData_ChangeAiState
function M:ChangeAiStateHandler(eventName, eventData)
    if self:isInAir() == true and self.player:equal(eventData.player) == true then
        local targetState = eventData.targetState
        if targetState.anim_name == "idle" or targetState.anim_name == "battle_idle" or targetState.anim_name == "run"then
            targetState.extra_anim_name = "skill3_loop"
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    M.super.destroy(self)
end

return M