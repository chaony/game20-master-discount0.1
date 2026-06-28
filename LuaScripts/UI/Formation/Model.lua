---@class FormationModel : OODataBase
local M = class("FormationModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    if self.m_params.mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_params.mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then -- 推图
        self.m_battle_id = UserDataManager:getBattleStage()
    end
    if self.m_params.mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 古剑奇谭
        self.m_stage_id = self.m_params.stage_id
    end
    self.m_raccon_hero_id = nil
    if self.m_params.mode == GlobalConfig.BATTLE_MODE.RACCON then -- 古剑奇谭
        self.m_stage_id = self.m_params.stage_id
        self.m_battle_id = self.m_params.battle_id
        self.m_raccon_hero_id = self.m_params.hero_index
    end

    self.m_special_open_id = self.m_params.special_open_id or nil -- 侠客志
    self.m_special_version = self.m_params.special_version or nil

    if self.m_params.mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then -- 入梦铃
        self.m_stage_id = self.m_params.stage_id 
        self.m_cur_stage_cfg =self.m_params.cur_stage_cfg or {}
    end
    if self.m_params.mode == GlobalConfig.BATTLE_MODE.HERO_FATE then -- 侠客情缘
        self.m_stage_id = self.m_params.stage_id
        self.m_battle_id = self.m_params.battle_id
        self.m_cur_stage_cfg = self.m_params.cur_stage_cfg or {} --有开始剧情和结束剧情，以及场景id——battle_scene
    end
    self.m_race_type = self.m_params.race_type or 0 --剑试天下 
    if self.m_params.net_data then
        self:callBack( self.m_params.net_data)
    else
        if GlobalConfig.BATTLE_MODE.RACCON == self.m_params.mode then --特殊处理小浣熊
            self:getData("battle_array_data", {open_id = self.m_special_open_id,vsn= self.m_special_version,battle_sort = self.m_params.mode, battle_id = self.m_params.battle_id, level_id = self.m_stage_id, stage_id = self.m_stage_id, hero_id = self.m_raccon_hero_id}, nil, nil, {forceBack = false})
        else
            self:getData("battle_array_data", {battle_sort = self.m_params.mode, battle_id = self.m_params.battle_id, level_id = self.m_stage_id, stage_id = self.m_stage_id, hero_id = self.m_raccon_hero_id}, nil, nil, {forceBack = false})
        end
    end
    -------------争锋联赛---------------
    self.m_forbidden_hero_ids=self.m_params.forbidden_hero_ids
    self.m_ban_num=self.m_params.ban_num
    self.m_rise_id=self.m_params.rise_id
    self.m_week_rule=self.m_params.week_rule

    if self.m_week_rule then
        self.m_limit_cfg=ConfigManager:getCfgByName("rise_arena_week_rule")
        self.m_limit_cfg=self.m_limit_cfg[self.m_rise_id][self.m_week_rule]
    end
    -------------RTA-------------------------
    self.m_rta_match_id =self.m_params.match_id
    self.m_rta_team=self.m_params.rta_team
    self.m_rta_end_ts=self.m_params.rta_end_ts
    self.cur_tier=self.m_params.cur_tier
end

function M:onEnter()
    self.can_click = true --控制英雄被拖动的变量
    self.m_mult_battle_pets = {} -- 多队宠物
    self.m_is_first = true
    self.show_pet_bl = false
    self.activeTeamBl = false
    --self.m_active_heaven_heros = false -- 阵法 可激活法阵的英雄弹窗展示（active_heros）
    --self.m_active_heaven_heros2 = false -- 阵法 激活法阵的信息弹窗展示（heaven_details_pop）
    self.m_solts = self:getWeaSolt()
    --阵法
    self.m_select_heaven_id = 1 --当前激活阵法id
    --self.m_normal_tab = self:getTeamIds()
    self.m_normal_array = 0
    self.m_mult_normal_array = {}
    --
    self.m_battle_pet = 0 -- 协战宠物
    ------------------------------------侠客岛
    self.m_layer=self.m_params.layer
    self.m_lose_num=self.m_params.lose_num
    ---------------------------------------------
    local mercenary = ConfigManager:getCfgByName("mercenary")
    self.m_mode = self.m_params.mode or 0
    --版本号
    self.version = self.m_params.version
    self.open_id = self.m_params.open_id or 395
    self.m_formation_id = self.m_params.formation_id or 0
    --编队id
    self.m_def_data = self.m_params.def_data
    --self.m_show_def_data = self.m_params.show_def_data or 0 --是否显示敌方英雄
    self.m_show_def_data = 0
    --self.m_active_tower_heros = self.m_params.active_tower_heros or {} -- 天机楼本次可选的英雄
    --self.m_active_tower_heros_id = self.m_params.active_tower_heros_id or {} -- 天机楼本次可选的英雄的id
    self.m_assist_heros = self.m_params.assist_heros or {} -- 助阵英雄
    self.m_is_pre_edit = false-- 多队推图的预编队编辑状态
    if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
        self.m_legend_heros = self.m_params.active_tower_heros or {}
    else
        self.m_legend_heros = {} -- 助阵英雄
    end
    if self.m_params.gvg_data and self.m_params.gvg_data.atk_heros then
        self.m_other_heros = self.m_params.gvg_data.atk_heros
    else
        self.m_other_heros = {}
    end
    self.m_GVGstar = self.m_params.GVGstar
    self.m_dyns = self.m_params.dyns or {} -- 英雄战斗数据
    self.boss_hp = self.m_params.boss_hp
    self.m_boss_pos = self.m_params.boss_pos;
    self.m_boss_size = self.m_params.boss_size;
    self.chapter_id = self.m_params.chapter_id
    self.m_combat_gve_battle = self.m_params.combat_gve_battle -- 奇门遁甲关卡综合战力
    self.block_id = self.m_params.block_id
    self.new_chapter = self.m_params.new_chapter
    self.m_bottom_type = 0 -- 0隐藏 1上浮
    self.m_def_pet = self.m_params.pet or 0
    self.m_from_view = self.m_params.from_view
    self.m_auto_battle_flag = self.m_params.auto_battle_flag
    self.m_team_changed_flag = false
    self.race_toggle_type = true --英雄种族页签状态
    self.m_raid_sort = self.m_params.raid_sort --武道场类型
    self.m_budo_floor = self.m_params.budo_floor or 1 --天机楼层数
    self.m_active_tower_day = self.m_params.active_tower_day or 0 --天机秘境第几天
    self.m_big_world_cur_scene_id = self.m_params.big_world_cur_scene_id or -1 -- 当前江湖大地图id
    self.m_death_hero_oids = self.m_params.death_hero_oids or {} --献祭的英雄 *古剑奇谭地宫*
    self.m_fair_fulwin = self.m_params.fair_fulwin or 0 -- 风云擂台 开启公平模式， 0 不开启  1 开启
    --种族
    self.m_races = table.copy(self.m_params.races)
    if self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE and self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE then
        if self.m_races and self:CanInsertRace7(self.m_races) == true then
            table.insert(self.m_races, 7)
            self.m_races = table.unique(self.m_races)
        end
    end
    self.m_lock_job = self.m_params.lock_job -- 禁用职业
    self.m_top_arena_races = self.m_params.top_arena_races or nil
    self.m_race_nums_tab = self.m_params.race_nums_tab or nil --罗天摘星 种族有个数限制
    self.m_wdtower_enemy_combat = self.m_params.wdtower_enemy_combat or 0 --罗天摘星 敌方战力
    self.m_team_nums = 3 -- 多队伍数量 默认是3 天级赛是2
    for k, v in pairs(self.m_assist_heros) do
        v.assist_flg = true
    end
    local apostles = self.m_data or {}
    self.m_race = self.m_params.race or 0 -- 塔类型0 普通塔 1-4 种族塔
    if self.m_data and self.m_data.apostles then
        -- 好友和公会无畏之手的佣兵
        self.apostles_use_num = self.m_data.apostle_use_num[tostring(self.m_mode)] or 0
        self.apostles_cfg_num = mercenary[self.m_mode] and mercenary[self.m_mode].count or 0
        if self.apostles_cfg_num > 0 then
            if self.m_mode ~= GlobalConfig.BATTLE_MODE.RACE_TOWER then
                for k, v in pairs(self.m_data.apostles.hero or {}) do
                    v.apostle_flag = true
                    self.m_assist_heros[k] = v
                end
            end
        end
        -- 师傅的佣兵
        self.mantor_apostles_use_num = self.m_data.mentor_use_num[tostring(self.m_mode)] or 0
        self.mastor_apostles_cfg_num = mercenary[self.m_mode] and mercenary[self.m_mode].mastor_count or 0
        if self.mastor_apostles_cfg_num > 0 then
            if self.m_mode ~= GlobalConfig.BATTLE_MODE.RACE_TOWER then
                for k, v in pairs(self.m_data.apostles.mastor_hero or {}) do
                    v.mastor_apostle_flag = true
                    self.m_assist_heros[k] = v
                end
            end
        end
        -- 推图配置的系统佣兵
        self.novice_times = self.m_data.apostles.novice_times or 0
        for k, v in pairs(self.m_data.apostles.novice_hero or {}) do
            v.novice_apostle_flag = true
            self.m_assist_heros[k] = v
        end
        -- 传记配置的佣兵
        for k, v in pairs(self.m_data.apostles.bio_hero or {}) do
            v.bio_apostle_flag = true
            self.m_assist_heros[k] = v
        end
        -- 古剑奇谭配置的佣兵
        if self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
            for k, v in pairs(self.m_data.ancient_sword_assist_heros or {}) do
                v.acient_sword_flag = true
                self.m_assist_heros[k] = v
            end
        end

        if self.m_mode == GlobalConfig.BATTLE_MODE.RACCON then
            for k, v in pairs(self.m_data.assist_heros or {}) do
                v.raccon_assist_flag = true
                self.m_assist_heros[k] = v
            end
        end
        if self.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
            --远超其他  过滤侠客
            local have_hero = {}
            have_hero = self:getHaveHeroID()
            for k, v in pairs(self.m_data.assist_heros or {}) do
                if not have_hero[v.id] then
                    v.raccon_assist_flag = true
                    self.m_assist_heros[k] = v
                else
                    Logger.log(v.id .. "被过滤掉了")
                end
            end
            
        end
    end

    for k, v in pairs(self.m_data.legend_heros or {}) do
        v.legend_apostle_flag = true
        self.m_assist_heros[k] = v
    end

    self:updateTeamNums()

    self.m_heirlooms = self.m_params.heirlooms or {} -- 遗物
    self.m_formation_index = self.m_params.formation_index or 1 -- 多阵容显示索引
    self.m_mult_team_flag = false -- 是否是多阵容
    self.m_battle_id_tab = {} --多阵容推图的战斗id
    self.m_lock_hids = self.m_params.lock_hids or {} -- 正在打扫战场的英雄配置id

    self:initMainTeam()
    self:initStageBattleId()
    self:InitSupportIds() --助战系统数据初始化
    self:checkHero()
    self:downHeroInSupport()--下阵已经已经参与助战的侠客
    self.temp_team = table.copy(self.main_team) or {}
    self.temp_combat = 0
    local wall_coef = self.m_data.wall_coef or {}
    self.m_server_hp_coef = wall_coef.hp_coef or 100
    self.m_server_dps_coef = wall_coef.dps_coef or 100
    self.m_gve_version = self.m_params.gve_version
    -- START 奇门遁甲战斗墙
    if self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
        local wall_coef2 = self.m_params.wall_coef or {}
        self.m_server_hp_coef = wall_coef2.hp_coef or 0
        self.m_server_dps_coef = wall_coef2.dps_coef or 0
        self.m_difficulty_reduce = self.m_params.difficulty_reduce or 0
    end
    -- END奇门遁甲战斗墙
    
    self.m_formation_skip_battle = UserDataManager.local_data:getUserDataByKey("formation_skip_battle", 0)
    self.m_select_slot_index = 0 --法宝切换选择框
    self:initSeasonBuffHeros()
    if self.m_battle_pet ~= 0 and self.m_battle_pet ~= "" then
        local data = self:getPetData(self.m_battle_pet)
        if data == nil then
            self.m_battle_pet = 0
        end
    end
    for k,v in pairs(self.m_mult_battle_pets) do
        if v ~= 0 and v ~= "" then
            local data = self:getPetData(v)
            if data == nil then
                self.m_mult_battle_pets[k] = 0
            end
        end
    end
    self.m_formation_pets = self:getPets()
    if self:showPets() == false then
        self.m_battle_pet = 0
        self.m_mult_battle_pets = {}
    end
    self.m_guild_high_war_model = self.m_params.guild_high_war_model
    -- 版本号 和 openid 决定
    --self.m_special_open_id = self.m_params.special_open_id or nil -- 侠客志
    --self.m_special_version = self.m_params.special_version or nil
    --巅峰战力压制等级添加
    self.eff_atk_level = self.m_data.talent_eff_level and self.m_data.talent_eff_level.eff_atk_level or 0
    self.eff_def_level = self.m_data.talent_eff_level and self.m_data.talent_eff_level.eff_def_level or 0 
    self.is_current_leve_type = 1
    self.my_score = 0

end

function M:getActowerDes()
    if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER and self.m_active_tower_day and self.m_active_tower_day > 0 then
        local tab_tower_all = ConfigManager:getCfgByName("tower_hero_active") or {}
        local cur_tower_cfg = tab_tower_all[self.version] or {}
        local cur_day_cfg = cur_tower_cfg[self.m_active_tower_day] or {}
        local des = cur_day_cfg.buff_des or ""
        return des
    end
    return ""
end

function M:initMainTeam()
    -- 爬塔层数
    self.tower_floor = self.m_params.tower_floor
    -- 防守阵法
    if self.m_def_data then
        self.m_def_deployment = self.m_def_data.deployment or 1
        self.m_def_pet = self.m_def_data.battle_pet
    end
    -- 战斗id
    self.m_battle_id = self.m_params.battle_id
    if self.m_battle_id == nil then
        self:initStageBattleId()
    end
    
    -- 侠客试炼活动、世界boss参数
    self.m_boss_id = self.m_params.boss_id
    self.m_boss_max_hp = self.m_params.boss_max_hp or 0
    self.m_boss_hp_cid = self.m_params.boss_hp_cid or 0
    self.m_boss_cur_damage = self.m_params.boss_cur_damage or 0
    self.m_move_camera = self.m_params.move_camera or 0 -- 奇门遁甲的镜头移动
    self.m_addition_race = self.m_params.addition_race or {}
    -- 五行阵参数
    self.m_five_pos = self.m_params.five_pos or 1
    self.m_floor = self.m_params.floor or 1
    -- 传记参数
    self.m_bio_id = self.m_params.bio_id
    self.m_chapter_id = self.m_params.chapter_id
    self.m_stage_id = self.m_params.stage_id
    self.next_floor = self.m_params.next_floor or false --true 爬塔点击下一层进入该界面
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode]
    if battle_mode_cfg_item then
        local def_deployment = battle_mode_cfg_item.def_deployment
        self.m_def_deployment = def_deployment or self.m_def_deployment
        local mode_util_item = BattleModeUtil[self.m_mode]
        if mode_util_item and mode_util_item.formationModel then
            mode_util_item.formationModel(self)
        else
            local team_key = battle_mode_cfg_item.team_key
            if self.m_mode == GlobalConfig.BATTLE_MODE.TOWER and self.next_floor and self.next_floor == true  then
                team_key = "tower"
            end
            if self.m_mult_team_flag == true then
                self.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray(team_key))
                self.m_mult_battle_pets = table.copy(UserDataManager:getMultPets(team_key)) or 0
            else
                self.m_normal_array = table.copy(UserDataManager:getNormalArray(team_key)) or 0
                self.m_battle_pet = table.copy(UserDataManager:getPet(team_key)) or 0
            end
            local default_team_key = battle_mode_cfg_item.default_team_key
            if team_key then
                self.main_team = table.copy(UserDataManager.hero_data:getTeamByKey(team_key, default_team_key))
                self.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey(team_key, default_team_key)
                if self.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.BIG_MAP or self.m_mode == GlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
                    --天机楼 大地图 默认队伍里有助阵的英雄的话置空
                    for k, v in pairs(self.main_team) do
                        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                        if hero_data == nil then
                            self.main_team[k] = ""
                        end
                    end
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
                    -- 奇门遁甲去掉锁卡相关英雄和锁种族相关英雄
                    self:screenMainTeamByLockHeroAndRace()
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM  then
                    local hero_group = self.m_cur_stage_cfg.hero_group or {}  --去掉不在策划配置中的侠客
                    local temp_data = {}
                    for k1,id in pairs(hero_group) do
                        temp_data[id] = true
                    end
                    for k, v in ipairs(self.main_team) do
                        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                        if hero_data == nil then
                            self.main_team[k] = ""
                        else
                            local hero_id = hero_data.id
                            if not temp_data[hero_id] then
                                self.main_team[k] = ""
                            end
                        end
                    end
                end
            else
                --Logger.logError(self.m_mode, "mode team key is error : ")
                self.main_team = {}
                self.m_atk_deployment = 1
            end
        end

    else
        Logger.logError(self.m_mode, "mode is error : ")
    end
    --阵法
    if self.m_mult_team_flag == true then
        self.m_select_heaven_id = self.m_mult_normal_array[self.m_formation_index] or 0 --当前激活阵法
    else
        self.m_select_heaven_id = self.m_normal_array or 0 --当前激活阵法    
    end
    self:updateHeaven() --确定阵法id
