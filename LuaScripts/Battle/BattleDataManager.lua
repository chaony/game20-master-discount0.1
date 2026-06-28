---@class BattleDataManager
local M = {}



function M:init()
    self.curIndex = 0
    self.curReplayIndex = 0
    self.battleData_List = Battle.List.new();
    local battle_data = require("Battle.BattleData.PreBattleData")
    self:addData(battle_data)
end


function M:addData( data )
    local json_data = Json.decode(data)
    self.battleData_List:add(json_data);
end

--获取布阵数据
function M:getArrayData( index )
    index = index or self.curIndex
    local battleData = self:getBattleData(index);
    local input = battleData.battle.client_input;
    local attack_team = {}
    local defend_team = {}
    if input ~= nil then
        local input_index = 1
        if battleData.battle.sort == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE or battleData.battle.sort == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
            input_index = index + 1
        end
        attack_team = input[input_index].attacker_team.team;
        defend_team = input[input_index].defender_team; 
    end
    local array = {}
    array.mode = battleData.battle.sort
    array.data = {}
    for k,v in ipairs(attack_team) do
        table.insert(array.data,v);
    end
    array.def_data = defend_team
    return array;
end

--获取布阵数据
function M:getMulArrayData( index , formation_index)
    index = index or self.curIndex
    local battleData = self:getBattleData(index);
    local input = battleData.battle.client_input;
    
    local deployments = {}
    local formation_index = 1
    local all_heros = {}
    local teams = {}
    local data = {}
    local user = battleData.battle.common.defender_user
    for i, v in ipairs(input) do
        local attack_team = v.attacker_team.team
        local defender_team = v.defender_team.team
        local heros = v.defender_team.heros
        table.merge(all_heros, heros)
        deployments[i] = v.defender_team.deployment
        teams[i] = defender_team
        if i == formation_index then
            data = attack_team
        end
    end
    local def_data = {deployments = deployments, formation_index = formation_index, heros = all_heros, teams = teams, user = user}
    local array = {}
    array.mode = battleData.battle.sort
    array.data = data
    array.def_data = def_data
    return array;
end

--获取战斗数据
function M:getBattleData( index )
    index = index or self.curIndex
    return self.battleData_List:get(index);
end

--获取战斗数据
function M:getBattleReplayData( index )
    index = index or self.curReplayIndex
    return self.battleData_List:get(index);
end

