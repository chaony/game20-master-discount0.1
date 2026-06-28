--沈嫣为我方全体侠客施加恢复效果，为其恢复200%攻击力的血量，
--若该侠客的血量已满，则溢出部分的治疗效果的60%会转化为护盾，持续5秒

---@class W_ShenY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenY_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.addBuff1 = self:getParam(1)    -- Buff[] 无敌buff
    self.interval = self:getParam(2)    -- Fix[] 治疗量转护盾
    self.addBuff2 = self:getParam(3)    -- Buff[] 魅惑buff

    self.dodge = false
    self.m_cd_flag = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    M.super.spawn(self)
    self.m_cd_flag = false
    self.dodge = false;
end

function M:skillStart()
    M.super.skillStart(self)
end

function M:beforeAttack(attackData, killer)
    if (not attackData.noAttack) and (not self.player:equal(killer)) and self.player.camp ~= killer.camp then -- 可触发
        self.dodge = true;
        if self.skill:canUse() and not self.m_cd_flag then
            self.m_cd_flag = true
            -- 免疫本次伤害
            attackData.noAttack = true
            self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
            killer.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
            -- 开始内部冷却
            TimeTools:delayTime(self.interval, function()
                self.m_cd_flag = false
            end)
        end
    end
end

function M:canUse()
    return self.dodge
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M