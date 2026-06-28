--战斗开始时，启灵派会骑上猎豹进入骑射状态，该状态下，启灵派的攻击力和血量会提升30%，且受到的单次伤害最多不超过最大生命值的30%，
--当启灵派累计受到相当于其50%最大生命值的伤害时，会退出骑射状态

---@class W_QiLP_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiLP_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffData = self:getParam(1) -- 骑射状态下增益buff
    self.onceHurtRate = self:getParam(2) -- 骑射状态下单次受伤最大百分比
    self.changeStateRate = self:getParam(3) -- 退出骑射受伤百分比
    self.buffData2 = self:getParam(4) -- 首次退出骑射状态增益buff
    self.skill3 = nil
    self.hurtHpNum = 0 -- 造成的伤害
    self.changeStateHpMax = 0 -- 当前改变状态最大血量
    self.firstDown = true -- 是否首次退出骑乘状态
    ---@type PlayerModel
    self.playerTarget = nil -- 造成伤害退出骑射状态的人
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.skill0 = nil
    self.attack1 = nil
    self.skill3 = nil
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end
    
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil and skill3.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill3 = skill3.cur_skill_config.feature
    end

    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil and attack1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.attack1 = attack1.cur_skill_config.feature
    end
    
    if self.player.summonList.Count > 0 then
        --删除宠物列表 
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                self.player.plyMgr:destoryPlayer(v)
            end
        end
        self.player.summonList:clear();
    end
end

--技能开始
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.player.summonList.Count == 0 and self.attack1 then
        self.attack1:changePlayerState(true)
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    ---@type PlayerModel
    local player = data["player"]
    if self.player:equal(player.master) == true then
        self.player.bufMgr:addBufById(self.buffData, self.player) -- 每次召唤后增益
        self.changeStateHpMax = GlobalTools:Mul(self.player.data:get_hp(), self.changeStateRate)  -- 当前改变状态最大血量
        self.hurtHpNum = 0
    end
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local victim = data["victim"]
    if self.player:equal(victim) and self.attack1 and self.attack1:getPlayerState() == true then -- 受伤害的是自己
        local hp_max = self.player.data:get_hp()
        local damage_max = GlobalTools:Mul(hp_max,self.onceHurtRate)
        data.wantdata.damage = data.wantdata.damage > damage_max and damage_max or data.wantdata.damage
        if self.changeStateHpMax ~= 0 then
            self.hurtHpNum = self.hurtHpNum + data.wantdata.damage
            if self.hurtHpNum >= self.changeStateHpMax then
                self.playerTarget = data["killer"]
                if self.skill0 then
                    self.skill0:addSkill0EffectBuff()
                end
                local cur_hp = self.player.data:get_curHp()
                self.player.bufMgr:removeBufById(self.buffData, true) -- 移除增益
                self.player.data:set_curHp(cur_hp) -- 保持之前血量不变
                self.changeStateHpMax = 0
                self.hurtHpNum = 0
                self.attack1:changePlayerState(false)
                if self.firstDown then
                    self.player.bufMgr:addBufById(self.buffData2, self.player) -- 首次退出骑射状态增益buff
                    self.firstDown = false
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

return M