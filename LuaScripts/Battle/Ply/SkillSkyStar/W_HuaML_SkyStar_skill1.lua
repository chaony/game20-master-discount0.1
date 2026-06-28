--花木兰天命：红裳 效果第一次消失后，花木兰会获得60%的攻击力提升和50%的伤害减免，持续8秒。

---@class W_HuaML_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HuaML_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.bufId = self:getParam(1)
    self.triggerCnt = 0
    EventDispatcher:registerEvent("remove_W_HuaML_skill0", {self, self.removeBuffHandler})
end

--红裳 效果第一次消失后 获得buff
function M:removeBuffHandler( eventName, data )
    if self.triggerCnt == 0 then
        local buff = data["buff"]
        if buff ~= nil and self.player:equal(buff.source) then
            local buffs = self.player.bufMgr:findBufByTag("W_HuaML_skill0")
            if  table.nums(buffs) <= 1 then
                self.player.bufMgr:addBufById(self.bufId, self.player)
                self.triggerCnt = self.triggerCnt + 1
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_HuaML_skill0", {self, self.removeBuffHandler})
end

return M;