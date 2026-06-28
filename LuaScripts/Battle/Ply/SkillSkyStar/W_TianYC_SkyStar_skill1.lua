--"寂灭：
--“毁殇”状态下击杀单位，百里屠苏会回复10%最大生命值，并增加“毁殇”6秒持续时间

---@class W_TianYC_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TianYC_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1, 0)
    self.addLastTime = self:getParam(2, 0)
    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
end

--杀死敌人
function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    if self.player:equal(killer) then
        local W_TianYC_skill3 = self.player.bufMgr:findBufByTag("W_TianYC_skill3")
        if table.nums(W_TianYC_skill3) > 0 then
            self.player.bufMgr:addBufById(self.buffId, self.player)
            for k,v in ipairs(W_TianYC_skill3) do
                v.curLastTime = v.curLastTime + self.addLastTime
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M;