end

-- 获取已经拥有的侠客的id
function M:getHaveHeroID()
    local hero_id_list = {}
    local hero_ids = self:getAllHeroIds()
    for k,v in pairs(hero_ids) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        hero_id_list[hero_data.id] = true
    end
    return hero_id_list
end


-- 筛选锁定的英雄和锁定的种族
function M:screenMainTeamByLockHeroAndRace()
    for k, v in pairs(self.main_team) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if self.m_races and hero_cfg and not table.indexof(self.m_races, hero_cfg.race) then -- 去掉锁定种族
            self.main_team[k] = ""
        end
        if self.m_lock_hids and hero_cfg and table.indexof(self.m_lock_hids, hero_cfg.id) then -- 去掉锁定配置id的卡
            self.main_team[k] = ""
        end
    end
end

function M:updateTeamNums()
    if self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA then
        self.m_team_nums = 2
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        self.m_team_nums = #(data["battle"])
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        local stage_tab = ConfigManager:getCfgByName("sword_main")
        local data = stage_tab[self.m_stage_id]
        self.m_team_nums = #(data["battle_id"])
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
        self.m_team_nums = GameUtil:getGuildHighWarTeamNums()
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
        self.m_team_nums = GameUtil:getCompareSwordDefendTeams()

    elseif self.m_mode==GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
        local stage_tab = ConfigManager:getCfgByName("hero_isle_layer")
        local data = stage_tab[self.m_layer]
        local battle_id_tab = data["battles"] or {}
        self.m_team_nums=#battle_id_tab
    elseif self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL then
        local cfg=ConfigManager:getCfgByName("rise_arena_base")[self.m_rise_id]
        self.m_team_nums=cfg.team_num
    end
end

function M:updateTeam()
    self.main_team = table.copy(UserDataManager.hero_data:getCityTeam())
    self:checkHero()
end

function M:updateTeam_ban()
    if table.nums(self.m_forbidden_hero_ids)>0 then
        local team=nil
        for i = 1, self.m_team_nums do
            team=self.mult_main_teams[i]
            for k,v in pairs(team) do
                local hero_data, _ = UserDataManager.hero_data:getHeroDataById(v)
                if hero_data then
                    if table.indexof(self.m_forbidden_hero_ids,hero_data.id) then
                        team[k] = ""
                    end
                end

            end
        end
    end

    --争锋联赛去除被禁用的英雄,不为空代表是争锋联赛
    --for k,v in pairs(self.main_team) do
    --    local hero_data, _ = UserDataManager.hero_data:getHeroDataById(v)
    --    if table.indexof(self.m_forbidden_hero_ids,hero_data.id) then
    --        self.main_team[k] = ""
    --    end
    --end
end

--下阵已经已经参与助战的侠客
function M:downHeroInSupport()

    if self:supportSysContainCurMode() then
        local help_hero_oids=UserDataManager.help_heros
        if table.nums(help_hero_oids)>0 then
            local team=nil
            if self.mult_main_teams~=nil then
                for i = 1, self.m_team_nums do
                    team=self.mult_main_teams[i]
                    for k,hero_oid in pairs(team) do
                        local data,_ =UserDataManager.hero_data:getHeroDataById(hero_oid)
                        if data~=nil then
                            if table.indexof(self.m_support_ids,data.id) then
                                team[k] = ""
                            end
                        end
                    end
                end
            end
            if self.main_team~=nil then
                for k,hero_oid in ipairs(self.main_team) do
                    local data,_ =UserDataManager.hero_data:getHeroDataById(hero_oid)
                    if data~=nil then
                        if table.indexof(self.m_support_ids,data.id) then
                            self.main_team[k] = ""
                        end
                    end
                end
            end
        end
    end
end

--当前战斗模式是否在助战系统范围内
function M:supportSysContainCurMode()
    local hero_help_base_cfg=ConfigManager:getCfgByName("hero_help_base")
    local index=table.indexof(hero_help_base_cfg.battle_sorts,self.m_mode)
    return index~=false
