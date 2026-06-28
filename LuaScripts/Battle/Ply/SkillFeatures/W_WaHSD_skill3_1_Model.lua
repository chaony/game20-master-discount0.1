--娲皇神殿召唤红月，对敌方全体造成200%攻击力的内功伤害，
--并有30%概率叠加一层冻伤（冻伤：降低2点攻速，并使目标每3秒受到一次20%攻击力的伤害，最多可叠加5层，持续12秒）
--没有天墉城上阵时，没有月亮，地面特效冰范围减少，有天墉城上阵，有月亮，地面特效冰维持现状，攻击次数增加

---@class W_WaHSD_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WaHSD_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addBuff3 = self:getParam(1)       -- Buff[]  3层冻伤buff
    self.addBuff4 = self:getParam(2)       -- Buff[]  4层冻伤buff
    self.addBuff5 = self:getParam(3)       -- Buff[]  5层冻伤buff
    self.anim2 = true

end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    for i = 1,friends.Count do
        local ply = friends:get(i-1)
        if ply:isXiaKe() and ply:equal(self.player) == false and ply.plyData.race ~= self.player.plyData.race then
            self.anim2 = false
            break
        end
    end
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)

    
    if self.anim2 then
        self.skill.extra_anim_name = "skill3_2"
    else
        self.skill.extra_anim_name = "skill3"
    end
end

function M:killerAfterAttack(data)
    if data.attackData and data.attackData.skillConfig == self.skill then   -- 本技能造成的伤害
        if data.attackData.injureType == "skill" then
            self:onSkillHit(data.victim)
        end
    end
end

---@param target PlayerModel
function M:onSkillHit(target)
    if target then
        -- 先检测
        local level = #target.bufMgr:findBufByTag("W_WaHSD_DongS")
        if level >= 5 then -- 5层冻伤
            target.bufMgr:addBufById(self.addBuff5, self.player, self.skill)
            if target.isBoss or self.addBuff5 == 0 then		-- boss不生效
                return
            end
            local hpRate = target.data:get_hpRate()
            if hpRate > 0 and hpRate <= 154 then
                local attackData, want_data = BattleTool:getHitDirectAttackData(self.player, target.data:get_curHp())
                attackData.ignoreGuard = false
                attackData.ignoreAvoidDeath = true
                target:beHitDirect(self.player, attackData, want_data, false)
                return
            end
        elseif level == 4 then -- 4层冻伤
            target.bufMgr:addBufById(self.addBuff4, self.player, self.skill)
        elseif level == 3 then -- 三层冻伤
            target.bufMgr:addBufById(self.addBuff3, self.player, self.skill)
        end
        self:addFrostbiteBuff(target)
    end
end

---@param target PlayerModel
function M:addFrostbiteBuff(target)
    
end
    
return M
