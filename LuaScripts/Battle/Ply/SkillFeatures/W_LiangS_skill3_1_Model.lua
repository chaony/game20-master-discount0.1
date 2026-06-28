--梁山挥舞双斧，一边旋转一边在敌人之间移动，期间每秒消耗100点内
--力并对周围的敌人造成150%攻击力的伤害。
--旋转期间梁山免疫控制效果，该状态会一直持续到梁山死亡或内力耗尽

--改 
--梁山挥舞双斧，【原地旋转，当眼前没有敌人后会向最近的敌人移动，移动的速度是正常移动速度的50%，
--旋转造成的伤害不增加怒气，且此时被击也不会增加怒气】，期间每秒消耗【167】点内力并对周围的敌
--人造成100%攻击力的外功伤害且受到的伤害减少50%。旋转期间梁山免疫控制效果，该状态会一直持续到
--梁山死亡或内力耗尽
--增加：释放期间，若命中被施加了流血效果的敌人，则该技能会获得15%的吸血效果
-- 每次命中敌人后重置流血buff

---@class W_LiangS_skill3_1_Model : SkillFeatures_Model
local M = class("W_LiangS_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.player.skill3ClearAnger = false
    self.angerCost = self:getParam(1)
    self.buffId = self:getParam(2) --免疫控制buf
    self.curePercent = self:getParam(3) --吸血百分比
    self.bleedBuff = self:getParam(4) --独属流血buff
    self.buffId2 = 0 --经脉的吸血buf 经脉未开默认为0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})

    self.addBuffLog = {}        -- 记录曾经对谁释放过bleedbuff
end

function M:spawn()
	 M.super.spawn(self)
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    self.addBuffLog = {}
    M.super.skillStart(self)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    -- 梁山技能3攻击了敌人
    if(self.player:equal(data.killer) and data.victim ~= nil and self.skill == data.attackData.skillConfig)then
        local victim = data.victim
        if self.addBuffLog[victim:get_playerInstanceId()] == nil then
            self.addBuffLog[victim:get_playerInstanceId()] = true
            victim.bufMgr:addBufById(self.bleedBuff, self.player, self.skill)
        else
            local bleedBuffs = victim.bufMgr:findBufByTag("liuxue")
            if #bleedBuffs > 0 then
                bleedBuffs[1].curRound = 0
            else
                victim.bufMgr:addBufById(self.bleedBuff, self.player, self.skill)
            end
        end
    end
end

function M:update(dt)
    M.super.update(self, dt)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill and self.player:isLive() == false then
        self.player.animator:changeState("skill3_end")
        self.player.bufMgr:removeBufById(self.buffId)
        self.player.bufMgr:removeBufById(self.buffId2)
        self.player.moveMgr:clear()
        return
    end
    if self.player.animator.curState ~= nil and self.player.animator.curState.name == "skill3_loop" then
        if self.player.data:get_curAnger() > 0 then
            local angerCost_value = GlobalTools:Mul(self.angerCost, dt);
            local anger = self.player.data:get_curAnger() - angerCost_value
            if anger <= 0 then
                anger = 0
                self.player.animator:changeState("skill3_end")
                self.player.bufMgr:removeBufById(self.buffId)
                self.player.bufMgr:removeBufById(self.buffId2)
                self.player.moveMgr:clear()
            end
            self.player.data:set_anger(anger)
        end
    end
end

--技能事件
function M:skillDispatch(data)
    if data.eventName == "startSkill3" then
        self:skillHandle(data)
    end
end

--技能事件
function M:skillHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        if self.player ~= nil and self.player.trait ~= nil then
            self.buffId2 = self.player.trait.buffId2
            self.player.bufMgr:addBufById(self.buffId2, self.player)
        end
    end
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    if self.player:equal(data.killer) and self.skill == data.attackData.skillConfig then  --攻击者是梁山
        if(data.victim.bufMgr:hasBufByTag("liuxue"))then
            -- 恢复最大生命值的血量
            local hp = GlobalTools:Mul(self.curePercent, self.player.data:get_hp())
            if hp > 0 then
                self.player:cure("fix", self.player, hp, self.skill)    -- 固定值血量
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M