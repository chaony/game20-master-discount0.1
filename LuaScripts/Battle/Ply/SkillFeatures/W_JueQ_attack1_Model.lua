--绝情被动
--普攻暴击 放三级的skill1
---@class W_JueQ_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JueQ_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.skill1Prob = false
end

function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1Prob = skill1.cur_skill_config.feature.start 
        self.skill1_cur_skill_config = skill1.cur_skill_config.feature.skill 
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local skill = data.attackData["skillConfig"]
    local isCrit = data["isCrit"]
    if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "attack1" then
        if  isCrit then
            if self.skill1Prob then
                if self.skill1_cur_skill_config ~= nil then
                    if self.player.aiEngine ~= nil  then
                        self.player.aiEngine.skillConfig = self.skill1_cur_skill_config
                        self.player.aiEngine:changeState("attack")
                    end
                end
            end
        end
    end
    return damage
end


function M:destroy()
    M.super.destroy(self)
end


return M