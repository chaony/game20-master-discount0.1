---@class W_JinY_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinY_skill2_Model", SkillFeatures_Model)

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