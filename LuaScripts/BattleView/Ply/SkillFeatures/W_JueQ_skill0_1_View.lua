--绝情被动
--在自身周围召唤结界，结界内的敌人受到的所有内力恢复效果会降低40% 
--敌人首次尝试出入结界的时候 会受到200%攻击力的伤害和2秒眩晕
---@class W_JueQ_skill0_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JueQ_skill0_1_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self.effectList = {}
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JueQ_skill0_1_Model_CreateEffect, {self,self.MV_W_JueQ_skill0_1_Model_CreateEffect})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JueQ_skill0_1_Model_DeleteEffect, {self,self.MV_W_JueQ_skill0_1_Model_DeleteEffect})
end


function M:MV_W_JueQ_skill0_1_Model_DeleteEffect( eventName, data )
    local index = data.index;
    local effect_data = self.effectList[index];
    if effect_data ~= nil and effect_data.effect ~= nil then
        ResourceUtil:ReturnItem(effect_data.effect)
    end
end


function M:MV_W_JueQ_skill0_1_Model_CreateEffect( eventName, data )
    local victim = data["victim"]
    
    local effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"W_JueQ_Skill0_Buff_001", nil)
    if effect ~= nil then
        effect.transform.position = victim.position:toVector3()
        effect.gameObject:SetActive(false)
    end

    local effectStart = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"W_JueQ_Skill0_SF_001", nil)
    if effectStart ~= nil then
        effectStart.transform.position = victim.position:toVector3()
        effectStart.gameObject:SetActive(true)
    end

    local index = self.model.effectIndex
    self.effectList[index] = {
        effect = effect
    }

    TimeTools:delayTimeUnity(1.3,
            function()
                ResourceUtil:ReturnItem(effectStart)
                if self.effectList[index] ~= nil and self.effectList[index].effect ~= nil then
                    self.effectList[index].effect.gameObject:SetActive(true)
                end
            end)
end


function M:destroy()
    M.super.destroy(self)
    for k,v in pairs(self.effectList) do
        ResourceUtil:ReturnItem(v.effect)
    end
    self.effectList = {}
end

return M