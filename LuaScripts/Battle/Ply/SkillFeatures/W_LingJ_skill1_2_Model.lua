-- 冰犬首次死亡时，灵鹫会获得30%的攻击提升，之后每额外死亡一只冰犬，
-- 攻击力还会额外提升5%，最多额外提升30%，攻击提升效果会一直持续到战斗结束

---@class W_LingJ_skill1_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local W_LingJ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_LingJ_skill1_1_Model")
local M = class("W_LingJ_skill1_2_Model", W_LingJ_skill1_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 冰犬首次死亡加buff
    self.fristDeadBuf = self:getParam(3)
    -- 额外死亡加buff
    self.exDeadBuf = self:getParam(4)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    -- 监听玩家死亡信息
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
    self.totalDeadDamage = 0;
    self.isFristDead = 0
end

--死亡回调
function M:deadHandler(eventName, data)
    local player = data["data"]
    if self:isMyLang(player) then
        self:langDead(player);
    end
end

-- 我的冰犬死亡时
function M:langDead(player)
    if self.isFristDead == 0 then
        --第一次死亡
        self.isFristDead = 1
        self.player.bufMgr:addBufById(self.fristDeadBuf, self.player)
    else
        --其他死亡
        self.player.bufMgr:addBufById(self.exDeadBuf, self.player)
    end
end

-- 是否是我冰犬
function M:isMyLang( ply )
    for i = 1, self.player.summonList.list.Count do
        local key = self.player.summonList.list:get(i-1)
        local plys = self.player.summonList:get(key)
        for k, v in ipairs(plys) do
            if ply:equal(v) then
                return true;
            end
        end
    end
    return false;
end

--销毁事件
function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M