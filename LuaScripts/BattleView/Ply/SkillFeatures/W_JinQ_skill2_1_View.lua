---@class W_JinQ_skill2_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JinQ_skill2_1_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self.show = false
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JinQ_skill2_1_Model_ShowEffect,{self, self.MV_W_JinQ_skill2_1_Model_ShowEffect})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JinQ_skill2_1_Model_CreateFootEffect,{self, self.MV_W_JinQ_skill2_1_Model_CreateFootEffect})
end

--金钱显示特效
function M:MV_W_JinQ_skill2_1_Model_ShowEffect(eventName, data)
    self:showEffect(data.show);
end

--金钱显示特效
function M:MV_W_JinQ_skill2_1_Model_CreateFootEffect(eventName, data)
    self:createFootEffect();
end

--创建脚底特效
function M:createFootEffect()
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
        if self.player.foot ~= nil then
            self.footEffect  = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"W_JinQ_Skill2_Buff_001", self.player.foot.gameObject)
            if self.footEffect ~= nil then
                --大小
                self.footEffect.transform.localScale = Vector3(1,1,1)
                --位置
                self.footEffect.transform.localPosition = Vector3(0,0,0)
                --旋转
                self.footEffect.transform.localRotation = Quaternion.Euler(0, 0, 0)
            end
        end
    end
end

--开关特效
function M:showEffect(show)
    if IsNull(self.footEffect) == false and  self.show ~= show then
        self.footEffect:SetActive(show)
        self.show = show
    end
end


--销毁脚底特效
function M:destroy()
    if IsNull(self.footEffect) == false then
        ResourceUtil:ReturnItem(self.footEffect)
        self.footEffect = nil;
    end
end


return M