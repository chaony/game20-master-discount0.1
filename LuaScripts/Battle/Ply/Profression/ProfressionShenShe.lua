--- 神射
--- 每秒3秒提升2%攻击，最大提升10%攻击。
--- 每秒3秒提升3%攻击，最大提升15%攻击。
--- 每秒3秒提升3%攻击，最大提升15%攻击。若击杀敌人，则额外增加 提升5%攻击 和 提升最大攻击5%，最多5次。
---@class ProfressionShenShe : Profression
---@field super Profression
local M = class("ProfressionShenShe", Profression)

function M:init(player,data)
    M.super.init(self,player,data)
    --每秒xx秒
    self.attackAddTime = self:getParam(1);
    --提升XX%攻击
    self.attackPerent = self:getParam(2);
    --最大提升XXX%攻击
    self.maxAttackPerent = self:getParam(3);
    --额外攻击xx
    self.outAttackPerent = self:getParam(4);
    --额外攻击上限xx
    self.outMaxAttackPerent = self:getParam(5);
    --攻击持续时间
    self.curattackAddTime = 0;
    --当前提升攻击百分比
    self.curAddAttackValue = 0;
    --最大上限是5
    self.maxCount = 5;
    self.curCount = 0;
    self.curAddAttackPerent = 0;

    --Logger.logError(" 初始化神射技能 ")
    --Logger.logError(" self.attackAddTime "..tostring(self.attackAddTime) )
    --Logger.logError(" self.attackPerent "..tostring(self.attackPerent))
    --Logger.logError(" self.maxAttackPerent "..tostring(self.maxAttackPerent))
    --Logger.logError(" self.outAttackPerent "..tostring(self.outAttackPerent))
    --Logger.logError(" self.outMaxAttackPerent "..tostring(self.outMaxAttackPerent))
end

--游戏开始
function M:gameStart()
    --每隔xxx秒
    self.curattackAddTime = self.attackAddTime;
    --当前的最大增加次数
    self.curCount = self.maxCount;
    --当前提升的攻击百分比
    self.curAddAttackPerent = 0;
end

--
function M:update(time)
    --当前 累计攻击百分比 < 最大攻击百分比
    if self.curAddAttackValue < self.maxAttackPerent then
        --当前的时间
        if self.curattackAddTime > 0 then
            self.curattackAddTime = self.curattackAddTime - time;
            if self.curattackAddTime <= 0 then
                --记录增加的攻击百分比
                self.curAddAttackValue = self.curAddAttackValue + self.attackPerent;
                --如果最大百分比 - 当前累计的百分比 < 单次增加的百分比
                if self.maxAttackPerent - self.curAddAttackValue < self.attackPerent then
                    --取 最大百分比 和 当前累计百分比的 差值
                    self.curAddAttackPerent = self.maxAttackPerent - self.curAddAttackValue
                else
                    --取 当前攻击百分比
                    self.curAddAttackPerent = self.attackPerent
                end
                --Logger.logError(" 增加攻击力百分比 "..tostring(self.curAddAttackPerent))
                self.player.data.atk:addToMulList(self.curAddAttackPerent)
                self.curattackAddTime = self.attackAddTime;
            end
        end
    end
end

--攻击时
function M:Attack( attackData )
    if attackData.victim.data:get_curHp() - attackData.damage <= 0 then
        --Logger.logError(" 击杀敌人 ")
        --可以取到额外攻击百分比系数
        if self.outAttackPerent ~= nil then
            if self.curCount > 0 then
                --Logger.logError(" 增加额外攻击力百分比 "..tostring(self.outAttackPerent))
                self.curAddAttackValue = self.curAddAttackValue + self.outAttackPerent
                --增加额外百分比
                self.player.data.atk:addToMulList(self.outAttackPerent)

                --Logger.logError(" 增加最大攻击力百分比 "..tostring(self.maxAttackPerent))
                --增加最大百分比
                self.maxAttackPerent = self.maxAttackPerent + self.outMaxAttackPerent;
                --增加层数
                self.curCount = self.curCount - 1;
            end
        end
    end
end


return M;