--- 傲血
--- 血量70%以上时，坚韧增加20，被击怒气回复百分比增加10%
---@class TalismanAoXue : Talisman
---@field super Talisman
local M = class("TalismanAoXue", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.hpRate = self:getParam(1); --血量
    self.buffId = self:getParam(2); --
    EventDispatcher:registerEvent("selfHp", {self,self.selfHpChangeHandler})
end

function M:selfHpChangeHandler(eventName, data)
    local hp_player = data["ply"]
    local cur_rate = data["value"]
    if hp_player and self.player:equal(hp_player) then
        local buff_list = self.player.bufMgr:findBufById(self.buffId)
        local buff_nums = #buff_list
        if cur_rate > self.hpRate and buff_nums == 0 then
            self.player.bufMgr:addBufById(self.buffId, self.player)
        elseif cur_rate <= self.hpRate and buff_nums > 0 then
            self.player.bufMgr:removeBufById(self.buffId, false, false)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("selfHp", {self,self.selfHpChangeHandler})
    M.super.destroy(self)
end

return M;