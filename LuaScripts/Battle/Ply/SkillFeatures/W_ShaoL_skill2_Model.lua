--少林skill2 少林进入防御状态 5秒 期间无法攻击和移动且会免疫所有控制效果，
--防御状态下回获得一个护盾，抵消自升攻击里500%的伤害，
--若该护盾在持续期间被打破，则少林会获得30%的减伤持续到防御状态结束
---@class W_ShaoL_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShaoL_skill2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.time = self:getParam(1)
    self.buffId = self:getParam(2)
    self.start = false
    self.cur_time = GlobalTools.base0;
    self.playerRenders = Battle.List.new()
end

--出生
function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end

--技能释放
function M:skillStart(data)
    self.start = true
end

--技能结束
function M:skillEnd()
     self.start = false
     self.cur_time = 0
    self.player.bufMgr:removeBufById(self.buffId)
    self.player.bufMgr:removeBufByTag("W_ShaoL_skill2")
end

--更新
function M:update(dt,unsdt)
    if self.start then
        self.cur_time = self.cur_time + dt
        if self.cur_time >= self.time then
            self.player.animator:changeState("skill2_End")
            self.cur_time = 0 
            self.start = false
        end
    end
end



function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if isStart == false then
        if buf.value <= GlobalTools.base0 then
            if buf.playerBuf.player:equal(self.player) then
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        end
    end
end



function M:destroy()
    M.super.destroy(self) 
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
end

return M