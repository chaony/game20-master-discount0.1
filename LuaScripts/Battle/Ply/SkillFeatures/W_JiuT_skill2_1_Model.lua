--[[
战斗开始时，若我方除九天以外，存在金木水火阴任意一个阵营的侠客，则九天受到的伤害会减少40%，受到的治疗效果会提升20%，之后每多一个阵营，减伤效果会额外提升5%，
受治疗效果额外提升5%，该效果会一直持续至战斗结束，若上阵有除九天以外的阳系侠客，则该阳系侠客会同时视为金木水火四个阵营
--]]
---@class W_JiuT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuT_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.firstDamageReduceRate = self:getParam(1) -- 首个阵营加成伤害减少比例
    self.firstHpRecoverRate = self:getParam(2) -- 首个阵营加成治疗比例
    self.damageReduceRate = self:getParam(3) -- 后续阵营加成伤害减少比例
    self.hpRecoverRate = self:getParam(4) -- 后续阵营加成治疗比例
    self.buffData = self:getParam(5) -- 治疗buff
    self.buffId6 = self:getParam(6)--自爆
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--出生
function M:spawnFinish()
    M.super.spawnFinish(self)

    --获取到友方英雄
    local raceTab = {1,2,3,4,6} -- 1金，2火，3木，4水，5阳，6阴, 7元
    local buffEfcTab = {"W_JiuT_Skill2_Buff_001", "W_JiuT_Skill2_Buff_004", 
                        "W_JiuT_Skill2_Buff_002", "W_JiuT_Skill2_Buff_003", "", 
                        "W_JiuT_Skill2_Buff_006",""} -- 特效buff
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    local heroTab = {} -- 激活了什么阵营特效
    local raceCount = 0 -- 阵营数量
    for i = friends.Count, 1, -1 do
        local player = friends:get(i-1)
        if player.master == nil and table.indexof(raceTab, player.plyData.race) and player:equal(self.player) == false then
            if not heroTab[player.plyData.race] then
                heroTab[player.plyData.race] = buffEfcTab[player.plyData.race]
                raceCount = raceCount+1
            end
        elseif player.master == nil and (player.plyData.race == 5 or player.plyData.race == 7) and player:equal(self.player) == false then
            for m = 1, 4 do
                if not heroTab[m] then
                    raceCount = raceCount + 1
                end
                heroTab[m] = buffEfcTab[m]
            end
        end
    end
    if raceCount == 1 then
        --外伤减伤
        self.player.data["atd"]:addToMulList(self.firstDamageReduceRate)
        --内伤减伤
        self.player.data["res"]:addToMulList(self.firstDamageReduceRate)
        --生命恢复效果
        self.player.data["hpRecover"]:addToMulList(self.firstHpRecoverRate)
    elseif raceCount > 1 then
        local damageReduceRate = self.firstDamageReduceRate + GlobalTools:Mul(self.damageReduceRate, GlobalTools:ToFix(raceCount-1))
        local hpRecoverRate = self.firstHpRecoverRate + GlobalTools:Mul(self.hpRecoverRate, GlobalTools:ToFix(raceCount-1))
        --外伤减伤
        self.player.data["atd"]:addToMulList(damageReduceRate)
        --内伤减伤
        self.player.data["res"]:addToMulList(damageReduceRate)
        --生命恢复效果
        self.player.data["hpRecover"]:addToMulList(hpRecoverRate)
    end
    -- 满级的治疗buff
    self.player.bufMgr:addBufById(self.buffData, self.player, self.skill)
    --self:creatBuffEfc(heroTab)
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JiuT_skill2_1_Model_CreateFootEffect,heroTab)
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_JiuT_skill2_1_Model_ShowEffect,true)
end

function M:creatBuffEfc(heroTab)
    for i, v in pairs(heroTab) do
        self.player.bufMgr:addBufById(v, self.player, self.skill)
    end
    
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player) then
        if player.killer_player ~= nil then
            if player.killer_player.isBoss == false then
                player.killer_player.bufMgr:addBufById(self.buffId6, self.player) --无法恢复能量
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M