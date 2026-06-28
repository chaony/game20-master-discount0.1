--选取一名距离自己最近的敌方目标，在之后的1.5秒内，每0.5秒对其造成一次90%攻击力的伤害，该技能造成的伤害会转化为自身血量
---@class W_WuD_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuD_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
    --local ply = data["killer"]
    --local skillConfig = data["attackData"]["skillConfig"]
    --local wantdata = data["wantdata"]
    --local dmg = wantdata["damage"]
    --if ply ~= nil and ply:equal(self.player) and skillConfig.anim_name == "skill1" then
    --    ply:cure("fix", self.player, dmg, self.skill)
    --end
end

function M:destroy()
    M.super.destroy(self)
    --EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end
return M