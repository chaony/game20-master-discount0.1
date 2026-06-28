--娲皇神殿挥舞巨镰瞬移并攻击敌方血量最低的侠客，造成140%攻击力的内功伤害，并为目标叠加一层冻伤效果。
--当“冰柱”存在时，此技能将变为范围伤害。攻击后娲皇神殿回到攻击前的位置。
--当与百里同时上阵时，额外造成已损失生命值10%的伤害，若击杀目标，则继续释放。

---@class W_WaHSD_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field old_pos FixVector3
---@field old_forward FixVector3
local M = class("W_WaHSD_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addDamagePercent = self:getParam(1)       --Fix[] 对敌方目标造成已损失生命百分比额外的伤害

    self.isUpgrade = true
    
    -- 技能击杀单位
    self.killCnt = 0
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    for i = 1,friends.Count do
        local ply = friends:get(i-1)
        if ply:isXiaKe() and ply:equal(self.player) == false and ply.plyData.race ~= self.player.plyData.race then
            self.isUpgrade = false
            break
        end
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self:recordPosForward()
    self.killCnt = 0
    if self.player.bufMgr:hasBufByTag("W_WaHSD_BingZ") then -- 存在冰柱buff
        self.skill.extra_anim_name = "skill0_2"
    else
        self.skill.extra_anim_name = "skill0_1"
    end
    if self.continueAttack then
        if self.player.evtMgr then
            self.player.evtMgr:commonEventWorkByKey("BlackScreen", 2)
            self.player:setUnScale(true)
        end
    end
end

---技能增伤
function M:killerBeforeAttack(attackData, victim)
    if self.isUpgrade and BattleTool:isMySkill0(self.player, attackData) then
        local loseHp = victim.data:get_hp() - victim.data:get_curHp()
        if loseHp > 0 then
             attackData.damageExtra = attackData.damageExtra + GlobalTools:Mul(loseHp, self.addDamagePercent)
        end
    end
end

---记录瞬移之前的位置
function M:recordPosForward()
    self.old_pos = self.player:get_position():CloneNew()
    self.old_forward = self.player:getForward():CloneNew()
end

---返回原位置
function M:skillDispatch(data)
    if data.eventName == "skill0_move_back" then
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

function M:killPlayer(data)
    M.super.killPlayer(self, data)
    if data.victim:isXiaKe() and BattleTool:isMySkill0(self.player, data.attackData) then
        self.killCnt = self.killCnt + 1
    end
end

function M:skillEnd(data)
    self.player:setUnScale(false)
    M.super.skillEnd(self, data)
    if self.isUpgrade and self.killCnt > 0 then -- 升级后才有效果
        self.killCnt = 0
        if BattleTool:skillEndCanUseAttack(self.player) then
            self.player.aiEngine.skillConfig = self.skill -- 击杀目标后继续使用一次技能0
            self.continueAttack = true
            return "attack"
        end  
    end
end

return M
