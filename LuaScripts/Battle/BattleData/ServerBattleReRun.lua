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


--local data = require("Battle.BattleData.ReplayData")
--data = Json.decode(data).data
--for i, v in pairs(data) do
--    print("======================", i)
--end

--assert(data)
--
--SceneManager:preLoad();
--local result = SceneManager:serverStart(data)
----io.writebattlelog("___result", Json.encode(result))
--Logger.log(result.result, "战斗结果----")
--do return end



--print("data", verifyBattleData:getNext())


function HandleBattleResult(battle_data, uploadData)
    local battleData = table.copy(battle_data)
    battleData.verify_data_client = uploadData
    local clientData = battleData.verify_data_client
    clientData.rounds[1].autofight_operations = nil
    local verify_data_client_str = table.serialize(clientData)

    local serverData = battleData.verify_data
    if serverData.rounds == nil then
        return
    end

    serverData.cost_time = nil
    serverData.rounds[1].autofight_operations = nil
    serverData.use_time = nil
    serverData.hero_count = nil
    local verify_data_str = table.serialize(serverData)
    local compare_result = (verify_data_str == verify_data_client_str)
    if compare_result == false then
        local name = string.format("___result_%s_%s_%s",
                (GameVersionConfig.IS_SERVER and "server" or "client"),
                tostring(battleData.uid),
                tostring(battleData.battle.common.battle_id)
        )
        --local data = Json.encode(battleData)
        --data = string.format("%snn client:n%snnServer:n%snn",
        --		data,
        --		verify_data_client_str,
        --		verify_data_str
        --)
        battleData.verify_data_client_str = verify_data_client_str
        battleData.verify_data_str = verify_data_str
        io.writebattlelog(name, Json.encode(battleData))
    end
end


function DoClientBattle(serverData, write_path)
    local battleData = serverData
    SceneManager:preLoad();
    GameVersionConfig.OPEN_BATTLE_LOG = true
    local result = SceneManager:serverStart(battleData)
    --save_battle_result(serverData, result, write_path)
    return result
end

--function DoServerBattle(serverData)
--    local battleData = serverData
--    if not startBattle then
--        require("Battle.ServerMain")
--        ConfigManager = require("Battle.DataCenter.ServerConfigManager")
--        ConfigManager:init()
--        importModule()
--        preLoad()
--    end
--    --Logger.log(Json.encode(battleData), "battleData ====================")
--    GameVersionConfig.OPEN_BATTLE_LOG = true
--    local result = startBattle(battleData)
--    save_battle_result(serverData, result, "server")
--end

function DoServerBattle(serverData)
    local battleData = serverData
    SceneManager:preLoad();
    GameVersionConfig.OPEN_BATTLE_LOG = true
    local result = SceneManager:serverStart(battleData)
    --save_battle_result(serverData, result, write_path)
    return result
end

function Main(isServer, isOrigin, from)
    ---@type VerifyBattleData
    local verifyBattleData = nil
    local write_path = ""
    
    ---@type BattleCheckParams
    local params = {}
    params.input_file = "battle_data_2021-12-31.txt"
    params.input_path = "D:/BattleData/verify/output/"
    params.output_path = "D:/BattleData/verify/output/"
    params.start_index = 0
    params.target_index = -1
    params.output_tag = nil
    
    if isOrigin then
        verifyBattleData = require("Battle.BattleData.VerifyBattleData"):new(params)
        params.output_tag = "client1"
    else
        if isServer then
            params.output_tag = "server"
            verifyBattleData = require("Battle.BattleData.VerifyBattleData"):new(params)
        else
            params.output_tag = "client2"
            verifyBattleData = require("Battle.BattleData.VerifyBattleData"):new(params)
        end
    end

    local checkOne = function()
        --local data = verifyBattleData:getRandomOne()
        local data = verifyBattleData:getNext()
        if data then
            local serverData = Json.decode(data)
            local result
            if isServer then
                result = DoServerBattle(serverData)
            else
                result = DoClientBattle(serverData)
            end
            assert(result.result == 0)
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