function M:create_hero_data(hero_id, mode, param)
    local hero_param = {}
    if mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
        local legend_cfg = ConfigManager:getCfgByName("legend")
        local legend_battle_cfg = ConfigManager:getCfgByName("legend_battle")
        local legend_attr = legend_cfg[param.battle_id]
        local legend_battle = nil
        if param.type == 1 then
            local count = math.min(param.count, #legend_attr.enemy_group_attr)
            legend_battle = legend_battle_cfg[legend_attr.enemy_group_attr[count]]
        elseif param.type == 2 then
            local count = math.min(param.count, #legend_attr.enemy_group_attr)
            legend_battle = legend_battle_cfg[legend_attr.enemy_group_attr[count]]
        elseif param.type == 3 then
            local count = math.min(param.count, #legend_attr.enemy_group_attr)
            legend_battle = legend_battle_cfg[legend_attr.boss_attr[count]]
        end
        hero_param.level = legend_battle.hero_lv
        hero_param.evo = legend_battle.hero_evo
        local equip_evo = legend_battle.equip_evo
        local equip_lv = legend_battle.equip_lv
        local sig_lv = legend_battle.equip_heroes_lv
        local equips = {}
        if equip_evo ~= nil and equip_lv ~= nil then
            local equip_list = {}
            for i = 1, 5 do
                equip_list[i] = {evo = equip_evo, lv = equip_lv}
            end
            equips = self:get_random_equip(hero_id, equip_list)
        end
        hero_param.equips = equips

        local sig = {}
        if sig_lv > 0 then
            for k,v in pairs(ConfigManager:getCommonValueById(368) or {}) do
                sig[v] = {lv = sig_lv}
            end
        end
        hero_param.sig = sig
    end
    return hero_param
end

function M:get_random_equip(hero_id, equip_list)
    local equip = {}
    local hero_table = ConfigManager:getCfgByName("hero_detail")
    local hero_cfg = hero_table[hero_id]
    if hero_cfg == nil then
        return
    end
    local h_type = hero_cfg.type
    local equip_qualitys = self:get_equip_classify()[h_type] or {}

    for k, v in pairs(equip_list) do
        local eid = equip_qualitys[v.evo][k]
        if eid ~= nil then
            local equip_dict = self:generate_base_equip(eid, 1, v.lv, 0)
            equip[k] = equip_dict
        end
    end
    return equip
end

function M:get_equip_classify()
    if self.equip_classify_mapping == nil then
        self.equip_classify_mapping = {}
        local equip_table = ConfigManager:getCfgByName("equip_detail")
        for k,v in pairs(equip_table) do
            local e_type = v.type
            local quality = v.quality
            local pos = v.pos
            if self.equip_classify_mapping[e_type] == nil then
                self.equip_classify_mapping[e_type] = {}
            end
            if self.equip_classify_mapping[e_type][quality] == nil then
                self.equip_classify_mapping[e_type][quality] = {}
            end
            self.equip_classify_mapping[e_type][quality][pos] = k
        end
    end
    return self.equip_classify_mapping
end

function M:generate_base_equip(equip_id, amount, lv, race)
    local equip_table = ConfigManager:getCfgByName("equip_detail")
    if equip_table[equip_id] == nil then
        return nil
    end
    
    local equip_dict = {
        ["id"] = equip_id,
        ["oid"] = 0,
        ["amount"] = amount or 1,
        ["exp"] = 0,
        ["lv"] = lv or 0,
        ["race"] = race or 0,
        ["lrace"] = 0,
    }
    return equip_dict
end

function M:create_hero(hero_id, param)
    local hero_table = ConfigManager:getCfgByName("hero_detail")
    local hero_cfg = hero_table[hero_id]
    if hero_cfg == nil then
        return
    end
    local equips = param.equips or {}
    local artifact = param.artifact or {}
    local level = param.level or 1
    local evo = param.evo or 1
    local sig = param.sig or {}
    local max_level = self:get_max_level(evo)
    if level > max_level then
        level = max_level
    end
    
    local oid = self:generate_oid(hero_id)
    local hero_data = {
        ["id"] = hero_id,
        ["oid"] = oid,
        ["ctime"] = TimeUtil.getTime(),
        ["evo"] = evo,
        ["attrs"] = {},
        ["lv"] = level,     --角色等级
        ["clv"] = 0,        --练武场等级
        ["combat"] = 0,
        ["lock"] = false,
        ["equals"] = equips,
        ["artifact"] = artifact,
        ["skill"] = {},
        ["sig"] = sig,      --经脉
    }
    self:update_skill(hero_data, hero_cfg)
    self:update_base_attr(hero_data, hero_cfg)
    
    return hero_data
end

function M:generate_oid(hero_id)
    self.hero_index = self.hero_index or 1
    self.hero_index = self.hero_index + 1
    local index = tostring(self.hero_index)
    local len = string.len(index)
    if len < 6 then
        for i = 1, 6 - len do
            index = "0"..index
        end
    end 
    return tostring(hero_id).."-"..tostring(TimeUtil.getTime()).."-".. index
end

function M:get_max_level(evo)
    local tab_ = ConfigManager:getCfgByName("hero_evolution")
    local max_lv = tab_[evo]["level_max"]
    return max_lv
end

function M:update_skill(hero_data, hero_cfg)
    if hero_cfg == nil then
        return
    end
    
    local unlock_skill = {}
    local hero_lv = 0
    if hero_data.clv > 0 then
        hero_lv = hero_data.clv
    else
        hero_lv = hero_data.lv
    end
    
    local skill_table = ConfigManager:getCfgByName("skill_detail")
    for k1,v1 in pairs(hero_cfg.skill) do
        for k2,v2 in ipairs(v1) do
            if hero_lv >= v2[2] then
                unlock_skill[k1] = v2[1]
                break
            end
        end
    end
    hero_data.skill = unlock_skill
end

--更新英雄基础属性
--裸体属性 = [ RankAdd{ID,Rank} + UnitBase{ID} + UnitCoef{ID,属性} * UnitLevel{等级} ] * Q{ID,资质} +QAdd{ID,资质}
function M:update_base_attr(hero_data, hero_cfg)
    if hero_cfg == nil then
        return
    end
    
    local base_attrs = {}
    local hero_id = hero_data.id
    local hero_evo = hero_data.evo
    local hero_lv = 0
    if hero_data.clv > 0 then
        hero_lv = hero_data.clv
    else
        hero_lv = hero_data.lv
    end
    local hero_upgrade_table = ConfigManager:getCfgByName("hero_upgrade")
    local hero_rank_table = ConfigManager:getCfgByName("hero_rank")
    local hero_quality_table = ConfigManager:getCfgByName("hero_quality")
    local level_cfg = hero_upgrade_table[hero_lv] or {}
    local hero_rank_cfg = hero_rank_table[hero_id] or {}
    local rank_cfg = hero_rank_cfg[level_cfg.rank or 0] or {}
    local hero_quality_cfg = hero_quality_table[hero_id] or {}
    local quality_cfg = hero_quality_cfg[hero_evo] or {}

    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    -- 暴击 906 不成长
    for k, v in pairs({906}) do
        local hero_enumeration_item = hero_enumeration[v]
        if hero_enumeration_item then
            local attr_name = hero_enumeration_item.user_key
            base_attrs[attr_name] = GlobalTools:CommonToFix(hero_cfg[attr_name .. "_base"])
        end
    end
    
    -- 基数成长属性 攻击、生命、防御
    for k, v in pairs({901, 902, 903}) do
        local hero_enumeration_item = hero_enumeration[v]
        if hero_enumeration_item then
            local attr_name = hero_enumeration_item.user_key
            
            local rank_add = rank_cfg[attr_name .. "_add"] or 0
            local unit_base = hero_cfg[attr_name .. "_base"] or 0
            local unit_coef = hero_cfg[attr_name .. "_coef"] or 1
            local unit_level = level_cfg[attr_name .. "_coef"] or 0
            local q_coef = quality_cfg[attr_name .. "_coef"] or 1
            local q_add = quality_cfg[attr_name .. "_add"] or 0

            base_attrs[attr_name] = GlobalTools:CommonToFix(GameUtil:getPreciseDecimal((rank_add + unit_base + unit_coef * unit_level) * q_coef + q_add, 4))
        end
    end
    hero_data.attrs = base_attrs
end

return M;