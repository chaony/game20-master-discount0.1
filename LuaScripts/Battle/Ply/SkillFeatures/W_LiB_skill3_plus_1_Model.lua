--李白解放剑仙之力，召唤10把飞剑，攻击随机敌人，每把飞剑都会对敌人造成100%攻击力的伤害，飞剑可以攻击同一个敌人，
--当一个敌人被飞剑连续命中3次时，会额外受到一次150%攻击力的真实伤害并被眩晕2秒
--lv2 敌人每受到一次飞剑伤害，则下次受到的飞剑伤害就会增加10%，最多增加60%
--lv3 诗仙状态叠加至5层以上时，额外增加5把飞剑
--lv4 诗仙，酒气和剑气叠加至7层以上时，额外增加5把飞剑
---@class W_LiB_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill,className)
    self.hitNums = self:getParam(1)
    self.triggerNums = self:getParam(2)
    self.extraHurtBuff = self:getParam(3)
    self.addHurtPer = self:getParam(4)
    self.maxAddHurtNums = self:getParam(5)
    self.needShiBuffNums = self:getParam(6)
    self.addHitNums1 = self:getParam(7)
    self.needBuffNums2 = self:getParam(8)
    self.addHitNums2 = self:getParam(9)
    self.triggerPlayer = {}
    EventDispatcher:registerEvent("add_W_LiB_skill3_plus", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    --local ply = data["player"]
    --local config = data["skillConfig"]
    --if self.player:equal(ply) and config and config.anim_name == "skill3_plus" then
    --   
    --end
end


function M:skillDispatch(data)
    if data.eventName == "skill3_Hit" then
        self.triggerPlayer = {}
        local hitNums = self.hitNums
        if self.needShiBuffNums > 0 then
            local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill1")
            local buff_nums = #buff_list
            if buff_nums >= self.needShiBuffNums then
                hitNums = self.hitNums + self.addHitNums1
            end
        end
        if self.needBuffNums2 > 0 then
            local buff_list1 = self.player.bufMgr:findBufByTag("W_LiB_skill0")
            local buff_nums1 = #buff_list1
            local buff_list2 = self.player.bufMgr:findBufByTag("W_LiB_skill1")
            local buff_nums2 = #buff_list2
            local buff_list3 = self.player.bufMgr:findBufByTag("W_LiB_skill2")
            local buff_nums3 = #buff_list3
            if buff_nums1 >= self.needBuffNums2 and buff_nums2 >= self.needBuffNums2 and buff_nums3 >= self.needBuffNums2 then
                hitNums = self.hitNums + self.addHitNums2
            end
        end
        for i = 1, hitNums do
            BattleTool:safeTriggerActionEventWork(self.player, "skill3_plus", "Hit", 1)
        end
    elseif data.eventName == "skill3_end" then
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {
            camp = "enemy",
            ignoreSummon = true,
        })
        enemies:safeWalkInverted(function(enemy)
            if enemy and enemy.bufMgr then
                enemy.bufMgr:removeBufByTag("W_LiB_skill3_plus")
            end
        end)
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    local attackData = eventData.attackData
    if self.player:equal(killer) and BattleTool:isMySkillWithPlayer(self.player, eventData.attackData, "skill3_plus") then
        local buffs = victim.bufMgr:findBufByTag("W_LiB_skill3_plus")
        local buffNums = #buffs
        local addNums = GlobalTools:Min(buffNums, self.maxAddHurtNums)
        addNums = GlobalTools:ToFix(addNums)
        local addPer = GlobalTools:Mul(self.addHurtPer, addNums)
        eventData.wantdata.damage = GlobalTools:Mul(eventData.wantdata.damage, GlobalTools.base1 + addPer)
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) and buff.player and buff.player.bufMgr then
        local buffs = buff.player.bufMgr:findBufByTag("W_LiB_skill3_plus")
        local buff_nums = #buffs
       
        if buff_nums >= self.triggerNums and not self.triggerPlayer[buff.player:get_playerInstanceId()] then
            self.triggerPlayer[buff.player:get_playerInstanceId()] = true
            buff.player.bufMgr:addBufById(self.extraHurtBuff, self.player, self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("add_W_LiB_skill3_plus", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M