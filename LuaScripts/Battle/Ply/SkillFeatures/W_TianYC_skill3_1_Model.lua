--毁殇状态下，天墉城的普攻将变为玄天炽焰
---@class W_TianYC_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianYC_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    --local flag = false
    --local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    --for i = friends.Count, 1, -1 do
    --    local player = friends:get(i-1)
    --    if player.master == nil and player.playerId == 702 then
    --        flag = true
    --        break
    --    end
    --end
    --if flag then
    --    self.skill.extra_anim_name = "skill3_2"
    --else
    --    self.skill.extra_anim_name = "skill3"
    --end
end

function M:destroy()
    M.super.destroy(self)
end

return M