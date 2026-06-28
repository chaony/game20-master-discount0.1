--召唤狼群攻击前方所有敌人，对其造成300%攻击力的伤害、若命中的敌人身上存在狩猎印记，则该技能的伤害提升20%
---@class W_WanS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanS_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.atk = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
end

--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    local isCrit = data["isCrit"]
    local ply = data["killer"]
    local victim = data["victim"]
    local skill_config = data["attackData"]["skillConfig"]
    if ply ~= nil and ply:equal(self.player) then
        if skill_config ~= nil and skill_config.anim_name == "skill3" then
            if victim ~= nil and victim:isLive()  then
                local atk_up = self:getAtkUp(victim, data);
                local atk_up_value = GlobalTools:Mul(atk_up, data.damage)
                data.damage = data.damage + atk_up_value;
            end
        end
    end
end


function M:getAtkUp(victim, data)
    local atk = 0
    local marks = victim.bufMgr:findBufByTag("W_WanS_skill1")
    if #marks > 0 then
        atk = atk + self.atk
    end
    return atk
end

function M:destroy()
    M.super.destroy(self)
end

return M