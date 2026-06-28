-- 羽人非獍發出道音刃，攻擊扇形範圍內的所有敵人，對其造成220%攻擊力的血量，若該技能暴擊，則本次造成傷害的30%會轉化為自身的恢復效果
---@class W_YuRFJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuRFJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1) -- 暴击回血百分比
    self.hurtUpRate = self:getParam(2) --暴击时伤害提升百分比
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    if self.player:equal(data.killer) and self.skill == data.attackData.skillConfig then  --攻击者是自己
        if data.attackData.isCrit then -- 发生暴击
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage, self.hurtUpRate)
            self.player:cure("fix", self.player, GlobalTools:Mul(data.wantdata.damage,self.hurtUpRate), self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M