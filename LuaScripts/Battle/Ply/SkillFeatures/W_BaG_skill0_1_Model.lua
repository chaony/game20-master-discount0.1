--战斗中提高自身10%暴击率,每次暴击时会回复自身6%已损失生命

-- 改
-- 八卦在攻击被施加了破甲状态的敌人时，暴击概率提升30%，且每次攻击暴击时会回复自身6%已损失生命

---@class W_BaG_skill0_1_Model : SkillFeatures_Model
local M = class("W_BaG_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --暴击数值 提升自身暴击率
    self.critValue = self:getParam(1)
    --治愈率
    self.cureRate = self:getParam(3)

    self.beforeCnt = 0
    self.afterCnt = 0

    EventDispatcher:registerEvent("critCount", {self,self.critHandler})
end

function M:spawn()
    M.super.spawn(self)
end

--攻击者的攻击开始处理
---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if victim and self.player:equal(attackData.player) then
        if(victim.bufMgr:hasBufByTag("pojia")) then -- 攻击有破甲的人，必定暴击
            self.player.data.critrate_correct:addToAddListTemp(self.critValue)
        end
    end
end

--发生暴击
function M:critHandler( eventName, data )
    local ply = data["ply"]
    if self.player:equal(ply) then
        local cure_value = GlobalTools:Mul( (self.player.data:get_hp() - self.player.data:get_curHp()), self.cureRate)
        self.player:cure("fix", self.player, cure_value, self.skill )
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("critCount", {self,self.critHandler})
    M.super.destroy(self)
end

return M