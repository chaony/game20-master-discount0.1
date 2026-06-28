--立即向前方射出一柄飞刀,对一名敌人造成1000%攻击力的伤害，若该敌人在受到伤害后血量低于10%，
--则会无视任何免疫效果使其立即死亡（对boss和召唤单位无效）
---@class W_TanH_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TanH_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpRate = self:getParam(1)
    self.isDead = false;
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local damage = data.damage
    local victim = data.victim
    local skill = data.attackData.skillConfig

    if skill ~= nil and skill.anim_name == "skill3" and victim.isBoss ~= true and victim:get_master() == nil then
        if data.attackData["ignoreGuard"] ~= true then
            local shieldBuf = victim.bufMgr:findBufByType("Shield")
            for k,v in ipairs(shieldBuf) do
                if v.bufWork.value > damage then
                    damage = GlobalTools.base0
                    break
                else
                    damage = damage - v.bufWork.value
                end
            end
        end
        local hp_value = GlobalTools:Mul(victim.data:get_hp(), self.hpRate);
        if victim.data:get_curHp() - damage <= hp_value then
            self.isDead = true
            self.victim = victim
        end
    end
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    if self.isDead then
        self.isDead = false
        if self.victim ~= nil and self.victim:isLive() == true then
            self.victim:realDead()
        end
    end
end

return M