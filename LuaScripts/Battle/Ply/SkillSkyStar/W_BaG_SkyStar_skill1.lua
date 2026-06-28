--白隙游龙：
--八卦每4秒可化解一次外功伤害，被化解的攻击将只造成原伤害的20%。

---@class W_BaG_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_BaG_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.intervalTime = self:getParam(1, GlobalTools.base1000)  --Fix[0-900]
    self.takeDmg = self:getParam(2, GlobalTools.base1)          --Fix[0-1]
    self.addBuff3 = self:getParam(3, 0)          --Buff[]   -- 化解伤害buff效果

    self.canTrigger = false     -- 是否可以化解伤害
    self.timer = TimeTools:startOneLoopTask(self.intervalTime, handler(self, self.onResetTrigger))
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

-- 激活化解伤害能力
function M:onResetTrigger()
    self.canTrigger = true
end

function M:update(dt)
    self.timer:update_dt(dt)
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.canTrigger then
        self.canTrigger = false
        eventData.wantdata.damage = GlobalTools:Mul(eventData.wantdata.damage, self.takeDmg)
        self.player.bufMgr:addBufById(self.addBuff3, self.player)
    end
end

function M:destroy()
    self.timer = nil
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end


return M;