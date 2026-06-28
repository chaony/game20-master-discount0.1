--护盾效果降低50% 10S
---@class B_TaoW_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_TaoW_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isFive = self:getParam(1) --第五形态
    self.shiled = self:getParam(2)
    EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end

function M:skillStart(data)
    if self.isFive == 1 then
        self.skill.extra_anim_name = "skill3_1"
    else
        self.skill.extra_anim_name = "skill3"
    end
end

function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if isStart == true then
        if buf ~= nil then
            if buf.value > 0 and ply.bufMgr and ply.bufMgr:hasBufByTag("B_TaoW_skill3") then
                buf.value = GlobalTools:Mul( buf.value, (GlobalTools.base1 + self.shiled) )
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler}) M.super.destroy(self)
end

return M