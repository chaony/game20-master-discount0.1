--合欢选取场上最多3名女性侠客并召唤其幻影，幻影拥有原侠客60%的属性，且会受到150%的伤害，召唤出来的幻影只能使用普攻。
---@class W_HeH_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_HeH_skill3_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    self.effectPrefab = "W_Heh_Skill3_Born_001"
    self:addEventListener_Local(Battle.SkillEventType.MV_W_HeH_skill3_1_Model_PlayEffect, {self,self.MV_W_HeH_skill3_1_Model_PlayEffect});
end

--播放特效
function M:MV_W_HeH_skill3_1_Model_PlayEffect(eventName, data) 
    local player = data.player;
    if player ~= nil then
        local player_view = self.player.plyMgr:GetPlayerViewByModel(player)
        if player_view ~= nil then
            self:playEffect(player_view)
        end
    end
end


function M:playEffect(player)
    local effectData = {}
    effectData["prefab"] = self.effectPrefab
    effectData["autodestoryTime"] = 2
    effectData["isPutUpInParent"] = true
    effectData["parent"] = "effectpoint0"
    effectData["directionType"] = "parent"
    effectData["scaleType"] = "world"
    effectData["positionType"] = "parentOffset"

    local prefabTrans = {}
    prefabTrans["useUserSet"] = false

    prefabTrans["position"] = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    prefabTrans["rotation"] = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    prefabTrans["scale"] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
    }
    effectData["prefabTrans"] = prefabTrans
    player:playEffect(effectData, player, self.player, nil)
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M