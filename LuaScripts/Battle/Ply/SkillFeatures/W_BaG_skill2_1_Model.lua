---@class W_BaG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaG_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.show = true;
    self.count = 0;
    self.curCritCount = 0;
    self.critCount = self:getParam(1)
    EventDispatcher:registerEvent("critCount", {self, self.critHandler})
end

--出生时
function M:spawn()
    M.super.spawn(self)
end

function M:canUse()
    if self.curCritCount >= self.critCount then
        return true
    end
    return false
end

--技能释放
function M:critHandler( eventName, data )
    local killer = data["ply"]
    if killer ~= nil and killer:equal(self.player) then
        if self.player.curSkillConfig ~= nil then
            if self.player.curSkillConfig.anim_name ~= "skill2" then
                self.curCritCount = self.curCritCount + 1
            end
        end
    end
end

--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    self.curCritCount = 0;
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("critCount", {self, self.critHandler})
end

return M