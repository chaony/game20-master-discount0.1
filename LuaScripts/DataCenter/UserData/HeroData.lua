------------ HeroData
---@class HeroData
local M = {
    m_heros = {},
     --英雄数据
    m_ids = {},
     --英雄id对应表
    m_type_name = "default",
     -- 排序类型
    m_main_team = {}, -- 主页挂机队伍更新
    m_formation = {}, -- 编队更新
    m_city_team = {}, -- 推图队伍更新
    m_teams = {},
    m_mult_teams = {},
    m_level_top = {},
    m_crystal_slot = {},
    m_crystal_all_heros_id = {},
    m_crystal_change = false,
    m_apostles = {}, -- 已借到的佣兵
    m_apostle_use_num = {}, -- 佣兵使用情况
    m_deployments = {}, -- 单队伍阵法
    m_mult_deployments = {}, -- 多队伍阵法
    hero_collect = {}, --图鉴解锁记录
    new_hero_ids = {},
    m_sig_red_point_data = {},
    m_new_hero_skins = {}, --新获得皮肤
    m_have_sp = false, --获得过sp侠客
    m_echo_sp = false, --有彩色品质的sp侠客，可以共鸣
    m_echo_total_lv = 0 --共鸣斋等级
}

--[[--
    更新英雄数据
]]
function M:updateMoreHeroData(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self:updateOneHeroData(v)
    end
    self:herosSortByTypeName()

    --计算共鸣斋等级
    self.m_echo_total_lv = 0
    for k, v in pairs(data) do
        local cfg = self:getHeroConfigByCid(v.id)
        if cfg.is_sp == 1 and v.evo >= 19 then
            local lv = v.resonance_lv or 0
            self.m_echo_total_lv = self.m_echo_total_lv + lv
        end
    end
end

--[[--
    更新英雄数据
]]
function M:updateOneHeroData(data)
    if data == nil then
        return
    end
    local oid = tostring(data.oid)
    if self.m_heros[oid] == nil then
        self.m_ids[#self.m_ids + 1] = oid
    end
    self.m_heros[oid] = data
    --标识获得了sp侠客
    if self.m_have_sp == false then
        local cfg = self:getHeroConfigByCid(data.id)
        if cfg.is_sp == 1 then
            self.m_have_sp = true
        end
    end
    --标识有了可以共鸣的sp侠客
    if self.m_echo_sp == false then
        local cfg = self:getHeroConfigByCid(data.id)
        if cfg.is_sp == 1 and data.evo >= 19 then
            self.m_echo_sp = true
        end
    end
end

--[[--
    通过id表格移出英雄数据
]]
function M:removeMoreHeroDataById(ids)
    if ids == nil then
        return
    end
    for k, v in pairs(ids) do
        self:removeOneHeroDataById(v)
    end
end

--[[--
    通过id移除英雄数据
]]
function M:removeOneHeroDataById(oid)
    oid = tostring(oid)
    local removeIndex = nil
    for k, v in pairs(self.m_ids) do
        if v == oid then
            removeIndex = k
            break
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_ids, removeIndex)
        -- self.m_ids[oid] = nil
        self.m_heros[oid] = nil
    end
end

--[[
	英雄排序
]]
function M:herosSortByTypeName(type_name)
    self.m_type_name = type_name or self.m_type_name
    self:heroIdsSort(self.m_ids, self.m_type_name)
end

--[[
    英雄排序
]]
function M:heroIdsSort(ids, type_name, other_heros)
    ids = ids or {}
    local remove_index = {}
    for i, v in ipairs(ids) do
        local data, cfg = self:getHeroDataById(v)
        if data == nil then
            if other_heros == nil or other_heros[v] == nil then
                remove_index[#remove_index + 1] = i
            end
        end
    end
    for i = #remove_index, 1, -1 do
        table.remove(ids, remove_index[i])
    end
    type_name = type_name or "default"
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getHeroDataById(id_one)
        local data2, cfg2 = self:getHeroDataById(id_two)
        local main_team_1 = self:heroInMainTeam(id_one)
        local main_team_2 = self:heroInMainTeam(id_two)
        if data1 == nil then
            data1 = other_heros[id_one]
            cfg1 = self:getHeroConfigByCid(data1.id)
        end
        if data2 == nil then
            data2 = other_heros[id_two]
            cfg2 = self:getHeroConfigByCid(data2.id)
        end
        local cid1, cid2 = data1.id, data2.id
        local lv1 = data1.clv > data1.lv and data1.clv or data1.lv
        local lv2 = data2.clv > data2.lv and data2.clv or data2.lv
        local evo1, evo2 = data1.evo, data2.evo
        local base_evo1, base_evo2 = cfg1.evo, cfg2.evo
        local cmb1, cmb2 = data1.combat, data2.combat
        if type_name == "default" then -- 默认排序
            if evo1 == evo2 then
                if lv1 == lv2 then
                    return cid1 > cid2
                else
                    return lv1 > lv2
                end
            else
                return evo1 > evo2
            end
        elseif type_name == "lv" then
            if lv1 == lv2 then
                if evo1 == evo2 then
                    if cmb1 == cmb2 then
                        return cid1 > cid2
                    else
                        return cmb1 > cmb2
                    end
                else
                    return evo1 > evo2
                end
            else
                return lv1 > lv2
            end
        elseif type_name == "combat" then
            if cmb1 == cmb2 then
                if lv1 == lv2 then
                    if evo1 == evo2 then
                        return cid1 > cid2
                    else
                        return evo1 > evo2
                    end
                else
                    return lv1 > lv2
                end
            else
                return cmb1 > cmb2  
            end
        elseif type_name == "team" then
            if main_team_1 == main_team_2 then
                if lv1 == lv2 then
                    if evo1 == evo2 then
                        if base_evo1 == base_evo2 then
                            if cmb1 == cmb2 then
                                return cid1 > cid2
                            else
                                return cmb1 > cmb2
                            end
                        else
                            return base_evo1 > base_evo2
                        end
                    else
                        return evo1 > evo2
                    end
                else
                    return lv1 > lv2
                end
            else
                return main_team_1 > main_team_2
            end
        else
            return cid1 > cid2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取英雄列表
]]
function M:getHerosId()
    return self.m_ids
