---@class VerifyUtil
local M = {}

VerifyUtil = M

ConfigUtil = require("Battle.BattleData.ConfigUtil")
ConfigUtil:init()

assert(VerifyUtil)

M.DefaultOutputPath = "D:/BattleData/cscheck/log/"

local __hero_id_name = require("Battle.BattleData.HeroInfo")

function M:calculateDps(battleData, battleResult)
    local rounds = battleData.battle.client_input and battleData.battle.client_input
    rounds = rounds or (battleData.battle.output and battleData.battle.output.rounds)
    --assert(rounds and #rounds == 1, "找不到回合数据或回合数据不正确")

    local hero_dps = {}
    for round, v in ipairs(rounds) do
        local clientRounds = rounds[round]
        local uid = battleData.battle.common.attacker_user.uid
        local base_info = {}
        for k, v in pairs(clientRounds.attacker_team.heros) do
            base_info[k] = base_info[k] or {}
            base_info[k].atk = v.attrs.atk
            base_info[k].def = v.attrs.atk
            base_info[k].hp = v.attrs.hp
        end
        
        local roundData = battleResult.rounds[round]
        local battle_cost_time = roundData.battle_cost_time
        local player_dead_frame = {}
        for i, v in ipairs(roundData.player_dead_frame) do
            local time = GlobalTools:ToFloat(GlobalTools:Mul(v.frame, GlobalTools.base0_1))
            time = math.min(time, battle_cost_time)
            if v.instance then
                player_dead_frame[v.instance] = time
            end
        end

        local client_info = {}
        for k, v in pairs(roundData.attacker_stats) do
            client_info[k] = client_info[k] or {}
            client_info[k].atk = v.atk
            client_info[k].def = v.def
            client_info[k].battle_cost_time = player_dead_frame[k] or battle_cost_time
            client_info[k].max_atk = v.a
            client_info[k].max_hp = v.b
        end

        for k, v in pairs(base_info) do
            local dps = client_info[k].atk / base_info[k].atk / client_info[k].battle_cost_time
            local cid = string.split(k, "-")[1]
            local atk_rate = client_info[k].max_atk / base_info[k].atk
            local hp_rate = client_info[k].max_hp / base_info[k].hp
            hero_dps[cid] = { 
                dps = dps, 
                uid = uid, 
                cid = cid,
                atk_rate = atk_rate,
                hp_rate = hp_rate,
            }
        end
    end
    
    return hero_dps
end

--- 分析单个英雄信息
function M:analyseHero(heroData)
    --local attr = "属性:" .. self:serializeTable(heroData.attrs)
    ---@type table<number, ConfigHeroDetail>
    local hero_detail_cfg = ConfigUtil:getCfgByName("hero_detail")
    local heroCfg = hero_detail_cfg[heroData.id]
    local heroInfo = self:getTextByKey(heroCfg.name) .. heroData.id
    local fate_level = "天命:" .. tostring(heroData.fate_level or  0)
    local mystic = "秘籍:" .. self:analyseHeroMystics(heroData.mystics)
    
    return {heroInfo, fate_level, mystic}
end

---分析队伍信息
function M:analyseTeam(battleData, teamKey)
    teamKey = teamKey or "attacker_team"
    local rounds = battleData.battle.client_input
    for i, roundData in ipairs(rounds) do
        Logger.log("第一波阵容:")
        local teamData = roundData[teamKey]
        local relicInfo = self:analyseHeroRelic(teamData.relic)
        Logger.log("神器" .. Json.encode(relicInfo))
        local team = teamData.team
        local heros = teamData.heros
        for i, v in ipairs(team) do
            if heros[v] then
                local info = self:analyseHero(heros[v])
                Logger.log(Json.encode(info))
            end
        end
    end
end

---写文件
function M:saveTableData(fileName, data, mode)
    mode = mode or "w+"
    data = data or {"无数据"}
    if type(data) == "table" then
        data = Json.encode(data)
    end
    local output_path = M.DefaultOutputPath .. fileName
    local fileHandler = io.open(output_path, mode)
    if fileHandler then
        fileHandler:write(data .. "\n")
        fileHandler:close()
        Logger.log(output_path, "文件导出成功")
        return true
    else
        Logger.log(output_path, "文件导出失败")
        return false
    end
end

--- 序列化表
---@param tdata table
function M:serializeTable(tdata)
    local lookup_table = {}
    local function _dump(tb)
        local str = "{"
        local keys = {}
        for k,v in pairs(tb) do
            table.insert(keys, {key = k, sort = tostring(k)})
        end
        table.sort(keys, function(a, b) return a.sort < b.sort end)

        for i, key in ipairs(keys) do
            local k = key.key
            local v = tb[k]
            str = str.."["..(tostring(k) or type(k)).."]".." = "
            if type(v) == "table" then
                if not lookup_table[v] then
                    lookup_table[v] = true
                    str = str.._dump(v)
                else
                    str = str..tostring(v)..",\n"
                end
            else
                str = str..tostring(v)..",\n"
            end
        end
        str = str .. "}\n"
        return str
    end
    return _dump(tdata)
end

function M:analyseHeroMystics(mystics)
    if not mystics then
        return ""
    end
    local mystic_cfg = ConfigUtil:getCfgByName("mystic")

    local myMystics = {}
    for i = 1, 5 do
        local data = mystics[tostring(i)]
        if data then
            local id = data.id
            ---@type ConfigMystic
            local cfg = mystic_cfg[id]
            local name = tostring(id)
            if cfg then
                name = cfg.name
                name = self:getTextByKey(name)
            else
                Logger.logError(id, "配置找不到")
            end
            table.insert(myMystics, name)
        end
    end
    return table.concat(myMystics, "|")
end

function M:analyseHeroRelic(relic)
    if not relic then
        return ""
    end
    local heirloom_cfg = ConfigUtil:getCfgByName("heirloom")
    local myRelic = {}
    for i = 1, 5 do
        local id = relic[i]
        if id and id ~= "" then
            local cfg = heirloom_cfg[id]
            local name = tostring(id)
            local level = "0"
            if cfg then
                level = cfg.quality
                name = cfg.name
                name = self:getTextByKey(name)
            else
                Logger.logError(id, "配置找不到")
            end
            table.insert(myRelic, string.format("%s_%s", name, level))
        end
    end
    return table.concat(myRelic, "|")
end


function M:getTextByKey(key)
    local languageData = ConfigUtil.languageData
    return languageData[key] or "NoText"
end