end


function M:getHeroOidInMainTeam(id)
    for k,oid in pairs(self.main_team) do
        if oid~="" then
            local hero_data,_=UserDataManager.hero_data:getHeroDataById(oid)
            if hero_data.id==id then
                return oid
            end
        end
    end
    return nil
end

--[[
1	推图
2	爬塔
3	种族塔
4	迷宫
5	普通竞技场
6	时光之颠 rpg
7	奇境探险
8	公会boss
9	公会秘境
10	多编队
11	高阶竞技场
12	高阶竞技场防守阵容
13	竞技场防守阵容
14	世界boss
    mercenary  模式表
]]
function M:isShowEnemyUI()
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode] or {}
    return battle_mode_cfg_item.show_enemy ~= false
end

--[[世界boss公会boss不显示战力、羁绊]]
function M:isShowHeroUI()
    if self.m_mode == 3 or self.m_mode == 8 then
        return false
    else
        return true
    end
end

--查询卡牌是否在队伍中
function M:inquireInTeams(c_id)
    for k, v in pairs(self.main_team) do
        if v == c_id then
            return true
        end
    end
    return false
end

--查询某个英雄中是否可以上阵
function M:inquireVacancy(c_id)
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        if #self.main_team < 3 then
            return true
        end
        for i = 1,3  do
            if self.main_team[i] and self.main_team[i] == "" then
                return true
            end
        end
    else
        if #self.main_team < 5 then
            return true
        end    
        for k, v in pairs(self.main_team) do
            if v == "" then
                return true
            end
        end
    end
    return false
end

--查询某个英雄中是否可以上阵
function M:inquireVacancyMultTeam()
    if (self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and self.mult_main_teams and next(self.mult_main_teams) then
        for team_index, team in pairs(self.mult_main_teams) do
            if #team < 5 then
                return true
            end
            for k, v in pairs(team) do
                if v == "" then
                    return true, team_index
                end
            end
        end
    end
    
    return false
end


--查询佣兵使用次数是否满足
function M:inquireApostleTimes(c_id)
    local hero_data = self:getHero(c_id)
    if hero_data and hero_data.apostle_flag then
        return self.apostles_use_num >= self.apostles_cfg_num
    end
    if hero_data and hero_data.mastor_apostle_flag then
        return self.mantor_apostles_use_num >= self.mastor_apostles_cfg_num
    end

    if hero_data and hero_data.novice_apostle_flag then
        return self.novice_times <= 0
    end

    return false
end

--查询上阵的英雄中是否已有佣兵
function M:inquireApostleInTeam(c_id)
    local hero_data = self:getHero(c_id)
    if hero_data and hero_data.apostle_flag or hero_data.mastor_apostle_flag or hero_data.novice_apostle_flag then
        for k, v in pairs(self.main_team) do
            if v ~= "" then
                hero_data = self:getHero(v)
                if
                    hero_data and hero_data.apostle_flag or hero_data.mastor_apostle_flag or
                        hero_data.novice_apostle_flag
                 then
                    return true
                end
            end
        end
    end
    return false
end

--查询多队伍上阵的英雄中是否已有佣兵
function M:inquireApostleInMultTeam(c_id)
    if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        local hero_data = self:getHero(c_id)
        if hero_data and hero_data.apostle_flag or hero_data.mastor_apostle_flag or hero_data.novice_apostle_flag then
            if self.mult_main_teams then
                for team_index, team in pairs(self.mult_main_teams) do
                    for k, v in pairs(team) do
                        if v ~= "" then
                            hero_data = self:getHero(v)
                            if
                            hero_data and hero_data.apostle_flag or hero_data.mastor_apostle_flag or
                                    hero_data.novice_apostle_flag
                            then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

--添加进队伍
function M:addTeams(c_id)
    local max_num = 5
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        max_num = 3
    end
    for i = 1, max_num do
        if self.main_team[i] == nil or self.main_team[i] == "" then
            self.main_team[i] = c_id
            return i
        end
    end
    return 1
end

--移出队伍
function M:removeTeams(c_id)
    for k, v in pairs(self.main_team) do
        if v == c_id then
            self.main_team[k] = ""
            return k
        end
    end
end

--移除所有
function M:removeAll()
    for k, v in pairs(self.main_team) do
        self.main_team[k] = ""
    end
end

--检查特定英雄是否在队伍中
function M:checkInTeams(oid)
    for k, v in pairs(self.main_team) do
        if v == oid then
            return true
        end
    end
    return false
end

--检查特定英雄是否在帮会战队伍中
function M:checkInUnionWarTeams(oid)
    for k, v in pairs(self.union_war_teams) do
        for key, val in pairs(v.team) do
            if val == oid then
                return tonumber(k), true
            end
        end
    end
    return -1, false
end

--检查特定英雄是否在苗疆战队伍中
function M:checkInMiningDefenseTeams(oid)
    for k, v in pairs(self.main_team) do
        for key, val in pairs(v) do
            if v == oid then
                return tonumber(k), true
            end
        end
    end
    return -1, false
end

--检查职业是否已经在队伍中
function M:checkJobIsInTeam(h_id)
    if self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA
    then
        if self.m_limit_cfg.rule_type==2 then
            local _, h_cfg = self:getHero(h_id)
            for k, v in pairs(self.main_team) do
                if #v > 0 then
                    local c_data, c_cfg = self:getHero(v)
                    if h_cfg.role_type == c_cfg.role_type then
                        return true
                    end
                end
            end
        end
    end

    return false
end

--检查队伍中是否已有同名英雄
function M:checkIsInTeam(h_id)
    local h_data, h_cfg = self:getHero(h_id)
    for k, v in pairs(self.main_team) do
        if #v > 0 then
            local c_data, c_cfg = self:getHero(v)
            if h_cfg == c_cfg then
                return true
            end
        end
    end
    if (self.m_mode ~= GlobalConfig.BATTLE_MODE.MULT_STAGE and self.m_mode ~= GlobalConfig.BATTLE_MODE.GU_JIAN_MULT)or not(self.m_mult_team_edit_flag) then
        if self.mult_main_teams then
            for k, v in pairs(self.mult_main_teams) do
                for pos, hero_oid in pairs(v) do
                    if #hero_oid > 0 then
                        local c_data, c_cfg = self:getHero(hero_oid)
                        if h_cfg == c_cfg then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

--检查队伍中是否已有同名宠物
function M:checkPetIsInTeamByPetDouji(p_id)
    local p_data, p_cfg = self:getPetData(p_id)
    for k, v in pairs(self.main_team) do
        if #v > 0 then
            local c_data, c_cfg = self:getPetData(v)
            if p_cfg == c_cfg and p_id ~= v then
                return true
            end
        end
    end
    return false
end

--检查队伍中是否已有当前宠物
function M:checkPetIsInTeamByPetOid(p_id)
    for k, v in pairs(self.main_team) do
        if #v > 0 then
            if p_id == v then
                return true
            end
        end
    end
    return false
end

function M:InitSupportIds()
    local help_hero_oids=UserDataManager.help_heros
    self.m_support_ids ={}
    for i, hero_oid in pairs(help_hero_oids) do
        local data,_=UserDataManager.hero_data:getHeroDataById(hero_oid)
        if data~=nil then
            if not table.indexof(self.m_support_ids,data.id) then
                table.insert(self.m_support_ids,data.id)
            end
        end
    end
end

--是否已经在助战系统中上阵
function M:checkIsInSupport(hero_oid)
    if self:supportSysContainCurMode() then
        local data,_ =UserDataManager.hero_data:getHeroDataById(hero_oid)
        if data then
            return table.indexof(self.m_support_ids,data.id)
        else
            return false
        end
    else
        return false
    end
end

--助战系统是否是处于助战类型战斗且有助战侠客上阵
function M:heroIsInsupport()
    local hero_help_base_cfg=ConfigManager:getCfgByName("hero_help_base")
    local index=table.indexof(hero_help_base_cfg.battle_sorts,self.m_mode)
    if index~=false then
        local help_hero_oids=UserDataManager.help_heros
        return table.nums(help_hero_oids)>0
    else
        return false
    end
end

-- 英雄列表移出被禁的职业
function M:removeRepeatJobHero()
    if self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE or
            self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA
    then
        if self.m_limit_cfg.rule_type==2 then
            self:removeRepeat(self.main_team)
            if self.mult_main_teams then
                local teamNum=table.nums(self.mult_main_teams)
                for i = 1, teamNum do
                    self:removeRepeat(self.mult_main_teams[i])
                end
            end
        end
    end
end

function M:removeRepeat(team)
    local team_num=#team
    for i = 1, team_num-1 do
        if #team[i]>0 then
            local _, h_cfg = self:getHero(team[i])
            for j = i+1, team_num do
                if #team[j]>0 then
                    local _, c_cfg = self:getHero(team[j])
                    if h_cfg.role_type == c_cfg.role_type then
                        team[j]=""
                        if  self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
                                self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE  then
                            self.m_team_changed_flag=true
                        end
                    end
                end
            end
        end
    end
    --for k1, v1 in pairs(team) do
    --    local _, h_cfg = self:getHero(v1)
    --    for k2, v2 in pairs(team) do
    --        if #v2 > 0 and v1~=v2 then
    --            local _, c_cfg = self:getHero(v2)
    --            if h_cfg.role_type == c_cfg.role_type then
    --                team[k2]=""
    --            end
    --        end
    --    end
    --end
end


--奇门遁甲检查队伍中是否有被锁英雄
function M:checkIsLockHids(h_id)
    local h_data, h_cfg = self:getHero(h_id)
    if table.indexof(self.m_lock_hids, h_cfg.id) then
        return true
    end
    return false
end

-- 检查是否被禁用职业
function M:checkIsLockJob(h_id)
    if self.m_lock_job then
        local h_data, h_cfg = self:getHero(h_id)
        if h_cfg and table.indexof(self.m_lock_job, h_cfg.role_type) then
            return true
        end
    end
    return false
end

-- 英雄列表移出被禁的职业
function M:removeLockJobHero()
    if self.m_lock_job then
        local new_list = {}
        for i,v in ipairs(self.Filtrate_list) do
            if not self:checkIsLockJob(v) then
                table.insert(new_list,v)
            end
        end
        self.Filtrate_list = new_list
    end
end

function M:getAllHeroCount()
    return UserDataManager.hero_data:getHerosCount()
end

function M:getAllHeroIds()
    if
        (self.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER) and
            self.m_race ~= 0
     then
        local tower_race = ConfigManager:getCfgByName("tower_race")
        local tower_race_item = tower_race[self.m_race] or {}
        local race_condition = tower_race_item.race_condition or {}
        local function filterFunc(data, cfg)
            return table.keyof(race_condition, cfg.race) ~= nil or cfg.race == 7
        end
        return UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
        return {}
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
        local hero_group = self.m_cur_stage_cfg.hero_group or {}
        local function filterFunc(data, cfg)
            return table.keyof(hero_group, cfg.id) ~= nil
        end
        return UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
    end
    
    return UserDataManager.hero_data:getHerosId()
end

--根据id获得英雄数据
function M:getHero(id)
    local hero_cfg = nil
    local hero_data = self.m_assist_heros[id] or self.m_legend_heros[id]
    if hero_data == nil and self.m_other_heros ~= nil then
        hero_data = self.m_other_heros[id]
    end
    if hero_data then
        hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
    else
        hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    end

    return hero_data, hero_cfg
end

function M:getLegendData()
    if self.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
        local legend_cfg = ConfigManager:getCfgByName("legend_stage")
        return legend_cfg[self.m_battle_id]
    end
    return nil
end

--检测编队是否与当前战斗类型冲突
function M:checkMultRace(hero_list)
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_race ~= 0 then
        for i, v in pairs(hero_list) do
            if next(v) ~= nil then
                local data, cfg = self:getHero(v.card_id)
                if self.m_race ~= cfg.race then
                    return false
                end
            end
        end
    end
    return true
end

--检测编队是否与当前战斗类型冲突
function M:checkMultRace2(hero_list)
    if hero_list == nil then
        return true
    end
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_race ~= 0 then
        for i, v in pairs(hero_list) do
            if #v > 0 then
                local data, cfg = self:getHero(v)
                if self.m_race ~= cfg.race then
                    return false
                end
            end
        end
    end
    return true
end

function M:listContain(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function M:getHeroByRaces(race_list)
    if race_list == nil then
        self.Filtrate_list = {}
        local hero_ids = self:getAllHeroIds()
        for k, v in pairs(hero_ids) do
            local is_die, _ = self:heroIsDie(v)
            local id_death = self:heroIsDeath(v)
            if not is_die and not id_death then
                table.insert(self.Filtrate_list, v)
            end
        end
    else
        local heros = {}
        local hero_ids = self:getAllHeroIds()
        for k, v in pairs(hero_ids) do
            local l_hero_data, l_hero_cfg = self:getHero(v)
            local is_die, _ = self:heroIsDie(v)
            local id_death = self:heroIsDeath(v)
            if (self:listContain(race_list, 0) or self:listContain(race_list, l_hero_cfg.race)) and not is_die and not id_death then
                table.insert(heros, v)
            end
        end
        self.Filtrate_list = heros
    end

    if self.m_sel_formation_index == nil then
        for k, v in pairs(self.m_assist_heros) do
            local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
            local is_die, _ = self:heroIsDie(k)
            local id_death = self:heroIsDeath(k)
            if (self:listContain(race_list, 0) or self:listContain(race_list, hero_cfg.race)) and not is_die and not id_death then
                table.insert(self.Filtrate_list, k)
            end
        end
    end
    
    self:removeLockJobHero()
    --self:removeRepeatJobHero()
    self:heroIdsSort()
end

--根据种族和属性筛选英雄
function M:getHeroByRace(race)
    if race == 0 then
        self.Filtrate_list = {}
        local hero_ids = self:getAllHeroIds()
        for k, v in pairs(hero_ids) do
            local is_die, _ = self:heroIsDie(v)
            local id_death = self:heroIsDeath(v)
            if not is_die and not id_death then
                table.insert(self.Filtrate_list, v)
            end
        end
    else
        local heros = {}
        local hero_ids = self:getAllHeroIds()
        for k, v in pairs(hero_ids) do
            local l_hero_data, l_hero_cfg = self:getHero(v)
            local is_die, _ = self:heroIsDie(v)
            local id_death = self:heroIsDeath(v)
            if (race == 0 or race == l_hero_cfg.race) and not is_die and not id_death then
                table.insert(heros, v)
            end
        end
        self.Filtrate_list = heros
    end
    if self.m_sel_formation_index == nil then
        for k, v in pairs(self.m_assist_heros) do
            local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
            local is_die, _ = self:heroIsDie(k)
            local id_death = self:heroIsDeath(k)
            if (race == 0 or race == hero_cfg.race) and not is_die and not id_death then
                table.insert(self.Filtrate_list, k)
            end
        end
    end
    for k, v in pairs(self.m_legend_heros) do
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
        local is_die, _ = self:heroIsDie(k)
        local id_death = self:heroIsDeath(k)
        if (race == 0 or race == hero_cfg.race) and not is_die and not id_death then
            table.insert(self.Filtrate_list, k)
        end
    end
    
    self:removeLockJobHero()
    --self:removeRepeatJobHero()
    -- UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"lv", self.m_assist_heros)
    self:heroIdsSort()
end

--[[
    英雄排序
]]
function M:heroIdsSort()
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getHero(id_one)
        local data2, cfg2 = self:getHero(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1 = data1.clv > data1.lv and data1.clv or data1.lv
        local lv2 = data2.clv > data2.lv and data2.clv or data2.lv
        local evo1, evo2 = data1.evo, data2.evo
        local cmb1, cmb2 = data1.combat, data2.combat
        local in_team1 = self:inquireInTeams(id_one) == true and 1 or 0
        local in_team2 = self:inquireInTeams(id_two) == true and 1 or 0
        local assist_flg1 =
            data1.assist_flg or data1.mastor_apostle_flag or data1.novice_apostle_flag or data1.bio_apostle_flag or data1.legend_apostle_flag or data1.acient_sword_flag or data1.raccon_assist_flag
        local assist_flg2 =
            data2.assist_flg or data2.mastor_apostle_flag or data2.novice_apostle_flag or data2.bio_apostle_flag or data2.legend_apostle_flag or data2.acient_sword_flag or data2.raccon_assist_flag
        local function levelSort()
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
        end

        local function assistSort()
            if assist_flg1 then
                if assist_flg2 then
                    if assist_flg1 then
                        if assist_flg2 then
                            return levelSort()
                        else
                            return true
                        end
                    elseif assist_flg2 then
                        return false
                    else
                        return levelSort()
                    end
                else
                    return true
                end
            elseif assist_flg2 then
                return false
            else
                if assist_flg1 then
                    if assist_flg2 then
                        return levelSort()
                    else
                        return true
                    end
                elseif assist_flg2 then
                    return false
                else
                    return levelSort()
                end
            end
        end

        if in_team1 == in_team2 then
            if self.m_params.mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO or
                    self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
            then
                return levelSort()
            else
                return assistSort() 
            end
        else
            return in_team1 > in_team2
        end
    end
    table.sort(self.Filtrate_list, sortFunc)
end

-- 我方战力
function M:getHeroCombat()
    local combat = 0
    if self.m_mode == GlobalConfig.BATTLE_MODE.MAZE or 
            self.m_mode == GlobalConfig.BATTLE_MODE.TOP_OF_TIME or 
            self.m_mode == GlobalConfig.BATTLE_MODE.FOUR_TOWER or 
            self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or
            self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or
            self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or
            self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE or
            self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or
            self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or
            self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD or
            self.m_mode == GlobalConfig.BATTLE_MODE.RACCON or
            self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE  then
        local team = self.main_team or {}
        local assist_heros = self.m_assist_heros or {} --雇佣的英雄
        local heirlooms = self.m_heirlooms or {}
        local _, heros_combat = GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms, self.m_solts, self.m_mode)
        combat = heros_combat
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA or
            self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE or
            self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or
            self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE or
            self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE or
            self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE then
        local team = self.main_team or {}
        local heirlooms = {}
        local solts = {}
        if self.m_mult_team_flag == true and self.m_mult_solts then
            solts = self.m_mult_solts[self.m_formation_index] or {}
        else
            solts = self.m_solts
        end
        local _, heros_combat = GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms, solts, self.m_mode)
        combat = heros_combat
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then --宠物斗技
        combat = 0
        for k, v in pairs(self.main_team) do
            local data,_ = self:getPetData(v)
            if data then
                combat = data.combat + combat
            end
        end
    else
        for k, v in pairs(self.main_team) do
            local data, cfg = self:getHero(v)
            -- if data ~= nil then --旧的 服务器战力
            --     combat = data.combat + combat
            -- end
            if data and cfg then --新的  根据当前切换法宝更新实时战力
                local solts = {}
                if self.m_mult_team_flag == true and self.m_mult_solts then
                    solts = self.m_mult_solts[self.m_formation_index] or {}
                else
                    solts = self.m_solts
                end
                local q_combat = UserDataManager:computeHeroCombat(data, cfg, true, nil, solts, true, 0)
                combat = q_combat + combat
            end
        end
    end
    local heaven_add = self:getHeavenCombatAdd()
    if heaven_add > 1 then
        combat = combat * heaven_add
    end
    return GameUtil:formatValueToString(combat)
