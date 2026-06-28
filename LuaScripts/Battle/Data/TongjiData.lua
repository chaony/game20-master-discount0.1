--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-19 15:24:37
]]

---@class TongjiData 战斗统计数据
---@class TongJiData @
local M = class("TongJiData")

--初始化
function M:init()
    --统计的数据
    self.data = {}
    self.data["common"] = {}
    self.data["output"] = {}
    self.data["output"]["rounds"] = {}
    self.data["result"] = 0
    self.data['cli_ver'] = Battle.BattleGlobalConfig.BATTLE_VISION
    self.replay = false
    self.mode = 0
    -- self.index = 1;
end


function M:destroy()
    self.curRoundData = nil;
end

---@param battleData Battle_StartupData_Battle_ClientInput
function M:initRoundData(round, battleData)
    if self.data["output"]["rounds"][round] ~= nil then
        Logger.log(round, "理论上此时不应该有此回合的数据")
        return
    end

    -- 记录战斗数据
    self:getRoundData(round)
end


--返回回合数据
function M:getRoundData( round, attacker_team_id, defender_team_id)
    if self.data["output"]["rounds"][round] == nil then
        self.data["output"]["rounds"][round] = {}
        local roundData = self.data["output"]["rounds"][round];
        --回合数
        roundData["round"] = round;
        --结果
        roundData["result"] = 0;
        --攻击队伍
        roundData["attacker_team"] = {};
        roundData["attacker_team"]["team"] = {
            [1] = "",
            [2] = "",
            [3] = "",
            [4] = "",
            [5] = "",
            [6] = "",
        };
        roundData["attacker_team"]["heros"] = {};
        roundData["attacker_team"]["relic"] = {};
        roundData["attacker_team"]["dyns"] = {};
        roundData["attacker_team"]["buffs"] = {};
        roundData["attacker_team"]["team_id"] = attacker_team_id or round
        ---------------- 宠物相关 start --------------------
        --- battle_pet 是pet的oid相当于team,但是结构为string
        roundData["attacker_team"]["battle_pet"] = "";
        --- pets 是oid为key相当于heros，结构为字典
        roundData["attacker_team"]["pets"] = {};
        --- 存储pet动态属性数据（车轮战）
        roundData["attacker_team"]["pet_dyns"] = {};
        ---------------- 宠物相关 end --------------------
        
        --防守队伍
        roundData["defender_team"] = {};
        roundData["defender_team"]["team"] = {
            [1] = "",
            [2] = "",
            [3] = "",
            [4] = "",
            [5] = "",
            [6] = "",
        };
        roundData["defender_team"]["heros"] = {};
        roundData["defender_team"]["dyns"] = {};
        roundData["defender_team"]["relic"] = {};
        roundData["defender_team"]["buffs"] = {};
        roundData["defender_team"]["team_id"] = defender_team_id or round
        --大招操作
        roundData["operations"] = {};
        --玩家自动战斗操作
        roundData["autofight_operations"] = {};
        --死亡帧数
        roundData["player_dead_frame"] = {};
        --攻击者统计
        roundData["attacker_stats"] = {};
        --防守者统计
        roundData["defender_stats"] = {};
        -- 当前战斗的帧数
        roundData["frame"] = 0
        ---------------- 宠物相关 start --------------------
        --- battle_pet 是pet的oid相当于team,但是结构为string
        roundData["defender_team"]["battle_pet"] = "";
        --- pets 是oid为key相当于heros，结构为字典
        roundData["defender_team"]["pets"] = {};
        --- 存储pet动态属性数据（车轮战）
        roundData["defender_team"]["pet_dyns"] = {};
        --攻击者宠物统计
        roundData["attacker_pet_stats"] = {};
        --防守者宠物统计
        roundData["defender_pet_stats"] = {};
        ---------------- 宠物相关 end --------------------
        return roundData;
    end
    return self.data["output"]["rounds"][round]
end


function M:setTeamRelic( data, camp )
    if self.curRoundData ~= nil then
        if camp == 1 then
            self.curRoundData.attacker_team.relic = data;
        else
            self.curRoundData.defender_team.relic = data;
        end
    end
end
-- 设置每回合队伍的法阵buffs
function M:setTeamBuffs( data, camp )
    if self.curRoundData ~= nil then
        if camp == 1 then
            self.curRoundData.attacker_team.buffs = data;
        else
            self.curRoundData.defender_team.buffs = data;
        end
    end
end

