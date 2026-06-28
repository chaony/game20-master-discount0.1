---@class W_JinQ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinQ_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buf1 = self:getParam(1)
    self.buf2 = self:getParam(2)
    self.time = self:getParam(3)
    self.timer = GlobalTools.base0
end

--出生
function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("add_debuff", {self,self.addBuffHandler})
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JinQ_skill2_1_Model_CreateFootEffect)
    self:showEffect(true)
end

--开关特效
function M:showEffect(show)
    local data = {}
    data.show = show;
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JinQ_skill2_1_Model_ShowEffect,data)
end

--更新
function M:update(dt)
    if self.timer > GlobalTools.base0 then
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
           self:showEffect(true)
        end
    end
end

--加buf
function M:addBuffHandler(eventName, data)
    if self.timer <= 0 then
        local buff = data["buff"]
        if buff ~= nil and self.player:equal(buff.player) then
            self:changeBuf()
            self.player.bufMgr:addBufById(self.buf2, self.player)
            self:showEffect(false)
            self.timer = self.time
        end
    end
end

--切换buf
function M:changeBuf( ... )
   -- self.player.bufMgr:addBufById(self.buff, self.player)
end


--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("add_debuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M