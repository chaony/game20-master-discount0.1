--等级3:护盾持续期间,若遭受单次伤害超过20%最大生命值,则该次伤害降低至原来的50%(真实伤害除外)
---@class W_HaiS_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiS_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --self.lostRate = self:getParam(1) -- 遭受单次伤害线比例
    --self.reduce_injure_percent = self:getParam(2) -- 承受伤害降低比例
    --EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

----攻击者攻击结束处理
-----@param data Battle_HandleData_Injure
--function M:injureHandler(eventName, data)
--    if data.attackData.skillConfig ~= nil then
--        local damage = data.wantdata.damage
--        local hp_max = self.player.data:get_hp() -- 获取血量上限
--        local rateFlag = GlobalTools:Div(damage, hp_max) >= self.lostRate
--        if rateFlag then
--            if(data.victim.bufMgr:hasBufByTag("W_HaiS_skill1"))then    -- 若遭受单次伤害超过20%最大生命值则敌人对自己造成的伤害减少
--                local reduce_value = GlobalTools:Mul(damage, self.reduce_injure_percent);
--                data.wantdata.damage = damage - reduce_value
--            end
--        end
--    end
--end

function M:destroy()
    --EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

   

return M