-- 设置每回合队伍的宠物
function M:setTeamPet( data, camp )
    if self.curRoundData ~= nil then
        if camp == 1 then
            self.curRoundData.attacker_team.pet = data;
        else
            self.curRoundData.defender_team.pet = data;
        end
    end
end

--注册一个统计id
--instanceid ---- 玩家的实例id 
--data ---- 数据 
--camp ---- 阵营
--index ---- 索引
function M:register( instanceid, data, camp, index, round )
    if self.replay then return end
    self.curRoundData = self:getRoundData(round);
    --游戏结果 
    if camp == 1 then
        local atk_team = self.curRoundData["attacker_team"]["team"];
        local atk_heros = self.curRoundData["attacker_team"]["heros"];
        atk_team[index + 1] = instanceid;
        if atk_heros[instanceid] == nil then
            atk_heros[instanceid] = {};
            self:registerPlayerData(atk_heros[instanceid], data);
        end
        local attacker_stats = self.curRoundData["attacker_stats"];
        if attacker_stats[instanceid] == nil then
            attacker_stats[instanceid] = {};
            self:registerStats(attacker_stats[instanceid]);
        end
    else
        local def_team = self.curRoundData["defender_team"]["team"];
        local def_heros = self.curRoundData["defender_team"]["heros"];
        def_team[index + 1] = instanceid;
        if def_heros[instanceid] == nil then
            def_heros[instanceid] = {};
            self:registerPlayerData(def_heros[instanceid], data);
        end
        local defender_stats = self.curRoundData["defender_stats"];
        if defender_stats[instanceid] == nil then
            defender_stats[instanceid] = {};
            self:registerStats(defender_stats[instanceid]);
        end
    end
end


function M:registerStats( sourceData )
    if self.replay then return end
    --攻击力
    sourceData["atk"] = 0;
    --防御力
    sourceData["def"] = 0;
    --血量
    sourceData["hp"] = 0;
    --当前最大血量
    sourceData["curMaxHp"] = 0;
    --治疗量
    sourceData["cure"] = 0;
    --怒气
    sourceData["rage"] = 0;
    --当前最大 怒气
    sourceData["curMaxRage"] = 0

    sourceData["a"] = 0;
    sourceData["b"] = 0;
end

-- 如果确定不需要参与战斗的数据，在这里做一个标记
local __ignore_battle_hero_data = {
    ctime = true,
    ievo = true,
    uid = true,
    evo_item = true,
    playerType = true,-- 类型（pet or player）
    quality = true, -- 宠物品质
    variation = true, -- 宠物变异效果
    mood = true, -- 宠物心情
    power_win = true, -- 宠物比气势胜负
    combat_repress = true, --战力压制
    oldSkillId1 = true,
    oldSkillId2 = true,
    plusSkillId1= true,
    plusSkillId2= true,
    plus_level= true,
    
}

function M:registerPlayerData( sourceData, targetData )
    if self.replay then return end
    sourceData["equips"] = targetData["equips"]
    sourceData["id"] = targetData["id"]
    sourceData["attrs"] = targetData["attrs"]
    sourceData["evo"] = targetData["evo"]
    sourceData["combat"] = targetData["combat"]
    sourceData["evo_hero"] = targetData["evo_hero"]
    sourceData["lv"] = targetData["lv"]
    sourceData["lock"] = targetData["lock"]
    sourceData["skill"] = targetData["skill"]
    sourceData["clv"] = targetData["clv"]
    sourceData["oid"] = targetData["oid"]
    sourceData["skin"] = targetData["skin"]
    sourceData["sig"] = targetData["sig"]
    sourceData["buffs"] = targetData["buffs"]
    sourceData["artifact"] = targetData["artifact"]
    sourceData["mystics"] = targetData["mystics"]
    sourceData["mystic_buffs"] = targetData["mystic_buffs"]
    sourceData["book"] = targetData["book"]
    sourceData["fate_level"] = targetData["fate_level"] --天命化星
    sourceData["remain_times"] = targetData["remain_times"]
    sourceData["seal_character_buffs"] = targetData["seal_character_buffs"]
    sourceData["seal_character"] = targetData["seal_character"]
    sourceData["resonance_lv"] = targetData["resonance_lv"]
    if GameVersionConfig.Debug then -- 监测是否有新增系统数据
        for k, v in pairs(targetData) do
            if sourceData[k] == nil and __ignore_battle_hero_data[k] ~= true then
                -- 如果确定不需要这个数据参与战斗，再__ignore_battle_hero_data数据里做显式标记 
                Logger.logError(string.format("严重问题，请检查代码，没有处理战斗数据：%s\n%s", tostring(k), debug.traceback()))
            end
        end
    end

    --debug.traceback()