--Main("battle_data_2021-12-31.txt", "D:/BattleData/verify/output/", 0);

Main(false, true, 0);
----Main(false);
--Main(true);

--local data = '{"sort":24,"class_name":"BattleRaid","uid":1459618364,"client_input":[{"attacker_team":{"team":["607-1639613497-R6EdBm","103-1639610827-iDqiG8","412-1639610670-l1Iwkg","211-1639843234-efrFyO","304-1639702920-IpjwQk"],"deployment":1,"relic":[],"heros":{"607-1639613497-R6EdBm":{"id":607,"oid":"607-1639613497-R6EdBm","ctime":1639613497,"evo":8,"ievo":5,"attrs":{"critrate":0,"hp":63856565,"atk":4226130,"def":1080265,"hr":43008,"haste":2048,"dodge":17408,"atd":61,"rage":102400,"weight":81920,"role_type":2048},"lv":1,"clv":109,"combat":32828,"lock":false,"equips":{"1":{"id":50101,"oid":100,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":30102,"oid":77,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60103,"oid":92,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"4":{"id":50104,"oid":97,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":70105,"oid":89,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":60712,"2":60723,"3":60731,"4":60741,"5":60751},"sig":{},"evo_hero":{"386":1,"387":1,"485":1},"mystics":{}},"103-1639610827-iDqiG8":{"id":103,"oid":"103-1639610827-iDqiG8","ctime":1639610827,"evo":13,"ievo":5,"attrs":{"critrate":8192,"hp":122154550,"atk":12642221,"def":2002321,"hr":90112,"dodge":43622,"atd":10,"weight":102400,"role_type":4096},"lv":140,"clv":0,"combat":79622,"lock":false,"equips":{"1":{"id":50201,"oid":85,"amount":1,"exp":50,"lv":0,"race":0,"lrace":0},"2":{"id":50202,"oid":86,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":50203,"oid":99,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":40204,"oid":93,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"5":{"id":40205,"oid":91,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":10312,"2":10323,"3":10332,"4":10341,"5":10351},"sig":{"1":{"lv":10},"2":{"lv":10},"3":{"lv":10},"4":{"lv":7}},"evo_hero":{"103":2,"104":1,"111":1,"181":2,"182":4,"183":2},"mystics":{}},"412-1639610670-l1Iwkg":{"id":412,"oid":"412-1639610670-l1Iwkg","ctime":1639610670,"evo":13,"ievo":5,"attrs":{"critrate":16793,"hp":104833011,"atk":9786642,"def":1987919,"res":30,"haste":2048,"dodge":38912,"atd":0,"weight":81920,"role_type":6144},"lv":121,"clv":0,"combat":66133,"lock":false,"equips":{"1":{"id":60301,"oid":101,"amount":1,"exp":0,"lv":0,"race":4,"lrace":0},"2":{"id":60302,"oid":6,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"3":{"id":70303,"oid":79,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":95,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":44,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":41212,"2":41223,"3":41232,"4":41241,"5":41251},"sig":{"1":{"lv":6},"2":{"lv":1},"4":{"lv":0}},"evo_hero":{"410":1,"412":2,"481":4,"484":2,"485":3},"mystics":{}},"211-1639843234-efrFyO":{"id":211,"oid":"211-1639843234-efrFyO","ctime":1639843234,"evo":5,"ievo":5,"attrs":{"critrate":6451,"hp":33315414,"atk":2954885,"def":564590,"haste":2662,"dodge":8192,"weight":81920,"role_type":6144},"lv":1,"clv":109,"combat":20225,"lock":false,"equips":{"1":{"id":40301,"oid":94,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":50302,"oid":70,"amount":1,"exp":0,"lv":0,"race":5,"lrace":0},"3":{"id":50303,"oid":90,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":20304,"oid":19,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":111,"amount":1,"exp":0,"lv":0,"race":2,"lrace":0}},"skill":{"1":21112,"2":21123,"3":21131,"4":21141,"5":21151},"sig":{},"mystics":{}},"304-1639702920-IpjwQk":{"id":304,"oid":"304-1639702920-IpjwQk","ctime":1639702920,"evo":8,"ievo":5,"attrs":{"critrate":9216,"hp":44607809,"atk":4641281,"def":875768,"haste":2048,"dodge":15360,"res":30,"weight":81920,"role_type":5120},"lv":1,"clv":109,"combat":30148,"lock":false,"equips":{"1":{"id":50301,"oid":63,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":108,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":96,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":30304,"oid":48,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":65,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":30412,"2":30423,"3":30431,"4":30441,"5":30451},"sig":{},"evo_hero":{"383":1,"387":2},"mystics":{}}},"dyns":{},"team_id":1},"defender_team":{"team":["485-1639991995-Fuge1Y","485-1639991995-44qj7W","9242-1639991995-2fulMu","9222-1639991995-NjyJuX","9222-1639991995-hByp9n"],"deployment":1,"relic":{},"heros":{"485-1639991995-Fuge1Y":{"id":485,"oid":"485-1639991995-Fuge1Y","ctime":1639991995,"evo":14,"ievo":6,"attrs":{"critrate":10240,"hp":185966000,"atk":15239585,"def":2859751,"rage":0,"rageregenper":0,"hr":122880,"dodge":92160,"weight":102400,"role_type":0},"lv":149,"clv":0,"combat":105771,"lock":false,"equips":{"1":{"id":60201,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60202,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60203,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60204,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60205,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":48512,"2":48523,"3":48532,"5":48551},"sig":{},"evo_hero":{"481":11,"485":3},"buffs":[],"mystics":{}},"485-1639991995-44qj7W":{"id":485,"oid":"485-1639991995-44qj7W","ctime":1639991995,"evo":14,"ievo":6,"attrs":{"critrate":10240,"hp":185966000,"atk":15239585,"def":2859751,"rage":0,"rageregenper":0,"hr":122880,"dodge":92160,"weight":102400,"role_type":0},"lv":149,"clv":0,"combat":105771,"lock":false,"equips":{"1":{"id":60201,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60202,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60203,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60204,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60205,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":48512,"2":48523,"3":48532,"5":48551},"sig":{},"evo_hero":{"481":11,"485":3},"buffs":[],"mystics":{}},"9242-1639991995-2fulMu":{"id":9242,"oid":"9242-1639991995-2fulMu","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":18432,"hp":168702222,"atk":14186651,"def":2587760,"rage":0,"rageregenper":0,"res":53,"dodge":46592,"weight":81920,"role_type":1024},"lv":149,"clv":0,"combat":97342,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"481":10,"9242":2},"buffs":[],"mystics":{}},"9222-1639991995-NjyJuX":{"id":9222,"oid":"9222-1639991995-NjyJuX","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":15360,"hp":164897269,"atk":13503130,"def":2444110,"rage":0,"rageregenper":0,"res":40,"dodge":35840,"weight":81920,"role_type":1024},"lv":148,"clv":0,"combat":93222,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"281":10,"9222":2},"buffs":[],"mystics":{}},"9222-1639991995-hByp9n":{"id":9222,"oid":"9222-1639991995-hByp9n","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":15360,"hp":166766862,"atk":13630619,"def":2467952,"rage":0,"rageregenper":0,"res":40,"dodge":35840,"weight":81920,"role_type":1024},"lv":149,"clv":0,"combat":94155,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"281":10,"9222":2},"buffs":[],"mystics":{}}},"dyns":{},"team_id":1}}],"attacker_combat":228956,"defender_combat":496261,"combat_rate":0.75,"rc":1,"cli_ver":"v1.1.0","rounds":[{"defender_dyns":{"485-1639991995-44qj7W":{"mp_pct":2050000,"hp_pct":0},"9222-1639991995-hByp9n":{"mp_pct":10240000,"hp_pct":0},"9222-1639991995-NjyJuX":{"mp_pct":9400000,"hp_pct":0},"9242-1639991995-2fulMu":{"mp_pct":10240000,"hp_pct":0},"485-1639991995-Fuge1Y":{"mp_pct":2680000,"hp_pct":0}},"operations":{},"attacker_team_id":1,"result":1,"round":1,"attacker_dyns":{"211-1639843234-efrFyO":{"mp_pct":9310000,"hp_pct":10240000},"103-1639610827-iDqiG8":{"mp_pct":2660000,"hp_pct":5150000},"607-1639613497-R6EdBm":{"mp_pct":8280000,"hp_pct":1990000},"412-1639610670-l1Iwkg":{"mp_pct":7060000,"hp_pct":4120000},"304-1639702920-IpjwQk":{"mp_pct":610000,"hp_pct":5660000}},"battle_cost_time":21.1171875,"defender_team_id":1,"autofight_operations":{"0":{"autofight":true}},"frame":217088,"player_dead_frame":[{"id":9222,"instance":"9222-1639991995-NjyJuX","frame":126976},{"id":485,"instance":"485-1639991995-44qj7W","frame":157696},{"id":485,"instance":"485-1639991995-Fuge1Y","frame":176128},{"id":9222,"instance":"9222-1639991995-hByp9n","frame":192512},{"id":9242,"instance":"9242-1639991995-2fulMu","frame":217088}],"defender_stats":{"485-1639991995-44qj7W":{"curMaxRage":0,"def":230731233,"atk":83991872,"rage":205864,"hp":0,"curMaxHp":213751936,"cure":11356570},"9222-1639991995-hByp9n":{"curMaxRage":0,"def":250572600,"atk":58131121,"rage":1024000,"hp":0,"curMaxHp":191684176,"cure":14091321},"9222-1639991995-NjyJuX":{"curMaxRage":0,"def":207089217,"atk":21956932,"rage":940032,"hp":0,"curMaxHp":189535240,"cure":4189675},"9242-1639991995-2fulMu":{"curMaxRage":0,"def":208606902,"atk":93235482,"rage":1024000,"hp":0,"curMaxHp":193908706,"cure":14666148},"485-1639991995-Fuge1Y":{"curMaxRage":0,"def":225291861,"atk":91344449,"rage":268820,"hp":0,"curMaxHp":213751936,"cure":5742488}},"attacker_stats":{"211-1639843234-efrFyO":{"curMaxRage":0,"def":0,"atk":79829453,"rage":931840,"hp":36633942,"curMaxHp":36633942,"cure":0},"103-1639610827-iDqiG8":{"curMaxRage":0,"def":66736319,"atk":612478165,"rage":266240,"hp":67585969,"curMaxHp":134322288,"cure":0},"607-1639613497-R6EdBm":{"curMaxRage":0,"def":72335880,"atk":54407467,"rage":828928,"hp":13709680,"curMaxHp":70217278,"cure":0},"412-1639610670-l1Iwkg":{"curMaxRage":0,"def":145589368,"atk":313034332,"rage":706560,"hp":46403052,"curMaxHp":115275362,"cure":45930026},"304-1639702920-IpjwQk":{"curMaxRage":0,"def":21907301,"atk":20451408,"rage":61440,"hp":27143864,"curMaxHp":49051165,"cure":26380470}}}],"verify_data":{"result":0,"cli_ver":"v1.1.0","rounds":[{"autofight_operations":{"294912":{"autofight":false}},"attacker_stats":{"412-1639610670-l1Iwkg":{"atk":343190547,"rage":245760,"hp":0,"curMaxHp":115275362,"cure":45930026,"curMaxRage":0,"def":239100155},"607-1639613497-R6EdBm":{"atk":44430443,"rage":931328,"hp":0,"curMaxHp":70217278,"cure":0,"curMaxRage":0,"def":82976862},"103-1639610827-iDqiG8":{"atk":565170955,"rage":61440,"hp":0,"curMaxHp":134322288,"cure":0,"curMaxRage":0,"def":142811379},"211-1639843234-efrFyO":{"atk":68550672,"rage":389120,"hp":0,"curMaxHp":36633942,"cure":0,"curMaxRage":0,"def":41490389},"304-1639702920-IpjwQk":{"atk":20423514,"rage":163840,"hp":0,"curMaxHp":49051165,"cure":26380470,"curMaxRage":0,"def":55679927}},"operations":[],"round":1,"battle_cost_time":28.6875,"defender_stats":{"9242-1639991995-2fulMu":{"atk":44369635,"rage":891412,"hp":0,"curMaxHp":193908706,"cure":14666148,"curMaxRage":0,"def":209271406},"485-1639991995-44qj7W":{"atk":122139385,"rage":41492,"hp":0,"curMaxHp":213751936,"cure":19925644,"curMaxRage":0,"def":263791116},"9222-1639991995-NjyJuX":{"atk":36645997,"rage":909312,"hp":0,"curMaxHp":189535240,"cure":4189675,"curMaxRage":0,"def":191682653},"9222-1639991995-hByp9n":{"atk":55535773,"rage":770128,"hp":0,"curMaxHp":191684176,"cure":14091321,"curMaxRage":0,"def":226860444},"485-1639991995-Fuge1Y":{"atk":360729165,"rage":621116,"hp":67162185,"curMaxHp":213751936,"cure":64210275,"curMaxRage":0,"def":207521755}},"defender_team_id":1,"attacker_team_id":1,"frame":294912,"attacker_dyns":{"412-1639610670-l1Iwkg":{"hp_pct":0,"mp_pct":2450000},"607-1639613497-R6EdBm":{"hp_pct":0,"mp_pct":9310000},"103-1639610827-iDqiG8":{"hp_pct":0,"mp_pct":610000},"211-1639843234-efrFyO":{"hp_pct":0,"mp_pct":3890000},"304-1639702920-IpjwQk":{"hp_pct":0,"mp_pct":1630000}},"defender_dyns":{"9242-1639991995-2fulMu":{"hp_pct":0,"mp_pct":8910000},"485-1639991995-44qj7W":{"hp_pct":0,"mp_pct":410000},"9222-1639991995-NjyJuX":{"hp_pct":0,"mp_pct":9090000},"9222-1639991995-hByp9n":{"hp_pct":0,"mp_pct":7700000},"485-1639991995-Fuge1Y":{"hp_pct":3210000,"mp_pct":6210000}},"player_dead_frame":[{"id":9222,"instance":"9222-1639991995-NjyJuX","frame":121856},{"id":211,"instance":"211-1639843234-efrFyO","frame":171008},{"id":9242,"instance":"9242-1639991995-2fulMu","frame":197632},{"id":485,"instance":"485-1639991995-44qj7W","frame":206848},{"id":607,"instance":"607-1639613497-R6EdBm","frame":209920},{"id":103,"instance":"103-1639610827-iDqiG8","frame":209920},{"id":9222,"instance":"9222-1639991995-hByp9n","frame":223232},{"id":304,"instance":"304-1639702920-IpjwQk","frame":235520},{"id":412,"instance":"412-1639610670-l1Iwkg","frame":293888}],"result":0}],"damage":1073316,"cost_time":{},"hero_count":{},"use_time":0.12695693969726562},"battle_data":{"battle":{"sort":24,"common":{"seed":9092,"seed_team":5,"param":1019,"sub_param":1,"battle_mode":0,"battle_id":901019,"attacker_add":{},"attacker_heirloom":{},"attacker_user":{"uid":1459618364,"name":"63闷","gender":0,"avatar":"181","frame":1,"level":54,"guild_name":"剑阁"},"attacker_element":[],"attacker_buffs":[],"defender_heirloom":{},"defender_user":{},"defender_element":[],"defender_buffs":[]},"client_input":[{"attacker_team":{"team":["607-1639613497-R6EdBm","103-1639610827-iDqiG8","412-1639610670-l1Iwkg","211-1639843234-efrFyO","304-1639702920-IpjwQk"],"deployment":1,"relic":[],"heros":{"607-1639613497-R6EdBm":{"id":607,"oid":"607-1639613497-R6EdBm","ctime":1639613497,"evo":8,"ievo":5,"attrs":{"critrate":0,"hp":63856565,"atk":4226130,"def":1080265,"hr":43008,"haste":2048,"dodge":17408,"atd":61,"rage":102400,"weight":81920,"role_type":2048},"lv":1,"clv":109,"combat":32828,"lock":false,"equips":{"1":{"id":50101,"oid":100,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":30102,"oid":77,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60103,"oid":92,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"4":{"id":50104,"oid":97,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":70105,"oid":89,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":60712,"2":60723,"3":60731,"4":60741,"5":60751},"sig":{},"evo_hero":{"386":1,"387":1,"485":1},"mystics":{}},"103-1639610827-iDqiG8":{"id":103,"oid":"103-1639610827-iDqiG8","ctime":1639610827,"evo":13,"ievo":5,"attrs":{"critrate":8192,"hp":122154550,"atk":12642221,"def":2002321,"hr":90112,"dodge":43622,"atd":10,"weight":102400,"role_type":4096},"lv":140,"clv":0,"combat":79622,"lock":false,"equips":{"1":{"id":50201,"oid":85,"amount":1,"exp":50,"lv":0,"race":0,"lrace":0},"2":{"id":50202,"oid":86,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":50203,"oid":99,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":40204,"oid":93,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"5":{"id":40205,"oid":91,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":10312,"2":10323,"3":10332,"4":10341,"5":10351},"sig":{"1":{"lv":10},"2":{"lv":10},"3":{"lv":10},"4":{"lv":7}},"evo_hero":{"103":2,"104":1,"111":1,"181":2,"182":4,"183":2},"mystics":{}},"412-1639610670-l1Iwkg":{"id":412,"oid":"412-1639610670-l1Iwkg","ctime":1639610670,"evo":13,"ievo":5,"attrs":{"critrate":16793,"hp":104833011,"atk":9786642,"def":1987919,"res":30,"haste":2048,"dodge":38912,"atd":0,"weight":81920,"role_type":6144},"lv":121,"clv":0,"combat":66133,"lock":false,"equips":{"1":{"id":60301,"oid":101,"amount":1,"exp":0,"lv":0,"race":4,"lrace":0},"2":{"id":60302,"oid":6,"amount":1,"exp":0,"lv":0,"race":1,"lrace":0},"3":{"id":70303,"oid":79,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":95,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":44,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":41212,"2":41223,"3":41232,"4":41241,"5":41251},"sig":{"1":{"lv":6},"2":{"lv":1},"4":{"lv":0}},"evo_hero":{"410":1,"412":2,"481":4,"484":2,"485":3},"mystics":{}},"211-1639843234-efrFyO":{"id":211,"oid":"211-1639843234-efrFyO","ctime":1639843234,"evo":5,"ievo":5,"attrs":{"critrate":6451,"hp":33315414,"atk":2954885,"def":564590,"haste":2662,"dodge":8192,"weight":81920,"role_type":6144},"lv":1,"clv":109,"combat":20225,"lock":false,"equips":{"1":{"id":40301,"oid":94,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":50302,"oid":70,"amount":1,"exp":0,"lv":0,"race":5,"lrace":0},"3":{"id":50303,"oid":90,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":20304,"oid":19,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":111,"amount":1,"exp":0,"lv":0,"race":2,"lrace":0}},"skill":{"1":21112,"2":21123,"3":21131,"4":21141,"5":21151},"sig":{},"mystics":{}},"304-1639702920-IpjwQk":{"id":304,"oid":"304-1639702920-IpjwQk","ctime":1639702920,"evo":8,"ievo":5,"attrs":{"critrate":9216,"hp":44607809,"atk":4641281,"def":875768,"haste":2048,"dodge":15360,"res":30,"weight":81920,"role_type":5120},"lv":1,"clv":109,"combat":30148,"lock":false,"equips":{"1":{"id":50301,"oid":63,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":108,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":96,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":30304,"oid":48,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":50305,"oid":65,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":30412,"2":30423,"3":30431,"4":30441,"5":30451},"sig":{},"evo_hero":{"383":1,"387":2},"mystics":{}}},"dyns":{},"team_id":1},"defender_team":{"team":["485-1639991995-Fuge1Y","485-1639991995-44qj7W","9242-1639991995-2fulMu","9222-1639991995-NjyJuX","9222-1639991995-hByp9n"],"deployment":1,"relic":{},"heros":{"485-1639991995-Fuge1Y":{"id":485,"oid":"485-1639991995-Fuge1Y","ctime":1639991995,"evo":14,"ievo":6,"attrs":{"critrate":10240,"hp":185966000,"atk":15239585,"def":2859751,"rage":0,"rageregenper":0,"hr":122880,"dodge":92160,"weight":102400,"role_type":0},"lv":149,"clv":0,"combat":105771,"lock":false,"equips":{"1":{"id":60201,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60202,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60203,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60204,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60205,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":48512,"2":48523,"3":48532,"5":48551},"sig":{},"evo_hero":{"481":11,"485":3},"buffs":[],"mystics":{}},"485-1639991995-44qj7W":{"id":485,"oid":"485-1639991995-44qj7W","ctime":1639991995,"evo":14,"ievo":6,"attrs":{"critrate":10240,"hp":185966000,"atk":15239585,"def":2859751,"rage":0,"rageregenper":0,"hr":122880,"dodge":92160,"weight":102400,"role_type":0},"lv":149,"clv":0,"combat":105771,"lock":false,"equips":{"1":{"id":60201,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60202,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60203,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60204,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60205,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":48512,"2":48523,"3":48532,"5":48551},"sig":{},"evo_hero":{"481":11,"485":3},"buffs":[],"mystics":{}},"9242-1639991995-2fulMu":{"id":9242,"oid":"9242-1639991995-2fulMu","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":18432,"hp":168702222,"atk":14186651,"def":2587760,"rage":0,"rageregenper":0,"res":53,"dodge":46592,"weight":81920,"role_type":1024},"lv":149,"clv":0,"combat":97342,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":3,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"481":10,"9242":2},"buffs":[],"mystics":{}},"9222-1639991995-NjyJuX":{"id":9222,"oid":"9222-1639991995-NjyJuX","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":15360,"hp":164897269,"atk":13503130,"def":2444110,"rage":0,"rageregenper":0,"res":40,"dodge":35840,"weight":81920,"role_type":1024},"lv":148,"clv":0,"combat":93222,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"281":10,"9222":2},"buffs":[],"mystics":{}},"9222-1639991995-hByp9n":{"id":9222,"oid":"9222-1639991995-hByp9n","ctime":1639991995,"evo":13,"ievo":6,"attrs":{"critrate":15360,"hp":166766862,"atk":13630619,"def":2467952,"rage":0,"rageregenper":0,"res":40,"dodge":35840,"weight":81920,"role_type":1024},"lv":149,"clv":0,"combat":94155,"lock":false,"equips":{"1":{"id":60301,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"2":{"id":60302,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"3":{"id":60303,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"4":{"id":60304,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0},"5":{"id":60305,"oid":0,"amount":1,"exp":0,"lv":0,"race":0,"lrace":0}},"skill":{"1":920211,"2":920221,"5":920251},"sig":{},"evo_hero":{"281":10,"9222":2},"buffs":[],"mystics":{}}},"dyns":{},"team_id":1},"operations":{},"autofight_operations":{"0":{"autofight":true}}}],"check_battle":1}},"battle_time":"2021-12-20 17:20:14","test_data":"t"}'
--
--data = Json.decode(data)
--
--local rounds = data.rounds[1].attacker_stats
--local  battle_data = table.serialize(rounds)
--
--local rounds = data.verify_data.rounds[1].attacker_stats
--local battle_data_2 = table.serialize(rounds)
--
--io.writebattlelog("battle_data", battle_data)
--io.writebattlelog("battle_data_2", battle_data_2)
--
--Logger.log("------")
