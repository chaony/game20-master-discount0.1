--月寒宫会禁锢敌人，对其造成3段，每段80%攻击力的伤害，最后一击时月寒宫会冲至敌人身后，随后切换为近战攻击，
--当月寒宫处于近战状态时，暴击率和暴击伤害提升30%，若月寒宫在近战状态下击杀了敌人，则会瞬移回战斗一开始所在的位置，回到远程状态
--lv2 释放时若自身有飞剑，则会消耗一把飞剑，使最后一次攻击的伤害提升50%并使敌人眩晕2秒
---@class W_YueHG_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YueHG_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
  
    self.buffId1 = self:getParam(1) -- 暴击buff
    self.costNums = self:getParam(2) --消耗数量
    self.addDamagePer = self:getParam(3) --伤害提升
    self.buffId2 = self:getParam(4)--眩晕buff
    self.skill_state = 1 --1远程 2 近战
    --当前攻击次数
    self.curAtkCount = 0
    self.finalAtkNums = 3 --
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})

end

function M:spawn()
    local skill2Item = self.player.plySkill:getSkillByName("skill2") -- 技能2可能未解锁
    if skill2Item ~= nil then
        self.skill2 = skill2Item.cur_skill_config.feature
    end
    M.super.spawn(self)
end

function M:spawnFinish()
    self.old_pos = FixVector3.New(0,0,0)
    self.old_forward = FixVector3.New(0,0,0)
    self.old_pos.x = self.player:get_position().x
    self.old_pos.y = self.player:get_position().y
    self.old_pos.z = self.player:get_position().z
    self.old_forward.x = self.player:getForward().x
    self.old_forward.y = self.player:getForward().y
    self.old_forward.z = self.player:getForward().z
end

function M:changeState(state)
    if self.skill_state ~= state then
        if self.skill_state == 2 then --近战切远程
            if self.old_pos ~= nil then
                self.player:setPos(self.old_pos, true)
            end
            if self.old_forward ~= nil then
                self.player:setForward(self.old_forward, true)
            end
            self.player.bufMgr:removeBufById(self.buffId1, true)
        else
            self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        end
        self.skill_state = state
    end
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill3"  then
            self.curAtkCount = self.curAtkCount + 1
            if self.curAtkCount == self.finalAtkNums and self.skill2 and self.skill2:removeFeiJianBuff(self.costNums) then
                local wantData = data["wantdata"]
                local damage_value = GlobalTools:Mul(wantData.damage, (GlobalTools.base1 + self.addDamagePer));
                data["wantdata"]["damage"] = damage_value
                victim.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                self.curAtkCount = 0
            end
        end
    end
end
function M:skillDispatch(data)
    if data.eventName == "skill3_change" then
        self:changeState(2)
    end
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    local killer = eventData["killer"]
    if self.player:equal(killer) and self.skill_state == 2 then
        self:changeState(1)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M