end


-- 敌方战力
function M:getEnemyCombat()
    local sub_combate = 0
    if self:isShowEnemyUI() == false then
        return sub_combate
    end
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE then -- 推图
        sub_combate =
            UserDataManager:computStageBattleCombat(self.m_battle_id, self.m_server_hp_coef, self.m_server_dps_coef)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE
            or self.m_mode == GlobalConfig.BATTLE_MODE.RACCON
            or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 推图，古剑奇谭
        sub_combate =
        UserDataManager:computStageBattleCombat(self.m_battle_id, self.m_server_hp_coef, self.m_server_dps_coef,nil, self.m_formation_index)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER then
        sub_combate = self.m_wdtower_enemy_combat
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then -- 宠物斗技
        return "?????"
    elseif
        self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS or
            self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS or
            self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE or
            self.m_mode == GlobalConfig.BATTLE_MODE.LEGEND or
            self.m_mode == GlobalConfig.BATTLE_MODE.RAID or
            self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or
            self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD or
            self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or
            self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or
            self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE or
                self.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS or
                self.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE
     then -- 世界boss
        return "?????"
    else
        if self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
                or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA 
                or self.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD 
                or self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA 
                or self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE 
                or self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
                or self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA then --高阶竞技场，计算当前队伍战力
            sub_combate = self:getCurEnemyTeamCombat()
        elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE then
            sub_combate = self.m_combat_gve_battle or "0" -- 奇门遁甲挂卡综合战力
        else
            if self.m_def_data and next(self.m_def_data) and self.m_def_data.heros ~= nil then
                for k, v in pairs(self.m_def_data.heros) do
                    local c_combat = v.combat
                    if c_combat == nil then
                        c_combat = UserDataManager:computeHeroCombat(v, nil, false, self.m_def_data)
                    end
                    sub_combate = sub_combate + c_combat
                end
            else
                if self.m_battle_id then
                    sub_combate = UserDataManager:computStageBattleCombat(self.m_battle_id)
                end
            end
        end
    end
    sub_combate = math.ceil(sub_combate)
    return GameUtil:formatValueToString(sub_combate)
