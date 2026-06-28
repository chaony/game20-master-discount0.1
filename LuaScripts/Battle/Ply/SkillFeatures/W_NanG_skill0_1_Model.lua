--南宫被动
--当南宫受到致命伤害时，会冲到击杀自己的地方角色面前，击飞沿途的橘色并对其造成300%攻击力的伤害，对击杀自己的橘色造成500%的攻击力伤害
---@class W_NanG_skill0_1_Model : SkillFeatures_Model
---@field super SkillFeatures_Model : SkillFeatures_Model
local M = class("W_NanG_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isFirst = true
    self.buff1 = {}
    self.buffId1 = self:getParam(1)--不被锁定
    self.buffId2 = self:getParam(2)--无敌
    self.buffId3 = self:getParam(3)--免死buf
    self.buffId4 = self:getParam(4)--免疫控制buf
    self.buffId5 = self:getParam(5)--免疫伤害控制buf
    self.buffId7 = self:getParam(7)--loop 特效
    self.buffId8 = self:getParam(8)--清所有buf
    self.dmg = self:getParam(9)--对击杀者的伤害
    self.start = false
    self.forward = false
    self.isDead = false;
end

--死亡
function M:dead(data)
   M.super.dead(self)
   if self.isFirst then
       self.data = data
       self.player.killer_player = self.data.killer
       self.isDead = true
       self.start = false
       self.forward = true
       self.player.data:set_curHp(GlobalTools.base1)
       self.player:set_curSkillConfig(self.skill)
       self.player.aiEngine:changeState("attack")

       local buff = self.player.bufMgr:addBufById(self.buffId1, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId8, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId2, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId3, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId4, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId5, self.player)
       table.insert(self.buff1, buff)
       self.isFirst = false
       return false
   end
   return true
end


function M:canUse()
    return self.isDead
end

function M:skillDispatch(data)
    if data.eventName == "skill0_dead" then
        self.player.bufMgr:removeBufById(self.buffId7)
        self.player.data:set_curHp( 0 )
        for k,v in ipairs(self.buff1) do
            if v ~= nil then
                self.player.bufMgr:removeBuf(v)
            end
        end
        self.buff1 = {}

        self.player:hideBody(false)
        ------此时角色已经死亡,户需要再次进入die
        --self.player.doNotEnterDie = false
        --self.player.delayDestoryTask = TimeTools:delayTime(GlobalTools.base0_5,function()
        --    self.player:destroy()
        --end)
    end
end


function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill0" then
        if victim ~= nil and victim:equal(self.player.killer) then
            attackData.damageFront = self.dmg
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M