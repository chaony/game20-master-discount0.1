--花荣攻击当前目标，对其造成180%攻击力的伤害，并附加5%敌方最大生命值的伤害，若该技能造成了暴击，则会额外释放一次，
--额外释放时会命中敌方全体目标，该技能最多额外释放一次
---@class W_HuaR_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaR_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.count = self:getParam(1)   -- Int[0-5] 额外释放时会命中敌方全体目标,单场战斗触发次数
    self.triggerTime = 0
    self.extHurt = false
    self.isOriginalSkill = true  -- 是否是原始技能
    EventDispatcher:registerEvent("injure", {self, self.injureHandle})
end

function M:skillStart(data)
    self.extHurt = false
    M.super.skillStart(self)
    
end

-- 发生暴击
---@param data Battle_HandleData_Injure
function M:injureHandle(eventName, data)
    -- 是原始技能且有触发次数
    if self.triggerTime < self.count and self.isOriginalSkill then
        if data.attackData.isCrit and self.player:equal(data.killer) then
            if BattleTool:isInjureByName(data.attackData, "skill1") then
                self.extHurt = true -- 是否再放一次skill1
                
            end
        end
    end
end

function M:skill1Finish()
    if self.extHurt then
        self.triggerTime = self.triggerTime + 1
        BattleTool:safeTriggerActionEventWork(self.player, "skill1", "ChangeAnim", 2)
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill1Finish" then
        self:skill1Finish(data)
    elseif data.eventName == "skill1_2Finish" then
        if self.player.skyStar then
            self.player.skyStar:triggerStart()
        end
    end
end

function M:destroy()
    self.extHurt = false
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandle})
    M.super.destroy(self)
end

return M