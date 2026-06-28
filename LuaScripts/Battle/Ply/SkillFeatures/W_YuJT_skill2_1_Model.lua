--战斗中，御竞堂每过15秒会获得一个护盾，当护盾存在时，若御竞堂受到了控制效果，则会免疫该控制并无敌1秒
--lv4 现在受到任意伤害都会触发无敌效果
---@class W_YuJT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuJT_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shiled_buff_cd = self:getParam(1) -- 护盾cd
    self.buffId1 = self:getParam(2) -- 护盾buffId
    self.buffId2 = self:getParam(3) -- 免控无敌buffId
    self.addShiledbuffTimer = TimeTools:startOneLoopTask(self.shiled_buff_cd, handler(self, self.addShiledbuffTrigger), true)
    EventDispatcher:registerEvent("BufWorkImmunityTakeEffect", {self,self.BufWorkImmunityTakeEffectHandler})
end

function M:spawn()
    M.super.spawn(self)
    self:addShiledbuffTrigger()
end

-- 控制自己的人
function M:BufWorkImmunityTakeEffectHandler(eventName, data)
    local playerBuf = data.playerBuf
    local buffs = self.player.bufMgr:findBufByTag("W_YuJT_skill2") -- 护盾TAG
    if #buffs>0 then
        if self.player:equal(playerBuf.player) then
            self.player.bufMgr:removeBufById(self.buffId1, true)
            self.player.bufMgr:addBufById(self.buffId2, self.player)
        end
    end
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    if self.addShiledbuffTimer then
        self.addShiledbuffTimer:update_dt(dt)
    end
end

function M:addShiledbuffTrigger()
    self.player.bufMgr:addBufById(self.buffId1,self.player)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("BufWorkImmunityTakeEffect", {self,self.BufWorkImmunityTakeEffectHandler})
    self.addShiledbuffTimer = nil
    M.super.destroy(self)
end

return M