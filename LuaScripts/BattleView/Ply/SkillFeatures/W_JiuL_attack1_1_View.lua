---@class W_JiuL_attack1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JiuL_attack1_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    self:addEventListener_Local(Battle.SkillEventType.W_JiuL_attack1_1_Model_ShowObj, {self,self.W_JiuL_attack1_1_Model_ShowObj});
    self:addEventListener_Local(Battle.SkillEventType.W_JiuL_attack1_1_Model_ChangeState, {self,self.W_JiuL_attack1_1_Model_ChangeState});
end

function M:W_JiuL_attack1_1_Model_ShowObj(eventName, data)
    local player_model = data.player
    local show = data.show
    local player_view = self.player.plyMgr:GetPlayerViewByModel(player_model)
    if player_view ~= nil and player_view.body ~= nil then
        player_view.body.gameObject:SetActive(show)
    end
end

function M:W_JiuL_attack1_1_Model_ChangeState(eventName, data)
    local player = data.player
    if not IsNull(player.evtMgr) then
        player.evtMgr:commonEventWork("PlayEffect", 1)
    end
end

return M