---@class M_HuFaTW_skill3_Model : SkillFeatures_Model
local M = class("M_HuFaTW_skill3_Model", SkillFeatures_Model)

---@class EHuFaTWState @护法天王有两种状态
local EHuFaTWState = {
    Attack = -1, -- 攻击
    Defense = 1, -- 防御
}

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hftw_state = EHuFaTWState.Attack
    self.defense_scale = self:getParam(1)
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

--当前技能释放
function M:skillStart(data)
    M.super.skillStart(self)
    self.hftw_state = -self.hftw_state
    self:updateState()
end

function M:spawnFinish()
    self.attack1 = self.player.plySkill:getSkillByName("attack1").cur_skill_config
    self.skill1 = self.player.plySkill:getSkillByName("skill1").cur_skill_config
    self.skill3 = self.player.plySkill:getSkillByName("skill3").cur_skill_config
    self:updateState()
end

function M:updateState()
    self:updateSkillState()
    if self.hftw_state == EHuFaTWState.Attack then
        self.player:setScale(GlobalTools.base1)
    else
        self.player:setScale(self.defense_scale)
    end
end

-- 因为释放技能后，会重置extra_anim_name，所以在每次释放技能后都重置
function M:updateSkillState()
    if self.hftw_state == EHuFaTWState.Attack then
        if self.attack1 then self.attack1.extra_anim_name = "attack1_1" end
        if self.skill1  then self.skill1.extra_anim_name = "skill1_1" end
        if self.skill3  then self.skill3.extra_anim_name = "skill3_2" end
    else
        if self.attack1 then self.attack1.extra_anim_name = "attack1_2" end
        if self.skill1  then self.skill1.extra_anim_name = "skill1_2" end
        if self.skill3  then self.skill3.extra_anim_name = "skill3_1" end
    end
end

function M:SkillEndHandler(event, data)
    if not self.player:equal(data.player) then
        return
    end
    self:updateSkillState()
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    M.super.destroy(self)
end

return M