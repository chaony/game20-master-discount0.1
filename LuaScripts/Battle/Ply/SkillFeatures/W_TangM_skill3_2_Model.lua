--后续6秒内蛇毒发作平率大幅上升
local W_TangM_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_TangM_skill3_1_Model")
---@class W_TangM_skill3_2_Model : W_TangM_skill3_1_Model @
---@field super W_TangM_skill3_1_Model @W_TangM_skill3_1_Model
local M = class("W_TangM_skill3_2_Model", W_TangM_skill3_1_Model)


--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.time = self:getParam(2)
--    self.freq = self:getParam(3)
--    self.cur_timer = 0
--end

----技能结束
--function M:skillEnd()
--    M.super.skillEnd(self)
--    self.cur_timer = self.time
--    local marks = self.player.bufMgr:findBufByFromMeType("Mark")
--    for k,v in ipairs(marks) do
--        if v.bufWork ~= nil then
--            v.bufWork.intervalReduce = self.freq
--        end
--    end
--    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
--end
--
--
--function M:update(dt,unsdt)
--    M.super.update(self,dt,unsdt)
--    if self.cur_timer > 0  then
--        self.cur_timer = self.cur_timer - dt
--        if self.cur_timer <= 0  then
--            EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
--
--            self.cur_timer = 0
--            local marks = self.player.bufMgr:findBufByFromMeType("Mark")
--            for k,v in ipairs(marks) do
--                if v.bufWork ~= nil then
--                    v.bufWork.intervalReduce = 0
--                end
--            end
--        end
--    end
--end
--
----条件触发
--function M:addBuffHandler( eventName, data )
--    local buf = data.buff
--    if buf.type == "Mark" and self.player: equal(buf.source) then
--        if buf.bufWork ~= nil then
--            buf.bufWork.intervalReduce = self.freq
--        end
--    end
--end

return M