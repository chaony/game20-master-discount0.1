-- 战斗中，每当蜀山的攻击造成暴击时，便为自身施加一层持续15秒的“凌羽”效果，每层翎羽效果会提升蜀山5%攻击速度，最多叠加10层

---@class W_ShuS_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill3 W_ShuS_skill3_1_Model
local M = class("W_ShuS_attack1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isFirst = true
    self.isDead = false
end
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.isDead then
        self.skill.extra_anim_name = "attack1_die"
    else
        if self:isInAir() then
            self.skill.extra_anim_name = "attack1_skill3"
        else
            self.skill.extra_anim_name = "attack1"
        end
    end
end

function M:isInAir()
    if not self.skill3 then
        local skill3 = self.player.plySkill:getSkillByName("skill3")
        if skill3 and skill3.cur_skill_config then
            self.skill3 = skill3.cur_skill_config.feature
        end
    end
    return self.skill3 and self.skill3:isInAir()
end

function M:dead(data)
    if self.player.skyStar then
        if self.isFirst then
            self.isFirst = false
            self.data = data
            self.player.killer = self.data.killer
            self.isDead = true
            
            self.player.skyStar:triggerStart(self)
        end
        return false
    end
    return M.super.dead(self, data)
end

function M:skillDispatch(data)
    if data.eventName == "ShuS_Attack_Die" then
        self:deadHandle(data)
    elseif data.eventName == "ShuS_Shoot" then
        if self.player.skyStar then
            self.player.skyStar:triggerEnd(self)
        end
    end
end

function M:deadHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        self.player.data:set_curHp(0)
    end
end

return M