end

--注册一个统计id
--instanceid ---- 玩家的实例id 
--data ---- 数据 
--camp ---- 阵营
--index ---- 索引
function M:registerPet( instanceid, data, camp, index, round )
    if self.replay then return end
    self.curRoundData = self:getRoundData(round);
    --游戏结果 
    if camp == 1 then
        self.curRoundData["attacker_team"]["battle_pet"] = instanceid
        local atk_heros = self.curRoundData["attacker_team"]["pets"];
        if atk_heros[instanceid] == nil then
            atk_heros[instanceid] = {};
            self:registerPlayerData(atk_heros[instanceid], data);
        end
        local attacker_stats = self.curRoundData["attacker_pet_stats"];
        if attacker_stats[instanceid] == nil then
            attacker_stats[instanceid] = {};
            self:registerStats(attacker_stats[instanceid]);
        end
    else
        self.curRoundData["defender_team"]["battle_pet"] = instanceid
        local def_heros = self.curRoundData["defender_team"]["pets"];
        if def_heros[instanceid] == nil then
            def_heros[instanceid] = {};
            self:registerPlayerData(def_heros[instanceid], data);
        end
        local defender_stats = self.curRoundData["attacker_pet_stats"];
        if defender_stats[instanceid] == nil then
            defender_stats[instanceid] = {};
            self:registerStats(defender_stats[instanceid]);
        end
    end
end

--获取操作数据
function M:getOperationData()
    return self.curRoundData;
end

function M:setTotalDamage(dmg)
    local totalDamage = 0
    local enemylostHplist = SceneManager.curScene.plyMgr.enemylostHplist
    for k,v in pairs(enemylostHplist) do
        totalDamage = totalDamage + v
    end
    self.data.totalDamage = totalDamage
end

--加入死亡节点
function M:addDeadNode( player )
    if self.curRoundData ~= nil then
        if self.replay then return end
        local list = self.curRoundData["player_dead_frame"];
        local data = {}
        data["frame"] = SceneManager.curScene:get_runframe()
        data["instance"] = player:get_playerInstanceId();
        data["id"] = player.playerId;
        table.insert(list, data)
    end
end

--设置自动攻击操作
function M:addAutoFightOperation( autofight )
    if self.curRoundData ~= nil then
        if self.replay then return end
        local list = self.curRoundData["autofight_operations"];
        local frame = SceneManager.curScene:get_runframe();
        local frameData = list[tostring(frame)];
        if frameData == nil then
            frameData = {}
            frameData.autofight = autofight
            list[tostring(frame)] = frameData;
        else
            frameData.autofight = autofight
        end
    end
end


--记录玩家点击卡牌释放大招操作加入操作
function M:addOperation( player, params )
    if self.curRoundData ~= nil then
        if self.replay then return end
        local list = self.curRoundData["operations"];
        local frame = SceneManager.curScene:get_runframe();
        local frameData = list[tostring(frame)];
        if frameData == nil then
            frameData = Battle.ListMap.new()
            list[tostring(frame)] = frameData;
        end
        local instanceId = player:get_playerInstanceId()
        local player_frameData = frameData:get(instanceId)
        if player_frameData == nil then
            player_frameData = {}
            player_frameData["frame"] = frame
            player_frameData["instanceId"] = player:get_playerInstanceId();
            player_frameData["id"] = player.playerId;
            if player.curSkillConfig ~= nil then
                player_frameData["skillId"] = player.curSkillConfig.id;
            else
                player_frameData["skillId"] = -999;
            end
            player_frameData["params"] = params
            frameData:add(instanceId, player_frameData);
        end
    end
end


