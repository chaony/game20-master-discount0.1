--逍遥瞬移至攻击力最高的敌方后排侠客身前，对其造成150%攻击力的伤害，并使自身进入“逍遥游”状态5秒，该状态下，逍遥的普攻会变为近战范围伤害。进入“逍遥游”状态时，逍遥会立即回满内力且不再减少和增加。 
--“逍遥游”状态下再次释放该技能时，逍遥会消耗所有内力释放“鲲鹏击”，对自身大范围内的敌人造成100%攻击力的范围伤害，之后回瞬移回原本所在的位置 。释放完“鲲鹏击”后，“逍遥游”状态会立即结束
---@class W_XiaoY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoY_skill3_1_Model", SkillFeatures_Model)
--1为普通状态，2位逍遥游状态
M.state = 1

M.old_pos = nil

M.old_forward = nil

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.time = self:getParam(1)
    --近战攻击范围
    self.meleeRange = self:getParam(3)
    self.timer = 0
end

function M:spawn()
    M.super.spawn(self)
    self.state = 1
    local attack = self.player.plySkill:getSkillByName("attack1")
    if attack ~= nil then
        self.attack = attack.cur_skill_config
    end

    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        self.skill2 = skill2.cur_skill_config
    end
end

function M:update(dt)
    M.super.update(self, dt)
    if self.state == 2 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.skill.canAutoUseSkill3 = true
            self.player:useSkill("skill3")
        end
    end
end

--技能释放,只有当前技能会调用
function M:skillStart(data)
    if self.state == 1 then
        self.skill.extra_anim_name = "skill3_1"
        self.old_pos = FixVector3.New(0,0,0)
        self.old_forward = FixVector3.New(0,0,0)
        self.old_pos.x = self.player:get_position().x
        self.old_pos.y = self.player:get_position().y
        self.old_pos.z = self.player:get_position().z
        self.old_forward.x = self.player:getForward().x
        self.old_forward.y = self.player:getForward().y
        self.old_forward.z = self.player:getForward().z
        TimeTools:delayTime(GlobalTools.base1, function()
            self.skill.canAutoUseSkill3 = false
            self.player.data:set_anger(self.player.data.maxAnger, true)
            self.player.data:setAngerLock(true)
        end)
    elseif self.state == 2 then
        self.skill.extra_anim_name = "skill3_2"
        self:setState(1)
    end
end

function M:setState(state)
    self.state = state
    if state == 2 then
        self.timer = self.time
        self.attack.skill_dis_temp = self.meleeRange
        if self.skill2 ~= nil then
            self.skill2.feature:stateStart()
        end
    elseif state == 1 then
        self.player.data:setAngerLock(false)
        self.attack.skill_dis_temp = nil
        if self.skill2 ~= nil then
            self.skill2.feature:stateEnd()
        end
    end
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        skill1.cur_skill_config.feature:setState(state)
    end
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config.feature.setState ~= nil then
        skill0.cur_skill_config.feature:setState(state)
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill3_changeState" then
        self:setState(2)
    elseif data.eventName == "skill3_move" then
        if self.old_pos ~= nil then
            self.player:setPos(self.old_pos, true)
            self.old_pos = nil
        end
        if self.old_forward ~= nil then
            self.player:setForward(self.old_forward, true)
            self.old_forward = nil
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M