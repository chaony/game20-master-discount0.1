--形意切换为“灵龟拳意”，立即为自身施加一个持续8秒的护盾，抵挡相当于自身攻击力200%的伤害，使用该技能后，形意的下一次普攻会获得强化效果若强化后的普攻命中了敌人，则形意会恢复15%的已损失生命值'

---@class W_XingY_skill1_1_Model : SkillFeatures_Model
local M = class("W_XingY_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    if ply ~= nil and ply:equal(self.player) and skillConfig ~= nil and skillConfig.anim_name == "skill1" then
        local hp_cha = self.player.data:get_hp() - self.player.data:get_curHp()
        self.player:cure("fix", self.player, GlobalTools:Mul( self.hp, hp_cha ), self.skill )
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end


return M