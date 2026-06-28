--当自身近战范围内有敌人时，武当会将其震退到屏幕边缘并对其造成100%攻击力的伤害，该效果效果有6秒的冷却时间
---@class W_WDang_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.already = false
    --是否开始检测周围敌人
    self.startCheck = false
end


function M:canUse()
    self.startCheck = true
    return self.already
end

function M:update(dt)
    M.super.update(self, dt)
    if self.startCheck == true then
        local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
        local has = false
        for i = 1, enemys.Count do
            local enemy = enemys:get(i - 1)
            local dis = GlobalTools:Distance(self.player:get_position(), enemy:get_position())
            if dis <= GlobalTools:Mul(self.skill.skill_dis, self.skill.skill_dis) then
                has = true
                break
            end
        end
        self.already = has

        if has == true and self.skill:canUse() then
            if self.player.aiEngine ~= nil  then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M