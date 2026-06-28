-- 战斗数据模板类

---@type Battle_StartupData_Battle_Common_UserData
local ServerBattleData_Common_UserData = {
    uid = 1049626764,
    name = "Attacker",
    gender = 0,
    avatar = "105",
    frame = 2,
    level = 180,
    guild_name = "AttackerGuide"
}

---@type Battle_StartupData_Battle_Common 战斗common数据
local ServerBattleData_Common = {
    seed = 4829,
    seed_team = 5,
    param = 0,
    sub_param = 0,
    battle_mode = 1,
    battle_id = 0,
    attacker_add = {},
    attacker_heirloom = {},
    attacker_user = {},
    attacker_element = {},    --[]
    defender_heirloom = {},
    defender_user = {},
    defender_element = {},   --[]
}

---@type Battle_StartupData_Battle_ClientInput_Once
local ServerBattleData_ClientInput_Once_Data = {
    attacker_team = "",
    defender_team = "",
}

---@type Battle_StartupData_Battle_ClientInput_Team
local ServerBattleData_Team_Data = {
    team = {},  --["105-1628156428-FklASK",]
    deployment = 1,
    relic = {}, --[10110]
    heros = {}, --[10110]
    dyns = {},  --{"605-1629599347-xvDaPj" = {}}
    team_id = 1,
}


---@type Battle_StartupData_Battle_ClientInput_Team_Hero_Attr
local Battle_StartupData_Battle_ClientInput_Team_Hero_Attr = {
    atk = 409600,
    def = 102400,
    critrate = 20480,
    hp = 1024*400*15,
    weight = 81920,
    dodge = 20480,
    haste = 20480,
    hr = 283852,
    atd = 458,
    res = 44,
    hpRecover = 30,
}

---@type Battle_StartupData_Battle_ClientInput_Team_Hero
local Battle_StartupData_Battle_ClientInput_Team_Hero = {
    id =  0,
    oid =  "0",
    ctime =  1629599347,
    evo =  23,
    ievo =  5,
    lv =  1,
    clv =  1085,
    combat =  12488913,
    lock =  false,
    equips =  {},   --{}
    attrs = {}, --  {"critrate": 10854,}
    skill = {}, -- {"1": 60514,}
    sig = {},   -- {"1" = {lv = 30, deep = 3}}
    mystics = {}, -- {"1": {id = 182004, oid = 258 }}
    fate_level = 0, -- 天命
}

---@class Battle_StartupData_Generate_Param 战斗数据生成器参数
---@field userLv number 玩家场登记
---@field playerLv number 角色登记
---@field seed number 指定随机数，填-1即是使用客户端随机数
---@field seed_team number 随机数组
---@field sort number 战斗类型
---@field param number 第一参数
---@field sub_param number 第二参数
---@field attacker_team table<number, Battle_StartupData_Generate_Hero_Param>
---@field defender_team table<number, Battle_StartupData_Generate_Hero_Param>

---@class Battle_StartupData_Generate_Hero_Param
---@field cid number
---@field lv number
---@field hp number
---@field fate_level number

---@class EBattleTeamType
local EBattleTeamType = {
    Attacker = 1,
    Defener = 2,
}

require("Battle.Framework.Commom.Functions")
require("Battle.Framework.Commom.IoUtil")
require("Battle.Framework.Commom.StringUtil")
require("Battle.Framework.Commom.TableUtil")

GameVersionConfig = require("Battle.GameVersionConfig")
Logger = require("Battle.Framework.Commom.Logger")
Json = require("Battle.Framework.Commom.Json")

---@class ServerBattleDataTemplate
---@field default_param Battle_StartupData_Generate_Param
---@field default_team Battle_StartupData_Generate_Hero_Param[]
local M = {
    UserData = ServerBattleData_Common_UserData,
    Common = ServerBattleData_Common,
    ClientInput = ServerBattleData_ClientInput_Once_Data,
    TeamData = ServerBattleData_Team_Data,
    HeroData = Battle_StartupData_Battle_ClientInput_Team_Hero,
}

M.default_team = {
    {cid = 403, lv = 100},
}

M.default_param = {
    userLv = 100, -- number 玩家场登记
    playerLv = 100, -- number 角色登记
    seed = 0, -- number 指定随机数，填-1即是使用客户端随机数
    seed_team = 0, -- number 随机数组
    sort = 1, -- number 战斗类型
    param = 0, -- number 第一参数
    sub_param = 0, -- number 第二参数

    attacker_team = M.default_team,
    defender_team = M.default_team,
}


