
package.path = "../../LuaScripts/?.lua;?.lua";
print(package.path)

GameVersionConfig = require("Battle.GameVersionConfig")
require("Battle.Init")
BattleDataManager = require("Battle.BattleDataManager")
BattleDataManager:init()
ConfigManager = require("Battle.DataCenter.ConfigManager")
ConfigManager:init()

require("Battle.BattleData.CSBattleCheck")

function LuaReload( moduleName )
    package.loaded[moduleName] = nil
    return require(moduleName)
end

function CustomRequire( moduleName )
    if GameVersionConfig.LUA_RELOAD_DEBUG then
        return LuaReload(moduleName)
    else
        return require(moduleName)
    end
end


---@type BattleCheckParams
local params = {}
params.input_file = "battle_data_1275070543_2022-01-07.txt"
params.input_path = "D:/BattleData/verify/output/"
params.output_path = "D:/BattleData/verify/output/"
params.start_index = 0
params.target_index = -1
params.output_tag = nil

local verifyBattleData = require("Battle.BattleData.VerifyBattleData"):new(params)

function DoServerBattle(serverData)
    local battleData = serverData
    SceneManager:preLoad();
    GameVersionConfig.OPEN_BATTLE_LOG = true
    local result = SceneManager:serverStart(battleData)
    --save_battle_result(serverData, result, write_path)
    return result
end

local checkOne = function()
    --local data = verifyBattleData:getRandomOne()
    local data = verifyBattleData:getNext()
    local data = Json.decode(data)
    --data = serverData.battle_data
    

    Logger.log(data.index, "check battle index ---- ")

    SceneManager:preLoad();
    for i = 1, 500 do
        data.battle.common.seed = i
        data.battle.common.seed_team = i % 11
        local result = SceneManager:serverStart(data)
        if result.result == 1 then
            Logger.log(data.index, "battle success === ")
            break
        end
    end
    
end

--GameVersionConfig.USE_LOCAL_BATTLE_DATA = false
local cnt = 0
while verifyBattleData:haveNext() do
    checkOne()
    --local ok ,e = pcall(checkOne)
    --if not ok then
    --    Logger.logError("战斗异常" .. tostring(verifyBattleData.index) .. tostring(e))
    --end
    cnt = cnt + 1
    --if cnt >= testCnt then
    --    break
    --end
end