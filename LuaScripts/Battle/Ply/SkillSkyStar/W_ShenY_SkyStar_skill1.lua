--葵風沐雨：为我方后排侠客额施加2秒免疫眩晕和冰冻效果

---@class W_ShenY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ShenY_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    --全体侠客3%最终伤害
    self.buffId = self:getParam(1, 0)    --Buff[]
end

-- 技能开始
function M:skillStart(ply, skill)
    if skill.anim_name == "skill3" then
        --后排队友
        local targets = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", posIndex = "backrow", ignoreSummon = true})
        for i = 1, targets.Count  do
            local ply = targets:get(i-1)
            ply.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end
return M;