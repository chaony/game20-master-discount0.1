---@class CSBattleCheck
local M = class("CSBattleCheck")

____________________________check_cnt = 1630

function M:DoOnceCheck(serverData)
    local url = NetUrl.getUrlForKey("battle_battle_debug")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    Logger.log(url, "url =======================================")
    local battleData = serverData
    battleData.check_battle = nil
    NetWork:httpRequest(function(data)
        if data then
            self:SaveVerifyData(serverData, data)
        end
        self:TryDoNextCheck()
    end, url, GlobalConfig.POST, { battle = battleData }, 
            "battle_battle_debug", 0, true, 0)
end

function M:DoCheck()
    --local battleData = require("Battle.BattleData.PreBattleData")
    --battleData = Json.decode(battleData)
    self.verifyBattleData = CustomRequire("Battle.BattleData.VerifyBattleData"):new("battle_data.txt", 0, ____________________________check_cnt)
    self:TryDoNextCheck()
end

local testCnt = 10
local cnt = 0
function M:TryDoNextCheck()
    --if cnt >= testCnt then
    --    return
    --end
    local data = self.verifyBattleData:getNext()
    if data then
        --Logger.log(data, "data ====== ")
        local serverData = Json.decode(data)
        --Logger.log("index ==== " .. tostring(serverData.index))
        --Logger.log(serverData.index, "do test  battle -------------------")
        self:DoOnceCheck(serverData)
    else
        Logger.log("检测完毕--------------")
        --self:DoCheck()
        return
    end
end

function M:DoOnceClientBattle(serverData)
    local battleData = serverData.battle_data
    local result = SceneManager:serverStart(battleData)
    Logger.log(Json.encode(result), "角色战斗结果:" .. tostring(result.result))
end

function M:SaveVerifyData(serverData, responseData)
    local resultData = responseData.verify_data
    save_battle_result(serverData, resultData, "server_net")
end


function save_battle_result(serverData, battleResult, path)
    local battle = serverData.battle
    local name = string.format("%s_%s_%s_%s_%s_%s_%s",
            tostring(serverData.index),
            tostring(battle.common.attacker_user.uid),
            tostring(battle.common.defender_user.uid),
            tostring(battle.sort),
            tostring(battle.common.battle_id),
            tostring(battle.common.seed),
            tostring(battle.common.seed_team)
    )

    path = serverData.__out_put_path or path
    assert(path)


    for i, v in ipairs(battleResult.rounds) do
        local player_dead_frame = v.player_dead_frame
        player_dead_frame = player_dead_frame.data
        M:saveLogData(path, name .. tostring(i), player_dead_frame)
    end
    
    local log_path = GameVersionConfig.BATTLE_LOG_PATH
    local client_sim_path = string.format("%s\\%s\\client_sim\\%s", log_path, tostring(path), name)
    saveSerializeResult(client_sim_path, battleResult)

    assert(serverData.__verify_data)
    if serverData.__verify_data then
        local server_path = string.format("%s\\%s\\server\\%s", log_path, tostring(path), name)
        saveSerializeResult(server_path, serverData.__verify_data)
    end
end

function saveSerializeResult(path, battleResult)
    local file = io.open(path, "w+b")
    --local content = Json.encode(battleResult)

    for i, v in ipairs(battleResult.rounds) do
        v.autofight_operations = nil
        v.fix = nil
        v.fix1 = nil
        v.player_dead_frame = nil
    end
    battleResult.cost_time = nil
    battleResult.hero_count = nil
    battleResult.use_time = nil
    battleResult.cli_ver = nil

    local content = table.serialize(battleResult)
    local result, info;
    if file then
        result, info = file:write(content)
        io.close(file)
    end
    if result then
        Logger.log(string.format("写文件文件:%s成功", path))
    else
        Logger.log(string.format("写文件文件:%s失败(%s)\t" .. tostring(debug.traceback()), path, tostring(info)))
    end
end

function M:saveLogData(path, name, data)
    data = tostring(data)
    local log_path = GameVersionConfig.BATTLE_LOG_PATH
    log_path = string.format("%s\\%s\\%s", log_path, tostring(path) .. "_frames", name)
    local file = io.open(log_path, "w+b")
    local result, info;
    if file then
        result, info = file:write(data)
        io.close(file)
    end
end

return M