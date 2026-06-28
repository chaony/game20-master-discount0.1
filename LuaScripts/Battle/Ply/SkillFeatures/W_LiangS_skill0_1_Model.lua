--梁山 每场战斗一次，当梁山受到致命伤害时，会免疫本次伤害并立即进入“浴血”状态，进入“浴血”状态时
--梁山会立即回满生命值。“浴血”状态持续期间，梁山会获得25点吸血等级，但每秒会损失最大生命值的10%
---@class W_LiangS_skill0_1 : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiangS_skill0_1", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxtime = self:getParam(1) -- 浴血状态持续时间
    self.buffId = self:getParam(2)  --回满血buf
    self.buffId2 = self:getParam(3)  --获得吸血等级buf
    self.hp = self:getParam(4)  --每秒损失生命值数据
    self.buffId3 = self:getParam(7)  --浴血状态特效
    self.hpRate = self:getParam(8)  --浴血状态停止血量
    self.time = GlobalTools.base1
    self.isFirst = true
    self.skill_Start = false
    self.dmg = GlobalTools.base0
    self.curTime = self.maxtime
end

function M:spawn()
    M.super.spawn(self)
    table.insert(self.player.avoidDeath, self)
end

function M:checkSkill(player)
    if self.player:isLive() and self.isFirst == true then
        self.player.data:set_curHp( GlobalTools.base1 )
        self.player.bufMgr:addBufById(self.buffId3, self.player) --回满血buf
        self.player.bufMgr:addBufById(self.buffId, self.player) --回满血buf
        self.player.bufMgr:addBufById(self.buffId2, self.player) --吸血等级buf
        local cure_hp_value = self.player.data:get_hp() - self.player.data:get_curHp()
        self.player.data:set_curHp(self.player.data:get_hp())
        self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelCure, {hp = cure_hp_value})
        local hp_value = GlobalTools:Mul( self.player.data:get_hp(), self.hp )
        self.dmg = hp_value
        self.curTime = self.maxtime
        self.isFirst = false
        self.skill_Start = true
        return true
    else
        return false
    end
end


function M:update(dt,unsdt)
    if self.skill_Start then --浴血状态开始
        if self.player:isLive() == false then
            self.skill_Start = false --结束
        else
            self.time = self.time - dt
            if self.time <= GlobalTools.base0 then --一秒后
                self:addAtkValue()
                self.player.data:set_curHp(self.player.data:get_curHp() - self.dmg)
                if self.player.data:get_hpRate() <= self.hpRate then
                    self.skill_Start = false --结束
                    self.player.bufMgr:removeBufById(self.buffId3) --回满血buf
                    self.player.bufMgr:removeBufById(self.buffId) --回满血buf
                    self.player.bufMgr:removeBufById(self.buffId2) --吸血等级buf
                end
                self.time = GlobalTools.base1
            end
        end
    end
end


function M:addAtkValue( ... )
    
end


return M