--万兽的普攻伤害暴击时，会为当前敌人施加一层狩猎印记
---@class W_WanS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanS_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end


function M:spawn()
    M.super.spawn(self)
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
end

--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    local isCrit = data["isCrit"]
    local ply = data["killer"]
    local victim = data["victim"]
    local skill_cofig = data["attackData"]["skillConfig"]
    if ply ~= nil and ply:equal(self.player) then
        if skill_cofig ~= nil and skill_cofig.anim_name == "attack1" then
            if victim ~= nil and victim:isLive() and isCrit == true then
                if self.skill1 ~= nil then
                    self.skill1.cur_skill_config.feature:addBuf(victim)
                end
            end
            
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M