--加攻击
---@param player PlayerModel
function M:addPlayerAtk(player, atk, camp )
    if self.curRoundData ~= nil then
        local instanceid = player:get_playerInstanceId()
        if self.replay or instanceid == nil then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"];
            if attacker_stats[instanceid] ~= nil then
                local cur_atk = attacker_stats[instanceid]["atk"];
                if atk ~= atk or atk <= -math.huge or atk >= math.huge then
                    atk = 0;
                end
                cur_atk = cur_atk + atk;
                attacker_stats[instanceid]["atk"] = cur_atk
                attacker_stats[instanceid]["a"] = Mathf.Max(attacker_stats[instanceid]["a"], player.data.atk:getValue())
                --Logger.log(attacker_stats[instanceid]["a"], 'attacker_stats[instanceid]["a"] ===')
            else
                --Logger.log("addPlayerAtk instanceid not Find ".. instanceid);
            end
            
        else
            local defender_stats = self.curRoundData["defender_stats"];
            if defender_stats[instanceid] ~= nil then
                local cur_atk = defender_stats[instanceid]["atk"];
                if atk ~= atk or atk <= -math.huge or atk >= math.huge then
                    atk = 0;
                end
                cur_atk = cur_atk + atk;
                defender_stats[instanceid]["atk"] = cur_atk
                defender_stats[instanceid]["a"] = Mathf.Max(defender_stats[instanceid]["a"], player.data.atk:getValue())
            else
                --Logger.log("addPlayerAtk instanceid not Find ".. instanceid);
            end
        end
    end
end

--加防御
---@param player PlayerModel
function M:addPlayerDef(player, def, camp )
    if self.curRoundData ~= nil then
        local instanceid = player:get_playerInstanceId()
        if self.replay or instanceid == nil  then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"];
            if attacker_stats[instanceid] ~= nil then
                local cur_def = attacker_stats[instanceid]["def"];
                cur_def = cur_def + def;
                attacker_stats[instanceid]["def"] = cur_def
                attacker_stats[instanceid]["b"] = Mathf.Max(attacker_stats[instanceid]["b"], player.data:get_curHp())
            else
                --Logger.log("addPlayerDef instanceid not Find "..instanceid );
            end
        else
            local defender_stats = self.curRoundData["defender_stats"];
            if defender_stats[instanceid] ~= nil then
                local cur_def = defender_stats[instanceid]["def"];
                cur_def = cur_def + def;
                defender_stats[instanceid]["def"] = cur_def
                defender_stats[instanceid]["b"] = Mathf.Max(defender_stats[instanceid]["b"], player.data:get_curHp())
            else
                --Logger.log("addPlayerDef instanceid not Find "..instanceid );
            end
        end
    end
end


--治疗量
function M:addPlayerCure( instanceid, cure, camp)
    if self.curRoundData ~= nil then
        if self.replay or instanceid == nil then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"];
            if attacker_stats[instanceid] ~= nil then
                local cur_cure = attacker_stats[instanceid]["cure"];
                cur_cure = cur_cure + cure;
                attacker_stats[instanceid]["cure"] = cur_cure
            else
                --Logger.log("addPlayerCure instanceid not Find "..instanceid );
            end
        else
            local defender_stats = self.curRoundData["defender_stats"];
            if defender_stats[instanceid] ~= nil then
                local cur_cure = defender_stats[instanceid]["cure"];
                cur_cure = cur_cure + cure;
                defender_stats[instanceid]["cure"] = cur_cure
            else
                --Logger.log("addPlayerCure instanceid not Find "..instanceid );
            end
        end
    end
end

--怒气
function M:setPlayerRage( instanceid, rage, camp)
    if self.curRoundData ~= nil then
        if self.replay or instanceid == nil  then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"]
            if attacker_stats[instanceid] ~= nil then
                attacker_stats[instanceid]["rage"] = rage
            else
                --Logger.log("setPlayerRage instanceid not Find "..instanceid );
            end
        else
            local defender_stats = self.curRoundData["defender_stats"]
            if defender_stats[instanceid] ~= nil then
                defender_stats[instanceid]["rage"] = rage
            else
                --Logger.log("setPlayerRage instanceid not Find "..instanceid );
            end
        end
    end
end


--最大血量
function M:setPlayerMaxHp( instanceid, maxHp, camp)
    if self.curRoundData ~= nil then
        if self.replay or instanceid == nil  then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"]
            if attacker_stats[instanceid] ~= nil then
                attacker_stats[instanceid]["curMaxHp"] = maxHp
            else
                --Logger.log("setPlayerRage instanceid not Find "..instanceid );
            end
        else
            local defender_stats = self.curRoundData["defender_stats"]
            if defender_stats[instanceid] ~= nil then
                defender_stats[instanceid]["curMaxHp"] = maxHp
            else
                --Logger.log("setPlayerRage instanceid not Find "..instanceid );
            end
        end
    end
end



