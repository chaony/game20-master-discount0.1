---@class W_TangM_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TangM_skill3_1_Model", SkillFeatures_Model)

M.enemyData = require("Battle.Ply.SkillFeaturesData.W_TangM_skill3_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.skillList = Battle.List.new()
    self.interval = GlobalTools.base0_1;
    self.curSkill = nil;
end

function M:skillDispatch(data)
    if data.eventName == "skill3_fire" then
        self:skill3_fire(data)
    end
end

function M:skill3_fire(data)
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player.camp)
    local victims = Battle.List.new()
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        victims:add(enemy)
        self.skillList:add({ timer = 0, enemy = enemy})
        local buff = enemy.bufMgr:findBufByTag("zhongdu")
        for i = 1, #buff do
            victims:add(enemy)
            self.skillList:add({ timer = 0, enemy = enemy})
        end
    end
end

function M:update(dt)
    if self.curSkill == nil and self.skillList.Count > 0 then
        self.curSkill = self.skillList:get(0)
    end
    if self.curSkill ~= nil then
        if self.curSkill.timer < self.interval then
            self.curSkill.timer = self.curSkill.timer + dt
            if self.curSkill.timer >= self.interval then
                self.curSkill.timer = 0
                self.enemy = self.curSkill.enemy
                self.player:set_forceSkillConfig(self.skill)
                self.player.evtMgr:commonEventWork( "Hit", self.skill.level )
                self.player:set_forceSkillConfig(nil);
                self.skillList:removeAt(0);
                if self.skillList.Count > 0 then
                    self.curSkill = self.skillList:get(0)
                else
                    self.curSkill = nil;
                end
            end
        end
    end
    --for i = self.skillList.Count, 1, -1 do
    --    local skill = self.skillList:get(i - 1)
    --    if skill.timer < self.interval then
    --        skill.timer = skill.timer + dt
    --    else
    --        skill.timer = 0
    --        local enemy = skill.enemys:get(0)
    --        if enemy ~= nil then
    --            skill.enemys:removeAt(0)
    --            self.enemy = enemy
    --            self.player.evtMgr:commonEventWork( 1 )
    --        end
    --        if skill.enemys.Count <= 0 then
    --            self.skillList:removeAt(i - 1)
    --        end
    --    end
    --end
end

--查找敌人
function M:findPlayer(data)
    if self.enemy ~= nil then
        data:clear()
        data:add(self.enemy)
        self.enemy = nil
    end
    return data
end

--
--M.atkRate = nil
--
--function M:init(ply, skill)
--    M.super.init(self, ply, skill)
--    self.atkRate = self:getParam(1)
--
--    self.frontDamage = self:getParam(4)
--    self.backDamage = self:getParam(5)
--    self.damageMaxCount = self:getParam(6)
--    self.interval = self:getParam(7)
--    
--    self.timer = 0
--    self.delayTime = 2.5
--    self.damageCount = 0
--end
--
----技能释放
--function M:skillStart()
--    self.timer = self.delayTime
--    self.damageCount = 0
--end
--
--function M:update(dt,unsdt)
--    if self.player:isLive() and self.timer > 0 then
--        self.timer = self.timer - dt
--        if self.timer <= 0 then
--            if self.damageCount < self.damageMaxCount then
--                self.timer = self.interval
--                self.damageCount = self.damageCount + 1
--                local enemys = SelectTargetTool:findPlayerByType(self.enemyData["count"], self.player)
--                for i = 1,enemys.Count do
--                    local player = enemys:get(i-1)
--                    if player ~= nil then
--                        local attackData = {}
--                        local marks = player.bufMgr:findBufByType("Mark")
--
--                        local count = 0
--                        for k,v in ipairs(marks) do
--                            if self.player:equal(v.source) then
--                                count = v.bufWork.count
--                                break
--                            end
--                        end
--                        attackData["damage"] = self.player.data.atk:getValue() * (1 + self.atkRate * count)
--                        attackData["player"] = self.player
--                        attackData["skillConfig"] = self.skill
--                        attackData["injureType"] = "skill"
--                        attackData["damageFront"] = self.frontDamage
--                        attackData["damageLast"] = self.backDamage
--                        attackData["angerAir"] = self.backDamage
--                        attackData["prefabName"] = "W_TangM_Attack_Hit_001"
--                        attackData["type"] = 0
--                        attackData["injureBuf"] = 0
--                        attackData["damageType"] = self.skill.atk_type
--
--                        player:injure(attackData)
--                    end
--                end
--            end
--            
--        end
--    end
--end
--
----技能结束
--function M:skillEnd()
--    if self.damageCount <= 0 then
--        self.timer = 0
--    end
--end


function M:destroy()
    M.super.destroy(self)
end

return M