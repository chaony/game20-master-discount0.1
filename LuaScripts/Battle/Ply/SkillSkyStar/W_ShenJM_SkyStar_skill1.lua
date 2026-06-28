--通过寒芒浣影获得“神剑”状态后3秒内不会死亡

---@class W_ShenJM_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ShenJM_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --加攻击的buff
    self.invicibleBuf = self:getParam(1)--免死
    EventDispatcher:registerEvent("add_W_ShenJM_skill2", {self,self.addBuffHandler})
end

function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) and eventData.buff.player.bufMgr then
        eventData.buff.player.bufMgr:addBufById(self.invicibleBuf, eventData.buff.source)
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_ShenJM_skill2", {self,self.addBuffHandler})
end
return M;