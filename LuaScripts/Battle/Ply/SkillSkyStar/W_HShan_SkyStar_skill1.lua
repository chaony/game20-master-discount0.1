--大音希声：
--“回风落雁”将沉默目标3秒，并使衡山恢复50%造成伤害的生命值

---@class W_HShan_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HShan_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.silentBuff = self:getParam(1, 0)  -- Buff[] 沉默buff
    self.addBlood = self:getParam(2, 0)    -- Fix[0-1] 回复生命百分比
    

    self.isRunning = true
    
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
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
    if self.isRunning then
        if BattleTool:isMySkill3(self.player, eventData.attackData) then    -- 是本技能3造成的伤害
            eventData.victim.bufMgr:addBufById(self.silentBuff, self.player)
            
            local cure = GlobalTools:Mul(eventData.wantdata.damage, self.addBlood)
            self.player:cure("fix", self.player, cure)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M;