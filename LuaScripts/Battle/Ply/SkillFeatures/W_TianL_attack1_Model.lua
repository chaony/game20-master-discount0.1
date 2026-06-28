---@class W_TianL_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianL_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.attack2buff = self:getParam(1)
    self.attack2buffRate = self:getParam(2)
    self.attackCount = 0;
    --self.attack3buff = self:getParam(3)
    EventDispatcher:registerEvent("injure", {self, self.injureHandle})
end

--技能释放
function M:skillStart()
    self.attackCount = self.attackCount + 1
    self.player.curSkillConfig.extra_anim_name = "attack1_"..self.attackCount
end

function M:injureHandle(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    if killer ~= nil and killer:equal(self.player) then
        if self.attackCount == 2 then
            local rate = WRandom:randomNum(0, 100)
            if self.attack2buffRate < rate then
                victim.bufMgr:addBufById(self.attack2buff, self.player)
            end
        elseif self.attackCount == 3 then
            --victim.bufMgr:addBufById(self.attack3buff, self.player)
        end
    end
end

function M:skillEnd()
    if self.attackCount == 3 then
        self.attackCount = 0
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandle})
end

return M