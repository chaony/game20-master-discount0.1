--探花的普攻威力提升至600%攻击力，暴击伤害提升50%，但每次普攻之前都需要蓄力8秒
---@class W_TanH_skill1_1 : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
---@field model W_TanH_skill1_1_Model
local M = class("W_TanH_skill1_1", SkillFeatures_View)


function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self:addEventListener_Local(Battle.SkillEventType.MV_W_TanH_skill1_1_Model_ShowEffect,{self, self.MV_W_TanH_skill1_1_Model_ShowEffect})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_TanH_skill1_1_Model_RefreshEffect,{self, self.MV_W_TanH_skill1_1_Model_RefreshEffect})
    
end

--显示特效
function M:MV_W_TanH_skill1_1_Model_ShowEffect( eventName, data ) 
    self:showEffect(data.show)
end

function M:spawn()
    
end


function M:showEffect(show)
    if self.footEffect == nil then
        self.footEffect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"W_TanH_Skill1_Buff_001")
    end
    if IsNull(self.footEffect) == false then
        self.footEffect.transform.parent = self.player.foot
        self.anim = self.footEffect:GetComponent("Animator")
        self.anim.speed = 6.5/(GlobalTools:ToFloat(self.model.currentInterval))
        self.anim:CrossFade("W_TanH_Skill1_Buff_001", 0, 1, 1 - (self.model.timer / self.model.currentInterval))

        --大小
        self.footEffect.transform.localScale = Vector3(1,1,1)
        --位置
        self.footEffect.transform.localPosition = Vector3(0,0,0)
        --旋转
        self.footEffect.transform.localRotation = Quaternion.Euler(0, 0, 0)
        self.footEffect:SetActive(false)

        if show then
            self.footEffect:SetActive(true)
        else
            self.footEffect:SetActive(false)
        end
    end
end

function M:MV_W_TanH_skill1_1_Model_RefreshEffect(eventName, eventData)
    if IsNull(self.footEffect) == false then
        self.anim = self.footEffect:GetComponent("Animator")
        self.anim.speed = 6.5/(GlobalTools:ToFloat(self.model.currentInterval))
        self.anim:CrossFade("W_TanH_Skill1_Buff_001", 0, 1, 1 - (self.model.timer / self.model.currentInterval))
    end
end

function M:destroy()
    M.super.destroy(self)
    if self.footEffect ~= nil then
        ResourceUtil:ReturnItem(self.footEffect)
    end
end
return M