end

function M:getCurEnemyTeamCombat()
    local cur_team = self.m_def_data.teams[self.m_formation_index] or {}
    local sub_combate = 0
    for k,v in pairs(cur_team) do
        if self.m_def_data.heros[v] then
            local hero_data = self.m_def_data.heros[v]
            if hero_data then
                local c_combat = hero_data.combat
                if c_combat == nil then
                    c_combat = UserDataManager:computeHeroCombat(hero_data, nil, false, self.m_def_data)
                end
                sub_combate = sub_combate + c_combat
            end
        end
    end
    return sub_combate
end


function M:calculateCombat(data, hp_coef, dps)
    local enemy_data = UserDataManager.hero_data:getHeroConfigByCid(data.id) --英雄配置信息
    local new_attrs = UserDataManager:computCfgAttrs(enemy_data, data.lv, data.evo, hp_coef, dps)
    local all_attr = {}
    if #data.equips > 0 then
        for i = 1, 5 do
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

--检查当前buff级别
function M:getAddBuffLv()
    local res1, res2, race1, race2 = self:checkArray()
    return {lv1 = res1, lv2 = res2, race1 = race1, race2 = race2}
end

--检查敌人buff级别
function M:getEnemyAddBuffLv()
    local res1, res2, race1, race2 = self:checkEnemyArray()
    return {lv1 = res1, lv2 = res2, race1 = race1, race2 = race2}
end

--检查是否有相同编队
function M:checkSameBd()
    local f_tab = table.copy(UserDataManager.hero_data:getFormation())
    for k, v in pairs(f_tab) do
        local index = tostring(self.m_formation_id) --不检查相同编队
        if index == k then
            return
        end
        if self:check(v.team, self.main_team) then
            return true
        end
    end
    return false
end

function M:check(t1, t2)
    local new_tab = {}
    for k, v in pairs(t1) do
        if self:checkA(t2, v) then
            table.insert(new_tab, v)
        end
    end
    if #new_tab == #t2 then
        return true
    end
    return false
end

function M:checkA(t1, b)
    for k, v in pairs(t1) do
        if v ~= "" and v == b then
            return true
        end
    end
    return false
end

-- 我方英雄属性加成
function M:checkArray()
    local plyDataList = {}
    for k, v in pairs(self.main_team) do
        local data, cfg = self:getHero(v)
        table.insert(plyDataList, cfg)
    end
    local res1, res2, race1, race2 = GlobalTools:checkArray(plyDataList, 1)
    return res1, res2, race1, race2
end

-- 敌方英雄属性加成
function M:checkEnemyArray()
    local enemyDataList = {}
    if self.m_def_data and next(self.m_def_data) ~= nil and self.m_def_data.heros then
        local team = nil
        if self.m_def_data.teams then
            team = self.m_def_data.teams[self.m_formation_index or 1]
        else
            team = self.m_def_data.team
        end
        
        if team then
            for k, v in pairs(team) do
                if v and v ~= "" then
                    local hero_data = self.m_def_data.heros[v]
                    if hero_data then
                        local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
                        table.insert(enemyDataList, cfg)
                    end
                end
            end
        end
    else
        --local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
        local battle_data = ConfigManager:getCfgStageBattle(self.m_battle_id)--stage_battle_tab[self.m_battle_id]
        if battle_data then
            local monsters = battle_data["monster"]
            for k, v in pairs(monsters) do
                local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
                table.insert(enemyDataList, cfg)
            end
        end
    end
    local res1, res2, race1, race2 = GlobalTools:checkArray(enemyDataList, -1)
    return res1, res2, race1, race2
end

function M:setMultTeamData(mult_main_teams)
    if mult_main_teams then
        self.mult_main_teams = mult_main_teams
        self:changeMultTeamData(self.m_formation_index)
    end
end

function M:changeMultTeamData(index)
    self.m_formation_index = index
    self.main_team = self.mult_main_teams[self.m_formation_index] or {}
    self.temp_team = self.mult_main_teams[self.m_formation_index] or {}
    self.m_atk_deployment = self.m_mult_deployments[self.m_formation_index] or {}
    self.m_select_heaven_id = self.m_mult_normal_array[self.m_formation_index] or 0
    if self.m_mode ~= GlobalConfig.BATTLE_MODE.MULT_STAGE and self.m_mode ~= GlobalConfig.BATTLE_MODE.GU_JIAN_MULT and self.m_mode ~= GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
        self.m_def_deployment = self.m_def_mult_deployments[self.m_formation_index] or 1
    end
    self:checkHero()
end

function M:changeUnionWarTeamData(index)
    self.m_formation_index = index
    local select_team = self.union_war_teams[tostring(self.m_formation_index)]
    if select_team ~= nil then
        self.main_team = table.copy(select_team.team)
        self.temp_team = table.copy(select_team.team)
        self.m_select_heaven_id = self.m_mult_normal_array[self.m_formation_index] or 0
        self.m_atk_deployment = select_team.deployment or 1
    else
        self.main_team = {}
        self.temp_team = {}
        self.m_atk_deployment = 1
    end
    self:checkHero()
end

function M:changeMiningDefenseTeamData(index)
    self.m_formation_index = index
    if self.mining_defense_teams[self.m_formation_index] ~= nil then
        self.main_team = table.copy(self.mining_defense_teams[self.m_formation_index])
        self.temp_team = table.copy(self.mining_defense_teams[self.m_formation_index])
    else
        self.main_team = {}
        self.temp_team = {}
    end
    self:checkHero()
end

function M:checkUnionTeamChange()
    if self.union_war_teams[tostring(self.m_formation_index)] ~= nil then
        return self:checkTeamsHero(self.main_team, self.union_war_teams[tostring(self.m_formation_index)].team)
    else
        return true
    end
    return false
end

-- 检测公会战队伍中是否有空位置
function M:checkUnionTeamHasNull()
    local has_null_flag = false
    for i = 1, 3 do
        local team_item = self.union_war_teams[tostring(i)]
        if team_item and team_item.team then
            local full_hero = true
            for team_idx = 1, 5 do
                local id = team_item.team[team_idx]
                if id == nil or id == "" then
                    full_hero = false
                end
            end
            if not full_hero then
                has_null_flag = true
                break
            end
        else
            has_null_flag = true
            break
        end
    end
    return has_null_flag
end

function M:checkMiningDefenseTeamChange()
    if self.mining_defense_teams[self.m_formation_index] ~= nil then
        return self:checkTeamsHero(self.main_team, self.mining_defense_teams[self.m_formation_index])
    else
        return false
    end
    return false
end

--检查队伍英雄是否改变
function M:checkTeamsHero(team_1, team_2)
    if tonumber(team_1) ~= tonumber(team_2) then
        return false
    end
    for k, v in pairs(team_1) do
        if v ~= team_2[k] then
            return true
        end
    end
    return false
end

function M:getMultTeamParam()
    local can_set = false
    local teams = {}
    local mult_main_teams = self.mult_main_teams or {}
    --local deployments = {}
    --local mult_deployments = self.m_mult_deployments or {}
    local boundry_up = self.m_team_nums
    for idx = 1, boundry_up do
        local one_team = mult_main_teams[idx] or {}
        local team = {}
        for i = 1, 5 do
            team[i] = one_team[i] or ""
            if team[i] ~= "" then
                can_set = true
            end
        end
        teams[idx] = team
        --deployments[idx] = mult_deployments[idx] or 1
    end
    return teams, can_set
end

function M:isAdditionRace(race)
    for k, v in pairs(self.m_addition_race or {}) do
        if v == race then
            return true
        end
    end
    return false
end

function M:heroIsDie(oid)
    local flag = false
    local hero_dyns = self.m_dyns[oid] or {}
    local hp_pct = hero_dyns.hp_pct or 1024000
    return hp_pct <= 0, hero_dyns
end

function M:heroIsDeath(oid)
    local flag = false
    if self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then -- 
        for k,v in pairs(self.m_death_hero_oids) do
            if v == oid then
                return true
            end
        end
    end
    return flag
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
end

function M:updateAtkDeployment(id)
    if self.m_mult_team_flag then
        self.m_mult_deployments[self.m_formation_index] = id
    end
    self.m_atk_deployment = id
end

function M:initStageBattleId()
    local battle_id = -1
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE then -- 推图
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        battle_id = data["battle_id"]
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then --多队推图
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        local battle_id_tab = data["battle"] or {}
        battle_id = battle_id_tab[self.m_formation_index] or self.m_battle_id
        self.m_battle_id_tab = battle_id_tab
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then --古剑奇谭，多队伍
        local stage_tab = ConfigManager:getCfgByName("sword_main")
        local data = stage_tab[self.m_stage_id]
        local battle_id_tab = data["battle_id"] or {}
        battle_id = battle_id_tab[self.m_formation_index] or self.m_battle_id
        self.m_battle_id_tab = battle_id_tab
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then --爬塔
        local race = self.m_race
        local tower_floor = UserDataManager:getRaceFloorByRace(race)
        local tower_stage_item = ConfigManager:getTowerStageCfgByRaceAndId(race, tower_floor)
        battle_id = tower_stage_item.battle_id or -1
    --elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACCON  then --小浣熊
        --local stage_tab = ConfigManager:getCfgByName("raccon_biography_stage") or {}
        --local data = stage_tab[self.m_stage_id] or {}
        --battle_id = data["battle_id"] or -1

    elseif self.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
        local stage_tab = ConfigManager:getCfgByName("hero_isle_layer")
        local data = stage_tab[self.m_layer]
        local battle_id_tab = data["battles"] or {}
        battle_id = battle_id_tab[self.m_formation_index] or self.m_battle_id
        self.m_battle_id_tab = battle_id_tab
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO then
        local stage_tab = ConfigManager:getCfgByName("hero_isle_layer")
        local data = stage_tab[self.m_layer]
        local battle_id_tab = data["battles"] or {}
        battle_id = battle_id_tab[1] or self.m_battle_id
    else
        battle_id = self.m_battle_id or battle_id
    end
    --local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
    local battle_data = ConfigManager:getCfgStageBattle(battle_id)--stage_battle_tab[battle_id]
    if battle_data == nil then
        if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
            local mult_stage_battle_tab = ConfigManager:getCfgByName("stage_battle" .. (self.m_formation_index == 1 and "" or self.m_formation_index)) or {}
            battle_data = mult_stage_battle_tab[battle_id]
        elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
            local mult_stage_battle_tab = ConfigManager:getCfgByName("stage_battle" .. (self.m_formation_index == 1 and "" or self.m_formation_index)) or {}
            battle_data = mult_stage_battle_tab[battle_id]
        end
    end
    if battle_data then
        self.m_def_deployment = battle_data.deployment or 1
        self.m_battle_id = battle_id
    end
