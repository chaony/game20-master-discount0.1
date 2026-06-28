---@class BattleFSM @战斗状态机
---@field curState BattleState 当前状态
---@field states table<string, BattleState>
local M = class("BattleFSM")

M.BATTLE_STATES = {
    Idle = "Idle", -- 空闲
    Init = "Init", -- 初始化
    PetContest = "Pet_Contest", -- 宠物比气势
    Battle = "Battle",   -- 战斗
    BattleOver = "BattleOver", -- 战斗结束
}

function  M:init(scene)
    self.curScene = scene

    self.states = {}
    self:register(M.BATTLE_STATES.Idle, "BattleState_Idle")
    self:register(M.BATTLE_STATES.Init, "BattleState_Init")
    self:register(M.BATTLE_STATES.Battle, "BattleState_Battle")
    self:register(M.BATTLE_STATES.BattleOver, "BattleState_BattleOver")
    self:register(M.BATTLE_STATES.PetContest, "BattleState_Pet_Contest")
    
end

--注册状态
function M:register(key, stateName)
    ---@type BattleState
    local stateCla = require("Battle.SM.Battle."..stateName)
    local stateIns = stateCla:new()
    stateIns:init(stateName, self.curScene)
    self.states[key] = stateIns
end

function M:changeState(key, data)
    if self.states[key] == nil then
        Logger.log(key, "战斗状态不存在")
    else
       self:toState(key, data)
    end
end

--状态机真正切换
function M:toState(key, data)
    local targetState = self.states[key]
    if self.curState ~= nil then
        self.curState:exit()
    end
    self.curState = targetState
    self:changeStateFinish(key, data)
    self.curState:enter(data)
end

--状态机切换状态完成
function M:changeStateFinish(key, data)

end

function M:update(dt)
    if self.curState then
        self.curState:update(dt)
    end
end

--销毁
function M:destroy()
    if self.curState then
        self.curState:destroy()
        self.curState = nil
    end
end

return M