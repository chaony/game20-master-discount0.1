--绝情被动
--在自身周围召唤结界，结界内的敌人受到的所有内力恢复效果会降低40% 敌人首次尝试出入结界的时候 会受到200%攻击力的伤害和2秒眩晕
---@class W_JueQ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field effectList ListMap
local M = class("W_JueQ_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dis = self:getParam(1) --范围
    self.buffId1 = self:getParam(2) --降低恢复
    self.buffId2 = self:getParam(3) --  --流血
    self.buffId3 = self:getParam(4) --  --眩晕
    self.time = self:getParam(7) --  --存在时间
    self.effectIndex = 1
    self.effectList = Battle.ListMap.new()
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end


function M:spawn()
    M.super.spawn(self)
end


function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    --击杀或者助攻
    if killer ~= nil and killer:equal(self.player) then
        local cur_time = 0.5
        local areaIn = {}
        local areaOut = {}
        local pos = FixVector3.New(0,0,0)
        pos.x = victim.position.x
        pos.y = victim.position.y
        pos.z = victim.position.z
        local enemy = SceneManager.curScene.plyMgr:getPlayers(-self.player.camp)
        for i = 1, enemy.Count do
            local ply = enemy:get(i-1)
            table.insert(areaOut,
                    {
                        isBuf = false,
                        ply = ply,
                        hasBuf = false,
                    })
        end

        local index = self.effectIndex

        self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JueQ_skill0_1_Model_CreateEffect, data)
        TimeTools:delayTime(GlobalTools.base1_3,
                function()
                    if self.effectList[index] ~= nil then
                        self.effectList[index].start = true
                    end
                end)
        
        local effectData = {
            time = cur_time ,
            start = true,
            areaOut = areaOut,
            areaIn = areaIn,
            pos = pos,
        }
        self.effectList:add(index, effectData)
        self.effectIndex = self.effectIndex + 1
    end
end

function M:update(dt,unsdt)
    -- if self.start then
    for i = 1, self.effectList.list.Count do
        local key = self.effectList.list:get(i-1)
        local effectData = self.effectList:get(key)
        if effectData and effectData.start then
            if effectData.time < self.time then
                effectData.time = effectData.time + dt
                if effectData.time >= self.time then
                    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JueQ_skill0_1_Model_DeleteEffect, {index = key})
                    effectData.start = false
                    self.effectList:remove(key)
                end
            end
            for k1,v1 in ipairs(effectData.areaOut) do
                if v1.ply ~= nil then
                    local distance = GlobalTools:Distance(effectData.pos,v1.ply.position)
                    if distance <= GlobalTools:ToFix2( self.dis ) then
                        self:addBuff(v1,effectData)
                    else
                        v1.hasBuf = false
                    end
                end
            end

            for k2,v2 in ipairs(effectData.areaIn) do
                if v2.ply ~= nil then
                    local distance = GlobalTools:Distance(effectData.pos,v2.ply.position)
                    if distance > GlobalTools:ToFix2( self.dis ) then
                        self:removeBuff(v2)
                    else
                        v2.hasBuf = false
                    end
                end
            end

        end
    end
end

function M:addBuff(value,data)
    local is_exist = false
    for k,v in ipairs(data.areaIn) do
        if v.ply == value.ply then
            is_exist = true
            break
        end
    end
    if is_exist == false then
        table.insert(data.areaIn,
                {
                    isBuf = false,
                    ply = value.ply,
                    hasBuf = false,
                })
    end
    if value.isBuf == false then
        value.isBuf = true
        value.ply.bufMgr:addBufById(self.buffId2, self.player) --2s眩晕
        value.ply.bufMgr:addBufById(self.buffId3, self.player) --200%伤害
    end
    if value.hasBuf == false then
        value.hasBuf = true
        value.ply.bufMgr:addBufById(self.buffId1, self.player) --降低恢复效果
        self:alterAdd_Value(value.ply)
    end
end

function M:removeBuff(value)
    if value.isBuf == false then
        value.isBuf = true
        value.ply.bufMgr:addBufById(self.buffId2, self.player) --2s眩晕
        value.ply.bufMgr:addBufById(self.buffId3, self.player) --200%伤害
    end
    if value.hasBuf == false then
        value.hasBuf = true
        value.ply.bufMgr:removeBufById(self.buffId1) --删除降低恢复效果
        self:alterRemove_Value(value.ply)
    end

end

function M:alterAdd_Value( ply )
    -- body
end

function M:alterRemove_Value(ply )
    -- body
end


function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
    
    --遍历特效
    for i = 1, self.effectList.list.Count do
        local key = self.effectList.list:get(i-1)
        local effectData = self.effectList:get(key)
        effectData.start = false
        effectData.time = 0
        self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JueQ_skill0_1_Model_DeleteEffect, {index = key})
    end
    self.effectList:clear();
end

return M