--当关羽被施加负面状态时，免疫该负面状态并使自身免疫负面状态1秒，每次触发该效果时，关羽还会恢复10%最大生命值，该效果有5秒冷却时间
---@class W_GuanY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.mianyiBuff = self:getParam(1)
    self.cureBuff = self:getParam(2)
    self.cdTime = self:getParam(3)
    self.defBuff = self:getParam(4)
    self.cdFlag = false
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) and not self.player:equal(buff.source) and not self.cdFlag then
        if buff:checkTag("debuff") or buff:checkTag("control") or buff:checkTag("meihuo")  then
            self.cdFlag = true
            self.player.bufMgr:removeBuf(buff, false)
            self.player.bufMgr:addBufById(self.mianyiBuff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.defBuff, self.player, self.skill)
            TimeTools:delayTime(self.cdTime, function()
                self.cdFlag = false
            end)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M