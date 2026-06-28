--- 护卫
--- 战斗开始提升伤害减免+10%，持续6秒。
--- 战斗开始提升伤害减免+20%，持续8秒
--- 战斗开始提升伤害减免+20%，受击有20%概率额外恢复100怒气，持续8秒
---@class ProfressionHuWei : Profression
---@field super Profression
local M = class("ProfressionHuWei", Profression)


function M:init(player,data)
    M.super.init(self,player,data)
    --伤害减免
    self.damageReduce = self:getParam(1, GlobalTools.base1);
    --持续时间
    self.time = self:getParam(2, 0)
    --20%概率
    self.angerCondition = self:getParam(3)
    --100怒气
    self.angerValue = self:getParam(4)

    self.curTime = 0
    --外伤伤害减伤率
    self.damageReduceRate = self.damageReduce

--    Logger.logError(" 初始化护卫技能 ")
--    Logger.logError(" self.damageReduce "..tostring(self.damageReduce) )
--    Logger.logError(" self.time "..tostring(self.time))
--    Logger.logError(" self.angerCondition "..tostring(self.angerCondition))
--    Logger.logError(" self.angerValue "..tostring(self.angerValue))
end

--战斗开始
function M:gameStart()
    self:addProperty()
    self.curTime = self.time;
end


function M:addProperty()
    --外伤减伤(乘，同类加异类乘)
    --Logger.logError(" 改变外伤减伤 ~~~~~~~~~~ "..tostring(self.damageReduceRate) )
    --外伤减伤
    self.player.data["atd"]:addToMulList(self.damageReduceRate)
    --内伤减伤
    self.player.data["res"]:addToMulList(self.damageReduceRate)
end

function M:removeProperty()
    --Logger.logError(" 移除外伤减伤 ~~~~~~~~~~ "..tostring(self.damageReduceRate) )
    --外伤减伤
    self.player.data["atd"]:removeFromMulList(self.damageReduceRate)
    --内伤减伤
    self.player.data["res"]:removeFromMulList(self.damageReduceRate)
end


function M:update( time )
    if self.curTime > 0 then
        self.curTime = self.curTime - time;
        if self.curTime <= 0 then
            self:removeProperty();
        end
    end
end

--被攻击时
function M:BeHit( attackData )
    if self.curTime > 0 then
        if self.angerCondition ~= nil then
            local random = WRandom:randomNum(0, 100, true)
            --Logger.logError(" 随机 ~~~~~~~~~~ "..tostring(random).." self.angerCondition "..tostring(self.angerCondition) )
            if random < self.angerCondition then
                if self.angerValue ~= nil then
                    --Logger.logError(" 加入怒气 ~~~~~~~~~~ "..tostring(self.angerValue) )
                    self.player.data:addAnger(self.angerValue)
                end
            end
        end
    end
end

return M