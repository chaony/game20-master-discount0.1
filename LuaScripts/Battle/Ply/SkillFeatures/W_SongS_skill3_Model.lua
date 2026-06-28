--嵩山爆发体内的寒冰真气，对前方范围内的敌人造成300%攻击力的内功伤害和持续2秒的冰冻效果，该技能每成功命中一个敌人，便为自身提供一层持续5秒的护盾，每层护盾可以抵挡60%攻击力的伤害
---@class W_SongS_skill3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongS_skill3_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.shieldBuff = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if victim ~= nil then
        if skillConfig ~= nil and skillConfig == self.skill then
            if ply ~= nil and ply:equal(self.player) then
                self.player.bufMgr:addBufById(self.shieldBuff, self.player)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M