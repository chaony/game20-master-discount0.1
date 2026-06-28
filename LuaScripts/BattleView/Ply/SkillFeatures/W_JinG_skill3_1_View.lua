--金刚进入蓄力状态8秒，蓄力期间，金刚受到的所有伤害减少50%且免疫控制效果。蓄力期间每受到1次攻击，会累积1点怒气，
--蓄力结束后，金刚会向前横挥，对范围内的敌人造成300%攻击力的外功伤害，自身每存在一点怒气，该技能造成的伤害就提升1%，
--金刚最多储存100点怒气。
---@class W_JinG_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JinG_skill3_1_View", SkillFeatures_View)

function M:init( player, skill, model)
    M.super.init(self, player, skill, model )
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelCreateHeadUI,{self, self.MV_SkillFeaturesModelCreateHeadUI})
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelUpdateHeadUI,{self, self.MV_SkillFeaturesModelUpdateHeadUI})
end

--更新头顶UI
function M:MV_SkillFeaturesModelUpdateHeadUI(eventName, data)
    if self.headUI ~= nil then
        self.headUI:refreshUI(data);
    end
end

--创建头顶UI
function M:MV_SkillFeaturesModelCreateHeadUI(eventName, data)
    self.headUI = self.headUIMgr:add(data.uiName, data);
end

function M:destroy()
    M.super.destroy(self)
    if self.headUI ~= nil then
        self.headUI:destroy()
    end
end

return M