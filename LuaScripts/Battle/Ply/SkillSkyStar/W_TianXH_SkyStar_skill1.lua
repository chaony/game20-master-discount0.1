---
--- 天下会压制期间，被压制目标每秒受到最大生命值2.5%的伤害，天下会每秒恢复2%最大生命值
---
local M = class("W_TianXH_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --伤害对方百分比
    self.dmgEnemy = self:getParam(1)
    --治疗自己百分比
    self.cureSelf = self:getParam(2)
end


function M:gameStart()
    self.perTime = GlobalTools.base1;
end

--触发开始
function M:triggerStart( data )
    self.target = data;
end

--触发结束
function M:triggerEnd( data )
    self.target = nil;
end


function M:update(time)
    if self.target ~= nil then
        if self.perTime > 0 then
            self.perTime = self.perTime- time
            if self.perTime <= 0 then
                --伤害对方
                local damage = GlobalTools:Mul(self.player.data:get_hp(), self.dmgEnemy)
                local attackData = BattleTool:getBaseAttackData()
                attackData["damage"] = damage
                attackData["player"] = self.player
                attackData["angerAir"] = GlobalTools.base1
                attackData["type"] = 3
                attackData["injureBuf"] = 0
                attackData["damageType"] = 1
                
                self.target:injure( attackData )
                
                --治疗自己
                self.player:cure("hp", self.player, self.cureSelf, nil)
                self.perTime = GlobalTools.base1
            end
        end
    end
end

return M;