---@class W_BaG_skill2_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_BaG_skill2_1_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self.show = true;
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
    EventDispatcher:registerEvent("critCount", handler(self,self.critHandler))
end

--出生
function M:spawn()
    M.super.spawn(self);
    --挂机场景不会有特效
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
        if self.player.foot ~= nil then
            self.effect_list = Battle.List.new()
            --八卦脚下特效
            self.player.footEffect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,"W_BaG_skill2_buff", self.player.foot.gameObject)
            if self.player.footEffect ~= nil and IsNull(self.player.footEffect) == false then
                self.effect_list:add(self.player.tranformHelper:FindObj(self.player.footEffect.transform, "fx_mat_BaGua_019"))
                self.effect_list:add(self.player.tranformHelper:FindObj(self.player.footEffect.transform, "fx_mat_BaGua_020"))
                self.effect_list:add(self.player.tranformHelper:FindObj(self.player.footEffect.transform, "fx_mat_BaGua_021"))
                self.effect_list:add(self.player.tranformHelper:FindObj(self.player.footEffect.transform, "fx_mat_BaGua_022"))
                --大小
                self.player.footEffect.transform.localScale = Vector3(1,1,1)
                --位置
                self.player.footEffect.transform.localPosition = Vector3(0,0,0)
                --旋转
                self.player.footEffect.transform.localRotation = Quaternion.Euler(0, 0, 0)
            end
        end
    end
    self:showEffect(false);
end

--暴击数量 
--根据暴击数量更新暴击特效 critCount
function M:updateCritEffect( critCount )
    if self.effect_list ~= nil then
        for i = 0, self.effect_list.Count - 1 do
            local show = i < critCount
            local effect = self.effect_list:get(i)
            if IsNull(effect) == false and effect.activeSelf ~= show then
                effect:SetActive(show)
            end
        end
    end
end

--技能开始
function M:skillStart()
    M.super.skillStart(self)
    if self.effect_list ~= nil then
        for i=1,self.effect_list.Count do
            if IsNull(self.effect_list:get(i-1)) == false then
                self.effect_list:get(i-1):SetActive(false)
            end
        end
    end
    self:showEffect(false)
    self.curCritCount = 0
end

--显示特效
function M:showEffect(show)
    if IsNull(self.player.footEffect) == false and self.show ~= show then
        self.player.footEffect:SetActive(show)
        self.show = show
    end
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil   then
        if "skill3" == config.anim_name  then
            self:showEffect(false)
        end
    end
end


--技能释放
function M:critHandler( eventName, data )
    local killer = data["ply"]
    if killer ~= nil and killer:equal(self.player) then
        if self.player.curSkillConfig ~= nil then
            if self.player.curSkillConfig.anim_name ~= "skill2" then
                self.curCritCount = self.curCritCount + 1
            end
            if self.player.curSkillConfig.anim_name == "attack1" or self.player.curSkillConfig.anim_name == "skill1" then
                self:showEffect(true)
            end
        end
        self:updateCritEffect(self.curCritCount);
    end
end



--技能结束
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil  then
        if "skill3" == config.anim_name   then
            self:showEffect(true)
        end
    end
end


--视图销毁
function M:destroy()
    if self.effect_list ~= nil then
        self.effect_list:clear();
        self.effect_list = nil;
    end
    if self.player.footEffect ~= nil then
        ResourceUtil:ReturnItem(self.player.footEffect)
        self.player.footEffect = nil;
    end
    EventDispatcher:unRegisterEvent("critCount", handler(self,self.critHandler))
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end

return M