--玄武boss skill2
--卸甲 进入防御状态，期间自己无法攻击，并在身体周围形成一层护盾，护盾可抵御200%boss攻击力的伤害
--若防御姿态结束时boss的护盾未被打破，则护盾会爆炸，对周围造成伤害
---@class B_XuanW_skill2_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("B_XuanW_skill2_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self,player, skill, model)
    --渲染器
    self.playerRenders = Battle.List.new()
end

function M:spawn()
    M.super.spawn(self)
    if self.player.tran ~= nil then
        local tranformHelper = self.player.tran:GetComponent("LuaTransformHelper");
        local body = self.player.tran:Find("body");
        for i=1,body.childCount do
            local child = body:GetChild(i-1)
            local isHas = tranformHelper:HasComponent(child, "SkinnedMeshRenderer")
            if isHas == true then
                local render =  child:GetComponent("SkinnedMeshRenderer")
                if render:Equals(nil) == false then
                    self.playerRenders:add(render)
                end
            end
        end
    end
end

--设定材质球
function M:setMaterial( toggler )
    for i=1,self.playerRenders.Count do
        local render = self.playerRenders:get(i-1);
        local mats = render.materials
        for j=1,mats.Length do
            local mat = mats[j-1]
            mat:SetFloat("_FresnelToggler",toggler)
        end
    end
end

--销毁时
function M:destroy()
    M.super.destroy(self)
    self:setMaterial(0)
end


return M