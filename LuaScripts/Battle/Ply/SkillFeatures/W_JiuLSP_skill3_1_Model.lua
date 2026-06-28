--  SP祈灵之舞：驱散所有敌人的无敌效果，对所有敌人造成XXX%的伤害和2秒眩晕。并为自己附加“祈灵”状态，持续10秒，祈灵状态下，其他技能获得增强。“祈灵”状态下再次释放此技能会使技能伤害提高100%
---@class W_JiuLSP_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field attack1 W_JiuL_attack1_1_Model
local M = class("W_JiuLSP_skill3_1_Model", SkillFeatures_Model)

M.summoned = nil

M.timer = 0
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:skillStart(data)
    if self.player.bufMgr:hasBufByTag("W_JiuLSP_skill3") then
        self.skill.extra_anim_name = "skill3_1"
    else
        self.skill.extra_anim_name = "skill3"
    end
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})
    for i = 1, enemies.Count do
        local enemy = enemies:get(i-1)
        if enemy and enemy:isLive() and enemy.bufMgr ~= nil and enemy.bufMgr:hasBufByType("Invincible") then
            enemy.bufMgr:removeBufByType("Invincible")
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M