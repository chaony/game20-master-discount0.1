--骤雨狂风：
--蜀山被击败时，将释放5道剑羽攻击敌方侠客，被命中的侠客内力回复减少100%，持续3秒。

---@class W_ShuS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ShuS_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.shootNum = self:getParam(1, 0)   --int[0, 5] -- 释放n道剑羽
    self.addBuff2 = self:getParam(2, 0)   --Buff[] -- 无敌buff
end

---@param data W_ShuS_attack1_1_Model
function M:triggerStart(data)
    -- 死亡的时候移除debuff
    self.player.bufMgr:removeBufByTag("debuff", true)
    self.player.bufMgr:addBufById(self.addBuff2, self.player)
    self.player.data:set_curHp(1)
    data.skill.extra_anim_name = "attack1_die"
    self.player.aiEngine.skillConfig = data.skill
    self.player.aiEngine:changeState("attack")
end

function M:triggerEnd(data)
    local targets = self:getTarget("enemy", "all")
    for i = 1, self.shootNum do
        if targets.Count > 0 then   -- 
            local index = (i-1)%targets.Count
            local target = targets:get(index)
            self:shootOnce(target)
        end
    end
end

function M:shootOnce(target)
    if self.player.evtMgr ~= nil then       -- 如果死亡了就没有事件管理器了
        ---@type AnimEvtFrame_Model
        local frame = self.player.evtMgr:getCommonEvent("Shoot", 3)
        if frame ~= nil then
            local targets = Battle.List.new()
            targets:add(target)
            frame.isWork = true
            frame:shootBullet(frame.data, targets)
        else
            Logger.logError(" 没有找到 commonFrame Shoot 3")
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ShuS_Die_Shoot", {self,self.shootAfterDie })
    M.super.destroy(self)
end

return M;