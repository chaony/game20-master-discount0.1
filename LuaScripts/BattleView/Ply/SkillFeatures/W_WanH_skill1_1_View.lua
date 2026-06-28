--每进行三次普攻，随机为一个敌人添加一种“七伤”诅咒，每种诅咒会为敌方施加不同的负面状态
---@class W_WanH_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_WanH_skill1_1_View", SkillFeatures_View)

M.effectName = "W_WanH_Skill1_Buff_001"

function M:init(ply, skill, model)
    M.super.init(self, ply, skill, model)
    self.effectList = {}
    EventDispatcher:registerEvent("remove_W_WanH_skill1", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
    self:addEventListener_Local(Battle.SkillEventType.MV_W_WanH_skill1_1_Model_ShowEffect,{self, self.MV_W_WanH_skill1_1_Model_ShowEffect})
end

--显示特效
function M:MV_W_WanH_skill1_1_Model_ShowEffect( eventName, data )
    local target = data.target
    local target_view = self.player.plyMgr:GetPlayerViewByModel(target)
    local index = data.index

    if self.effectList[target] == nil then
        local effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot, self.effectName, target_view.obj)
        if IsNull(effect) == false then
            effect.transform.localPosition = Vector3.New(0,0,0)
            effect.transform.localEulerAngles = Vector3.New(0,180,0)
            self.effectList[target] = {}
            self.effectList[target]["obj"] = effect
            local child = effect.transform:GetChild(0)
            local renderer = child:GetComponent("MeshRenderer")
            for i = 1, 7 do
                renderer.material:SetFloat("_"..i, 0);
            end
            self.effectList[target]["renderer"] = renderer
            self.effectList[target]["curseList"] = {}
        end
    end

    if self.effectList[target] ~= nil then
        table.insert(self.effectList[target]["curseList"], index)
        local renderer = self.effectList[target]["renderer"]
        if renderer ~= nil then
            renderer.material:SetFloat("_"..index, 1);
        end
    end
end

--死亡回调
function M:deadHandler( eventName, data )
    local target = data["data"]
    if self.effectList[target] ~= nil then
        ResourceUtil:ReturnItem(self.effectList[target]["obj"])
        self.effectList[target] = nil
    end
end

function M:removeBuffHandler(eventName, data)
    local buf = data["buff"]
    if buf.source:equal(self.player) then
        local index = self.model:getCurseIndex(buf.id)
        local target = buf.player
        if self.effectList[target] ~= nil then
            local renderer = self.effectList[target]["renderer"]
            if IsNull(renderer) == false then
                renderer.material:SetFloat("_"..index, 0);
            end
            table.removebyvalue(self.effectList[target]["curseList"], index, true)
            if table.nums(self.effectList[target]["curseList"]) <= 0 then
                ResourceUtil:ReturnItem(self.effectList[target]["obj"])
                self.effectList[target] = nil
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.critHandler})
    EventDispatcher:unRegisterEvent("remove_W_WanH_skill1", {self,self.removeBuffHandler})
    if self.effectList ~= nil then
        for k,v in pairs(self.effectList) do
            if v ~= nil and v.obj ~= nil then
                ResourceUtil:ReturnItem(v.obj)
            end
        end
        self.effectList = nil
    end
    M.super.destroy(self)
end
return M