--当天墉城的血量低于40%时，将有50%概率额外触发一次玄天炽焰
--每次释放玄天炽焰，该技能的伤害提升4%，最多可叠加10层，持续整场战斗
---@class W_TianYC_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianYC_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpRate = self:getParam(1) -- [额外触发生命百分比
    self.useSkillRate = self:getParam(2) -- 额外触发概率
    self.addSkillDamageRate = self:getParam(3) -- 每次释放此技能后伤害百分比增长比例]
    self.skillDamageRateNum = self:getParam(4) -- 最大层数
    self.buffNum = 0
end

-- skill1技能结束后判断是否再放一次skill1
function M:skillEnd()
    M.super.skillEnd(self)
    local rate = self.player.data:get_hpRate();
    if rate <= self.hpRate then
        if GlobalTools:CheckRandom1(self.useSkillRate) then
            if self.player.aiEngine.skillConfig and self.player.aiEngine.skillConfig.anim_name ~= "skill3" and self.skill then -- 排除放大招的情况
                self.player.aiEngine.skillConfig = self.skill -- 强制用一次skill0
                return "attack"
            end
        end
    end
    
    self.buffNum = math.min(self.buffNum + 1, self.skillDamageRateNum)
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill then
        local afterDamageAddValue = GlobalTools:Mul(self.addSkillDamageRate, GlobalTools:ToExistFixNum(self.buffNum))
        attackData["damageLast"] = attackData["damageLast"] + afterDamageAddValue
    end
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    
end


function M:destroy()
    M.super.destroy(self)
end

return M