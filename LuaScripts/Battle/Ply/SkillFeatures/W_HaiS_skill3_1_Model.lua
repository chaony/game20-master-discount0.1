--等级3:海沙受到伤害时,则会恢复5%的最大生命值
---@class W_HaiS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiS_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.addHpBuff = self:getParam(1) -- 海沙受到伤害时,则会恢复5%的最大生命值
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    if self.addHpBuff > 0 and self.player:equal(data.victim) and self.player.bufMgr then -- 自己受到攻击
        self.player.bufMgr:addBufById(self.addHpBuff, self.player,self.skill) -- 加buff
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

   

return M