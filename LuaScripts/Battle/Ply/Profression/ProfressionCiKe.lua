--- 刺客
--- 暴击时，提升10点闪避和5%爆伤增福，持续5秒，最多可叠加三层。
--- 暴击时，提升15点闪避和10%爆伤增福，持续5秒，最多可叠加三层。
--- 暴击时，提升15点闪避和10%爆伤增福，持续5秒，最多可叠加三层。击杀敌人，则立即恢复自身最大生命值10%且进入嗜血状态自身攻击+10%持续5秒
---@class ProfressionCiKe : Profression
---@field super Profression
local M = class("ProfressionCiKe", Profression)


function M:init(player,data)
    M.super.init(self,player,data)
    --提升XX点闪避
    self.shanbi = self:getParam(1);
    --XX%爆伤增福
    self.critDamage = self:getParam(2);
    --效果持续时间
    self.critEffectTime = self:getParam(3);
    --最大血量百分比
    self.maxHpPercent = self:getParam(4);
    --攻击持续时间
    self.addAttackTime = self:getParam(5);
    --增加攻击的数值
    self.addAttackValue = self:getParam(6);
    --最大层数
    self.maxCount = 3
    --最大杀人数量
    self.maxKillCount = 5;
    --攻击持续时间
    self.curAttackTime = 0;
    --效果
    self.curEffectTime = 0;
    
    -- 5秒内一共加的攻击百分比
    self.totalAddAttackValue = 0;

    self.curCount = 0;
    self.curKillCount = 0
    self.curEffectTime = 0;
    self.curAttackTime = 0;
    self.totalAddAttackValue = 0

    --Logger.logError(" 初始化刺客技能 ")
    --Logger.logError(" self.shanbi "..tostring(self.shanbi) )
    --Logger.logError(" self.critDamage "..tostring(self.critDamage))
    --Logger.logError(" self.critEffectTime "..tostring(self.critEffectTime))
    --Logger.logError(" self.maxHpPercent "..tostring(self.maxHpPercent))
    --Logger.logError(" self.addAttackTime "..tostring(self.addAttackTime))
    --Logger.logError(" self.addAttackValue "..tostring(self.addAttackValue))
end

--战斗开始
function M:gameStart()
    self.curCount = 0;
    self.curKillCount = 0
    self.curEffectTime = 0;
    self.curAttackTime = 0;
    self.totalAddAttackValue = 0
end

--增加属性
function M:addProperty()
    --闪避
    self.player.data.dodge:addToAddList(self.shanbi)
    --爆伤增福
    self.player.data.crit:addToAddList(self.critDamage)

    --Logger.logError(" 增加属性 ~~~~~~~~~~~~~~~~~~ ")
end

--增加属性
function M:removeProperty()
    --闪避
    self.player.data.dodge:removeFromAddList(self.shanbi)
    --爆伤增福
    self.player.data.crit:removeFromAddList(self.critDamage)

    --Logger.logError(" 移除属性 ~~~~~~~~~~~~~~~~~~ ")
end

--更新
function M:update( time )
    if self.curAttackTime > 0 then
        self.curAttackTime = self.curAttackTime - time;
        if self.curAttackTime <= 0 then
            --删除持续5秒的增加攻击力
            --Logger.logError(" 删除攻击力 ~~~~~~~~~~~~~~~~~~ "..tostring(self.addAttackValue) )
            for i = 1, self.totalAddAttackValue do
                self.player.data.atk:removeFromMulList(self.addAttackValue)
            end
            self.totalAddAttackValue = 0;
        end
    end

    if self.curEffectTime > 0 then
        self.curEffectTime = self.curEffectTime - time
        if self.curEffectTime <= 0 then
            if self.curCount > 0 then
                for i = 1, self.curCount do
                    self:removeProperty()
                end
                self.curCount = 0;
            end
        end
    end
end

function M:Attack( attackData )
    if self.curCount < self.maxCount then
        if attackData.isCrit then
            self.curEffectTime = self.critEffectTime
            self:addProperty();
            self.curCount = self.curCount + 1
        end
    end
    
    if self.maxHpPercent ~= nil then    -- 等级不够，没有效果
        if attackData.victim ~= nil then
            local noDead = attackData.victim.bufMgr:findBufByType("NoDeath")
            if #noDead == 0 then
                if self.curKillCount < self.maxKillCount then
                    if attackData.victim.data:get_curHp() - attackData.damage <= 0 then
                        --加最大生命的血量
                        local maxHp = self.player.data:get_hp();
                        local curHp = GlobalTools:Mul(maxHp, self.maxHpPercent)
                        self.player:cure("fix",self.player, curHp);
                        --伤害+10%
                        self.player.data.atk:addToMulList(self.addAttackValue)
                        self.totalAddAttackValue = self.totalAddAttackValue + 1
                        --当前攻击时间
                        self.curAttackTime = self.addAttackTime;
                        self.curKillCount = self.curKillCount + 1;
                    end
                end
            end
        end
    end
end


return M;