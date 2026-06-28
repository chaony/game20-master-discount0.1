--百花派立即为我方血量百分比最低的1名己方侠客恢复150%攻击力的血量，且会在侠客身上种下1个“共生”之种
--（优先选择不存在“共生”之种的侠客，“共生”之种会存在一直存在且不可叠加）

--寄生之种：tag：W_BaiH_skill1,W_BaiH_skill11


---@class W_BaiHP_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiHP_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.addBuff1 = self:getParam(1)    -- Buff[] 生息场地中生效buff
end

--优先选择不存在“共生”之种的侠客，“共生”之种会存在一直存在且不可叠加）
function M:findPlayer(data)
    if self.player:get_curSkillConfig() ~= self.skill then
        return data
    end

    local maxCnt = data.Count
    -- 尝试重新选目标
    local targets = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "friend",
        ignoreSummon = true,
        pos = "bloodLeast",
        priority = true,
    })
    if targets.Count > maxCnt then
        local list = Battle.List.new()
        targets:safeWalkInverted(function(ply)
            if not (ply.bufMgr:hasBufByTag("W_BaiH_skill2") or ply.bufMgr:hasBufByTag("W_BaiH_skill21")) then
                list:add(ply)
            end
        end)
        if list.Count > 0 then
            return GlobalTools:RetainRandomByCount(list, maxCnt)
        end
        return GlobalTools:RetainRandomByCount(targets, maxCnt)
    end
    return targets
end

return M