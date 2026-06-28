--战斗中，武则天每次为敌人施加“慑服”状态时，还会额外施加一层“霜羽”状态，处于“霜羽”状态的敌人，攻击力和攻击速度会降低8%，持续5秒，最多叠加5层，
--当我方侠客死亡时，会立即为击杀者施加5层“霜羽”状态，若场上同时存在狄仁杰，则狄仁杰每次施加“断狱”效果时，都有30%的几率额外施加一层“霜羽”效果
--lv 3 当敌人身上的“霜羽”状态叠加至5层时，会立即被冰冻2秒，该效果有10秒的冷却时间
---@class W_WuZT_skill2_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_skill2_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.shuangYubuffId = self:getParam(1)       --霜羽buffid，
    self.addBuffNums = self:getParam(2)       --给击杀者叠加的霜羽层数
    self.triggerRate = self:getParam(3)      --额外几率
    self.triggerNums = self:getParam(4)      --触发冰冻的层数，
    self.bingDongBuff = self:getParam(5)      --冰冻buff
    EventDispatcher:registerEvent("add_W_WuZT_skill1", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler2})
    EventDispatcher:registerEvent("add_W_WuZT_skill2_plus", {self,self.addBuffHandler3})
end
function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local target = buff.player
        if target and target.bufMgr then
            target.bufMgr:addBufById(self.shuangYubuffId, self.player, self.skill)
        end
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    local victim = data.victim
    local killer = data.killer
    if victim and self.player.camp == victim.camp and killer and killer.bufMgr then
        for i = 1, self.addBuffNums do
            killer.bufMgr:addBufById(self.shuangYubuffId, self.player, self.skill)
        end
    end
end

function M:addBuffHandler2(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.source and buff.source.camp == self.player.camp then
        if GlobalTools:CheckRandom1(self.triggerRate) then
            local target = buff.player
            if target and target.bufMgr then
                target.bufMgr:addBufById(self.shuangYubuffId, self.player, self.skill)
            end
        end
    end
end

function M:addBuffHandler3(eventName, data)
    local buff = data["buff"]
    local target = buff.player
    if buff ~= nil and target and target ~= self.player.camp then
        local buffs = target.bufMgr:findBufByTag("W_WuZT_skill2_plus")
        local buffNums = #buffs
        if target.bufMgr and buffNums >= self.triggerNums then
            target.bufMgr:addBufById(self.bingDongBuff, self.player, self.skill)
            target.bufMgr:removeBufByTag("W_WuZT_skill2_plus")
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_WuZT_skill1", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler2})
    EventDispatcher:unRegisterEvent("add_W_WuZT_skill2_plus", {self,self.addBuffHandler3})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end


return M
