--
-- Created by IntelliJ IDEA.
-- User: kongliang
-- Date: 2020/1/17
-- Time: 3:33 下午
-- To change this template use File | Settings | File Templates.

package.path = "../../LuaScripts/?.lua;?.lua";
print(package.path)

GameVersionConfig = require("Battle.GameVersionConfig")
require("Battle.Init")
BattleDataManager = require("Battle.BattleDataManager")
BattleDataManager:init()
ConfigManager = require("Battle.DataCenter.ConfigManager")
ConfigManager:init()

ConfigManager:getCfgByName("hero_detail");
ConfigManager:getCfgByName("skill_detail");
ConfigManager:getCfgByName("heirloom");
ConfigManager:getCfgByName("deployment");
ConfigManager:getCfgByName("common");
ConfigManager:getCfgByName("artifact");
ConfigManager:getCfgByName("buff");
ConfigManager:getCfgByName("buff_effect");
ConfigManager:getCfgByName("world_boss");
--ConfigManager:getCfgByName("world_boss_cycle");
ConfigManager:getCfgByName("stage");
ConfigManager:getCfgByName("stage_battle");

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

function DoClientBattle(serverData, startIndex, endIndex)
    local battleData = serverData

    for i = startIndex, endIndex do
        SceneManager:preLoad();
        GameVersionConfig.OPEN_BATTLE_LOG = false
        battleData.battle.common.seed = i
        battleData.battle.common.seed_team = i % 11
        local result = SceneManager:serverStart(battleData)
        --save_battle_result(serverData, result, write_path)
        if result.result == 1 then
            return true
        end
    end
    return false
end

function Main(input_path, out_path, startIndex, endIndex)
    ---@type VerifyBattleData
    local verifyBattleData = nil
    local write_path = ""
    local serverStart = 0
    local testCnt = -1
    local test_file = input_path

    verifyBattleData = require("Battle.BattleData.VerifyBattleData"):new(test_file, 0, testCnt, serverStart)
    write_path = "client1"


    local checkOne = function()
        --local data = verifyBattleData:getRandomOne()
        local data, sdata = verifyBattleData:getNext()
        if data then
            local serverData = Json.decode(data)
            serverData.__out_put_path = write_path
            local result = DoClientBattle(serverData, startIndex, endIndex)
            if not result then
                local fileHandler = io.open("D:\\BattleData\\verify\\output\\" .. out_path, "a+")
                if fileHandler then
                    fileHandler:write(sdata .. "\n")
                    fileHandler:close()
                end
                Logger.log(serverData.index, "战斗失败")
            else
                Logger.log(serverData.index, "战斗成功")
            end
        end
        --Logger.log(Json.encode(result), "战斗结果----" ..tostring( verifyBattleData.index))
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
end


Main("battle_data.txt", "battle_data_2.txt", 1, 10);
Main("battle_data_2.txt", "battle_data_3.txt", 10, 50);
Main("battle_data_4.txt", "battle_data_5.txt", 50, 500);