--最大怒气
function M:setPlayerMaxRage( instanceid, maxRage, camp)
    if self.curRoundData ~= nil then
        if self.replay or instanceid == nil  then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"]
            if attacker_stats[instanceid] ~= nil then
                attacker_stats[instanceid]["curMaxRage"] = maxRage
            else
                --Logger.log("setPlayerMaxRage instanceid not Find "..instanceid );
            end
        else
            local defender_stats = self.curRoundData["defender_stats"]
            if defender_stats[instanceid] ~= nil then
                defender_stats[instanceid]["curMaxRage"] = maxRage
            else
                --Logger.log("setPlayerMaxRage instanceid not Find "..instanceid );
            end
        end
    end
end



--血量
function M:setPlayerHp( instanceid, hp, camp)
    if self.curRoundData ~= nil then
        if hp < 0 then
            hp = 0;
        end
        if self.replay or instanceid == nil then return end
        if camp == 1 then
            local attacker_stats = self.curRoundData["attacker_stats"]
            if attacker_stats[instanceid] ~= nil then
                attacker_stats[instanceid]["hp"] = hp
            else
                --Logger.log("setPlayerHp instanceid not Find "..instanceid  .. self.curRoundData.round);
            end
        else
            local defender_stats = self.curRoundData["defender_stats"]
            if defender_stats[instanceid] ~= nil then
                defender_stats[instanceid]["hp"] = hp
            else
                --Logger.log("setPlayerHp instanceid not Find "..instanceid .. self.curRoundData.round );
            end
        end
    end
end

--天级赛两队1:1打平的时候判断胜负关系
function M:getTopRaceArenaLittleWin(rounds)
    local atk_lives, def_lives = 0, 0
    local atk_hp, atk_total_hp, def_hp, def_total_hp = 0, 0, 0, 0
    local atk_combat, def_combat = 0, 0
    local function getResultData(stats_data, team_data)
        local lives, hp, total_hp, combat = 0, 0, 0, 0
        for hero_id, heros_data in pairs(stats_data) do
            if heros_data.hp > 0 then
                lives = lives + 1
            end
            hp = hp + heros_data.hp
            total_hp = total_hp + heros_data.curMaxHp
        end
        if team_data.heros and next(team_data.heros) then
            for i, v in pairs(team_data.heros) do
                combat = v.combat + combat
            end
        end
        return lives, hp, total_hp, combat
    end
    for i, v in pairs(rounds) do
        if v.result == 1 then
            local attacker_stats = v.attacker_stats or {}
            local attacker_team = v.attacker_team or {}
            atk_lives, atk_hp, atk_total_hp, atk_combat = getResultData(attacker_stats, attacker_team)
        elseif  v.result == 0 then
            local defender_stats = v.defender_stats or {}
            local defender_team = v.defender_team or {}
            def_lives, def_hp, def_total_hp, def_combat = getResultData(defender_stats, defender_team)
        end
    end
  
    if atk_lives == def_lives then
        if atk_hp / atk_total_hp == def_hp / def_total_hp then
            return atk_combat > def_combat and 1 or 0
        else
            return (atk_hp / atk_total_hp > def_hp / def_total_hp) and 1 or 0
        end
    else
        return atk_lives > def_lives and 1 or 0
    end
end

