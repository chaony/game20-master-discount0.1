--李白肆意挥洒胸中剑气，诗气，酒气，并将其化为漫天飞剑，对所有敌人造成9段伤害，每段80%攻击力
--lv2当酒、诗、剑三气都叠加至5层时，该技能伤害造成的伤害提升50%
--lv4 当酒、诗、剑三气都叠加至5层时，该技能伤害造成的伤害提升100%
---@class W_LiB_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.triggerNums = self:getParam(1)--叠加至5层时
    self.addHurtRate = self:getParam(2)--伤害提升
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill3"  then
            if self:isTriggerBuff() then
                local wantData = data["wantdata"]
                local damage_value = GlobalTools:Mul(wantData.damage, (GlobalTools.base1 + self.addHurtRate));
                data["wantdata"]["damage"] = damage_value
            end
        end
    end
end

function M:isTriggerBuff()
    local shiqi_nums = table.nums(self.player.bufMgr:findBufByTag("W_LiB_skill1"))
    if self.triggerNums > 0 and shiqi_nums > self.triggerNums then
        local jiuqi_nums = table.nums(self.player.bufMgr:findBufByTag("W_LiB_skill2"))
        if jiuqi_nums > self.triggerNums then
            local jianqi_nums = table.nums(self.player.bufMgr:findBufByTag("W_LiB_skill0"))
            if jianqi_nums > self.triggerNums then
                return true
            end
        end
    end
    return false
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M