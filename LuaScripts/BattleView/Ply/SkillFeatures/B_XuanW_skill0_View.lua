--玄武boss skill0
--玄武之躯
--每损失一定血量，会叠加一层强化buf，每层buf会提升防御力和攻击，buf叠加至10、20、50层时，boss都会陷入8秒的虚弱状态
--此时boss的防御力会大幅降低，虚弱状态结束时，boss会获得额外的强化效果
--10层时获得一层相当于200%的自身防御的护盾
--20层时自身将受到物理伤害减少50%
--50层时将受到物理伤害的80%放回给攻击者
---@class B_XuanW_skill0_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("B_XuanW_skill0_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self,player, skill, model)
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelDestroyEffect,{self,self.SkillFeaturesModelDestroyEffect});
end

--销毁特效
function M:SkillFeaturesModelDestroyEffect()
    if self.effect ~= nil then
        ResourceUtil:ReturnItem(self.effect)
        self.effect = nil;
    end
end


function M:skillStart(data)
    M.super.skillStart(data);
    TimeTools:delayTimeUnity(2,
        function()
            self.effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"B_XuanW_Skill3_Buff_001", self.player.foot.gameObject)
            self.effect.transform.localScale = Vector3(-1,1,1)
                    --位置
            self.effect.transform.localPosition = Vector3(-6,1,0)
            self.effect.transform.localRotation = Quaternion.Euler(0, 0, 0)
        end)
end

--销毁
function M:destroy()
    M.super.destroy(self)
    if self.effect ~= nil then
        ResourceUtil:ReturnItem(self.effect)
        self.effect = nil;
    end
end

return M