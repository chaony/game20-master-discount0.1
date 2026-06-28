--展昭在开启护卫状态后的5秒内生命值不会降低到1点以下

---@class W_ZhanZ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ZhanZ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    --5秒不死buff
    self.noDieBuff = self:getParam(1)
end

function M:gameStart()
    EventDispatcher:registerEvent("add_W_ZhanZ_skill1", {self, self.addBuffHandler})
end

function M:addBuffHandler(eventName, eventData)
    if eventData.buff and eventData.buff.player ~= nil then
        self.player.bufMgr:addBufById(self.noDieBuff, self.player)
    end
end
function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_ZhanZ_skill1", {self, self.addBuffHandler})
end
return M;