---@class W_CiH_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_CiH_skill3_1_View", SkillFeatures_View)

M.headUIList = nil

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    --self.headUIList = {}
    --self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelCreateHeadUI,{self, self.MV_SkillFeaturesModelCreateHeadUI})
    --self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelUpdateHeadUI,{self, self.MV_SkillFeaturesModelUpdateHeadUI})
    --self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelRemoveHeadUI,{self, self.MV_SkillFeaturesModelRemoveHeadUI})
end

----创建头顶UI
--function M:MV_SkillFeaturesModelCreateHeadUI(eventName, data)
--    local player = data.player
--    data.offset = Vector2.New(0, 0)
--    local player_view = self.player.plyMgr:GetPlayerViewByModel(player)
--    local headUI = player_view.headUIMgr:add(data.uiName, data);
--    local playerInstanceId = player:get_playerInstanceId()
--    self.headUIList[playerInstanceId] = headUI
--end
--
----更新头顶UI
--function M:MV_SkillFeaturesModelUpdateHeadUI(eventName, data)
--    local player = data.player
--    local playerInstanceId = player:get_playerInstanceId()
--    if self.headUIList[playerInstanceId] ~= nil then
--        self.headUIList[playerInstanceId]:refreshUI(data);
--    end
--end
--
----移除头顶UI
--function M:MV_SkillFeaturesModelRemoveHeadUI(eventName, data)
--    local player = data.player
--    local playerInstanceId = player:get_playerInstanceId()
--    if self.headUIList[playerInstanceId] ~= nil then
--        self.headUIList[playerInstanceId]:destroy()
--        self.headUIList[playerInstanceId] = nil
--    end
--end

function M:destroy()
    M.super.destroy(self)
    --for k,v in pairs(self.headUIList) do
    --    if v ~= nil then
    --        v:destroy()
    --    end
    --end
end

return M