--返回上传服务器的数据
function M:getBattleUploadData()
    local battle_mode = self.data.common.battle_mode or 0
    local result = 0
    local win_count = 0
    local failed_count = 0
    local upload_rounds = {}
    local battle = self.data or {}
    local rounds = battle.output.rounds or {}
    for k, v in ipairs(rounds) do
        local attacker_stats = v.attacker_stats or {}
        local attacker_team = v.attacker_team or {}
        local attacker_dyns = self:getHerosDyns(attacker_stats, attacker_team)
        local defender_stats = v.defender_stats or {}
        local defender_team = v.defender_team or {}
        local defender_dyns = self:getHerosDyns(defender_stats, defender_team)
        local operations_data = self:getUploadOperation(v.operations)
        upload_rounds[k] = {
            round = v.round,
            result = v.result,
            operations = operations_data,
            autofight_operations = v.autofight_operations,
            player_dead_frame = v.player_dead_frame,
            defender_dyns = defender_dyns,
            attacker_dyns = attacker_dyns,
            attacker_stats = attacker_stats,
            defender_stats = defender_stats,
            attacker_team_id = attacker_team.team_id,
            defender_team_id = defender_team.team_id,
            frame = v.frame,
            battle_cost_time = GlobalTools:ToFloat(GlobalTools:Mul( v.frame, TimeManager:get_baseUpdateDelaTime()))
        }
        if v.result == 1 then
            win_count = win_count + 1
        else
            failed_count = failed_count + 1
        end
    end
    --self:getTopRaceArenaLittleWin(rounds)
    if battle_mode == 0 then
        if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.TOP_RACE_ARENA then
            if win_count == 1 then
                result = self:getTopRaceArenaLittleWin(rounds)
            else
                result = win_count == 2 and 1 or 0
            end
        elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT
        or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then --多队推图必须全胜
            if failed_count == 0 then
                result = 1
            else
                result = 0
            end
        else
            if #rounds > 1 then
                result = win_count > failed_count and 1 or 0
            else
                result = win_count > 0 and 1 or 0
            end
        end
    else
        if #rounds > 0 then
            result = rounds[#rounds].result
        end
    end
    self.data["result"] = result

    local totalDamage = 0
    local enemylostHplist = SceneManager.curScene.plyMgr.enemylostHplistFix
    for k,v in pairs(enemylostHplist) do
        totalDamage = totalDamage + math.floor(GlobalTools:ToFloat(v))
    end
    --local totalDamage = GlobalTools:ToFloat(totalDamage)
    --totalDamage = math.floor(totalDamage)
    local data = {result = result, cli_ver = Battle.BattleGlobalConfig.BATTLE_VISION, rounds = upload_rounds, damage = totalDamage}
    return data
end

--获取上传的操作信息
function M:getUploadOperation( operations )
    local uploadData = {}
    for frame, frameData in pairs(operations) do
        if uploadData[tostring(frame)] == nil then
            uploadData[tostring(frame)] = {}
            uploadData[tostring(frame)].key = {}
            uploadData[tostring(frame)].value = {}
        end
        local instanceIdData = {}
        for i = 1, frameData.list.Count do
            local instanceId = frameData.list:get(i-1);
            table.insert(uploadData[tostring(frame)].key, instanceId)
            local playerData = frameData:get(instanceId)
            if instanceIdData[instanceId] == nil then
                instanceIdData[instanceId] = {}
                instanceIdData[instanceId].frame = playerData.frame;
                instanceIdData[instanceId].instanceId = playerData.instanceId;
                instanceIdData[instanceId].id = playerData.id;
                instanceIdData[instanceId].skillId = playerData.skillId;
                instanceIdData[instanceId].params = playerData.params;
            end
        end
        uploadData[tostring(frame)].value = instanceIdData;
    end
    return uploadData;
end

--获取一场战斗同步信息
function M:getOneBattleDynsData(round, camp)
    local battle = self.data or {}
    local rounds = battle.output.rounds or {}
    local one_round = rounds[round]
    local dyns = nil
    if one_round then
        if camp == 1 then
            local attacker_stats = one_round.attacker_stats or {}
            local attacker_team = one_round.attacker_team or {}
            dyns = self:getHerosDyns(attacker_stats, attacker_team)
        else
            local defender_stats = one_round.defender_stats or {}
            local defender_team = one_round.defender_team or {}
            dyns = self:getHerosDyns(defender_stats, defender_team)
        end
    end
    return dyns or {}
end

--获取人物动态数据
function M:getHerosDyns(common_stats, common_team)
    local dyns = {}
    common_stats = common_stats or {}
    common_team = common_team or {}
    local heros = common_team.heros or {}
    for k, v in pairs(common_stats) do
        local cur_hp = v.hp or 0
        local cur_rage = v.rage or 0
        local hp = v.curMaxHp or 0
        local rage = GlobalTools.base1000 -- 默认怒气 1000
        local hp_pct = hp > 0 and GlobalTools:Mul( GlobalTools:Div(cur_hp, hp), GlobalTools.base10000 ) or GlobalTools.base10000
        local mp_pct = rage > 0 and GlobalTools:Mul( GlobalTools:Div(cur_rage, rage), GlobalTools.base10000 ) or GlobalTools.base10000
        dyns[k] = {hp_pct = math.max(0, hp_pct), mp_pct = math.max(0, mp_pct)}
    end
    return dyns
end

function M:getServerData()
    --local data = {
    --    data = self.data,
    --    update_data = self:getBattleUploadData()
    --}
    --return  data
    local data = self:getBattleUploadData()
    --data["output"] = self.data["output"]
    return  data
end

function M:getData()
    local json = Json.encode(self.data)
    return json;
end


return M;
