-- 海殤君召喚狂風攻擊敵人，對範圍內的敵人造成300%攻擊力的傷害，並使其攻速降低30%，持續5秒
-- 復活後5秒內，該技能的冷卻時間減少50%
-- 當自身血量低於50%時，該技能造成傷害的30%會轉化為自身恢復效果
---@class W_HaiSJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiSJ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) -- 减冷却buff
    self.hpRate = self:getParam(2) -- 血量百分比
    self.cureHpRate = self:getParam(2) -- 回血百分比
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    if self.player:equal(data.killer) and (data.attackData and data.attackData.skillConfig == self.skill) then -- 攻击者是自己
        local damage = data.wantdata.damage
        if self.player.data:get_hpRate() <= self.hpRate then
            local cure_value = GlobalTools:Mul( damage, self.cureHpRate)
            self.player:cure("fix", self.player, cure_value, self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M