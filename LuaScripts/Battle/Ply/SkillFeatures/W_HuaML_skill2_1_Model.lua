-- 战斗中，若花木兰攻击范围内没有敌人，则会强制选取在场攻击力最高的一名敌方侠客，将其拉到自己攻击范围内，并立即对其造成200%攻击力的伤害和2秒沉默效果
---@class W_HuaML_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaML_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.range = self:getParam(1)
end

function M:canUse()
    local enemy = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    local range = self.range
    local count = 0
    local minDist = GlobalTools.base999
    local minDistPly = nil
    local facePly = nil
    for i = 1, enemy.Count do
        local ply = enemy:get(i - 1)
        if ply:isLive() then
            local dis = GlobalTools:Distance(ply.position, self.player.position)
            if dis < GlobalTools:ToFix2( range ) then
                count = count + 1
            else
                if ply.index == self.player.index then
                    facePly = ply
                end
                if dis < minDist then
                    dis = minDist
                    minDistPly = ply
                end
            end
        end
    end
    if count > 0 then
        return false
    else
        self.player:lockEnemy( facePly or minDistPly )
        return true
    end
end

return M