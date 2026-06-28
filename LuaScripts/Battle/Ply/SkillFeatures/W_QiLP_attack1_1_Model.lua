--灵派会骑上猎豹进入骑射状态
--当启灵派累计受到相当于其50%最大生命值的伤害时，会退出骑射状态

---@class W_QiLP_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiLP_attack1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.skill3 = nil
    self.skill1 = nil
    self.qiChengState = false -- 是否是骑乘状态
    EventDispatcher:registerEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.skill3 = nil
    self.skill1 = nil
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil and skill3.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill3 = skill3.cur_skill_config.feature
    end
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
        self.changeStateRate = self.skill1.changeStateRate
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
    -- 宠物配置
    local frame = self.player.evtMgr:getCommonEvent("Sendfor", 1)
    self.summonData = table.copy(frame.data)
end

--创建豹子
function M:createBaozi(data)
    if self.summon == nil then
        local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
        SendForFuncframe:init(self.summonData, self.player)
        self.summon = SendForFuncframe.player
        if self.summon ~= nil and self.skill3 then
            self.summon.data:set_level( self.player.data:get_level() )
            self.summon.data:set_evo( self.player.data:get_evo() )
            self.summon.plySkill:refreshSkill(nil)
            self.summon.data.hp:setInitialValue(self.summon.data:getCopyData(self.player.data.hp, true, self.skill3.attrRate))
            self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(self.player.data.atk, true, self.skill3.attrRate))
            self.summon.data.def:setInitialValue(self.summon.data:getCopyData(self.player.data.def, true, self.skill3.attrRate))
            self.summon.data:set_curHp(self.summon.data:get_hp())
            self.summon:setPos(self.player.position);
            self.summon.aiEngine:changeState("skill3_skill2")
            self.summon:ShowHpBar(false)
            self.summon.bufMgr:addBufById(self.skill3.mianYiBuff) -- 免疫所有能免疫的东西
        end
    end
end

function M:update(dt, unsdt)
    M.super.update(self,dt, unsdt)
    if self.summon ~= nil and self.player ~= nil and self.player:isLive() then
        self.summon:setPos(self.player.position);
        self.summon:setForward(self.player:getForward())
    end
end

-- 角色切换动作
---@param eventData Battle_HandleData_ChangeAiState
function M:ChangeAiStateHandler(eventName, eventData)
    if self.player:equal(eventData.player) then
        if self.summon ~= nil then
            local targetState = eventData.targetState
            if targetState.key== "skill" or targetState.key == "attack" then
                local currentSkill = self.player.aiEngine.skillConfig
                if currentSkill.anim_name == "skill2" and self.player.evtMgr then
                    self.player.evtMgr:triggerActionEventWorkByKey("skill2_skill2", "Hit", 2)
                end
                if currentSkill then
                    currentSkill.extra_anim_name = currentSkill.anim_name .. "_skill2"
                end
                if self.summon and self.summon.aiEngine then
                    local summonTargetState = self.summon.aiEngine:getStateByName("idle")
                    if summonTargetState then
                        if currentSkill.anim_name == "attack1" then
                            summonTargetState.extra_anim_name = "battle_idle_skill2"
                        else
                            summonTargetState.extra_anim_name = currentSkill.anim_name .. "_skill2"
                        end
                        self.summon.aiEngine:changeState("idle")
                    else
                        self.summon.aiEngine:changeState("idle")
                    end
                end
            else
                if targetState.anim_name then
                    targetState.extra_anim_name = targetState.anim_name .. "_skill2"
                end
                if self.summon.aiEngine then
                    self.summon.aiEngine:changeState("idle_skill2")
                end
            end
        end
    end
end

function M:changePlayerState(upDown, stateKey)
    if self.summon == nil and upDown == true then
        self:createBaozi()
    elseif self.summon ~= nil and upDown == false  then
        if self.player.summonList and self.player.summonList.Count > 0 then
            --删除宠物列表 
            for i = 1, self.player.summonList.list.Count do
                local key = self.player.summonList.list:get(i-1)
                local plys = self.player.summonList:get(key)
                for i, v in ipairs(plys) do
                    v:realDead()
                end
            end
            self.summon = nil
            self.player.summonList:clear();
        end
    end
    self.qiChengState = upDown
end

function M:getPlayerState()
    return self.qiChengState
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    M.super.destroy(self)
end

return M