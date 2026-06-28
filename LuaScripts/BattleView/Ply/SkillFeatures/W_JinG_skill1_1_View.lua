--金刚重击前方敌人，对范围内的敌人造成200%攻击力的
--外功伤害并为自身积累10点怒气。
--若释放时的怒气大于50点，还会使命中的敌人眩晕2秒。
---@class W_JinG_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JinG_skill1_1_View", SkillFeatures_View)

M.effect = "W_JinG_touzi_00"

function M:spawn()
    local frame = self.player:get_model().evtMgr:getCommonEvent("PlayEffect", 1)
    self.effectData = frame.data
end

--角色出生结束
function M:spawnFinish()
    local prefabName = "W_JinG_touzi_00"
    prefabName = string.gsub(prefabName, self.player.default_plyType, self.player.plyType)
    self.effect = prefabName
    self.effectData.prefab = self.effect..self.model.selfPoint
    self:playEffect(self.player)
    if self.skill.feature.enemy ~= nil then
        self.effectData.prefab = self.effect..self.model.enemyPoint
        local target_view = self.player.plyMgr:GetPlayerViewByModel(self.skill.feature.enemy)
        self:playEffect(target_view)
    end
end

function M:playEffect(player)
    self.effectData["effect_bundle"] ="fx_"..string.lower( self.player.prefabRoot );
    player:playEffect(self.effectData, player, self.player)
end

return M