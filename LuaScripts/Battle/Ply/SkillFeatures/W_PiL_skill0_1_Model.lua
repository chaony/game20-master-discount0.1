--霹雳在受到致命伤害时，会冲到距离自己最近的一名敌人面前并自爆，对爆炸范围内的敌人造成600%攻击力的伤害

---@class W_PiL_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_PiL_skill0_1_Model", SkillFeatures_Model)

M.plyTable = require("Battle.Ply.SkillFeaturesData.W_PiL_skill0_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isFirst = true
    self.buff1 = {}
    self.buffId1 = self:getParam(1)--不被锁定
    self.buffId2 = self:getParam(2)--无敌
    self.buffId4 = self:getParam(3)--免疫控制buf
    self.buffId3 = self:getParam(4)--免死buf
    self.buffId5 = self:getParam(5)--免疫伤害控制buf
    self.buffId7 = self:getParam(6)--loop 特效
    self.buffId8 = self:getParam(7)--清所有buf
    self.start = false
    self.forward = false
    self.isDead = false;
end


function M:skillDispatch(data)
    if data.eventName == "w_piL_dead" then
        self:deadHandle(data)
    end
end



function M:deadHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        self.player.data:set_curHp(0)
        for k,v in ipairs(self.buff1) do 
            if v ~= nil then
                self.player.bufMgr:removeBuf(v)
            end
        end
        self.player.bufMgr:removeBufById(self.buffId7)
        self.buff1 = {}
    end
end


--死亡
function M:dead(data)
   M.super.dead(self)
   if self.isFirst then
       self.data = data
       self.player.killer = self.data.killer
       self.isDead = true
       self.start = false
       self.forward = true
       self.player.data:set_curHp(1)
       self.player:set_curSkillConfig(self.skill)
       self.player.aiEngine:changeState("attack")

       local buff = self.player.bufMgr:addBufById(self.buffId1, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId2, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId3, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId4, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId5, self.player)
       table.insert(self.buff1, buff)
       buff = self.player.bufMgr:addBufById(self.buffId8, self.player)
       table.insert(self.buff1, buff)
       self.isFirst = false
       return false
   end
   return true
end


function M:canUse()
    return self.isDead
end


function M:update(dt,unsdt) 
    if self.forward then 
        local enemys = SelectTargetTool:findPlayerByType(self.plyTable["count"], self.player) 
        if enemys[0] ~= nil then
            local dir =  GlobalTools:Mul( enemys[0]:getForward(), -GlobalTools.base1); 
            self.player:setForward( dir,true ) 
            self.forward = false 
        end 
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M