---@param param Battle_StartupData_Generate_Hero_Param
function M:GenerateHeroData(param)
    if not param then
        return
    end
    --Logger.log(Json.encode(param), "Generate Hero Data =======>  ")
    ---@type table<number, ConfigHeroSkin>
    local heroSkinConfig = ConfigManager:getCfgByName("hero_skin")
    ---@type table<number, ConfigHeroDetail>
    local heroDetailConfig = ConfigManager:getCfgByName("hero_detail")

    local skinId = nil
    ---@param v ConfigHeroSkin
    for k, v in pairs(heroSkinConfig) do
        if v.hero == param.cid then
            skinId = k
            break
        end
    end

    if(not skinId)then
        Logger.logError(skinId, "找不到皮肤")
        return nil
    end

    local skinConfig = heroSkinConfig[skinId]
    local heroConfig = heroDetailConfig[skinConfig.hero]
    if not heroConfig then
        Logger.logError(skinConfig, "Cannot find hero config")
        return
    end

    local openSkill = {}
    for i, one_skill in pairs(heroConfig.skill) do
        local sid = nil
        for ii, one in ipairs(one_skill) do
            if(one[2] <= param.lv)then
                sid = one[1]
            end
        end
        openSkill[tostring(i)] = sid
    end

    ---@type Battle_StartupData_Battle_ClientInput_Team_Hero_Attr
    local attrs = table.copy(Battle_StartupData_Battle_ClientInput_Team_Hero_Attr)

    local atk_def = 6.0 -- 攻击防御系数比
    local atk_hp = 0.07 -- 攻击血量系数比

    local lv = param.lv
    if lv > 300 then
        lv = 300 + (lv - 300) * 10
    end

    attrs.atk = lv * 1000
    attrs.def = math.floor(attrs.atk / atk_def)
    attrs.hp = math.floor(attrs.atk / atk_hp)

    attrs.critrate = math.random(10, 70) * 1024
    attrs.dodge = math.random(1, 30) * 1024

    ---@type Battle_StartupData_Battle_ClientInput_Team_Hero
    local data = table.copy(self.HeroData)
    data.id = param.cid
    data.skin = skinId
    data.lv = param.lv
    data.clv = nil
    data.skill = openSkill
    data.attrs = attrs
    data.fate_level = param.fate_level
    data.mystics = param.mystics
    return data
end

---@param team table<number, number>
---@return Battle_StartupData_Battle_ClientInput_Team
function M:GenerateTeamData(teamType, team, index)
    ---@type Battle_StartupData_Battle_ClientInput_Team
    local teamData = table.copy(ServerBattleData_Team_Data)
    for i = 1, 5 do
        local role = team[i]
        local heroData = self:GenerateHeroData(role)
        if heroData then
            heroData.oid = string.format("%s-%s-%s-%s-%s-%s",
                    tostring(teamType == EBattleTeamType.Attacker and "a" or "d"),
                    tostring(heroData.id),
                    tostring(heroData.skin),
                    tostring(heroData.lv),
                    tostring(index),
                    tostring(i))
            teamData.team[i] = heroData.oid
            teamData.heros[heroData.oid] = heroData
        else
            teamData.team[i] = ""
        end
    end
    teamData.team_id = index
    if teamType == EBattleTeamType.Attacker then
        teamData.relic = self.param.attacker_relic or {}
    else
        teamData.relic = self.param.defender_relic or {}
    end
    return teamData
end

---@return Battle_StartupData_Battle_ClientInput_Once[]
function M:GenerateBattleData()
    ---@type Battle_StartupData_Battle_ClientInput_Once
    local data = table.copy(ServerBattleData_ClientInput_Once_Data)
    data.attacker_team = self:GenerateTeamData(EBattleTeamType.Attacker, self.param.attacker_team, 1)
    data.defender_team = self:GenerateTeamData(EBattleTeamType.Defener, self.param.defender_team, 1)

    return {data}
end


function M:GenerateCommonData()
    ---@type Battle_StartupData_Battle_Common
    local common = table.copy(ServerBattleData_Common)
    common.seed = self.param.seed
    --if common.seed < 0 then
    --    common.seed = tonumber(os.time())
    --end
    common.seed_team = self.param.seed_team or 5

    ------------------------ 进攻方 ------------------------
    ---@type Battle_StartupData_Battle_Common_UserData
    local attacker = table.copy(ServerBattleData_Common_UserData)
    attacker.level = self.param.userLv
    attacker.name = "攻击方"
    attacker.uid = 1
    common.attacker_user = attacker

    ------------------------ 防守方 ------------------------
    ---@type Battle_StartupData_Battle_Common_UserData
    local defender = table.copy(ServerBattleData_Common_UserData)
    defender.level = self.param.userLv
    defender.name = "防守方"
    defender.uid = -1
    common.defender_user = defender

    return common
end

---@param param Battle_StartupData_Generate_Param
---@return Battle_StartupData
function M:GenerateStartupData(param)
    self.param = param

    local startupData = {}
    startupData.sort = param.sort
    startupData.common = self:GenerateCommonData()
    startupData.client_input = self:GenerateBattleData()

    local serverData = {
        battle = startupData,
        useTime = true,
    }

    --local filePath = "D:\\battle_server_data.json"
    --local dataStr = Json.encode(serverData)
    --local file = io.open(filePath, "w")
    --if file then
    --    local result, info = file:write(dataStr)
    --    if result then
    --        Logger.log("服务器战斗数据 "..filePath.."导出成功")
    --    else
    --        Logger.log("服务器战斗数据 "..filePath.."导出失败：" .. tostring(info))
    --    end
    --end
    return serverData
end

--M:GenerateStartupData()

function M:ConvertClientData2ServerData(clientData)
    
end

return M