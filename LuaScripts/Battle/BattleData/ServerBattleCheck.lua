--- 模拟测试服务器战斗，测试战斗bug
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

-- 战斗测试不使用本地战斗数据
GameVersionConfig.USE_LOCAL_BATTLE_DATA = false

require("Battle.BattleData.CheckConfig"):prepare()

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

local logInfo = function(msg)  
    print("Lua Check Log", msg)
end

local logError = function(msg)
    print("Lua Check Error", msg)
end

function write_table_data(name, data)
    name = tostring(name)
    local content = Json.encode(data)
    local log_path = GameVersionConfig.BATTLE_LOG_PATH ..tostring(name)
    local file = io.open(log_path, "w+b")
    local result, info;
    if file then
        result, info = file:write(content)
        io.close(file)
    end
    if result then
        logInfo( string.format("写文件文件:%s成功", log_path))
    else
        logError( string.format("写文件文件:%s失败(%s)\t"..tostring(debug.traceback()), log_path, tostring(info)))
    end
end

---@param data Battle_StartupData
function convert_startup_data_2_key(data)
    local onceData = data.battle.client_input[1]
    local data = Json.encode({
        ateam = onceData.attacker_team.team,
        dteam = onceData.defender_team.team,
        arelic = onceData.attacker_team.relic,
        drelic = onceData.defender_team.relic,
    })
    return Json.encode(data)
end

---@param data Battle_StartupData
function DoOnceFight(data, gid)
    assert(gid)
    local logData = {
        data = data,
        tongji = nil
    }
    local key = convert_startup_data_2_key(data)
    local function realFight()
        SceneManager:preLoad();
        SceneManager:clear()
        logData.tongji = SceneManager:serverStart(data)
    end

    local function __error__call__(msg)
        logError("BattleError:战斗发生错误 " .. msg)
        write_table_data("error_battle/error_" .. tostring(gid) .. ".txt", logData)
    end
    --realFight()
    xpcall(realFight, __error__call__)
    collectgarbage("collect")

    local result = logData.tongji ~= nil
    if not result then  -- 战斗未完成
        logError("BattleError:战斗发生错误 " .. key)
        write_table_data("error_battle/error_" .. tostring(gid) .. ".txt", logData)
    else
        --if logData.tongji.rounds[1].battle_cost_time >= 90 then
        --    logError("BattleError:超出战斗时间，没有结束战斗 " .. key)
        --    write_table_data("error_battle/overtime_" .. tostring(gid) .. ".txt", logData)
        --else
        --    logInfo("BattleLog:战斗成功 " .. key)
        --end
    end


    --write_table_data("data/data_" .. tostring(gid) .. ".txt", logData)

    
    local log_path = GameVersionConfig.BATTLE_LOG_PATH.."__battle_log.log"
    local file = io.open(log_path, "a")
    if file then
        file:write(string.format("%d:%s:%s\n", gid, key, tostring(result)))
        file:close()
    end
    return result
end

function CompleteStartupDataWithTeam(attacker, defender)
    assert(attacker)
    assert(defender)
    local BattleDataTemplate = require("Battle.BattleData.BattleDataTemplate");
    ---@type Battle_StartupData_Generate_Param
    local param = table.copy(BattleDataTemplate.default_param)
    param.attacker_team = attacker
    param.defender_team = defender
    return BattleDataTemplate:GenerateStartupData(param)
end