end

function M:getStageBattleName()
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE  then -- 推图
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        return Language:getTextByKey(data["map_point_name"])
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOWER then -- 天机楼
        return Language:getTextByKey("world_str_009").."：".. Language:getTextByKey("budo_str_001",self.m_budo_floor)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then -- 种族塔    
        return Language:getTextByKey("new_str_0869",self.m_budo_floor)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then -- 种族塔    
        return Language:getTextByKey("budoServer_text_0007").."：".. Language:getTextByKey("budo_str_001",self.m_budo_floor)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then --古剑奇谭
        local stage = ConfigManager:getCfgByName("sword_main")
        local stage_cfg = stage[self.m_stage_id or 1] or {}
        return Language:getTextByKey(stage_cfg.name) or ""
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACCON then --古剑奇谭
        local stage = ConfigManager:getCfgByName("raccon_biography_stage") or {}
        local stage_cfg = stage[self.m_stage_id or 1] or {}
        return Language:getTextByKey(stage_cfg.name) or ""
    end
end

-- 检查英雄数据
function M:checkHero()
    if self.m_mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI then 
        for k, v in pairs(self.main_team or {}) do
            if v ~= "" then
                local data, cfg = self:getHero(v)
                if data == nil then
                    self.main_team[k] = ""
                elseif data.apostle_flag or data.mastor_apostle_flag or data.novice_apostle_flag then
                    if self:inquireApostleTimes(v) == true then
                        self.main_team[k] = ""
                    end
                end
    
                if self.m_lock_job then -- 去掉锁定的职业
                    if self:checkIsLockJob(v) then
                        self.main_team[k] = ""
                    end
                end
                --已经在助战系统中上阵的侠客不能参与布阵
                if self:heroIsInsupport() then
                    if self:checkIsInSupport(v) then
                        self.main_team[k] = ""
                    end
                end
            end
        end
    end
end

function M:checkMultHero(to_change_team)
    local function check_hero_in_team(teams, oid)
        for k, v in pairs(teams) do
            if v == oid then
                return true
            end
        end
        return false
    end
    
    for team_index, teams in pairs(self.mult_main_teams or {}) do
        if team_index ~= self.m_formation_index then
            for k, v in pairs(teams or {}) do
                if v ~= "" then
                    local is_in_team = check_hero_in_team(to_change_team, v)
                    if is_in_team  then
                        return false
                    end
                    local data, cfg = self:getHero(v)
                    if data == nil then
                        self.main_team[k] = ""
                    elseif data.apostle_flag or data.mastor_apostle_flag or data.novice_apostle_flag then
                        if self:inquireApostleTimes(v) == true then
                            self.main_team[k] = ""
                        end
                    end
                end
            end
        end
    end
    return true
end

function M:getDefByFloor(index, floor)
    --local stage_battle = ConfigManager:getCfgByName("stage_battle")
    local four_tower_stage = ConfigManager:getCfgByName("four_tower_stage")
    local floor_data = four_tower_stage[floor]
    if index == 0 then
        --boss
        local b_id = floor_data.boss_id
        --Logger.logError(floor_data," floor_data floor =  "..floor.."  ")
        return ConfigManager:getCfgStageBattle(b_id)--stage_battle[b_id]
    else
        local b_ids = floor_data["battle_id_list"]
        --Logger.logError(floor_data," floor_data floor =  "..floor.."  ")
        return ConfigManager:getCfgStageBattle(b_ids[index])--stage_battle[b_ids[index]]
    end
end

function M:getSaveTeamBtnShow()
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode] or {}
    return self.m_formation_id > 0 or battle_mode_cfg_item.show_save_team_btn == true or
        self.m_sel_formation_index ~= nil
end

-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio()
    local team = UserDataManager.hero_data:getTeamByKey("maze") or {}
    local assist_heros = self.m_assist_heros or {} --雇佣的英雄
    local heirlooms = self.m_heirlooms or {}
    return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

function M:checkTeamChange()
    for k, v in pairs(self.main_team) do
        local temp_data = self.temp_team[k]
        if v ~= temp_data then
            return true
        end
    end
    return false
end

--
function M:checkRaceTypeCount(race)
    local usethisRace = true
    if self.m_races ~= nil then
        usethisRace = false
        for i, v in ipairs(self.m_races) do
            if v == race then
                usethisRace = true
                break
            end
        end
    end

    if usethisRace == true then
        local hero_ids = self:getAllHeroIds()
        for k, v in pairs(hero_ids) do
            local l_hero_data, l_hero_cfg = self:getHero(v)
            if (l_hero_cfg ~= nil and race == l_hero_cfg.race) then
                return true
            end
        end
        for k, v in pairs(self.m_assist_heros) do
            local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
            local is_die, _ = self:heroIsDie(k)
            local id_death = self:heroIsDeath(k)
            if (hero_cfg ~= nil and race == hero_cfg.race) and not is_die and not id_death then
                return true
            end
        end
        for k, v in pairs(self.m_legend_heros) do
            local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
            local is_die, _ = self:heroIsDie(k)
            local id_death = self:heroIsDeath(k)
            if (hero_cfg ~= nil and race == hero_cfg.race) and not is_die and not id_death then
                return true
            end
        end
    end
    return false
end

function M:getBuffNum(id, isPercent)
    if isPercent == nil then
        isPercent = true
    end
    local common = Battle.BattleGlobalConfig.ARRAY_ADDITION[id]
    local new_tab = {}
    if id < 10 then
        local data = ConfigManager:getBattleCommonValueById(common, {})
        for k, v in pairs(data) do
            if isPercent == true then
                new_tab[k] = v * 100
            else
                new_tab[k] = v
            end
        end
    else
        local data = ConfigManager:getBattleCommonValueById(common, 0)
        if isPercent == true then
            table.insert(new_tab, data * 100)
        else
            table.insert(new_tab, data)
        end
    end
    return new_tab
end

--显示过关阵容按钮
function M:showArrayBtn()
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode] or {}
    return battle_mode_cfg_item.show_formation_pass_btn == true
end

function M:changeMultiFormation(index)
    self.m_sel_formation_index = index
    self.m_formation_id = index
    self.m_temp_atk_deployment = self.m_atk_deployment
    self:changeTeamByMultiFormation(index)
end

function M:changeTeamByMultiFormation(index)
    self.m_team_changed_flag = true
    self.m_temp_main_team = self.main_team
    local formation = UserDataManager.hero_data:getFormation()
    local index_str = tostring(index)
    local can_change = true
    if formation[index_str] and formation[index_str].team then
        if (self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and not(self.m_mult_team_edit_flag) then
            can_change = self:checkMultHero(formation[index_str].team)
        end
        if not can_change then
            return can_change
        end
        self.main_team = table.copy(formation[index_str].team)
        if (self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and self.mult_main_teams  then
            self.mult_main_teams[self.m_formation_index] = table.copy(formation[index_str].team)
        end
        self.m_atk_deployment = formation[index_str].deployment
        self.m_team_changed_flag = true
    else
        self.main_team = {}
        self.m_atk_deployment = 1
    end
    
    self:checkHero()
    return can_change
end

function M:resetMainTeam()
    self.m_team_changed_flag = true
    self.m_temp_main_team = self.main_team
    self.m_sel_formation_index = nil
    self.m_formation_id = 0
    self:initMainTeam()
end

--是否有可上阵英雄
function M:isHaveInToHero()
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI or self.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA then
        return false
    end
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
        return self:checkIsCanInToUp() == true
    end
    if self.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER then
        
    end

    if self:inquireVacancy() == false then
        return false
    end
    local hero_ids = table.copy(self:getAllHeroIds())
    for k, v in pairs(hero_ids) do
        if self:inquireInTeams(v) == false and self:checkIsInTeam(v) == false then
            return true
        end
    end
    return false
end

--获取当前阵容中除阴阳外可上阵的数量
function M:getOtherCanUpNums()
    local yin_nums = self.m_race_nums_tab[6] or 0
    local yang_nums = self.m_race_nums_tab[5] or 0
    local can_up_nums = 5 - yin_nums - yang_nums
    for k, v in pairs(self.main_team) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            if hero_cfg.race ~=5 and hero_cfg.race ~= 6  then
                can_up_nums = can_up_nums - 1
            end
        end
    end
    return can_up_nums
end

function M:getCurRaceNums()
    local race_nums = {}
    for k, v in pairs(self.main_team) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            if race_nums[tostring(hero_cfg.race)] == nil then
                race_nums[tostring(hero_cfg.race)] = 1
            else
                race_nums[tostring(hero_cfg.race)] = race_nums[tostring(hero_cfg.race)] + 1
            end
        end
    end
    return race_nums
end

function M:checkRaceNumsByHeroId(hero_id)
    local race_nums_tab = self:getCurRaceNums()
    local race_key, race_num = nil, nil
    local can_use = true
    local limit_num = 0
    local _, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
    race_key = hero_cfg.race
    local cur_other_nums = self:getOtherCanUpNums()
    if race_key ~= 7 then
        if race_nums_tab[tostring(hero_cfg.race)] == nil then
            race_num = 1
        else
            race_num = race_nums_tab[tostring(hero_cfg.race)] + 1
        end
        limit_num = self.m_race_nums_tab[race_key] or 0
        if limit_num < race_num or (race_key < 5 and cur_other_nums <= 0) then
            can_use = false
        end
    elseif race_key == 7 then
        can_use = cur_other_nums > 0
    end
    
    return can_use, race_key, limit_num
end

function M:checkIsActiveTeam()
    if self.activeTeamBl == false then
        self.activeTeamBl = true
        return true
    else
        return false
    end
    return false
end

function M:setUnionWarTeam()
    -- 如果帮会战,从原队伍中清掉
    if self:showUnionWarTeamsMultBtn() then
        local strKey = tostring(self.m_formation_index)
        if not self.union_war_teams[strKey] then
            self.union_war_teams[strKey] = { team = {
                [1] = "",
                [2] = "",
                [3] = "",
                [4] = "",
                [5] = ""
            }}

        end
        for k, v in pairs(self.main_team) do
            for m, n in pairs(self.union_war_teams) do
                --更新当前队伍
                if self.m_formation_index == tonumber(m) then
                    for i = 1, 5 do
                        if self.main_team[i] then
                            self.union_war_teams[m].team[i] = self.main_team[i]
                        else
                            if self.union_war_teams[m].team[i] then
                                self.union_war_teams[m].team[i] = ""
                            end
                        end
                    end
                else
                    --移除原位置
                    for key, val in pairs(n.team) do
                        if val ~= "" and val == v then
                            self.union_war_teams[m].team[key] = ""
                        end
                    end
                end
            end
        end
    end
end

function M:seMiningDefenseTeam()
    -- 如果帮会战,从原队伍中清掉
    if self.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE then
        for k, v in pairs(self.main_team) do
            for m, n in pairs(self.mining_defense_teams) do
                --更新当前队伍
                if self.m_formation_index == tonumber(m) then
                    for i = 1, 5 do
                        if self.main_team[i] then
                            self.mining_defense_teams[m][i] = self.main_team[i]
                        else
                            if self.mining_defense_teams[m][i] then
                                self.mining_defense_teams[m][i] = ""
                            end
                        end
                    end
                else
                    --移除原位置
                    for key, val in pairs(n) do
                        if val ~= "" and val == v then
                            self.mining_defense_teams[m][key] = ""
                        end
                    end
                end
            end
        end
    end
end

function M:showMultiFormationNodeFlag()
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
        return false
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE then
        return false
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
        return false
    end
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(24)
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode] or {}
    local showNode = open_flag and self.m_bottom_type == 0 and battle_mode_cfg_item.show_multi_formation ~= false
    return showNode
end

function M:showFormationSkipBtn()
    local show_btn = GlobalConfig.BATTLE_MODE_CFG[self.m_mode].show_formation_skip_btn == true
    return show_btn
end

function M:switchFormationSkipBattle()
    self.m_formation_skip_battle = self.m_formation_skip_battle == 0 and 1 or 0
    UserDataManager.local_data:setUserDataByKey("formation_skip_battle", self.m_formation_skip_battle)
end

--上阵的英雄数量上限
function M:checkStageUpNum()
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
        local tower_stage_tab = ConfigManager:getCfgByName("tower_stage")
        local tower_cfg = tower_stage_tab[self.m_race]
        if tower_cfg == nil then
            Logger.logErrorAlways(tower_stage_tab, "tower_stage----表数据错误" .. self.m_race or 0)
            return 5
        end
        local tower_floor = tower_cfg[self.m_budo_floor]
        if tower_floor then
            return tower_floor.hero_num
        end
        Logger.logErrorAlways(tower_cfg, "tower_cfg----层数数据错误" .. self.m_budo_floor or 0)
        return 5
    else
        return 5
    end
end

--上阵的英雄数量
function M:getInToHeros()
    local num = 0
    for k, v in pairs(self.main_team) do
        if v ~= "" then
            num = num + 1
        end
    end
    return num
end

--是否可上阵
function M:checkIsCanInToUp()
    if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
        if self:getInToHeros() >= self:checkStageUpNum() then
            return false
        end
    end
    return true
end

--种族塔挑战次数
function M:getRaceTowerAttackNum()
    if self.m_race == 0 then
        return true
    end
    local tower_tab = ConfigManager:getCfgByName("tower_race")
    local tower_cfg = tower_tab[self.m_race]
    local use_num = UserDataManager.race_floor_times[tostring(self.m_race)] or 0
    if tower_cfg.floors_per_day - use_num <= 0 then
        return false
    end
    return true
end

function M:getXiaKeDaoLoseNum()
    return self.m_lose_num<=0
end

function M:isUnionWarTeams()
    return self.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE or
        self.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK 
end

function M:showUnionWarTeamsMultBtn()
    return self:isUnionWarTeams() or self.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR
end

function M:needFormationTipsFlag()
    if self.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
        local atk_lock = self.m_params.gvg_data.atk_lock
        return not atk_lock
    end
    return true
end

--法宝槽位
function M:getWeaSolt()
    local slots = table.copy(UserDataManager.m_slots)
    return slots or {}
end

--多阵容法宝槽位
function M:getWeaMultSolt()
    local m_mult_relics = table.copy(UserDataManager.m_mult_relics)
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode]
    local team_key = battle_mode_cfg_item.team_key
    local mult_relics = m_mult_relics[team_key] or {}
    if next(mult_relics) == nil then
        mult_relics[1] = self:getWeaSolt()
    end
    return mult_relics
