-- 同人菩萨有两种状态 普攻和范围普攻
---@class M_TongRenPS_skill3_Model : SkillFeatures_Model
local M = class("M_TongRenPS_skill3_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.rang_attack_continue_max = self:getParam(1) --GlobalTools.base5
    self.rang_attack_continue_time = 0
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:spawnFinish()
    self.attack1 = self.player.plySkill:getSkillByName("attack1").cur_skill_config
    self:updateSkillState()
    M.super.spawnFinish(self)
end

--当前技能释放
function M:skillEnd(data)
    self.rang_attack_continue_time = self.rang_attack_continue_max
    self:updateSkillState()
    M.super.skillEnd(self)
end

function M:update(dt, unsdt)
    if(self.rang_attack_continue_time > 0)then
        self.rang_attack_continue_time = self.rang_attack_continue_time - dt
        if(self.rang_attack_continue_time <= 0)then
            self:updateSkillState()
        end
    end
    M.super.update(self, dt, unsdt)
end

-- 因为释放技能后，会重置extra_anim_name，所以在每次释放技能后都重置
function M:updateSkillState()
    if self.rang_attack_continue_time > 0 then
        if self.attack1 then self.attack1.extra_anim_name = "attack1_2" end
    else
        if self.attack1 then self.attack1.extra_anim_name = "attack1_1" end
    end
end

function M:SkillEndHandler(event, data)
    if self.player:equal(data.player) then
        self:updateSkillState()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    M.super.destroy(self)
end

return M