end

--[[--
    获得英雄的数量
]]
function M:getHerosCount()
    return #self.m_ids
end

--[[--
    获取heros数据
]]
function M:getHerosData()
    return self.m_heros
end

--[[--
    通过id获得hero数据
    TODO ：之后添加配置的读取
]]
function M:getHeroDataById(oid)
    oid = tostring(oid)
    local data = self.m_heros[oid]
    local cfg = nil
    if data then
        cfg = self:getHeroConfigByCid(data.id)
    else
        Logger.logWarning(oid, "hero data not found :")
    end
    return data, cfg
end

--[[
    通过配置id获得英雄配置
]]
function M:getHeroConfigByCid(cid)
    local hero_detail = ConfigManager:getCfgByName("hero_detail")
    return hero_detail[cid]
end

--[[
    通过配置id获得对应的英雄
]]
function M:getHeroIdsByCid(cid, evo)
    local hero_ids = {}
    for k, v in pairs(self.m_heros) do
        if evo == nil then
            if v.id == cid then
                table.insert(hero_ids, k)
            end
        else
            if v.id == cid and v.evo == evo then
                table.insert(hero_ids, k)
            end
        end

    end
    return hero_ids
end

--[[
    获得英雄的id列表
]]
function M:getHerosIdByFilterFunc(filter_func)
    local ids = {}
    for k, v in pairs(self.m_ids) do
        local data, cfg = self:getHeroDataById(v)
        if filter_func(data, cfg) then
            table.insert(ids, v)
        end
    end
    return ids
end

-- 主页挂机队伍
function M:setMainTeam(data)
    if data == nil then
        return
    end
    self.m_main_team = data
end

function M:getMainTeam()
    return self.m_main_team or {}
end

