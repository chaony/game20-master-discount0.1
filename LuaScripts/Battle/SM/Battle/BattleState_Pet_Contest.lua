---@class BattleState_Pet_Contest :BattleState  @战斗-宠物斗技-比气势
---@field super BattleState
local M = class("BattleState_Pet_Contest", Battle.BattleState)

function M:init(stateName, battleScene)
    self.super.init(self, stateName, battleScene)
end

function M:enter()
    self.maxTime = GlobalTools.base6    -- 宠物比气势时间
    self.curTime = 0

    Logger.log(self.curTime, "开始比气势-------")

    self.curScene:addEventListener_Local(Battle.EventType.VM_SceneModel_PetContestStart, function()  
        self:startBattle()
    end)
    self.curScene:addEventListener_Local(Battle.EventType.VM_SceneModel_PetContestResult, {self,self.VM_SceneModel_PetContestResult})
    self.curScene:dispatchEvent_Local(Battle.EventType.MV_SceneModel_PetContestStart,nil)
end

function M:startBattle()
    --local attacker = WRandom:randomNum(100,200)
    --self.curScene.plyMgr.attackerTeam:setPetContest(attacker)
    --
    --local defender = WRandom:randomNum(100,200)
    --self.curScene.plyMgr.defenderTeam:setPetContest(defender)

    local result = 0
    --if attacker > defender then
    --    -- 攻方胜利
    --    Logger.log(Json.encode({attacker, defender}), "宠物气势：攻方胜利")
    --    self:addWinBuff(1)
    --    result = 1
    --elseif attacker < defender then
    --    -- 守方胜利
    --    result = -1
    --    self:addWinBuff(-1)
    --    Logger.log(Json.encode({attacker, defender}), "宠物气势：攻方失败")
    --else
    --    -- 平局
    --    result = 0
    --    Logger.log(Json.encode({attacker, defender}), "宠物气势：平局")
    --end
    self.curScene:dispatchEvent_Local(Battle.EventType.MV_PetContestResult, {result = result, attacker = attacker, defender = defender})
end

---胜者加buff
function M:addWinBuff(camp)
    local add_buffs = {}
    local players = self.curScene.plyMgr:getPlayers(camp)
    players:safeWalkInverted(function(ply)
        for i, v in ipairs(add_buffs) do
            ply.bufMgr:addBufById(v, ply)            
        end
    end)
end

function M:update(dt)
    self.curTime = self.curTime + dt
    --Logger.log(self.curTime, "正在比气势-------")
    if self.curTime >= self.maxTime then
        -- 比气势阶段结束
        self.curScene.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.Battle)
    end
end

function M:VM_SceneModel_PetContestResult()
    
end


return M