---@class G_FuW_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("G_FuW_skill1_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelCreateHeadUI,{self, self.MV_SkillFeaturesModelCreateHeadUI})
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelUpdateHeadUI,{self, self.MV_SkillFeaturesModelUpdateHeadUI})
end

--创建头顶UI
function M:MV_SkillFeaturesModelCreateHeadUI(eventName, data)
    data.offset = Vector2.New(0, -30)
    self.headUI = self.player.headUIMgr:add(data.uiName, data);
end

--更新头顶UI
function M:MV_SkillFeaturesModelUpdateHeadUI(eventName, data)
    if self.headUI ~= nil then
        self.headUI:refreshUI(data);
    end
end

function M:destroy()
    M.super.destroy(self)
    if self.headUI ~= nil then
        self.headUI:destroy();
    end
end

return M