--等级2:”逍遥游“状态持续期间，逍遥每次攻击和受到攻击，都获得1%的攻击力和防御力提升，该效果最多提升30%的攻击和防御，且会在“逍遥游”状态结束时消失
local W_XiaoY_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_XiaoY_skill0_1_Model")
---@class W_XiaoY_skill0_2_Model : W_XiaoY_skill0_1_Model @
---@field super W_XiaoY_skill0_1_Model @W_XiaoY_skill0_1_Model
local M = class("W_XiaoY_skill0_2_Model", W_XiaoY_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.atk = self:getParam(2)
    self.def = self:getParam(3)
    self.atkMax = self:getParam(4)
    self.defMax = self:getParam(5)
end

function M:spawn()
    M.super.spawn(self)
    self.curAtk = 0
    self.curDef = 0
end

function M:killerAfterAttack(data)
    if self.skill3 and self.skill3.state == 2 then
        local killer = data["killer"]
        local victim = data["victim"]
        if victim ~= nil and killer ~= nil and killer:equal(self.player) then
            victim.bufMgr:addBufById(self.buffId, self.player, self.skill)
            self:addAttr()
        end
    end
end

function M:afterAttack(data)
    if self.skill3 and self.skill3.state == 2 then
        self:addAttr()
    end
end

function M:addAttr()
    self.player.data.atk:removeFromMulList(self.curAtk)
    self.player.data.def:removeFromMulList(self.curDef)
    self.curAtk = self.curAtk + self.atk
    self.curDef = self.curDef + self.def
    if self.curAtk > self.atkMax then
        self.curAtk = self.atkMax
    end
    if self.curDef > self.defMax then
        self.curDef = self.defMax
    end
    self.player.data.atk:addToMulList(self.curAtk)
    self.player.data.def:addToMulList(self.curDef)
end

function M:setState(state)
    if state == 1 then
        self.player.data.atk:removeFromMulList(self.curAtk)
        self.player.data.def:removeFromMulList(self.curDef)
        self.curAtk = 0
        self.curDef = 0
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M