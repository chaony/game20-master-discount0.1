--对路径上的敌人造成200%攻击力的伤害，并为其随机附加一种七伤诅咒
---@class W_WanH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanH_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill1Item = self.player.plySkill:getSkillByName("skill1")
    if skill1Item ~= nil then
        self.skill1 = skill1Item.cur_skill_config.feature
    end
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if ply ~= nil and ply:equal(self.player) == true and skillConfig ~= nil and skillConfig.anim_name == "skill2" then
        if self.skill1 ~= nil then
            self.skill1:addCurse(victim)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M