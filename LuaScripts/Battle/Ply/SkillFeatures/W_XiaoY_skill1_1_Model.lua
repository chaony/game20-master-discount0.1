--在敌方阵营中引发范围爆炸，造成200%攻击力的伤害，释放时若自身处于“逍遥游”状态，则爆炸范围变为以自身为中心，且不再有释放动作
---@class W_XiaoY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoY_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cd_reduce = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil then
        self.skill3 = skill3.cur_skill_config.feature
    end
end

function M:canUse()
    if self.skill3 then
        if self.skill3.state == 1 then
            return true
        elseif self.skill3.state == 2 then
            self:useSkillInState()
            self.skill:use()
            self.skill.cur_post_cd = GlobalTools:Mul(self.player.data:getAttackCd(self.skill.post_cd), GlobalTools.base1 - self.cd_reduce)
            return false
        end
    end 
end

function M:useSkillInState()
    if self.player.evtMgr then
        self.player:set_forceSkillConfig(self.skill)
        self.player.evtMgr:commonEventWork("Hit",self.skill.level );
        self.player:set_forceSkillConfig(nil)
    end
end

function M:setState(state)
    if state == 1 then
        self.skill.cur_post_cd = self.skill.cur_post_cd + GlobalTools:Mul(self.player.data:getAttackCd(self.skill.post_cd), self.cd_reduce)
    elseif state == 2 then
        self.skill.cur_post_cd = self.skill.cur_post_cd - GlobalTools:Mul(self.player.data:getAttackCd(self.skill.post_cd), self.cd_reduce)
        if self.skill.cur_post_cd < 0 then
            self.skill.cur_post_cd = 0
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M