local M = class("BudoServerModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("tower_active_index")
end

M.RACE_TYPE = {54,57,55,56}

function M:onEnter()
    self.cur_floor =  0
    self.m_version = self.m_data.version or 1
    self.cur_floor = self.m_data.max_layer or 0
    self.m_cur_day = self.m_data.day or 1
    self.m_buffs = self.m_data.buffs or {}
    self.m_hero_id = {}
    self:updateDownTimeData()
    local tab_tower_all = ConfigManager:getCfgByName("tower_stage_active")
    self.m_cur_tower_cfg = tab_tower_all[self.m_version]
    self.max_floor = table.nums(self.m_cur_tower_cfg)
    self:initHeroData()
    self.enemy_list = self:getEnemyTable()
end

function M:updateDownTimeData()
    self.m_activityData = UserDataManager:getActivesDataByOpenId(245)
end

function M:getEndTs()
    if self.m_activityData and self.m_activityData.end_ts then
        return self.m_activityData.end_ts - UserDataManager:getServerTime()
    end
    return 0
end

function M:isShowBuff()
    if next(self.m_buffs) then
        return self.m_cur_day
    end
    return 0
end

function M:getOpenStatus()
    if self.m_activityData and self.m_activityData.open_status then
        return self.m_activityData.open_status
    end
    return 1
end

function M:initHeroData()
    if self.m_data.heros and next(self.m_data.heros) then
        for i, v in pairs(self.m_data.heros) do
            self.m_hero_id[#self.m_hero_id + 1] = i
        end
    end
end

function M:getTowerDataByLayer(layer_index)
    if self.m_data.tower_data then
        for i = 1, #self.m_data.tower_data do
            if  self.m_data.tower_data[i].layer == tonumber(layer_index) then
                return self.m_data.tower_data[i]
            end
        end
    end 
    return nil
end

function M:getBuZhenMode()
    return GlobalConfig.BATTLE_MODE.ACTIVE_TOWER
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

function M:setTempUser(user)
    self.m_user = user
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

function M:refreshData(response)
    if response then
        table.merge(self.m_data, response)
    end
    self:updateDownTimeData()
    self.m_version = self.m_data.version or 1
    self.cur_floor = self.m_data.max_layer or 0
    self.m_cur_day = self.m_data.day or 1
    self.m_buffs = self.m_data.buffs or {}
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
    return self.m_cur_tower_cfg[floor]
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
    return false
   
end

function M:checkMainTeamCombat()
    local user = UserDataManager.user_data.user_status
    local combat = user.full_combat or 0
    --for k, v in pairs(self.main_team) do
    --    local data, cfg = self:getHero(v)
    --    if data ~= nil then
    --        combat = data.combat + combat
    --    end
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
