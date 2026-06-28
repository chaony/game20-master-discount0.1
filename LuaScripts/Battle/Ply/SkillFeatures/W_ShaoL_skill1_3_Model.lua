--少林技能一被动，
--第二击每击中一个敌人自身减伤20%持续8秒
---@class W_ShaoL_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShaoL_skill1_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --减伤
	self.buffId = self:getParam(1)
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if ply ~= nil and ply:equal(self.player) then
        if skillConfig ~= nil and "skill1" == skillConfig.anim_name  then
            local injuremove = data["attackData"]["injureMove"]
            if injuremove ~= nil and table.nums(injuremove) > 0 then
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        end
    end
end


function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M