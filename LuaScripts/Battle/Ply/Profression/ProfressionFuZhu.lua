--- 辅助(测试ok)
--- 战斗开始时获得一个20%最大生命值的护盾持续5秒
--- 战斗开始时获得一个20%最大生命值的护盾持续5秒，若结束时护盾存在，则每1%生命的护盾值转化为怒气10点，最大不超过200点。
--- 战斗开始时获得一个30%最大生命值的护盾持续5秒，若结束时护盾存在，则每1%生命的护盾值转化为怒气10点，最大不超过300点。
---@class ProfressionFuZhu : Profression
---@field super Profression
local M = class("ProfressionFuZhu", Profression)

function M:init(player,data)
    M.super.init(self,player,data)
    --20%最大生命值的护盾 buf
    self.sheildBuf = self:getParam(1);
    --提升XX%攻击
    self.sheildBufTime = self:getParam(2);
    --转换怒气
    self.changeAnger = self:getParam(3);
    --血量百分比
    self.hpPerent = self:getParam(4);
    --最大怒气
    self.maxAnger = self:getParam(5);
    --当前的护盾时间
    self.curSheildBufTime = 0;

    --Logger.logError(" 初始化辅助技能 ")
    --Logger.logError(" self.sheildBuf "..tostring(self.sheildBuf) )
    --Logger.logError(" self.sheildBufTime "..tostring(self.sheildBufTime))
    --Logger.logError(" self.changeAnger "..tostring(self.changeAnger))
    --Logger.logError(" self.hpPerent "..tostring(self.hpPerent))
    --Logger.logError(" self.maxAnger "..tostring(self.maxAnger))
end

--战斗开始
function M:gameStart()
    self.curSheildBufTime = self.sheildBufTime - GlobalTools.base0_5;
    self.player.bufMgr:addBufById(self.sheildBuf, self.player)
    --Logger.logError(" 战斗开始 加一个护盾buf "..tostring(self.sheildBuf) )
end


function M:update( time )
    if self.curSheildBufTime > 0 then
        self.curSheildBufTime = self.curSheildBufTime - time;
        if self.curSheildBufTime <= 0 then
            if self.changeAnger ~= nil then
                local buflist = self.player.bufMgr:findBufByType("Shield")
                local sheildValue = 0
                for i, v in ipairs(buflist) do
                    sheildValue = sheildValue + v.bufWork:get_value()
                end
                --Logger.logError(" 护盾时间结束 护盾值 "..tostring(sheildValue) )
                --最大血量的 1%
                local unitHp = GlobalTools:Mul(self.player.data:get_hp(), self.hpPerent)
                local count = GlobalTools:Div( sheildValue, unitHp);
                local add_anger = GlobalTools:Mul(count, self.changeAnger )
                if add_anger > self.maxAnger then
                    add_anger = self.maxAnger;
                end
                --Logger.logError(" 护盾时间结束 护盾值 装换成 怒气 "..tostring(add_anger) )
                self.player.data:addAnger(add_anger,true);
            end
        end
    end
end

return M;