function DoTestHeroes(hero_ids, gid)
    local generateTeam = function(ids, isAttacker)
        local cnt = 5
        if isAttacker then
            cnt = math.min(5, math.ceil(#ids / 2))  -- 不是最后一个组，不能超过超过一半，需要给防守方留下一定人数
        else
            cnt = math.min(5, #ids)
        end
        ---@type Battle_StartupData_Generate_Hero_Param
        local team = {}
        for i = 1, cnt do
            local cid = ids[1]
            table.remove(ids, 1)
            local heroData = generateHero(cid, 300)
            table.insert(team, heroData)
        end
        return team
    end
    local team1 = generateTeam(hero_ids, true)
    local team2 = generateTeam(hero_ids, false)
    local startupData = CompleteStartupDataWithTeam(team1, team2)
    DoOnceFight(startupData, gid)
end

function random_mystics()
    local testInfo = require("Battle.BattleData.TestHeroIdList")
    local mystic_ids = testInfo.mystic_ids
    
    local mystics = {}
    for i = 1, 5 do
        local index = math.random(1, math.floor(#mystic_ids * 1.4))
        local id = mystic_ids[index]
        if id then
            mystics[tostring(i)] = {id = id}            
        end
    end
    return mystics
end

local testInfo = require("Battle.BattleData.TestHeroIdList")

--- 快速排查配置，技能脚本问题
function Test1V1Fast()
    local hero_ids = table.copy(testInfo.hero_ids)
    local index = 1
    while #hero_ids >= index do
        local cid = hero_ids[index]
        logInfo("===================================================================================================")
        logInfo(string.format("开始测试第%s次：[%s] 剩余%s个角色", tostring(index), tostring(cid), tostring(#hero_ids - index)))
        logInfo("===================================================================================================")

        local team = {{ cid = cid, lv = 300}}
        local startupData = CompleteStartupDataWithTeam(team, team)
        DoOnceFight(startupData, index)
        index = index + 1
    end
    logInfo("Test1V1Fast ================ complete")
end

--- 快速排查组合问题
function Test5V5Fast()
    local testIds = table.copy(testInfo.hero_ids)
    local battle_gid = 0
    while #testIds >= 1 do
        battle_gid = battle_gid + 1
        logInfo("===================================================================================================")
        logInfo(string.format("开始测试第%s次： 剩余%s个角色", tostring(battle_gid), tostring(#testIds)))
        logInfo("===================================================================================================")
        Logger.log(string.format("开始测试第%s场战斗", battle_gid))
        if #testIds < 10 then
            for i = #testIds + 1, 10 do
                testIds[i] = testIds[1]
            end
        end
        DoTestHeroes(testIds, battle_gid)
    end
end

---@class CheckFightParams
---@field attacker table
---@field defender table
---@field attacker_relic number[]
---@field defender_relic number[]

---@param params CheckFightParams
function CompleteBattleDataWithParams(params)
    assert(params.attacker)
    assert(params.defender)
    local BattleDataTemplate = require("Battle.BattleData.BattleDataTemplate");
    ---@type Battle_StartupData_Generate_Param
    local param = table.copy(BattleDataTemplate.default_param)

    param.attacker_team = params.attacker
    param.defender_team = params.defender

    param.attacker_relic = params.attacker_relic
    param.defender_relic = params.defender_relic
    return BattleDataTemplate:GenerateStartupData(param)
end




local convert_params_key = function(params)
    local attacker = params.attacker
    local defender = params.defender

    local keys1 = {}
    for i = 1, 5 do
        table.insert(keys1, attacker[i] and attacker[i].cid or "nil")
    end
    for i, v in ipairs(params.attacker_relic) do
        table.insert(keys1, v)
    end
    local key1 = "a:" .. table.concat(keys1, "_")

    local keys2 = {}
    for i = 1, 5 do
        table.insert(keys2, defender[i] and defender[i].cid or "nil")
    end
    for i, v in ipairs(params.defender_relic) do
        table.insert(keys2, v)
    end
    local key2 = "d:" .. table.concat(keys2, "_")
    return key1 .. ">vs<" .. key2
end

function generateHero(cid, level)
    ---@type Battle_StartupData_Battle_ClientInput_Team_Hero
    local heroData = { cid = cid, lv = level}
    heroData.fate_level = math.random(0,3)
    heroData.mystics = random_mystics()
    return heroData
end

--- 排查所有可能问题
function Test5V5Complete()
    local startTest = 0
    local testIds = table.copy(testInfo.hero_ids)
    local battle_gid = startTest
    local battle_logs = {}
    while true do
        if(battle_gid % 100 == 0)then
            collectgarbage("collect")
            collectgarbage("collect")
            collectgarbage("collect")
        end
        Logger.log(string.format("开始测试第%s场战斗", battle_gid))
        battle_gid = battle_gid + 1
        if(battle_gid > 30000000)then
            logInfo("一百万次-------")
            break
        end
        math.randomseed(battle_gid)
        for i = 1, 14 do
            math.random()
        end
        local curLv = math.random(1, 500)
        local minLv = math.max(1, curLv - 100)
        local maxLv = math.max(1, curLv + 100)
        local team1 = {}
        for i = 1, 5 do
            local index = math.random(1,#testIds)
            if math.random(1,#testIds) % 7 < 5 then
                team1[i] = generateHero(testIds[index], math.random(minLv, maxLv))
            end
        end

        local team2 = {}
        for i = 1, 5 do
            local index = math.random(1,#testIds)
            if math.random(1,#testIds) % 7 < 5 then
                team2[i] = generateHero(testIds[index], math.random(minLv, maxLv))
            end
        end

        local heirloom_ids = testInfo.heirloom_ids
        local relic1 = {}
        local relic2 = {}
        for i = 1, 4 do
            local index = math.random(1, #heirloom_ids)
            if(index % 6 < 5)then
                table.insert(relic1, heirloom_ids[index])
            end
            local index = math.random(1, #heirloom_ids)
            if(index % 6 < 5)then
                table.insert(relic2, heirloom_ids[index])
            end
        end

        local params = {
            attacker = team1,
            defender = team2,
            gid = battle_gid,
            attacker_relic = relic1,
            defender_relic = relic2,
        }

        local battleData = CompleteBattleDataWithParams(params)
        DoOnceFight(battleData, battle_gid)
    end
end

--Test5V5Complete()


--local attacker = {{cid = 212, lv = 300}, {cid = 603, lv = 300, hp = 1024* 400 * 100},}
--local defender = {{cid = 311, lv = 300, hp = 1024*400}, {cid = 212, lv = 300}, {cid = 603, lv = 300, hp = 1024* 400 * 30},}
--DoTestWithAttackerAndDefenderTeam(attacker, defender, 0)

--Test1V1Fast()

function Main()
    Test5V5Complete()
    --Test1V1Fast()
    
end

Main()

return {
    TestInfo = testInfo,
    RelicList = relic,
    DoOnceFight = DoOnceFight,
    DoTestWithAttackerAndDefenderTeam = CompleteStartupDataWithTeam,
    Do1V1TestHeroes = Do1V1TestHeroes,
    Test1V1Fast = Test1V1Fast,
    DoTestWithParams = CompleteBattleDataWithParams,
    Test5V5Fast = Test5V5Fast,
    Test5V5Complete = Test5V5Complete,
}