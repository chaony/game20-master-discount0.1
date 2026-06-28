--移魂式：
--“灵傀魅影”存在时会替代古墓承受一次致命伤害，同时古墓恢复40%的生命值，此效果每场战斗只生效一次。

---@class W_GuM_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_GuM_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.addBuff1 = self:getParam(1, 0)   --buff[] 

    self.deadTriggerCnt = 0     -- 濒死触发次数
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.deadTriggerCnt < 1 then
        if self.player:equal(eventData.victim) then
            if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                local summon = self:getLiveSummon()     -- 找一个存活的魅影
                if summon then
                    self.deadTriggerCnt = self.deadTriggerCnt + 1
                    
                    self.player.bufMgr:addBufById(self.addBuff1, self.player)
    
                    -- 魅影承受此次伤害
                    local wantdata = {}
                    wantdata["damage"]  = eventData.wantdata.damage
                    wantdata["suck_value"] = GlobalTools.base0;
                    local data = {}
                    data["type"] = 3
                    data["hitEffectList"] = eventData.attackData.hitEffectList
                    summon:beHitDirect(eventData.killer, data, wantdata, false, false)

                    -- 古墓免受此次伤害
                    eventData.wantdata.damage = 0
                end
            end
        end
    end
end

function M:getLiveSummon()
    if self.player.summonList.Count > 0 then  -- 此时有召唤物在场
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            ---@type PlayerModel[]
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                if v:isLive() then
                    return v
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M;