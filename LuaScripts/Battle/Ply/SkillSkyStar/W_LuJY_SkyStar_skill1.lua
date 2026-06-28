--天罡麒麟阵：阵图内的友军获得伤害提升至40%

---@class W_LuJY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LuJY_SkyStar_skill1",SkillSkyStar)

function M:init( player, param, level )
    M.super.init(self,player, param, level )
    EventDispatcher:registerEvent("add_W_LuJY_skill3", {self,self.addBuffHandler})
    self.buffId = self:getParam(1, 0)
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) and eventData.buff.player.bufMgr then
        eventData.buff.player.bufMgr:addBufById(self.buffId, eventData.buff.source)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_LuJY_skill3", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M;