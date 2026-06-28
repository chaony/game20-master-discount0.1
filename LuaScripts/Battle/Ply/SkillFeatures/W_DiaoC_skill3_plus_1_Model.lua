--极·流云遮月   放逐攻击力最高的敌人，使其无法攻击也无法受到伤害，放逐期间貂蝉会获得所放逐敌人40%的攻击力和生命值，持续5秒。仅剩余1名敌人时，貂蝉仍然能获得属性的提升，但不再放逐敌人，而是降低敌人50%的攻击力，使其受到伤害提高50%
--等级2：持续8秒
--等级3：获得属性提升效果至60%
--等级4：1名敌人时，降低攻击和受到伤害效果提升至70%
---@class W_DiaoC_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiaoC_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className)
    self.disappearBuff = self:getParam(1) --放逐buff
    self.atkBuff = self:getParam(2)--获得敌人攻击力和生命buff
    self.defBuff = self:getParam(3)--降低敌人攻击和伤害buff
end

function M:skillStart(data)
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "enemy",
        ignoreSummon = true,
        pos = "forceMax",
        --priority = true,
    })
    if enemies.Count > 0 then
        local target = enemies:get(0)
        if target and target.bufMgr then
            self.player.bufMgr:addBufById(self.atkBuff,target,self.skill)
            if enemies.Count == 1 then
                target.bufMgr:addBufById(self.defBuff,self.player,self.skill)
            else
                target.bufMgr:addBufById(self.disappearBuff,self.player,self.skill)
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M