end

function M:setWeaMultSolt(mult_solts)
    if mult_solts then
        self.m_mult_solts = mult_solts
        self:changeMultTeamData(self.m_formation_index)
    end
end

--获得槽位上的法宝
function M:getCurSoltWea(index)
    local cur_id = self:getDressedWeaByIndex(index)
    local treasure_cfg = self:getTreasurePosition(index)
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    local ids = {}
    local treasure = {}
    local seascon = UserDataManager:getCurSeason()
    if treasure_cfg.treasure_s and treasure_cfg.treasure_s[seascon] then
        treasure = treasure_cfg.treasure_s[seascon]
    else
        treasure = treasure_cfg.treasure
    end
    for k,v in ipairs(treasure) do
        if tab_cfg[v] then 
            table.insert(ids,v)
        end
    end
    local show_ids = {}
    for k ,v in pairs(ids) do
        if self:WeaponBangType(v) == true then
            table.insert(show_ids, v)
        end
    end
    if cur_id == 0 then
        table.insert(show_ids, 0)
    end
    local function sortFunc(id_one, id_two)
        local select_id_1 = id_one == cur_id and 1 or 0
        local select_id_2 = id_two == cur_id and 1 or 0
        if select_id_1 == select_id_2 then
            return id_one < id_two
        else
            return select_id_1 > select_id_2
        end
    end
    table.sort(show_ids,sortFunc)
    return show_ids
end

--帮会法宝开启状态 帮会法宝只有获得之后才会显示
function M:WeaponBangType(wea_id)
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    if tab_cfg[wea_id] == nil then
        Logger.logError(" 法宝 id = "..tostring(wea_id).." 没有找到 ")
        return false
    end


    local cur_wea_cfg = tab_cfg[wea_id]
    if cur_wea_cfg.type == 1 then  --普通法宝不需要检测
        return true
    end
	--奇门遁甲开启
    if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER and cur_wea_cfg.type == 2 then
        return false
    end
    
	if BtnOpenUtil:isBtnOpen(246) == true then
		return true
	end
	return false
end


--多阵容 获得槽位上的法宝
function M:getMultCurSoltWea(index)
    local mult_solt = self.m_mult_solts[self.m_formation_index] or {}
    local cur_id = mult_solt[tostring(index)] or 0
    local treasure_cfg = self:getTreasurePosition(index)
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    local ids = {}
    local treasure = {}
    local seascon = UserDataManager:getCurSeason()
    if treasure_cfg.treasure_s and treasure_cfg.treasure_s[seascon] then
        treasure = treasure_cfg.treasure_s[seascon]
    else
        treasure = treasure_cfg.treasure
    end
    for k,v in ipairs(treasure) do
        if tab_cfg[v] then 
            table.insert(ids,v)
        end
    end
    if cur_id == 0 then
        table.insert(ids, 0)
        local function sortFunc(id_one, id_two)
            return id_one < id_two
        end
        table.sort(ids,sortFunc)
    else
        local function sortFunc(id_one, id_two)
            local select_id_1 = id_one == cur_id and 1 or 0
            local select_id_2 = id_two == cur_id and 1 or 0
            if select_id_1 == select_id_2 then
                return id_one < id_two
            else
                return select_id_1 > select_id_2
            end
        end
        table.sort(ids,sortFunc)
    end
    return ids
end

--替换多阵容穿着的法宝
function M:replaceMultWea(wea_id)
    for k,v in pairs(self.m_mult_solts) do
        for kk,vv in pairs(v) do
            if vv == wea_id then
                self.m_mult_solts[k][kk] = 0
                return
            end
        end
    end
end

--多阵容获取身上的法宝
function M:getMultDressedWeaByIndex(index)
    local mult_solt = self.m_mult_solts[self.m_formation_index] or {}
    return mult_solt[tostring(index)] or 0
end

--获取法宝属于的队伍
function M:getMultWeaTeamIndex(wea_id)
    for k,v in pairs(self.m_mult_solts) do
        for kk,vv in pairs(v) do
            if vv == wea_id then
                return k
            end
        end
    end
    return 0
end

--获取身上的法宝
function M:getDressedWeaByIndex(index)
    return self.m_solts[tostring(index)]
end

--法宝槽位
function M:getTreasurePosition(index)
	local tab_cfg = ConfigManager:getCfgByName("treasure_position")
	return tab_cfg[index]
end


--法宝数据
function M:getWeaRelics(id)
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    if tab_cfg[id] == nil then
        Logger.logError(" 法宝 id = "..tostring(id).." 没有找到 ")
    end
    local w_data = {}
    if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
        w_data = table.copy(UserDataManager.m_relics[tostring(id)]) or {}
        local max_lv = 10
        if tab_cfg[id] and tab_cfg[id].detail then
            max_lv = #(tab_cfg[id].detail)
        end
        w_data.lv = max_lv
    else
        w_data = UserDataManager.m_relics[tostring(id)]
    end
    return w_data, tab_cfg[id]
end

function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[id]
end

--检查法宝是否开启
function M:checkWeaOpen()
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then --斗技
        return false
    end
    if self.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then --帮会战并且已开战
        local atk_use = self.m_params.gvg_data.atk_use
        if atk_use and next(atk_use) then
           return false  
        end
    end
    local solt = self:getWeaSolt()
    if next(solt) == nil then
        return false
    end
    local bl = BtnOpenUtil:isBtnOpen(190)
    if bl == true then
        local top_hero = UserDataManager.hero_data:getLevelTop()
        if next(top_hero) == nil then
            return true
        end
        local lock_lv = ConfigManager:getCommonValueById(577,160) 
        if #top_hero >= 5 then
            local cur_data = top_hero[5]
            if cur_data[2] >= lock_lv then
                return true	 
            end	
        end   
    end
    return false
end

--获取解锁的槽位数量
function M:getTreasurePosNum()
    local solts = self:getWeaSolt()
    return table.nums(solts) 
end

--检查是否显示关卡进度/天机楼进度
function M:checkShowStageName()
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE 
        or self.m_mode == GlobalConfig.BATTLE_MODE.TOWER
        or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER 
        or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER 
        or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE
        or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
    then
        return true
    else
        return false    
    end
end

--根据限制阵营检查能不能上元阵营
function M:CanInsertRace7(races)
    local hv_normal_race = false
    for k,v in pairs(races) do
        if v >= 1 and v<= 4 then
            hv_normal_race = true
        end
    end
    --限制阵营必须有普通种族才能上元
    return hv_normal_race
end


--赛季buff是否开启
function M:checkSeasonBuffOpen()
    return BtnOpenUtil:isBtnOpen(336)
end

