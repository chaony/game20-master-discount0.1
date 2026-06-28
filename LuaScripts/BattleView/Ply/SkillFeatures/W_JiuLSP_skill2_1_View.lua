--召唤飞雪到场上，飞雪会继承自身50%的属性并存在15s；若自身存在“祈灵”buff，飞雪还会对附近的敌人进行攻击，每次造成自身250%攻击力的伤害；
---@class W_JiuLSP_skill2_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JiuLSP_skill2_1_View", SkillFeatures_View)


function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    self:addEventListener_Local(Battle.SkillEventType.W_JiuLSP_Summon_ShowObj, {self,self.W_JiuLSP_Summon_ShowObj});
    self:addEventListener_Local(Battle.SkillEventType.W_JiuLSP_LaoHu_Dead, {self,self.W_JiuLSP_LaoHu_Dead});
end

function M:W_JiuLSP_Summon_ShowObj(eventName, data)
    local player_model = data.player
    local show = data.show
    local player_view = self.player.plyMgr:GetPlayerViewByModel(player_model)
    if player_view ~= nil and player_view.body ~= nil then
        player_view.body.gameObject:SetActive(show)
    end
end

function M:W_JiuLSP_LaoHu_Dead(eventName, data)
    local player = data.player
    if not IsNull(player.evtMgr) then
        --player.evtMgr:commonEventWork("PlayEffect", 1)
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M