---@class W_JiuT_skill2_1_View : SkillFeatures_View
---@field super SkillFeatures_View
local M = class("W_JiuT_skill2_1_View", SkillFeatures_View)
function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self.show = false
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JiuT_skill2_1_Model_ShowEffect,{self, self.MV_W_JiuT_skill2_1_Model_ShowEffect})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_JiuT_skill2_1_Model_CreateFootEffect,{self, self.MV_W_JiuT_skill2_1_Model_CreateFootEffect})
    self.effectTab = {}
end

--九天显示特效
function M:MV_W_JiuT_skill2_1_Model_ShowEffect(eventName, show)
    self:showEffect(show);
end

--九天显示特效
function M:MV_W_JiuT_skill2_1_Model_CreateFootEffect(eventName, effectNameTab)
    self:createFootEffect(effectNameTab);
end

--创建脚底特效
function M:createFootEffect(effectNameTab)
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
        if self.player.foot ~= nil then
            for i, v in pairs(effectNameTab) do
                local footEffect  = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,v..LODUtil:getLodKey(), self.player.foot.gameObject)
                if footEffect ~= nil then
                    --大小
                    footEffect.transform.localScale = Vector3(1,1,1)
                    --位置
                    footEffect.transform.localPosition = Vector3(0,0,0)
                    --旋转
                    footEffect.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    self.effectTab[#self.effectTab+1] = footEffect
                end
            end
            
        end
    end
end

--开关特效
function M:showEffect(show)
    for i, v in pairs(self.effectTab) do
        if IsNull(v) == false and self.show ~= show then
            v:SetActive(show)
            self.show = show
        end
    end
end


--销毁脚底特效
function M:destroy()
    for i, v in pairs(self.effectTab) do
        if IsNull(v) == false then
            ResourceUtil:ReturnItem(v)
        end
    end
    self.effectTab = {}
end
return M