function M:initSeasonBuffHeros()
    local season_notice_tab = ConfigManager:getCfgByName("season_notice")
    local season = UserDataManager:getCurSeason()
    local sea_notice = season_notice_tab[season]
    if self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA or --争锋论剑
        self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA or --地赛
        self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA or --天赛
        self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA or --联赛
        self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA or --演武
        self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE or --争锋论剑防守
        self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE or --地赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or --天赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE or --联赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE --演武防守
    then
        if sea_notice and next(sea_notice) then
            self.m_season_ids = sea_notice.hero or {}
            self.m_additions = sea_notice.addition or {}
        else
            self.m_season_ids = {}  
            self.m_additions = {}  
        end
    else
        self.m_season_ids = {}  
        self.m_additions = {}   
    end
end

function M:checkSeasonBuffByHero(id)
    for k,v in pairs( self.m_season_ids) do
        if id == v then
            if next(self.m_additions) ~= nil then
                if self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE --争锋论剑
                then
                    return self.m_additions[1]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE --地赛
                then
                    return self.m_additions[2]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE --天赛
                then
                    return self.m_additions[3]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE --联赛
                then
                    return self.m_additions[4]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE --演武
                then
                    return self.m_additions[5]
                end
            else
                return 0
            end
        end
    end
    return 0
end

--阵法开启
function M:isOpenHeaven()
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        return false
    end
    return BtnOpenUtil:isBtnOpen(338)
end

--获得激活的战阵，根据当前已经上阵的侠客
function M:checkActiveHeavens()
    local normal_array_tab = ConfigManager:getCfgByName("normal_array")
    local teams = {}
    for k, v in pairs(normal_array_tab) do
        local array = table.keys(v)
        local function sortFunc(a, b)
            return a > b --倒序
        end
        table.sort(array, sortFunc)
        for i = 1, #array do
            local id = array[i]
            local data = v[id]
            local is_active = self:checkActiveHeavenTeam(data.activate_array)
            if is_active == true then
                local team = {} --重新组织数据
                team.id = k --组id
                team.active_id = id --激活的阵法id
                team.active_data = data --激活的阵法数据，icon、name
                team.lv = UserDataManager.m_normal_teams_lv[tostring(k)] or 1 --阵法等级
                team.active_effect = self:getHeavenEffect(id, team.lv) --激活的阵法效果，buffid、描述，战力百分比
                table.insert(teams, team)
                break
            end
        end
    end
    return teams
end

--阵法组条件达成
function M:checkActiveHeavenTeam(cond_array)
    --每个条件都去遍历上阵侠客，只要有一个侠客满足条件，即为本条件激活；如果所有上阵侠客都没能满足条件组中的任意一个条件，那该阵法就不算激活
    local team = table.copy(self.main_team)
    for l, cond in pairs(cond_array) do
        local is_cond_active = false
        if cond[1] == 4 then --条件4，上阵x个y品质的z型sp侠客
            is_cond_active = self:isReachHeroSPNum(cond[2], cond[3], cond[4])
        else
            local is_active = self:checkActiveHeavenCondition(cond, team)
            if is_active == true then
                is_cond_active = true
            end
        end
        if is_cond_active == false then
            return false --只要有一个条件没达成，则本法阵就算没激活
        end
    end
    return true
end

--阵法单个条件达成
function M:checkActiveHeavenCondition(cond, team)
    for k,v in pairs(team) do
        local hero, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero and hero_cfg then
            if cond[1] == 1 then --性别
                if cond[3] ==  hero_cfg.sex then
                    team[k] = ""
                    return true
                end
            elseif cond[1] == 2 then --职业
                if cond[3] == hero_cfg.role_type then
                    team[k] = ""
                    return true
                end
            elseif cond[1] == 3 then --特定英雄
                if cond[2] == hero_cfg.id and cond[3] <= hero.evo then
                    team[k] = ""
                    return true
                end
            end
        end
    end
    return false
end

--到达某个品质的上阵sp侠客数量
function M:isReachHeroSPNum(sp_type, evo, num)
    local heroes_oid = self.main_team --因为是上阵侠客，不可能重复，所以不用去重
    local sum = 0
    for k,v in pairs(heroes_oid) do
        local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero and cfg then
            --if cfg.is_sp and cfg.is_sp == sp_type then --test
            if cfg.is_sp and cfg.is_sp == sp_type and hero.evo >= evo then
                sum = sum + 1
                if sum >= num then
                    return true
                end
            end
        end
    end
    return false
end

--获得阵法效果，包括buffid、描述、战力百分比
function M:getHeavenEffect(id, level)
    local cfg = ConfigManager:getCfgByName("normal_effect")
    local c = cfg[id]
    if c ~= nil and c[level] ~= nil then
        return c[level]
    end
    return nil
end

--获取阵法战力加成
function M:getHeavenCombatAdd()
    if self:isOpenHeaven() == true then
        local heaven_team = self:getHeavenTeam(self.m_select_heaven_id)
        if heaven_team ~= nil and heaven_team.active_effect ~= nil then
            local combat_add = heaven_team.active_effect.combat
            return combat_add
        end
    end
    return 1
end

--更新激活的阵法数据，重新确定当前阵法组id
function M:updateHeaven()
    self.m_heaven_teams = self:checkActiveHeavens()
    if #self.m_heaven_teams <= 0 then
        self:setHeavenID(0)
        return
    end
    local heaven_team = self:getHeavenTeam(self.m_select_heaven_id)
    if heaven_team == nil then
        local id = self.m_heaven_teams[1].id
        self:setHeavenID(id)
    end
end

--获得阵法组
function M:getHeavenTeam(id)
    if id == 0 then
        return nil
    end
    for k,v in pairs(self.m_heaven_teams) do
        if v.id == id then
            return v
        end
    end
    return nil
end

--设置阵法组id
function M:setHeavenID(id)
    self.m_select_heaven_id = id
    if self.m_mult_team_flag == true then
        self.m_mult_normal_array[self.m_formation_index] = id
    else
        self.m_normal_array = id
    end
end

--格式化阵法条件
--为了处理类型4的情况
function M:formatCond(cond_array)
    local new_cond_array = {}
    for i, v in pairs(cond_array) do
        if v[1] == 4 and v[4] > 1 then
            for j = 1, v[4] do
                new_cond_array[#new_cond_array + 1] = {v[1], v[2], v[3], 1}
            end
        else
            new_cond_array[#new_cond_array + 1] = v
        end
    end
    return new_cond_array
end

--展示宠物功能
function M:showPets()
	if self.m_mode ~= GlobalConfig.BATTLE_MODE.TOP_ARENA and self.m_mode ~= GlobalConfig.BATTLE_MODE.TOP_ARENA_DEFENSE 
    and self.m_mode ~= GlobalConfig.BATTLE_MODE.MYTH_ARENA  and self.m_mode ~= GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE and 
    self.m_mode ~= GlobalConfig.BATTLE_MODE.LEGEND and  self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE and
    self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE and self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ONE
    and self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_THREE and self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE
    and self.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE and self.m_mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI
    and BtnOpenUtil:isBtnOpen(351) == true then
		return true
	end
    return false
end

function M:getPets()
    local formation_pets = {}
    local pets = UserDataManager.pet_data:getPetsId()
    for k,v in pairs(pets) do
        local data,_ = self:getPetData(v)
        if data.egg_ets == nil then
            table.insert(formation_pets, v)
        end
    end
    return formation_pets
end

function M:getPetData(oid)
    return UserDataManager.pet_data:getPetDataById(oid)
end

function M:getCurPet()
    if self.m_mult_team_flag == true then
        return self.m_mult_battle_pets[self.m_formation_index] or 0
    else
        return self.m_battle_pet 
    end
    return 0
end

function M:addPetInTeam(id)
    if self.m_mult_team_flag == true then
        self.m_mult_battle_pets[self.m_formation_index] = id
    else
        self.m_battle_pet = id
    end
end

function M:removePetInTeam(id)
    if self.m_mult_team_flag == true then
        self.m_mult_battle_pets[self.m_formation_index] = 0
    else
        self.m_battle_pet = 0
    end
end

--检查其他队伍中是否已有这个宠物
function M:checkPetIsInTeam(p_oid)
    if self.m_mult_team_flag == true then
        if p_oid == self:getCurPet() then
            return false
        end
        for k,v in pairs(self.m_mult_battle_pets) do
            if v == p_oid then
                return true
            end
        end
    end
    return false
end

--检查其他队伍中是否已有同类型宠物
function M:checkSameNmaePetIsInTeam(p_oid)
    local c_data,c_cfg = self:getPetData(p_oid)
    if self.m_mult_team_flag == true then
        for k,v in pairs(self.m_mult_battle_pets) do
            local data,cfg = self:getPetData(v)
            if p_oid ~= v and cfg and c_data and data and c_data.id  == data.id then
                return true
            end
        end
    else
        local data,cfg = self:getPetData(self.m_battle_pet)
        if p_oid ~= self.m_battle_pet and data and c_data and data.id  == c_data.id then
            return true
        end
    end
    return false
end

--检查其他队伍中是否已有同类型宠物斗技
function M:checkSameNmaePetIsInTeamByDouJi(p_oid)
    local c_data,c_cfg = self:getPetData(p_oid)
    if self.m_mult_team_flag == true then
        for k,v in pairs(self.m_mult_battle_pets) do
            local data,cfg = self:getPetData(v)
            if p_oid ~= v and cfg and c_data and data and c_data.id  == data.id then
                return true
            end
        end
    else
        local data,cfg = self:getPetData(self.m_battle_pet)
        if p_oid ~= self.m_battle_pet and data and c_data and data.id  == c_data.id then
            return true
        end
    end
    return false
end


function M:checkPetSkillType()
    local pet_id = self:getCurPet()
    if pet_id == 0 or pet_id == "" then
        return true
    end
    local c_data,c_cfg = self:getPetData(pet_id)
    local skill_id = 0
    local skill_type_2 = false --是否有协战技能
    if c_data then
        for k,v in pairs(c_data.skills) do
            if GameUtil:checkPetSkillType(v) == 2 then
                skill_type_2 = true
                skill_id = v
            end
        end  
    end
    return skill_type_2
end

--判断是否是PVP
function M:getPVPFlag()
    if self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI or self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA then
        return false
    end
    local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode]
    if battle_mode_cfg_item then
        if BtnOpenUtil:isBtnOpen(402) then
            return battle_mode_cfg_item.pvp or battle_mode_cfg_item.show_combat_repress    
        end         
    end
    Logger.log("GlobalConfig.BATTLE_MODE_CFG没有对应的mode" .. self.m_mode)
    return false
end

--判断是否有敌人的防守阵容
function M:getDefDataFlag()
    return self.m_def_data and next(self.m_def_data) and self.m_def_data.heros ~= nil
end

--获取英雄数据
function M:getHeroData(hero_id)
    local hero_cfg =UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    --获取道具人物头像数据
    local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
    itemData.quality = hero_cfg.evo;
    itemData.oid = hero_cfg.oid
    return itemData;
end

return M
