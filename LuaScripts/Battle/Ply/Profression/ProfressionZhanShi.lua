--- 战士
--- 开场额外获得200怒气与10%生命上限。
--- 开场额外获得400怒气与10%生命上限。
--- 开场额外获得400怒气与10%生命上限，增加40点攻速和10点吸血等级
---@class ProfressionZhanShi : Profression
---@field super Profression
local M = class("ProfressionZhanShi", Profression)

function M:init(player,data)
    M.super.init(self,player,data)
    --xxx怒气
    self.angerValue = self:getParam(1);
    --xx%生命上限
    self.hpMaxRate = self:getParam(2);
    --增加40点攻速
    self.hasteValue = self:getParam(3);
    --10点吸血等级
    self.suckValue = self:getParam(4);

    --Logger.logError(" 初始化战士技能 ")
    --Logger.logError(" self.angerValue "..tostring(self.angerValue) )
    --Logger.logError(" self.hpMaxRate "..tostring(self.hpMaxRate))
    --Logger.logError(" self.hasteValue "..tostring(self.hasteValue))
    --Logger.logError(" self.suckValue "..tostring(self.suckValue))
    
end

--战斗开始
function M:gameStart()
    self:addProperty()
end

--加属性
function M:addProperty()
    --加生命上限
    local initHp = self.player.data.hp:getInitialValue()
    --Logger.logError(" 设定 最开始生命上限 "..tostring(maxHp) )
    local curMaxHp = GlobalTools:Mul(initHp, self.hpMaxRate) + initHp
    --Logger.logError(" 设定 10%生命上限 "..tostring(curMaxHp) )
    self.player.data.hp:setInitialValue(curMaxHp )
    self.player.data:set_curHp(self.player.data:get_hp())

    --Logger.logError(" 增加怒气 "..tostring(self.angerValue) )
    --增加怒气
    self.player.data:addAnger(self.angerValue)
    --Logger.logError(" 增加攻速 "..tostring(self.hasteValue) )
    --增加攻速
    self.player.data.haste:addToAddList(self.hasteValue)
    --Logger.logError(" 增加吸血等级 "..tostring(self.suckValue) )
    --增加吸血等级
    self.player.data.leeching:addToAddList(self.suckValue)
end


return M;