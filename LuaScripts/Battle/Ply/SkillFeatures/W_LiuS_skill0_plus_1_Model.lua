--等级1：六扇的普攻对被标记的敌人，造成伤害提升50%，并且有10%的概率眩晕敌人1秒
--等级2：六扇每次普攻被标记的敌人时，会额外恢复10点内力
--等级3：六扇每次普攻都会提高自身12点攻速，最多叠加5层，持续至战斗结束
--等级4：每次受到六扇普攻的敌人，会被附加“高级破甲”效果，每层降低5%的防御力，最多叠加20层 ，持续至战斗结束。
---@class W_LiuS_skill0_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiuS_skill0_plus_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.physicaldamage = self:getParam(1)
    self.enemyBuf = self:getParam(2)
    self.enemyBufRate = self:getParam(3)
    self.selfBuf = self:getParam(4)
    self.selfBuf2 = self:getParam(5)
    self.enemyBuf2 = self:getParam(6)
end


function M:spawn()
    M.super.spawn(self)
end



--攻击者的攻击开始处理
function M:killerDataChangeTemp(victim, skill)
    if skill == nil or skill.type ~= 2 then
        return
    end
    if victim ~= nil then
        local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
        if #buffs > 0 then
            if self.enemyBuf > 0 and self.enemyBufRate < WRandom:randomNum(0, 100) then
                victim.bufMgr:addBufById(self.enemyBuf, self.player,self.skill)
            end
            if self.selfBuf > 0 then
                self.player.bufMgr:addBufById(self.selfBuf, self.player,self.skill)
            end
            self.player.data.physicaldamage:addToMulListTemp( self.physicaldamage )
            self.player.data.magicdamage:addToMulListTemp( self.physicaldamage )
        end
        if self.enemyBuf2 > 0 then
            victim.bufMgr:addBufById(self.enemyBuf2, self.player,self.skill)
        end
        if self.selfBuf2 > 0 then
            self.player.bufMgr:addBufById(self.selfBuf2, self.player,self.skill)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M