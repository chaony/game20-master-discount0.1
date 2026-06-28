--天下会压制一名敌人6秒，压制期间，天下会会持续嘲讽附近敌人，压制期间，双方都无法攻击和移动。
--当压制双方的一方受到攻击时，另一方也会受到相同的攻击效果，该技能会优先选择突入我方阵营中的敌方侠客
---@class W_TianXH_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --时长 
    self.time = self:getParam(1)
    --敌方免疫buff
    self.enemyBuff = self:getParam(2)
    --己方免疫buff
    self.selfBuff = self:getParam(3)
    --治疗buff
    self.cureBuff = self:getParam(4)
    self.timer = 0
    self.enterSkill3 = false;
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:skillDispatch(data)
    if data.eventName == "skill3_addBuff" then
        self.timer = self.time
        local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
        self.target = nil
        local pos_x
        if self.player:get_camp() == 1 then
            pos_x = GlobalTools.base10000
        else
            pos_x = -GlobalTools.base10000
        end
        for i = enemys.Count, 1, -1 do
            local enemy = enemys:get(i - 1)
            local buffs = enemy.bufMgr:findBufByType("Immunity")
            local noControl = false
            for k, v in ipairs(buffs) do
                if v.bufWork:checkTag("control", self.player) == true then
                    noControl = true
                    break
                end
            end
            if enemy:isLive() == true and noControl == false then
                if self.player:get_camp() == 1 then
                    if enemy:get_position().x < pos_x then
                        self.target = enemy
                        pos_x = enemy:get_position().x
                    end
                else
                    if enemy:get_position().x > pos_x then
                        self.target = enemy
                        pos_x = enemy:get_position().x
                    end
                end
            end
        end
        if self.target ~= nil then
            if self.player.skyStar ~= nil then
                self.player.skyStar:triggerStart(self.target)
            end
            self.player.bufMgr:addBufById(self.selfBuff, self.player, self.skill)
            self.target.bufMgr:addBufById(self.enemyBuff, self.player, self.skill)
        else
            self:stopState()
        end
    end
end

function M:update(dt)
    M.super.update(self, dt)
    --if self.player.animator ~= nil and self.player.animator.curState ~= nil then
    --    if self.player.animator.curState.name == "skill3" or self.player.animator.curState.name == "skill3_loop" then
    --        self.enterSkill3 = true;
    --    else
    --        if self.enterSkill3 then
    --            if self.target ~= nil then
    --                self:stopState();
    --            end
    --        end
    --    end
    --end
    if self.player.animator ~= nil and self.player.animator.curState ~= nil and self.player.animator.curState.name == "skill3_loop" then
        self.timer = self.timer - dt
        if self.timer <= 0 or self.player:isLive() ~= true then
            self:stopState()
        end
    end
end

function M:stopState()
    if self.player.skyStar ~= nil then
        self.player.skyStar:triggerEnd(self.target)
    end
    self.enterSkill3 = false;
    self.player.animator:changeState("skill3_end")
    self.player.bufMgr:removeBufById(self.selfBuff)
    if self.target ~= nil then
        self.target.bufMgr:removeBufById(self.enemyBuff)
        self.target = nil
    end
end

function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    if self.target ~= nil and self.target:equal(victim) == true then
        self:stopState()
        if self.cureBuff ~= 0 and self.cureBuff ~= nil then
            self.player.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
        end
    end
end

function M:injureHandler(eventName, data)
    if self.target ~= nil then
        local killer = data["killer"]
        local victim = data["victim"]
        local attackType = data["attackData"]["type"]
        local damage = data["wantdata"]["damage"]
        if attackType ~= 3 then
            if self.player:equal(victim) == true then
                self:injure(self.target, self.player, data["attackData"])
            elseif self.target:equal(victim) == true then
                self:injure(self.player, self.target, data["attackData"])
            end
        end
    end
end

function M:injure(player, source, attackData)
    local attackData_new = table.shallow_copy(attackData)
    attackData_new.player = source
    attackData_new.type = 3
    attackData_new.angerAir = 0
    player:injure( attackData_new )
end

function M:destroy()
    if self.target ~= nil then
        self.target.bufMgr:removeBufById(self.enemyBuff)
        self.enterSkill3 = false;
        self.target = nil;
    end
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M