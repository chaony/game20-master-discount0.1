--百花派召唤藤蔓随机攻击1名敌方侠客，对其造成150%攻击力的伤害，且会在侠客身上种下1个“寄生”之种
--（优先选择不存在“寄生”之种的后排侠客，“寄生”之种会一直存在且不可叠加）

--寄生之种：tag：W_BaiH_skill1
--寄生之种激活tag:W_BaiH_skill11

---@class W_BaiHP_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiHP_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.addEnemyBuff1 = self:getParam(1)    -- Buff[] 狂野场地中生效buff
end

--（优先选择不存在“寄生”之种的后排侠客，“寄生”之种会一直存在且不可叠加）
function M:findPlayer(data)
    if self.player:get_curSkillConfig() ~= self.skill then
        return data
    end
    
    local maxCnt = data.Count
    -- 尝试重新选目标
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "enemy",
        posIndex = "backrow",
        ignoreSummon = true,
        priority = true,
    })
    if enemies.Count > maxCnt then
        local backList = Battle.List.new()
        local frontList = Battle.List.new()
        enemies:safeWalkInverted(function(ply)
            if not (ply.bufMgr:hasBufByTag("W_BaiH_skill1") or ply.bufMgr:hasBufByTag("W_BaiH_skill11")) then
                if SceneManager.curScene.ZhenFaManager:isFront(ply:get_camp(), ply.index) then
                    frontList:add(ply)
                else
                    backList:add(ply)
                end
            end
        end)
        if backList.Count > maxCnt then
            return GlobalTools:RetainRandomByCount(backList, maxCnt)
        elseif backList.Count == maxCnt then
            return backList
        elseif frontList.Count > 0 then
            local needList = GlobalTools:RetainRandomByCount(frontList, maxCnt - backList.Count)
            needList:safeWalkInverted(function(ply)  
                backList:add(ply)
            end)
            return backList
        end
        return GlobalTools:RetainRandomByCount(enemies, maxCnt)
    end
    return enemies
end

return M