--日月劫：
--正为日，翻为月，明教施展“圣火追魂”时，每段攻击将造成等量的内功伤害

---@class W_MingJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_MingJ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    self.extraDamage = self:getParam(1, 0)  --Fix[0-1] 额外内功伤害  
    
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})

    self.isRunning = false
end

function M:skillStart(ply, skill)
    if skill.anim_name == "skill3" then
        self.isRunning = true
    end
end

function M:skillEnd(ply, skill)
    if skill.anim_name == "skill3" then
        self.isRunning = false
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.isRunning and eventData.attackData.sky_star_trigger ~= true and BattleTool:isMySkill3(self.player, eventData.attackData) then
        ---@type Battle_AttackData
        local attackDataNew = table.shallow_copy(eventData.attackData)
        attackDataNew.damageType = 1
        attackDataNew.sky_star_trigger = true       -- 加了标记的不会再触发
        eventData.victim:injure(attackDataNew)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M;