---@class W_XieJ_Weapon_skill0_1_View : SkillFeatures_View
---@field super SkillFeatures_View
---@field puppetsObj UnityEngine.GameObject[]
local M = class("W_XieJ_Weapon_skill0_1_View", SkillFeatures_View)

function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self.activeIndex = {
        true, false, false
    }
    self.puppetsObj = {}
    self.isInitFinish = false
    self.isAddListener = true
    self:addEventListener_World(Battle.SkillEventType.MV_W_XieJ_Weapon_skill_Model_Puppet_Change,{self, self.MV_W_XieJ_Weapon_skill_Model_Puppet_Change})
end


function M:spawn()
    self:loadWeaponObject()
    M.super.spawn(self)
end

function M:loadFinish(data)
    self:loadWeaponObject()
    M.super.loadFinish(self, data)
end

function M:loadWeaponObject()
    if self.isInitFinish then
        return
    end 
    if IsNull(self.player.tranformHelper) == false and IsNull(self.player.tran) == false then
        self.isInitFinish = true
        local weapon1 = self.player.tranformHelper:FindObj(self.player.tran, "W_XieJ_Weapon1")
        local weapon2 = self.player.tranformHelper:FindObj(self.player.tran, "W_XieJ_Weapon2")
        local weapon3 = self.player.tranformHelper:FindObj(self.player.tran, "W_XieJ_Weapon3")
        self.puppetsObj = {weapon1, weapon2, weapon3}
        for i = 1, 3 do
            self:changePuppetState(i)
        end
    end
end
    
function M:MV_W_XieJ_Weapon_skill_Model_Puppet_Change(eventName, data)
    local states = data.summonPuppets
    for i = 1, 3 do
        if states[i] ~= self.activeIndex[i] then
            self.activeIndex[i] = states[i] 
            self:changePuppetState(i)
        end
    end
end

function M:changePuppetState(index)
    local isActive = (self.activeIndex[index] == true)
    local obj = self.puppetsObj[index]
    if IsNull(obj) then
        return
    end
    local render =  obj:GetComponent("SkinnedMeshRenderer")
    if not IsNull(render) then
        if isActive then
            --local color = Color.New(1, 0, 0.887, 1)        -- 激活状态的效果
            render.material:SetFloat("_UseMainColor", 1);
            --render.material:SetColor("_FeedBackColor", color);
        else
            --local color = Color.New(1, 1, 1, 1)
            render.material:SetFloat("_UseMainColor", 0);
            --render.material:SetColor("_FeedBackColor", color);
        end
    end
end

function M:getPuppetByIndex()
    
end


function M:destroy()
    if self.isAddListener then
        self:removeEventListener_World(Battle.SkillEventType.MV_W_XieJ_Weapon_skill_Model_Puppet_Change,{self, self.MV_W_XieJ_Weapon_skill_Model_Puppet_Change})
        self.isAddListener = false
    end
    M.super.destroy(self)
end

return M
