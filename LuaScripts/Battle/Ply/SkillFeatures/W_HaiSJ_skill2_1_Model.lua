-- 戰鬥開始時，海殤君會召喚水流對自己位置相對的敵人造成260%攻擊力的傷害，並使其攻擊力降低20%，該效果會一直持續到戰鬥結束
-- 敵人降低的攻擊力會轉化為自身攻擊力，但加成效果會在敵人死亡時消失（霹雳效果：队伍中的其他霹雳角色也会受到该技能效果的一半）
---@class W_HaiSJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiSJ_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) -- 加攻击buff
    self.buffId2 = self:getParam(2)--隊友加攻擊buff
    self.removeFlag = self:getParam(3) -- 是否死亡移除 1 移除， 0 不移除
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
end

function M:skillStart(data)
    M.super.skillStart(self,data)
    self.player.bufMgr:addBufById(self.buffId, self.player)
    self:checkSeriesHero()
end

--- 我方系列英雄
function M:checkSeriesHero()
    local heroes = self.player.plyMgr:getPlayers(self.player.camp)
    for i = heroes.Count, 1, -1 do
        local hero = heroes:get(i-1)
        if hero.plyData.id ~= self.player.plyData.id and
                table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(hero.plyData.id))  then
            hero.bufMgr:addBufById(self.buffId2, self.player)
        end
    end
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and self.removeFlag == 1 then
        local buffs = player.bufMgr:findBufByTag("W_HaiSJ_skill2")
        if #buffs > 0 then
            self.player.bufMgr:removeBufById(self.buffId, true)
            local heroes = self.player.plyMgr:getPlayers(self.player.camp)
            for i = heroes.Count, 1, -1 do
                local hero = heroes:get(i-1)
                if hero.plyData.id ~= self.player.plyData.id and
                        table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(hero.plyData.id))  then
                    hero.bufMgr:removeBufById(self.buffId2, true)
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead",{self,self.deadHandler} )
    M.super.destroy(self)
end

return M