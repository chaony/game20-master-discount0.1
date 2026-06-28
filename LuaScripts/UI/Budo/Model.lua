---@class BudoModel:OODataBase
local M = class("BudoModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

M.RACE_TYPE = {54,57,55,56}

function M:onEnter()
    self.cur_floor =  0
    self.m_tower_type = self.m_params.tower_type or 0
    if self.m_tower_type == 0 then
        self.cur_floor = UserDataManager.tower_floor or 0
    else
        self.cur_floor = UserDataManager:getRaceFloorByRace(self.m_tower_type or 0)
    end
    local tab_tower_all = ConfigManager:getCfgByName("tower_stage")
    local tab_tower_main = tab_tower_all[self.m_tower_type]
    self.max_floor = table.nums(tab_tower_main)
    --local o_id = self:getMainShowHero()
    --local h_data, cfg = UserDataManager.hero_data:getHeroDataById(o_id)
    --self.show_hero = cfg.id
    self.enemy_list = self:getEnemyTable()
end

function M:getBuZhenMode()
    if self.m_tower_type == 0 then
        return GlobalConfig.BATTLE_MODE.TOWER
    else
        return GlobalConfig.BATTLE_MODE.RACE_TOWER
    end
end

function M:checkSpecialDrop(floor)
    if self.m_tower_type == 0 then
        local quests_data = UserDataManager:getChapterQuestSpecialData(5)
        for i,v in pairs(quests_data) do
            if floor == v.target_value and v.status >= 0 then
                return v.cfg.drop
            end
        end
    else
        local race_cfg = self.RACE_TYPE[self.m_tower_type]
        if race_cfg then
            local quests_data = UserDataManager:getChapterQuestSpecialData(race_cfg)
            for i,v in pairs(quests_data) do
                if floor == v.target_value and v.status >= 0  then
                    return v.cfg.drop
                end
            end
        end
    end
    return nil
end

function M:getNextShowReward()
    local cur_floor = self.cur_floor 
    if self.m_tower_type == 0 then
        local quests_data = UserDataManager:getChapterQuestSpecialData(5)
        local cur_data = quests_data[1]
        if cur_data then
            return cur_data.cfg.drop
        end
    else
        local race_cfg = self.RACE_TYPE[self.m_tower_type]
        if race_cfg then
            local quests_data = UserDataManager:getChapterQuestSpecialData(race_cfg)
            local cur_data = quests_data[1]
            if cur_data then
                return cur_data.cfg.drop
            end
        end
    end
    return {}
end

function M:refreshData()
    if self.m_tower_type == 0 then
        self.cur_floor = UserDataManager.tower_floor or 0
    else
        self.cur_floor = UserDataManager:getRaceFloorByRace(self.m_tower_type or 0)
    end
end

function M:refreshEnemyData()
    self.enemy_list = self:getEnemyTable()
end

function M:getEnemyTable()
    local new_tab = {}
    for i = self.cur_floor - 4, self.max_floor do
        if i > 0 then
            table.insert(new_tab, i)
        end
    end
    return new_tab
end

function M:getTempEnemyTable(temp_floot)
    local new_tab = {}
    for i = temp_floot, self.max_floor do
        table.insert(new_tab, i)
    end
    return new_tab
end

function M:getEnemyDataByFloor(floor)
    local tab_tower_all = ConfigManager:getCfgByName("tower_stage")
    local tab_tower_main = tab_tower_all[self.m_tower_type]
    return tab_tower_main[floor]
end

function M:getSkNameById(id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    return cfg.hero_spine
end

function M:getFace(id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    return cfg.face
end


function M:getNextFloor()
    local next_floor = (self.cur_floor + 1) > self.max_floor and self.max_floor or self.cur_floor + 1
    local data = self:getEnemyDataByFloor(next_floor)
    return next_floor, data
end

function M:getTeamByBattleId(battle_id)
    return ConfigManager:getCfgStageBattle(battle_id)
    --local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
    --return stage_battle_tab[battle_id]
end

function M:getCurbattleId()
    local floor_data = nil
    if self.cur_floor >= self.max_floor then
        floor_data = self:getEnemyDataByFloor(self.max_floor)
    else
        floor_data = self:getEnemyDataByFloor(self.cur_floor + 1)
    end

    if floor_data then
        return floor_data.battle_id
    end
    return nil
end

function M:getMainName()
    return UserDataManager.user_data:getUserStatusDataByKey("name")
end

function M:checkCanQuick()
    if self.cur_floor == 0 then
         return false
    end
    if self.m_tower_type ~= 0 then
        local vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
        local vip_config = ConfigManager:getCfgByName("vip")
        if vip_config[vip] ~= nil and vip_config[vip].race_tower_auto ~= nil and vip_config[vip].race_tower_auto == 0 then
            return false
        end
    end
    local ratio = ConfigManager:getCommonValueById(288)
    local main_combat = self:checkMainTeamCombat()
    if self.m_tower_type ~= 0 then
        main_combat = self:checkRaceTowerTeamCombat()
    end
    local enemy_combat = self:checkEnemyTeamCombat()
    Logger.log("<color=yellow>.我方战力."..main_combat.."..</color>")
    Logger.log("<color=yellow>.敌方战力."..enemy_combat.."..</color>")
    local com_a = (main_combat * ratio)
    local com_b = enemy_combat * 100
    Logger.log("----------我方-----------"..com_a)
    Logger.log("----------敌方-----------"..com_b)
    return com_a > com_b
end

function M:checkMainTeamCombat()
    local user = UserDataManager.user_data.user_status
    local combat = user.full_combat or 0
    --self.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("best", "stage"))
    --for k, v in pairs(self.main_team) do
    --    local data, cfg = self:getHero(v)
    --    if data ~= nil then
    --        combat = data.combat + combat
    --    end
    --end
    return combat
end

--计算种族塔战力
function M:checkRaceTowerTeamCombat()
    local combat = 0
    local team = table.copy(UserDataManager.hero_data:getTeamByKey("race_tower_" .. self.m_tower_type))
    for k, v in pairs(team) do
        local data, cfg = self:getHero(v)
         if data ~= nil then --旧的 服务器战力
             combat = data.combat + combat
         end
    end
    --local   = self:getHeavenCombatAdd()
    --if heaven_add > 1 then
    --    combat = combat * heaven_add
    --end
    return combat
end


--根据id获得英雄数据
function M:getHero(id)
    return UserDataManager.hero_data:getHeroDataById(id)
end

function M:checkEnemyTeamCombat()
    local sub_combate = 0
    local e_l = {}
    --local stage_tab = ConfigManager:getCfgByName("stage_battle")
    local battle_id = self:getCurbattleId()
    sub_combate = UserDataManager:computStageBattleCombat(battle_id)
    return sub_combate
end

function M:calculateCombat(data, hp_coef, dps)
    local enemy_data = UserDataManager.hero_data:getHeroConfigByCid(data.id) --英雄配置信息
    local new_attrs = UserDataManager:computCfgAttrs(enemy_data, data.lv, data.evo, hp_coef, dps)
    local all_attr = {}
    if #data.equips > 0 then
        for i = 1, 4 do
            local id = data.equips[(i * 2) - 1]
            local iv = data.equips[(i * 2)]
            local c_attr = UserDataManager:computEnemyEqu(id, iv)
            all_attr = self:appendCfgAttrs(c_attr, all_attr)
        end
    end
    all_attr = self:appendCfgAttrs(new_attrs, all_attr)
    local enemy_m = UserDataManager:computeAttrsCombat(all_attr)
    enemy_m = math.ceil(enemy_m)
    return enemy_m
end

function M:appendCfgAttrs(cfg_atttrs, all_attrs)
    all_attrs = all_attrs or {}
    for k, v in pairs(cfg_atttrs) do
        all_attrs[k] = (all_attrs[k] or 0) + v
    end
    return all_attrs
end

function M:getAttackNum()
    if self.m_tower_type == 0 then
        return
    end
    local tower_tab = ConfigManager:getCfgByName("tower_race")
    local tower_cfg = tower_tab[self.m_tower_type]
    local use_num = UserDataManager.race_floor_times[tostring(self.m_tower_type)] or 0
    return tower_cfg.floors_per_day - use_num
end

-- 5 天机楼  54 金   55 木   56 水   57 火
function M:getQuestType()
    if self.m_tower_type == 1 then -- 金
        return 54
    elseif self.m_tower_type == 2 then -- 火
        return 57
    elseif self.m_tower_type == 3 then -- 木
        return 55
    elseif self.m_tower_type == 4 then -- 水
        return 56
    else
        return 5
    end
end

function M:changeFloor()
    if self.cur_floor +1 <= self.max_floor then
        return self.cur_floor +1
    else
        return self.max_floor
    end
end

return M