-- 编队
function M:updateFormation(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_formation[k] = v
    end
end

function M:getFormation()
    return self.m_formation or {}
end

-- 推图队伍
function M:setCityTeam(data)
    if data == nil then
        return
    end
    self.m_city_team = data
end

function M:getCityTeam()
    return self.m_city_team or {}
end

-- 返回英雄按门派整理数据
function M:getHeroDataMakeRace()
    local heros = {}
    for k, v in pairs(self.m_heros) do
        local cfg = self:getHeroConfigByCid(v.id)
        if heros[cfg.race] == nil then
            heros[cfg.race] = {}
        end
        table.insert(heros[cfg.race], v.oid)
    end

    local function sortTable(oid1, oid2)
        local data1 = self:getHeroDataById(oid1)
        local data2 = self:getHeroDataById(oid2)
        if data1.evo > data2.evo then
            return true
        elseif data1.evo < data2.evo then
            return false
        else
            return data1.id < data2.id
        end
    end

    for k, v in pairs(heros) do
        table.sort(v, sortTable)
    end

    return heros
end

-- 返回英雄配置按门派整理数据
function M:getHeroCfgMakeRace()
    local heros_cfg = ConfigManager:getCfgByName("hero_detail")
    local heros = {}

    for k, v in pairs(heros_cfg) do
        if heros[v.race] == nil then
            heros[v.race] = {}
        end
        table.insert(heros[v.race], v)
    end

    local function sortTable(data1, data2)
        if data1.evo > data2.evo then
            return true
        elseif data1.evo < data2.evo then
            return false
        else
            return data1.id < data2.id
        end
    end

    for k, v in pairs(heros) do
        table.sort(v, sortTable)
    end

    return heros
end

----------------------------------------队伍 start---------------------------------------------

-- 编队
function M:updateTeams(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_teams[k] = v
    end
end

function M:getTeams()
    return self.m_teams or {}
end

--[[
    best --最强队伍
    view --左上角玩家信息展示队伍
    stage -- 推关队伍
    stage_pass -- 挂机队伍
    five_element -- 五行阵 
    maze -- 迷宫队伍
    tower -- 爬塔队伍
    race_tower_1 -- 种族塔队伍
    race_tower_2 -- 种族塔队伍
    race_tower_3 -- 种族塔队伍
    race_tower_4 -- 种族塔队伍
    local_arena_defense -- 竞技场防守队伍
    local_arena -- 竞技场队伍
    guild_boss -- 未定
    raid  -- 未定
    guild_boss_2  -- 未定
    activity_boss -- 未定
    rpg_map -- 时光之巅
]]
function M:getTeamByKey(key, default_key)
    local teams = self:getTeams()
    local team = teams[key] or {}
    local have_hero = false
    for k, v in pairs(team) do
        if v ~= "" then
            have_hero = true
            break
        end
    end
    if not have_hero and default_key then
        team = teams[default_key] or {}
    end
    return team
end

-- 多编队
function M:updateMultTeams(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_mult_teams[k] = v
    end
end

function M:getMultTeams()
    return self.m_mult_teams or {}
end

--[[
    high_arena -- 高阶竞技场 [[1] = {"","","","",""},[2] = {"","","","",""},[3] = {"","","","",""}]
    high_arena_defense -- 高阶竞技场防守 [[1] = {"","","","",""},[2] = {"","","","",""},[3] = {"","","","",""}]
]]
function M:getMultTeamByKey(key)
    local mult_teams = self:getMultTeams()
    return mult_teams[key] or {}
end

--[[
    挂机队伍
]]
function M:getStagePassTeam()
    local stage_pass = self:getTeamByKey("view") or {}
    if _G.next(stage_pass) == nil then
        stage_pass = self:getTeamByKey("best") or {}
    end
    return stage_pass
end

function M:checkMultTeamNeedSetUp(key, team_nums)
    local teams = self:getMultTeamByKey(key)
    local flag = false
    local team_nums = team_nums and team_nums or 3
    for i = 1, team_nums do
        local set_flag = true
        local one_team = teams[i] or {}
        for team_idx = 1, 5 do
            local hero_id = one_team[team_idx] or ""
            if hero_id ~= "" then
                set_flag = false
                break
            end
        end
        if set_flag then
            flag = set_flag
            break
        end
    end
    return flag
end

function M:checkMultTeamIsFull(key)
    local teams = self:getMultTeamByKey(key)
    for i = 1, 3 do
        local one_team = teams[i] or {}
        for team_idx = 1, 5 do
            local hero_id = one_team[team_idx] or ""
            if hero_id == "" then
                return false
            end
        end
    end
    return true
end

function M:getDeployments()
    return self.m_deployments or {}
end

-- key 和 teams 对应
function M:getDeploymentByKey(key, default_key)
    local deployments = self:getDeployments()
    local deployment = deployments[key]
    if deployment == nil and default_key then
        deployment = deployments[default_key]
    end
    return deployment or 1
end

function M:updateDeployments(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_deployments[k] = v
    end
end

function M:getMultDeployments()
    return self.m_mult_deployments or {}
end

-- key 和 mult_teams 对应
function M:getMultDeploymentByKey(key)
    local mult_deployments = self:getMultDeployments()
    return mult_deployments[key] or {}
end

-- 多编队阵法
function M:updateMultDeployments(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_mult_deployments[k] = v
    end
end

-- 英雄是否在论剑山庄防御阵容中
function M:heroInLocalArenaDefense(oid)
    local team = self:getTeamByKey("local_arena_defense")
    local flag = false
    if oid and oid ~= "" then
        for k,v in pairs(team) do
            if v == oid then
                flag = true
                break
            end
        end
    end
    return flag
end

--英雄是否在主页队伍中
function M:heroInMainTeam(oid)
    local team = self:getTeamByKey("stage")
    local flag = 0
    if oid and oid ~= "" then
        for k,v in pairs(team) do
            if v == oid then
                flag = 1
                break
            end
        end
    end
    return flag
end

----------------------------------------队伍 end------------------------------------------------

----------------------------------------共享水晶 start------------------------------------------------
function M:setLevelTop(data)
    self.m_level_top = data or {}
    self.m_crystal_change = true
end

function M:getLevelTop()
    return self.m_level_top or {}
end

function M:setCrystalSlot(data)
    table.merge(self.m_crystal_slot, data or {})
    self.m_crystal_change = true
end

function M:getCrystalSlot()
    return self.m_crystal_slot or {}
end

function M:getCrystalAllHerosId()
    if self.m_crystal_change then
        self.m_crystal_all_heros_id = {}
        for k, v in pairs(self.m_level_top) do
            local id = v[1] or ""
            if id ~= "" then
                self.m_crystal_all_heros_id[id] = 1
            end
        end
        for k, v in pairs(self.m_crystal_slot) do
            local id = v.hid or ""
            if id ~= "" then
                self.m_crystal_all_heros_id[id] = 1
            end
        end
        self.m_crystal_change = false
    end
    return self.m_crystal_all_heros_id or {}
end

----------------------------------------共享水晶 end------------------------------------------------

----------------------------------------图鉴解锁奖励 star------------------------------------------------

function M:updateHeroCollect(data)
    self.hero_collect = data
end

function M:updateMoreHeroCollect(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        local cid = tostring(k)
        if self.hero_collect[cid] == nil then
            self.new_hero_ids[#self.new_hero_ids + 1] = tonumber(cid)
        end
        self.hero_collect[cid] = v
    end
end

function M:cleanNewHero()
    self.new_hero_ids = {}
end

function M:isNewHero(cid)
    for i, v in ipairs(self.new_hero_ids) do
        if v == tonumber(cid) then
            -- table.remove(self.new_hero_ids, i)
            return true
        end
    end
    return false
end

function M:removeNewHero(cid)
    for i, v in ipairs(self.new_hero_ids) do
        if v == tonumber(cid) then
            table.remove(self.new_hero_ids, i)
            return
        end
    end
end

function M:updateOneHeroCollect(c_id)
    if self.hero_collect[tostring(c_id)] then
        self.hero_collect[tostring(c_id)] = 1
    end
end

function M:checkHeroCollect(c_id)
    if self.hero_collect[tostring(c_id)] then
        return true
    end
    return false
end

function M:checkHeroCollectPoint(c_id)
    if self.hero_collect then
        for k, v in pairs(self.hero_collect) do
            if self.hero_collect[tostring(c_id)] then
                return self.hero_collect[tostring(c_id)] == 0 --0：解锁未领奖，1：解锁已领奖
            end
        end
    end
    return false
end

function M:checkHeroRedPoint()
    if self.hero_collect then
        for k, v in pairs(self.hero_collect) do
            if v == 0 then
                return true --0：解锁未领奖，1：解锁已领奖
            end
        end
    end
    return false
end

function M:getHeroCurSkinCfgByOid(oid)
    local hero_data, hero_cfg = self:getHeroDataById(oid)
    return self:getHeroCurSkinCfgByData(hero_data, hero_cfg)
end

function M:getHeroCurSkinCfgByData(hero_data, hero_cfg)
    return Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(hero_data, hero_cfg)
end

function M:getHeroDefaultSkinCfgByHeroCfg(hero_cfg)
    return Battle.BattleConfigManager:getHeroDefaultSkinCfgByHeroCfg_Battle(hero_cfg)
end


--任意英雄任一槽位开启
function M:checkAnySlotOpen()
    local heros=self.m_heros
    local sig=nil
    local open=false
    local cur_deep=0
    for _, heroData in pairs(heros) do
        sig=heroData.sig or {}
        for pos = 1, 4 do
            local sigdata=sig[tostring(pos)]
            if sigdata and sigdata.deep then
                cur_deep=sigdata.deep
                open=self:meridanPosOpenFlagByPos(cur_deep,pos)
                if open then
                    return open
                end
            end

        end
    end
    return open
end

-- 秘籍位置是否开启
function M:meridanPosOpenFlagByPos(cur_deep,pos)
    local need_sig_deep=GlobalConfig.SLOTPOS_SIGDEEP[pos]
    if math.min(cur_deep, GlobalConfig.HERO_SIG_DEEP_MAX) >= need_sig_deep then
        return true
    else
        return false
    end
end


-- 经脉数据
function M:getSigDataByHeroOid(oid)
    local hero_data, _ = self:getHeroDataById(oid)
    return self:getSigDataByHeroData(hero_data)
end

-- 经脉数据
function M:getSigDataByHeroData(hero_data)
    local sig
    if hero_data then
        sig = hero_data.sig
    end
    return sig or {}
end

function M:resetData()
    self.m_heros = {} --英雄数据
    self.m_ids = {} --英雄id对应表
end

-- 经脉红点数据
function M:resetSigRedPointData()
    self.m_sig_red_point_data = {[1] = -1, [2] = -1, [3] = -1, [4] = -1}
    local heros_id = self:getHerosId()
    local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
    for k, v in pairs(heros_id) do
        local hero_data, _ = self:getHeroDataById(v)
        local sig = hero_data.sig or {}
        for k1,v1 in pairs(sig) do
            local id = tonumber(k1)
            local cur_lv = self.m_sig_red_point_data[id] or -1
            local sig_lv = v1.lv
            local sig_deep = v1.deep or 0
            local meridians_cultivation_cfg_item = meridians_cultivation_cfg[sig_deep] or {}
            local lower_level = meridians_cultivation_cfg_item.lower_level or 10
            if sig_lv < lower_level and sig_lv > cur_lv then
                self.m_sig_red_point_data[id] = v1.lv
                self.m_sig_red_point_data[id + 100] = v
            end
        end
    end
end

function M:getSigRedPointData()
    return self.m_sig_red_point_data
end

function M:addHeroSkin(id)
    self.m_new_hero_skins[id] = 1
end

function M:removeHeroSkin(id)
    self.m_new_hero_skins[id] = nil
end

function M:checkHeroSkin(id)
    return self.m_new_hero_skins[id] or nil
end

-- 通过其他英雄数据和id获取数据
function M:getHeroDataByDataAndId(heros, oid)
    heros = heros or {}
    oid = tostring(oid)
    local hero_data = heros[oid]
    local hero_cfg = nil
    if hero_data then
        hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
    end
    return hero_data, hero_cfg
end

-- 通过cid获取当前英雄养成的最大品质
function M:getHeroHighEvoByCid(cid)
    local evo = 0
    local hero_id = 0
    local hero_ids = UserDataManager.hero_data:getHeroIdsByCid(cid)
    for i, v in pairs(hero_ids) do
        local hero_data, _ = self:getHeroDataById(v)
        if hero_data and hero_data.evo > evo then
            evo = hero_data.evo
            hero_id = v
        end
    end
    return evo, hero_id
end
-- 获取职业等级
function M:getHeroRoleLevelById(heroId)
    local level = 0
    local hero_data = UserDataManager.hero_data:getHeroDataById(heroId)
    if hero_data and hero_data.book and hero_data.book.lv then
        level = hero_data.book.lv
    end
    return level
end

-- 获取职业等级配置信息
function M:getHeroRoleCfg( heroId, level )
    local heroRoleCfg = {}
    local role_level = 0
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季
    if heroId and heroId~=0 then
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(heroId)
        role_level = UserDataManager.hero_data:getHeroRoleLevelById(heroId) -- 职业等级
        if level then role_level = level end -- 读取消耗时需要
        if role_level and hero_cfg then
            local role_type = hero_cfg.role_type or 0
            if role_type ~= 0 then
                local herorole = ConfigManager:getCfgByName("herorole")
                local heroRoleItem = herorole[role_type] or {}
                local seasonHeroRoleCfg = heroRoleItem[role_level] or {}
                if seasonHeroRoleCfg.season and seasonHeroRoleCfg.season <= cur_season then -- 根据赛季取配置
                    heroRoleCfg = seasonHeroRoleCfg
                end
            end
        end
    end
    return heroRoleCfg,  role_level
end

-- 获取吃卡个数 和 品质
function M:getHeroRoleCostNumByRoleLevel(heroId, level)
    local num , quality = 999, 0
    local consume_item = {}
    if level then
        local heroRoleCfg = self:getHeroRoleCfg(heroId,level+1)
        if heroRoleCfg and _G.next(heroRoleCfg) then
            local consume_hero = heroRoleCfg.consume_hero
            if consume_hero and consume_hero[1] then
                num = consume_hero[1][2]
                quality = consume_hero[1][3]
                consume_item = heroRoleCfg.consume_item
            end
        end
    end
    return num, quality, consume_item
end

-- 通过cid和evo等级找到所有符合的卡牌
function M:getHeroListByCidEvo(cid, evo)
    local hero_id_list = {}
    local hero_ids = UserDataManager.hero_data:getHeroIdsByCid( cid )
    for i, v in pairs(hero_ids) do
        local hero_data, _ = self:getHeroDataById(v)
        if hero_data and hero_data.evo == evo then
            hero_id_list[#hero_id_list+1] = v
        end
    end
    return hero_id_list
end
-- 获取可以进行图鉴升级的英雄cid列表
function M:getHeroRoleCanUpGradeIdList()
    local roleUpGradeLv = ConfigManager:getCommonValueById(602,0)
    local heros_id = UserDataManager.hero_data:getHerosId()
    local hero_id_list = {}
    for i, v in pairs(heros_id) do
        local hero_data, _ = self:getHeroDataById(v)
        if hero_data and hero_data.evo == roleUpGradeLv then
            hero_id_list[#hero_id_list+1] = v
        end
    end
    local hero_list = {}
    for i, heroId in pairs(hero_id_list) do
        local role_level = UserDataManager.hero_data:getHeroRoleLevelById(heroId) -- 职业等级
        local needNum, quality, consume_item = UserDataManager.hero_data:getHeroRoleCostNumByRoleLevel(heroId, role_level)
        local hero_data, _ = UserDataManager.hero_data:getHeroDataById(heroId)
        local id_list = UserDataManager.hero_data:getHeroListByCidEvo(hero_data.id, quality)
        if table.nums(id_list) >= needNum then
            local consItem = RewardUtil:getProcessRewardData(consume_item[1])
            if consItem.user_num >= consItem.data_num then
                if not table.indexof(hero_list, hero_data.id) then
                    hero_list[#hero_list+1] = hero_data.id
                end
            end
        end
    end
    return hero_list
end

function M:getEquipNumByCid(cid)
    local num = 0 
    for k,v in pairs(self.m_heros) do
        if v.equips and next(v.equips) ~= nil then
            for kk,vv in pairs(v.equips) do
                if vv.id == cid then
                    num = num + 1
                end
            end
        end
    end
    return num
end

--是否有获得了sp侠客
function M:checkHaveSP()
    return self.m_have_sp
end

--是否有可以共鸣的sp侠客，彩色品质的sp侠客才能共鸣
function M:checkEchoSP()
    return self.m_echo_sp
end

return M
