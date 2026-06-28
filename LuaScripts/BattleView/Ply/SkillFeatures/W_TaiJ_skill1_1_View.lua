--太极身周围会环绕一个阴阳球，每当太极释放普攻时，若身边存在阴阳球，则太极会将阴阳球扔至随机敌方脚下，对小范围内的敌人造成180%攻击力的内功伤害，扔出的阴阳球会在战场上停留3秒，之后再返回太极身边
---@class W_TaiJ_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_TaiJ_skill1_1_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self,player, skill, model)

    --self:addEventListener_Local(Battle.SkillEventType.MV_W_TaiJ_skill3_1_Model_HidePlayer, {self,self.MV_W_TaiJ_skill3_1_Model_HidePlayer})
    --self:addEventListener_Local(Battle.SkillEventType.MV_W_TaiJ_skill1_1_Model_ShowEffect, {self,self.MV_W_TaiJ_skill1_1_Model_ShowEffect})
end


----隐藏和显示特效
--function M:MV_W_TaiJ_skill3_1_Model_ShowEffect(eventName, data)
--    self:showEffect(data.show);
--end

--
----隐藏人物
--function M:MV_W_TaiJ_skill3_1_Model_HidePlayer(eventName, data)
--    local ply_model = data;
--    local ply = self.player.plyMgr:GetPlayerViewByModel(ply_model)
--    if ply ~= nil and ply.tranformHelper ~= nil then
--        local obj = ply.tranformHelper:FindObj(ply.tran, "body")
--        obj:SetActive(false)
--    end
--end

--创建完成
function M:spawnFinish()
    M.super.spawnFinish();

    if self.model.ballCount == 1 then
        self:createEffect("W_TaiJ_Skill1_Buff_001")
    elseif self.model.ballCount == 2 then
        self:createEffect("W_TaiJ_Skill1_Buff_002")
    end
end

--创建特效
function M:createEffect(effectName)
    self.effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot,effectName, self.player.obj)
    if self.effect ~= nil and IsNull(self.effect) == false then
        --大小
        self.effect.transform.localScale = Vector3(1,1,1)
        --位置
        self.effect.transform.localPosition = Vector3(0,1,0)
        --旋转
        self.effect.transform.localRotation = Quaternion.Euler(0, 0, 0)
    end
end

----显示特效
--function M:showEffect(show)
--    if show then
--        self.effect:SetActive(true)
--    else
--        self.effect:SetActive(false)
--    end
--end

--销毁
function M:destroy()
    if self.effect ~= nil then
        ResourceUtil:ReturnItem(self.effect)
        self.effect = nil
    end
end

return M