--昆仑附身状态下，每5秒会治疗附身英雄一次，治疗量为攻击的100%
---@class W_KunL_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KunL_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureBuff = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end


function M:SendForFinish()
    
end


function M:follow( followPly )
    --昆仑附身状态下，每5秒会治疗附身英雄一次，治疗量为攻击的100%
    if followPly ~= nil then
        followPly.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

return M