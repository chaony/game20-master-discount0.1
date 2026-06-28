-- 灵鹫为自己和己方召唤单位附加寒冰气息，使其攻击速度提升60点持续5秒，
-- 持续期间每有一个己方召唤单位死亡，攻击速度还会额外提升10点，最多额外提升60点

---@class W_LingJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LingJ_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 持续期间每有一个己方召唤单位死亡，攻击速度还会额外提升10点
    self.exSpeedValue = self:getParam(1)
    -- 最多额外提升60点
    self.exMaxSpeedValue = self:getParam(2)
    -- 持续时间
    self.lastTime = self:getParam(3)
    -- 当前时间
    self.curTime = 0;
    -- 当前额外增加的速度
    self.curAddExSpeed = 0

    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end


function M:skillStart()
    M.super.skillStart(self)
    self.curTime = self.lastTime;
    self.curAddExSpeed = 0
end

-- 监听死亡回调
function M:deadHandler(eventName, data)
    local player = data["data"]
    if self.curTime > 0 and player.master ~= nil and player.camp == self.player.camp then
        local buffs = player.bufMgr:findBufByTag("W_LingJ_skill2")
        if #buffs > 0 then
            -- 持续期间 同阵营的 召唤物死亡
            if self.curAddExSpeed < self.exMaxSpeedValue then
                self.curAddExSpeed = self.curAddExSpeed + self.exSpeedValue
                self:addSpeedToPlayers(self.exSpeedValue)
            end
        end
    end
end

-- 给灵鹫和我方召唤物都加攻击速度
function M:addSpeedToPlayers( value, remove )
    --增加速度
    if remove == nil then
        self.player.data.haste:addToAddList(value)
    else
        self.player.data.haste:removeFromAddList(value)
    end
    --我方召唤物
    local friends = self.player.plyMgr:getPlayers(self.player.camp)
    for i = 1, friends.Count do
        local player = friends:get(i-1)
        if player.master == nil then
            for i = 1, player.summonList.list.Count do
                local key = player.summonList.list:get(i-1)
                local plys = player.summonList:get(key)
                for i, v in ipairs(plys) do
                    if remove == nil then
                        v.data.haste:addToAddList(value)
                    else
                        v.data.haste:removeFromAddList(value)
                    end
                end
            end
        end
    end
end


function M:update(dt,unsdt)
    -- 持续5秒
    if self.curTime > 0 then
        self.curTime = self.curTime - dt;
        if self.curTime <= 0 then
            self:timeOver();
        end
    end
end

-- 时间到
function M:timeOver()
    -- 把增加的速度删除掉
    self:addSpeedToPlayers(self.curAddExSpeed, true)
end



function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M