----------- Battle.BattleGlobalConfig
---@class BattleGlobalConfig
local M = {
    EVENT_KEYS = {
        DATA_UPDATE_EVENT = "data_update_event",
        NET_DATA_UPDATE_EVENT = "net_data_update_event",
        CLOSE_VIEW = "close_view",
        OPEN_VIEW = "open_view",
    },
    USE_REPLAY_FIX = false,  --使用回放校正功能
    BATTLE_VISION = "v1.9.6",
}

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
M.BATTLE_MODE = {
    --客户端，服务器公用
    STAGE = 1, -- 推图
    TOWER = 2, -- 爬塔
    RACE_TOWER = 3, -- 种族塔
    MAZE = 4, -- 迷宫
    LOCAL_ARENA = 5, -- 普通竞技场
    TOP_OF_TIME = 6, -- 时光之颠
    UNION_BOSS = 8, -- 公会boss
    HIGH_ARENA = 11, -- 高阶竞技场
    WORLD_BOSS = 14, -- 世界boss
    TOP_ARENA = 16, -- 巅峰论剑战斗阵容
    FIVE_ARRAY = 17, -- 五行阵
    BIG_MAP = 18, --大地图
    BIOGRAPHY = 20, --传记
    UNIONWAR = 21, -- 帮会战
    RACE_ARENA = 23, --种族竞技场 
    RAID = 24, --  武道场
    ACTIVE = 25, --侠客试炼活动 
    LEGEND = 26, --江湖传说
    MINING = 27, --苗疆觅宝
    TOP_RACE_ARENA = 28, --天级赛进攻阵容
    FOUR_TOWER  = 29, -- 四象阵
    FIVE_RACE_ARENA = 30,--五行联赛进攻阵容
    ACTIVE_TOWER = 31,--天机楼活动版
    GVE_BATTLE = 32, -- 奇门遁甲
    GVE_BATTLE_BOSS = 33, -- 奇门遁甲boss
    YINYANG_TOWER = 34,--极阴塔
    EVIL_SHADOW = 35,--邪极魅影
    MULT_STAGE = 36,--双队推图
    DRAGONSWORD = 37,--龙泉剑影
    HUASHAN_SWORD = 38,--华山论剑
    ACTIVE_MINING = 39, --夺宝奇兵
    GU_JIAN_MULT = 40,--古剑奇谭，双队伍
    WD_TOWER = 41, --罗天摘星
    GU_JIAN_MAZE = 42,--古剑奇谭，地宫战斗
    NEW_BIG_MAP = 43, -- 随机江湖大地图
    FULWIN_AREA_ATTACK_ONE = 44,--风云擂台, 单队
    FULWIN_AREA_ATTACK_THREE = 45,--风云擂台, 三队
    MYTH_ARENA = 46,--武林神话 进攻 
    GUILD_HIGH_WAR = 47,--巅峰帮会战
    ACTIVE_BOSS = 48,--通用活动boss
    RACCON = 49,--武林神话 进攻
    PET_DOUJI = 50, -- 宠物斗技
    SORT_CHIVALROUS = 51, -- 三侠五义
    COMMON_BATTLE = 52, -- 通用试炼
    SORT_FULL_SERVICE_BOSS = 53,--剑试天下-BOSS战
    SORT_FULL_SERVICE_POINT_RACE = 54, --剑试天下-积分赛
    TEAM_SORT_FULL_SERVICE_PROMOTION  = 55, --剑试天下-晋级赛
    AWAKE_SYSTEM = 56, --觉醒系统的入梦铃 
    XIAKEDAO = 57, --侠客岛
    XIAKEDAO_MULTI = 58, --侠客岛多队伍
   -- SORT_GUILD_WORLD_BOSS = 59, --帮会世界boss (越南版本53,59是互换的)
    ZF_ARENA = 60,--联赛争锋进攻阵容--单队
    ZF_ARENA_MUL = 61,--联赛争锋进攻阵容--多队
    HERO_FATE = 62,--侠客情缘
    HERO_BOSS_PVE = 63,--天府夺刀
    HERO_BOSS_PVP = 64,--天府夺刀
     RTA_ARENA=65,--剑出红蒙

    --客户端用，服务端不用
    HIGH_ARENA_DEFENSE = 400, -- 高阶竞技场防守阵容
    LOCAL_ARENA_DEFENSE = 401, -- 竞技场防守阵容
    RACE_ARENA_DEFENSE = 402, --种族竞技场防守阵容
    MULT_FORMATION = 403, -- 多编队
    MINING_DEFENSE = 404, -- 苗疆觅宝防守阵容
    TOP_RACE_ARENA_DEFENSE = 405, -- 天级赛防守阵容
    UNIONWAR_ATTACK = 406, -- 帮会战进攻队伍
    UNIONWAR_DEFENSE = 407, -- 帮会战防守
    TOP_ARENA_DEFENSE = 408, -- 巅峰论剑战斗阵容
    FIVE_RACE_ARENA_DEFENSE = 409,--五行联赛防守阵容
    QIMENDUNJIA = 410,      -- 奇门遁甲阵容
    HUASHAN_SWORD_DEFENSE = 411,      -- 华山论剑防守阵容
    ACTIVE_MINING_DEFENSE = 412, -- 夺宝奇兵防守阵容
    FULWIN_AREA_ONE = 413,  -- 风云擂台 单队防守阵容
    FULWIN_AREA_THREE = 414, -- 风云擂台 三队防守阵容
    FULWIN_AREA_ATTACK_LOCAL_ONE = 415,  -- 风云擂台 单队攻击阵容
    FULWIN_AREA_ATTACK_LOCAL_THREE = 416, -- 风云擂台 三队攻击阵容
    MYTH_ARENA_DEFENSE = 417, -- 武林神话防守阵容

    ZF_ARENA_DEFENSE=418,--联赛争锋防守阵容--单队
    ZF_ARENA_DEFENSE_MUL =419,--联赛争锋防守阵容--多队

    --五行阵boss
    FIVE_ARRAY_BOSS = 999,

    STAGE_SET_TEAM = 10001, --推图队伍设置
    GHOSTS_SHOW_SKILL = 10002, --
}

--[[
    pvp ： 是否和玩家对战
    team_key : 编队key
    default_team_key ： 默认的编队key
    create_enemy_type： 1 通过battle_id创建敌人 2 通过def_data创建敌人 3 多阵容创建敌人
    def_deployment : 敌人阵法id
    show_multi_formation ：是否显示预编队伍
    show_save_team_btn ： 显示保存队伍按钮 ， 现在true为隐藏挑战按钮逻辑， 无保存按钮
    show_formation_skip_btn ：是否显示战斗跳过按钮
    show_formation_pass_btn ：是否显示录像按钮
    show_restart_btn ：是否显示战斗暂停界面的重新开始按钮
    show_enemy : 显示敌人, 默认显示
    show_combat_repress : 是否显示战力压制的按钮
]]
M.BATTLE_MODE_CFG = {
    [M.BATTLE_MODE.STAGE] = {pvp = false, team_key = "stage", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = true}, -- 推图
    [M.BATTLE_MODE.TOWER] = {pvp = false, scene_id = 105, team_key = "stage", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = true}, -- 爬塔
    [M.BATTLE_MODE.RACE_TOWER] = {pvp = false, scene_id = 105, showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = true}, -- 种族塔
    [M.BATTLE_MODE.MAZE] = {pvp = false, scene_id = 103, showSkill3Effect = true, team_key = "maze", create_enemy_type = 2}, -- 迷宫
    [M.BATTLE_MODE.LOCAL_ARENA] = {pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_formation_skip_btn = true, team_key = "local_arena", create_enemy_type = 2}, -- 普通竞技场
    [M.BATTLE_MODE.RACE_ARENA] = {pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_formation_skip_btn = true, team_key = "race_arena", create_enemy_type = 2, show_multi_formation = false}, -- 种族竞技场
    [M.BATTLE_MODE.TOP_OF_TIME] = {pvp = false, scene_id = 101, showSkill3Effect = true, team_key = "rpg_map", create_enemy_type = 2}, -- 时光之颠
    [M.BATTLE_MODE.MULT_FORMATION] = {pvp = false, show_enemy = false, showSkill3Effect = true,show_combat_repress = true}, -- 多编队
    [M.BATTLE_MODE.HIGH_ARENA] = {create_enemy_type = 3, pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_multi_formation = false, show_result_bg = false, show_formation_skip_btn = true}, -- 高阶竞技场
    [M.BATTLE_MODE.HIGH_ARENA_DEFENSE] = {pvp = false, def_deployment = -1, showSkill3Effect = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 高阶竞技场防守阵容
    [M.BATTLE_MODE.TOP_ARENA_DEFENSE] = {pvp = false, team_key = "top_arena", showSkill3Effect = true, isAuto = true, def_deployment = -1, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 巅峰论剑防守阵容
    [M.BATTLE_MODE.TOP_ARENA] = {pvp = true, showSkill3Effect = true, show_restart_btn = false, team_key = "top_arena",isAuto = true, def_deployment = -1, show_multi_formation = false, show_save_team_btn = true, show_enemy = false}, -- 巅峰论剑阵容
    [M.BATTLE_MODE.LOCAL_ARENA_DEFENSE] = {pvp = false, team_key = "local_arena_defense", showSkill3Effect = true, def_deployment = -1, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 竞技场防守阵容
    [M.BATTLE_MODE.RACE_ARENA_DEFENSE] = {pvp = false, team_key = "race_arena_defense", showSkill3Effect = true, def_deployment = -1, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 种族竞技场防守阵容
    [M.BATTLE_MODE.WORLD_BOSS] = {pvp = false, scene_id = 109, showSkill3Effect = false, team_key = "world_boss", create_enemy_type = 1}, -- 世界boss
    [M.BATTLE_MODE.ACTIVE_BOSS] = {pvp = false, scene_id = 109, showSkill3Effect = false, team_key = "world_boss", create_enemy_type = 1}, -- 通用活动boss
    [M.BATTLE_MODE.UNION_BOSS] = {pvp = false, team_key = "guild_boss", showSkill3Effect = true, create_enemy_type = 1}, -- 公会boss
    [M.BATTLE_MODE.FIVE_ARRAY] = {pvp = false, scene_id = 107, team_key = "five_element", showSkill3Effect = true, default_team_key = "stage", create_enemy_type = 2,create_cfg_name = "mood_shadow_stage", show_formation_pass_btn = false}, -- 五行阵
    [M.BATTLE_MODE.BIG_MAP] = {pvp = false, show_restart_btn = false, team_key = "stage", showSkill3Effect = true, create_enemy_type = 1}, -- 大地图
    [M.BATTLE_MODE.BIOGRAPHY] = {pvp = false, team_key = "biography", showSkill3Effect = true, create_enemy_type = 1}, -- 传记
    [M.BATTLE_MODE.ACTIVE] = {pvp = false, team_key = "train_challenge", showSkill3Effect = false, create_enemy_type = 2, create_cfg_name = "stage_battle_active"}, --侠客试炼活动 --
    [M.BATTLE_MODE.STAGE_SET_TEAM] = {pvp = false, team_key = "stage", showSkill3Effect = true, show_save_team_btn = true, show_enemy = false}, -- 设置推图队伍
    [M.BATTLE_MODE.UNIONWAR] = {pvp = true, show_restart_btn = false, isAuto = true, showSkill3Effect = true, show_multi_formation = false, create_enemy_type = 2, show_result_bg = false, save_url_key = "gvg_set_atk_formation"}, -- 帮会战
    [M.BATTLE_MODE.UNIONWAR_DEFENSE] = {pvp = true,isAuto = true, showSkill3Effect = true, show_multi_formation = false, show_save_team_btn = true, save_url_key = "gvg_set_formation", show_enemy = false,show_combat_repress = true}, -- 帮会战防守
    [M.BATTLE_MODE.UNIONWAR_ATTACK] = {pvp = true,isAuto = true, showSkill3Effect = true, show_multi_formation = false, show_save_team_btn = true, save_url_key = "gvg_set_atk_formation", show_enemy = false,show_combat_repress = true}, -- 帮会战进攻
    [M.BATTLE_MODE.RAID] = {pvp = false, team_key = "raid", default_team_key = "stage", showSkill3Effect = true, create_enemy_type = 1}, -- 武道场
    [M.BATTLE_MODE.LEGEND] = {pvp = false, showSkill3Effect = false,  team_key = "legend"}, -- 江湖传说
    [M.BATTLE_MODE.MINING] = {create_enemy_type = 2, pvp = true, showSkill3Effect = true, team_key = "mining",show_formation_skip_btn = true, isAuto = true, show_multi_formation = false, show_save_team_btn = false}, -- 苗疆觅宝
    [M.BATTLE_MODE.MINING_DEFENSE] = {pvp = true, team_key = "mining_defense", showSkill3Effect = true, isAuto = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 苗疆觅宝防守阵容
    [M.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE] = {pvp = true, show_restart_btn = false, team_key = "top_race_arena_defense", showSkill3Effect = true, show_formation_skip_btn = false, isAuto = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, --天级赛防守阵容
    [M.BATTLE_MODE.TOP_RACE_ARENA] = {create_enemy_type = 3, pvp = true,  show_restart_btn = false, team_key = "top_race_arena", showSkill3Effect = true, show_formation_skip_btn = true, isAuto = true, show_multi_formation = false, show_save_team_btn = false, show_result_bg = false}, --天级赛进攻阵容
    [M.BATTLE_MODE.FOUR_TOWER] = {pvp = false, scene_id = 107, team_key = "four_tower", default_team_key = "stage", showSkill3Effect = true, create_enemy_type = 2, show_formation_pass_btn = false}, -- 四象阵
    [M.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE] = {pvp = true, scene_id = 133, showSkill3Effect = true, show_restart_btn = false, team_key = "season_race_arena_defense", show_formation_skip_btn = false, isAuto = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, --五行联赛防守阵容
    [M.BATTLE_MODE.FIVE_RACE_ARENA] = {create_enemy_type = 3, scene_id = 133, pvp = true,  showSkill3Effect = true, show_restart_btn = false, team_key = "season_race_arena",show_formation_skip_btn = true, isAuto = true, show_multi_formation = false, show_save_team_btn = false, show_result_bg = false}, --五行联赛进攻阵容
    [M.BATTLE_MODE.ACTIVE_TOWER] = {pvp = false, scene_id = 105, team_key = "tower_active", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = false, show_multi_formation = false}, -- 爬塔
    [M.BATTLE_MODE.YINYANG_TOWER] = {pvp = false, scene_id = 107, team_key = "dark_tower", showSkill3Effect = true, create_enemy_type = 2, show_formation_pass_btn = false, show_multi_formation = false}, -- 四象阵
    [M.BATTLE_MODE.EVIL_SHADOW] = {pvp = false, scene_id = 107, team_key = "evil_shadow", showSkill3Effect = true, default_team_key = "stage", create_enemy_type = 2,create_cfg_name = "evil_shadow_stage", show_formation_pass_btn = false}, -- 邪极魅影
    [M.BATTLE_MODE.SORT_CHIVALROUS] = {pvp = false, scene_id = 107, team_key = "chivalrous", showSkill3Effect = true, default_team_key = "stage", create_enemy_type = 2,create_cfg_name = "chivalrous_practice_stage", show_formation_pass_btn = false}, -- 三侠五义
    [M.BATTLE_MODE.COMMON_BATTLE] = {pvp = false, scene_id = 107, team_key = "common_train_challenge", showSkill3Effect = true, default_team_key = "stage", create_enemy_type = 2,create_cfg_name = "active_train", show_formation_pass_btn = false}, -- 通用侠客试炼
    [M.BATTLE_MODE.DRAGONSWORD] = {pvp = false, scene_id = 107, team_key = "dragonsword", showSkill3Effect = true, default_team_key = "stage", create_enemy_type = 2,create_cfg_name = "dragonsword_stage", show_formation_pass_btn = false}, -- 龙泉试炼
    [M.BATTLE_MODE.MULT_STAGE] = {pvp = false, team_key = "mult_team_stage", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = true, show_multi_formation = true}, -- 推图
    [M.BATTLE_MODE.QIMENDUNJIA] = {pvp = false, scene_id = 135, team_key = "qimendunjia", create_enemy_type = 2,show_combat_repress = true}, -- 奇门遁甲
    [M.BATTLE_MODE.GVE_BATTLE] = {pvp = false, showSkill3Effect = false, team_key = "gve", create_enemy_type = 2, show_formation_skip_btn = true, create_cfg_name = "gve_stage_battle"}, -- 奇门遁甲
    [M.BATTLE_MODE.GVE_BATTLE_BOSS] = {pvp = false, showSkill3Effect = false, team_key = "gve", create_enemy_type = 1, create_cfg_name = "gve_stage_battle"}, -- 奇门遁甲BOSS
    [M.BATTLE_MODE.HUASHAN_SWORD] = {create_enemy_type = 3, scene_id = 136, pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_multi_formation = false, show_formation_skip_btn = true, show_result_bg = false}, -- 华山论剑竞技场
    [M.BATTLE_MODE.HUASHAN_SWORD_DEFENSE] = {pvp = false, scene_id = 136, def_deployment = -1, showSkill3Effect = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, --  华山论剑防守阵容
    [M.BATTLE_MODE.ACTIVE_MINING] = {create_enemy_type = 2, pvp = true, showSkill3Effect = true, team_key = "active_mining",show_formation_skip_btn = true, isAuto = true, show_multi_formation = false, show_save_team_btn = false}, -- 夺宝奇兵
    [M.BATTLE_MODE.ACTIVE_MINING_DEFENSE] = {pvp = true, team_key = "active_mining_defense", showSkill3Effect = true, isAuto = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 苗疆觅宝防守阵容
    [M.BATTLE_MODE.WD_TOWER] = {pvp = false, scene_id = 107, team_key = "wdtower", showSkill3Effect = true, create_enemy_type = 2, show_formation_pass_btn = false, show_multi_formation = false}, -- 四象阵
    [M.BATTLE_MODE.GU_JIAN_MULT] = { pvp = false, team_key = "mult_team_stage", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = false, show_multi_formation = false }, --古剑奇谭，多队伍
    [M.BATTLE_MODE.GU_JIAN_MAZE] = { pvp = false, scene_id = 140, showSkill3Effect = true, team_key = "ancient_sword_akuma", create_enemy_type = 2 }, --古剑奇谭，迷宫
    [M.BATTLE_MODE.NEW_BIG_MAP] = {pvp = false, show_restart_truebtn = false, team_key = "stage", showSkill3Effect = true, create_enemy_type = 1}, -- 随机江湖大地图
    [M.BATTLE_MODE.FULWIN_AREA_ONE] = {pvp = false, team_key = "friend_arena_defense1",def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 风云擂台，单人队防守
    [M.BATTLE_MODE.FULWIN_AREA_THREE] = {pvp = false, team_key = "friend_arena_defense3", def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 风云擂台，三人队防守
    [M.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE] = {pvp = true, team_key = "friend_arena1",scene_id = 133, showSkill3Effect = true, show_save_team_btn = false, show_formation_skip_btn = true, show_multi_formation = false, isAuto = true, create_enemy_type = 2}, -- 风云擂台，单人队进攻
    [M.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE] = {pvp = true, team_key = "friend_arena3",scene_id = 133, showSkill3Effect = true, show_save_team_btn = false, show_formation_skip_btn = true, show_multi_formation = false, isAuto = true, create_enemy_type = 3, show_result_bg = false}, -- 风云擂台，三人队进攻
    [M.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE] = {pvp = true, team_key = "friend_arena1",def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 风云擂台，单人队布阵
    [M.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE] = {pvp = true, team_key = "friend_arena3", def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 风云擂台，三人队布阵
    [M.BATTLE_MODE.MYTH_ARENA] = {create_enemy_type = 3, pvp = true, team_key = "myth_arena", showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_multi_formation = false, show_result_bg = false, show_formation_skip_btn = true}, -- 高阶竞技场
    [M.BATTLE_MODE.MYTH_ARENA_DEFENSE] = {pvp = false, team_key = "myth_arena_defense", def_deployment = -1, showSkill3Effect = true, show_multi_formation = false, show_save_team_btn = true, show_enemy = false}, -- 高阶竞技场防守阵容
    [M.BATTLE_MODE.RACCON] = { pvp = false, team_key = "raccon_chapter", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = false, show_multi_formation = false }, --古剑奇谭，多队伍
    [M.BATTLE_MODE.PET_DOUJI] = {pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_formation_skip_btn = false, team_key = "pet_arena", create_enemy_type = 2, show_save_team_btn = true, show_multi_formation = false}, -- 宠物斗技竞技场
    [M.BATTLE_MODE.AWAKE_SYSTEM] = {pvp = false, team_key = "awaken_stage", def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = false, show_enemy = true,show_combat_repress = false,create_enemy_type = 1}, --觉醒系统的入梦铃
    [M.BATTLE_MODE.SORT_FULL_SERVICE_BOSS] = {pvp = false, showSkill3Effect = true, show_restart_btn = false, show_formation_skip_btn = false, team_key = "full_service_boss", create_enemy_type = 1, show_save_team_btn = false,create_cfg_name = "stage_battle_active",show_multi_formation = false}, -- 剑试天下--Boss战
    [M.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE] = {pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_formation_skip_btn = false, team_key = "full_service_point_race", show_save_team_btn = true, show_multi_formation = true, show_enemy = false,show_combat_repress = true}, -- 剑试天下--积分赛
    [M.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION] = {pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_formation_skip_btn = false, team_key = "full_service_promotion",  show_save_team_btn = true, show_multi_formation = true}, -- 剑试天下--晋级赛

    [M.BATTLE_MODE.GUILD_HIGH_WAR] = {  pvp = true, showSkill3Effect = true, show_restart_btn = false,isAuto = true, show_multi_formation = false, show_formation_skip_btn = true, show_result_bg = false, show_enemy = false, show_save_team_btn = true}, -- 巅峰帮会战

    [M.BATTLE_MODE.GHOSTS_SHOW_SKILL] = {pvp = true, team_key = "stage", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = true}, -- 推图
    [M.BATTLE_MODE.XIAKEDAO] = {pvp = false, scene_id = 105,team_key = "hero_isle_sing", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = false,show_result_bg= true},--单队侠客岛
    [M.BATTLE_MODE.XIAKEDAO_MULTI] = {pvp = false, scene_id = 105,team_key = "hero_isle_mul", showSkill3Effect = true, create_enemy_type = 1, show_formation_pass_btn = false, show_multi_formation = true,show_result_bg= true}, -- 多队侠客岛

    [M.BATTLE_MODE.ZF_ARENA] = {pvp = true, team_key = "rise_arena_atk_sgl", showSkill3Effect = true, create_enemy_type = 3, show_formation_pass_btn = false, show_multi_formation = false,show_result_bg= true, show_restart_btn = false,isAuto = true}, -- 争锋联赛进攻单队伍阵容
    [M.BATTLE_MODE.ZF_ARENA_DEFENSE] = {pvp = true, team_key = "rise_arena_def_sgl", showSkill3Effect = true, def_deployment = -1, show_multi_formation = false, show_save_team_btn = true, show_enemy = false,show_combat_repress = true}, -- 争锋联赛单队伍防守阵容
    [M.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL] = {pvp = true,  scene_id = 133,team_key = "rise_arena_def_mul", showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false,show_enemy = false,show_result_bg= true,show_combat_repress = true, show_save_team_btn = true}, -- 争锋联赛多队伍防守阵容
    [M.BATTLE_MODE.ZF_ARENA_MUL] = {create_enemy_type = 3, scene_id = 133, pvp = true,  showSkill3Effect = true, show_restart_btn = false, team_key = "rise_arena_atk_mul",show_formation_skip_btn = true, isAuto = true, show_multi_formation = false, show_save_team_btn = false, show_result_bg = false}, --争锋联赛多队伍进攻阵容

    [M.BATTLE_MODE.HERO_FATE] = {pvp = false, team_key = "stage", def_deployment = -1, show_formation_skip_btn = false, showSkill3Effect = true, show_formation_pass_btn = false, show_multi_formation = false, show_save_team_btn = false, show_enemy = true,show_combat_repress = false,create_enemy_type = 1}, --侠客情缘

    [M.BATTLE_MODE.HERO_BOSS_PVE] = {pvp = false, team_key = "train_challenge", showSkill3Effect = false, create_enemy_type = 2, create_cfg_name = "stage_battle_active"}, --天府夺刀pve活动 --
    [M.BATTLE_MODE.HERO_BOSS_PVP] = {pvp = true, team_key = "train_challenge", showSkill3Effect = true, create_enemy_type = 3, show_formation_pass_btn = false, show_multi_formation = true, show_result_bg = true, show_restart_btn = false,isAuto = true}, --天府夺刀pvp活动 --

    [M.BATTLE_MODE.RTA_ARENA] = {create_enemy_type = 2, scene_id = 133, pvp = true,  showSkill3Effect = true, show_restart_btn = false, team_key = "rise_arena_atk_mul",show_formation_skip_btn = false, isAuto = true, show_multi_formation = false, show_save_team_btn = false, show_result_bg = true}, --剑出红蒙


}
M.SCENE_ID =
{
    HangUpScene = 1, --挂机场景
    FightScene = 2, --战斗场景
    BossScene = 3, --Boss场景
    TianJiLouScene = 4, --天机楼场景
    MiGongScene = 5, --迷宫场景
    PantheonScene = 6, --先贤祠万神店场景
    TianjiLouFightScene = 7, --天机楼战斗场景
    AdvancedScene = 8, --人物进阶场景
    MiGongFightScene = 9, --迷宫战斗场景
    UnionBossScene = 10, --工会Boss场景
    ShiGuangScene = 11, --时光之巅场景
    ShiGuangFightScene = 12, --时光之巅战斗场景
    WuXingZhenScene = 13, --五行阵场景
    WuXingZhenFightScene = 14, --五行阵战斗场景
    UnionWarScene = 15,
    VoyageScene = 16, --盗帅迷踪场景
    JuBaoShanScene = 17, --聚宝山场景
    LegendScene = 18, --江湖传说场景
    HeroTrainScene = 19, --侠客试炼场景LunJianShanZhuang
    GuJianQiTanScene = 24, --古剑奇谭
    GuJianQiTanFightScene = 21, --古剑奇谭，战斗
    ActiveBossScene = 22, --通用活动Boss场景
    PetHallScene = 23, --宠物大厅
    GuildHighWar = 20, --侠客试炼场景LunJianShanZhuang

    WorldScene1 = 91, --大世界场景1
    WorldScene2 = 92, --大世界场景2
    WorldScene3 = 93, --大世界场景3
    WorldScene4 = 94, --大世界场景4
    WorldScene9 = 99, --大世界场景9
    GhostsShowSkillScene = 100, --

    JiaoWai = 901,

    QiMenDunJiaScene = 135, --奇门遁甲
}

M.SCENE_ID_CFG = {
    [M.SCENE_ID.HangUpScene] = M.BATTLE_MODE.STAGE, --挂机场景
    [M.SCENE_ID.FightScene] = M.BATTLE_MODE.STAGE, --战斗场景
    [M.SCENE_ID.BossScene] = M.BATTLE_MODE.WORLD_BOSS, --Boss场景
    [M.SCENE_ID.TianJiLouScene] = M.BATTLE_MODE.TOWER, --天机楼场景
    [M.SCENE_ID.MiGongScene] = M.BATTLE_MODE.MAZE,  --迷宫场景
    [M.SCENE_ID.PantheonScene] = M.BATTLE_MODE.STAGE, --先贤祠万神店场景
    [M.SCENE_ID.TianjiLouFightScene] = M.BATTLE_MODE.TOWER, --天机楼战斗场景
    [M.SCENE_ID.AdvancedScene] = M.BATTLE_MODE.STAGE, --人物进阶场景
    [M.SCENE_ID.MiGongFightScene] = M.BATTLE_MODE.MAZE, --迷宫战斗场景
    [M.SCENE_ID.UnionBossScene] = M.BATTLE_MODE.UNION_BOSS, --工会Boss场景
    [M.SCENE_ID.ShiGuangScene] = M.BATTLE_MODE.TOP_OF_TIME, --时光之巅场景
    [M.SCENE_ID.ShiGuangFightScene] = M.BATTLE_MODE.TOP_OF_TIME, --时光之巅战斗场景
    [M.SCENE_ID.WuXingZhenScene] = M.BATTLE_MODE.FIVE_ARRAY, --五行阵场景
    [M.SCENE_ID.WuXingZhenFightScene] = M.BATTLE_MODE.FIVE_ARRAY, --五行阵战斗场景
    [M.SCENE_ID.WorldScene1] = M.BATTLE_MODE.BIG_MAP, --大世界场景1
    [M.SCENE_ID.WorldScene2] = M.BATTLE_MODE.BIG_MAP, --大世界场景2
    [M.SCENE_ID.WorldScene3] = M.BATTLE_MODE.BIG_MAP, --大世界场景2
    [M.SCENE_ID.JiaoWai] = M.BATTLE_MODE.STAGE, --
    [M.SCENE_ID.UnionWarScene] = M.BATTLE_MODE.UNIONWAR, --
    [M.SCENE_ID.VoyageScene] = M.BATTLE_MODE.STAGE, --


    [M.SCENE_ID.GhostsShowSkillScene] = M.BATTLE_MODE.STAGE, --

    [M.SCENE_ID.LegendScene] = M.BATTLE_MODE.LEGEND, --
    [M.SCENE_ID.QiMenDunJiaScene] = M.BATTLE_MODE.QIMENDUNJIA, -- 奇门遁甲
    [M.SCENE_ID.GuJianQiTanScene] = M.BATTLE_MODE.GU_JIAN_MAZE, -- 古剑奇谭，迷宫
    [M.SCENE_ID.GuJianQiTanFightScene] = M.BATTLE_MODE.GU_JIAN_MAZE, -- 古剑奇谭，战斗
    [M.SCENE_ID.ActiveBossScene] = M.BATTLE_MODE.ACTIVE_BOSS, --通用活动Boss场景
    [M.SCENE_ID.GuildHighWar] = M.BATTLE_MODE.GUILD_HIGH_WAR, -- 巅峰帮会战
}

--阵营加成对应的common值
--类型0：无阵型
--类型1：金、木、水、火各一名
--类型2：同势力3名
--类型3：同势力3名+其他势力2名
--类型4：同势力4名
--类型5：同势力5名
--类型6：同势力6名
--类型7：同势力8名
--类型8：同势力10名
--类型10：阴0名
--类型11：阴1名
--类型12：阴2名
--类型13：阴3名
--类型14：阴4名
--类型15：阴5名
M.ARRAY_ADDITION = {
    [0] = 0,
    [1] = 330,
    [2] = 71,
    [3] = 72,
    [4] = 73,
    [5] = 74,
    [6] = 112,
    [7] = 113,
    [8] = 114,
    [10] = 0,
    [11] = 75,
    [12] = 76,
    [13] = 77,
    [14] = 78,
    [15] = 79,
}

--hero_showHp           英雄是否显示血条
--enemy_showHp          敌人是否显示血条
--hero_showLevel        英雄是否显示等级
--enemy_showLevel       敌人是否显示等级
--hero_showHpLabel      英雄是否显示掉血数字
--enemy_showHpLabel     敌人是否显示掉血数字
--hero_showBuffLabel    英雄是否显示buff图标
--enemy_showBuffLabel   敌人是否显示buff图标
--showSkill3Effect      英雄是否显示大招效果（包括黑屏和大招UI）
--hero_showStand        英雄是否显示站立特效
--enemy_showStand       敌人是否显示站立特效

M.SCENE_ID_INFO = {
    [M.SCENE_ID.HangUpScene] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false}, --挂机场景
    [M.SCENE_ID.FightScene] = { hero_showHp = true,
                                enemy_showHp = true,
                                hero_showLevel = true,
                                enemy_showLevel = true,
                                hero_showHpLabel = true,
                                enemy_showHpLabel = true,
                                hero_showBuffLabel = true,
                                enemy_showBuffLabel = true,
                                showSkill3Effect = true,
                                hero_showStand = true,
                                enemy_showStand = true }, --战斗场景
    [M.SCENE_ID.BossScene] = { hero_showHp = true,
                               enemy_showHp = true,
                               hero_showLevel = true,
                               enemy_showLevel = false,
                               hero_showHpLabel = true,
                               enemy_showHpLabel = true,
                               hero_showBuffLabel = true,
                               enemy_showBuffLabel = true,
                               showSkill3Effect = false,
                               hero_showStand = true,
                               enemy_showStand = false }, --Boss场景
    [M.SCENE_ID.TianJiLouScene] = { hero_showHp = false,
                                    enemy_showHp = false,
                                    hero_showLevel = false,
                                    enemy_showLevel = false,
                                    hero_showHpLabel = true,
                                    enemy_showHpLabel = true,
                                    hero_showBuffLabel = true,
                                    enemy_showBuffLabel = true,
                                    showSkill3Effect = true,
                                    hero_showStand = false,
                                    enemy_showStand = false }, --天机楼场景
    [M.SCENE_ID.MiGongScene] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false },  --迷宫场景
    [M.SCENE_ID.PantheonScene] = { hero_showHp = false,
                                   enemy_showHp = false,
                                   hero_showLevel = false,
                                   enemy_showLevel = false,
                                   hero_showHpLabel = true,
                                   enemy_showHpLabel = true,
                                   hero_showBuffLabel = true,
                                   enemy_showBuffLabel = true,
                                   showSkill3Effect = true,
                                   hero_showStand = false,
                                   enemy_showStand = false }, --先贤祠万神店场景
    [M.SCENE_ID.TianjiLouFightScene] = { hero_showHp = true,
                                         enemy_showHp = true,
                                         hero_showLevel = true,
                                         enemy_showLevel = true,
                                         hero_showHpLabel = true,
                                         enemy_showHpLabel = true,
                                         hero_showBuffLabel = true,
                                         enemy_showBuffLabel = true,
                                         showSkill3Effect = true,
                                         hero_showStand = true,
                                         enemy_showStand = true }, --天机楼战斗场景
    [M.SCENE_ID.AdvancedScene] = { hero_showHp = false,
                                   enemy_showHp = false,
                                   hero_showLevel = false,
                                   enemy_showLevel = false,
                                   hero_showHpLabel = true,
                                   enemy_showHpLabel = true,
                                   hero_showBuffLabel = true,
                                   enemy_showBuffLabel = true,
                                   showSkill3Effect = true,
                                   hero_showStand = false,
                                   enemy_showStand = false }, --人物进阶场景
    [M.SCENE_ID.MiGongFightScene] = { hero_showHp = true,
                                      enemy_showHp = true ,
                                      hero_showLevel = true,
                                      enemy_showLevel = true,
                                      hero_showHpLabel = true,
                                      enemy_showHpLabel = true,
                                      hero_showBuffLabel = true,
                                      enemy_showBuffLabel = true,
                                      showSkill3Effect = true,
                                      hero_showStand = true,
                                      enemy_showStand = true}, --迷宫战斗场景
    [M.SCENE_ID.UnionBossScene] = { hero_showHp = true,
                                    enemy_showHp = false,
                                    hero_showLevel = false,
                                    enemy_showLevel = false,
                                    hero_showHpLabel = true,
                                    enemy_showHpLabel = true,
                                    hero_showBuffLabel = true,
                                    enemy_showBuffLabel = true,
                                    showSkill3Effect = true,
                                    hero_showStand = true,
                                    enemy_showStand = false }, --工会Boss场景
    [M.SCENE_ID.ShiGuangScene] = { hero_showHp = false,
                                   enemy_showHp = false,
                                   hero_showLevel = false,
                                   enemy_showLevel = false,
                                   hero_showHpLabel = true,
                                   enemy_showHpLabel = true,
                                   hero_showBuffLabel = true,
                                   enemy_showBuffLabel = true,
                                   showSkill3Effect = true,
                                   hero_showStand = false,
                                   enemy_showStand = false }, --时光之巅场景
    [M.SCENE_ID.ShiGuangFightScene] = { hero_showHp = false,
                                        enemy_showHp = false,
                                        hero_showLevel = false,
                                        enemy_showLevel = false,
                                        hero_showHpLabel = true,
                                        enemy_showHpLabel = true,
                                        hero_showBuffLabel = true,
                                        enemy_showBuffLabel = true,
                                        showSkill3Effect = true,
                                        hero_showStand = true,
                                        enemy_showStand = true }, --时光之巅战斗场景
    [M.SCENE_ID.WuXingZhenScene] = { hero_showHp = false,
                                     enemy_showHp = false,
                                     hero_showLevel = false,
                                     enemy_showLevel = false,
                                     hero_showHpLabel = true,
                                     enemy_showHpLabel = true,
                                     hero_showBuffLabel = true,
                                     enemy_showBuffLabel = true,
                                     showSkill3Effect = true,
                                     hero_showStand = false,
                                     enemy_showStand = false }, --五行阵场景
    [M.SCENE_ID.WuXingZhenFightScene] = { hero_showHp = true,
                                          enemy_showHp = true,
                                          hero_showLevel = true,
                                          enemy_showLevel = true,
                                          hero_showHpLabel = true,
                                          enemy_showHpLabel = true,
                                          hero_showBuffLabel = true,
                                          enemy_showBuffLabel = true,
                                          showSkill3Effect = true,
                                          hero_showStand = true,
                                          enemy_showStand = true }, --五行阵战斗场景
    [M.SCENE_ID.WorldScene1] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false }, --大世界场景1
    [M.SCENE_ID.WorldScene2] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false }, --大世界场景2
    [M.SCENE_ID.WorldScene3] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false }, --大世界场景2
    [M.SCENE_ID.JiaoWai] = { hero_showHp = false,
                             enemy_showHp = false,
                             hero_showLevel = false,
                             enemy_showLevel = false,
                             hero_showHpLabel = true,
                             enemy_showHpLabel = true,
                             hero_showBuffLabel = true,
                             enemy_showBuffLabel = true,
                             showSkill3Effect = true,
                             hero_showStand = false,
                             enemy_showStand = false }, -- 
    [M.SCENE_ID.VoyageScene] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false}, --挂机场景
    [M.SCENE_ID.GhostsShowSkillScene] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false}, --挂机场景
    [M.SCENE_ID.LegendScene] = { hero_showHp = true,
                                 enemy_showHp = true,
                                 hero_showLevel = true,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = false,
                                 enemy_showHpLabel = false,
                                 hero_showBuffLabel = false,
                                 enemy_showBuffLabel = false,
                                 showSkill3Effect = false,
                                 hero_showStand = true,
                                 enemy_showStand = true}, --江湖传说场景
    [M.SCENE_ID.JuBaoShanScene] = { hero_showHp = false,
                                    enemy_showHp = false,
                                    hero_showLevel = false,
                                    enemy_showLevel = false,
                                    hero_showHpLabel = false,
                                    enemy_showHpLabel = false,
                                    hero_showBuffLabel = false,
                                    enemy_showBuffLabel = false,
                                    showSkill3Effect = false,
                                    hero_showStand = false,
                                    enemy_showStand = false}, --聚宝山场景
    [M.SCENE_ID.HeroTrainScene] = { hero_showHp = true,
                                    enemy_showHp = true,
                                    hero_showLevel = true,
                                    enemy_showLevel = false,
                                    hero_showHpLabel = true,
                                    enemy_showHpLabel = true,
                                    hero_showBuffLabel = true,
                                    enemy_showBuffLabel = true,
                                    showSkill3Effect = false,
                                    hero_showStand = true,
                                    enemy_showStand = false }, --侠客试炼场景
    [M.SCENE_ID.QiMenDunJiaScene] = { hero_showHp = false,
                                     enemy_showHp = false,
                                     hero_showLevel = false,
                                     enemy_showLevel = false,
                                     hero_showHpLabel = true,
                                     enemy_showHpLabel = true,
                                     hero_showBuffLabel = true,
                                     enemy_showBuffLabel = true,
                                     showSkill3Effect = true,
                                     hero_showStand = false,
                                     enemy_showStand = false },  --奇门遁甲场景
    [M.SCENE_ID.GuJianQiTanScene] = { hero_showHp = false,
                                 enemy_showHp = false,
                                 hero_showLevel = false,
                                 enemy_showLevel = false,
                                 hero_showHpLabel = true,
                                 enemy_showHpLabel = true,
                                 hero_showBuffLabel = true,
                                 enemy_showBuffLabel = true,
                                 showSkill3Effect = true,
                                 hero_showStand = false,
                                 enemy_showStand = false },  --古剑奇谭场景
    [M.SCENE_ID.GuJianQiTanFightScene] = { hero_showHp = true,
                                      enemy_showHp = true ,
                                      hero_showLevel = true,
                                      enemy_showLevel = true,
                                      hero_showHpLabel = true,
                                      enemy_showHpLabel = true,
                                      hero_showBuffLabel = true,
                                      enemy_showBuffLabel = true,
                                      showSkill3Effect = true,
                                      hero_showStand = true,
                                      enemy_showStand = true}, --古剑奇谭战斗场景
    [M.SCENE_ID.ActiveBossScene] = { hero_showHp = true,
                               enemy_showHp = true,
                               hero_showLevel = true,
                               enemy_showLevel = false,
                               hero_showHpLabel = true,
                               enemy_showHpLabel = true,
                               hero_showBuffLabel = true,
                               enemy_showBuffLabel = true,
                               showSkill3Effect = false,
                               hero_showStand = true,
                               enemy_showStand = false }, --Boss场景
    [M.SCENE_ID.PetHallScene] = { hero_showHp = false,
                                     enemy_showHp = false,
                                     hero_showLevel = false,
                                     enemy_showLevel = false,
                                     hero_showHpLabel = false,
                                     enemy_showHpLabel = false,
                                     hero_showBuffLabel = false,
                                     enemy_showBuffLabel = false,
                                     showSkill3Effect = false,
                                     hero_showStand = false,
                                     enemy_showStand = false }, --宠物大厅
    [M.SCENE_ID.GuildHighWar] = { hero_showHp = false,
                                enemy_showHp = false,
                                hero_showLevel = false,
                                enemy_showLevel = false,
                                hero_showHpLabel = true,
                                enemy_showHpLabel = true,
                                hero_showBuffLabel = true,
                                enemy_showBuffLabel = true,
                                showSkill3Effect = true,
                                hero_showStand = false,
                                enemy_showStand = false }, --巅峰公会战
}

M.BattleConfigName = require("Battle.BattleConfigFiles")

M.AnimEvtKeys = {
    "skill1_2",
    "idle",
    "hit2_flyend",
    "hit2_flyspin",
    "skill0_loop",
    "die",
    "hit2_flyloop",
    "hit2_fyloop",
    "skill1",
    "jupmin1",
    "skill0_1",
    "skill0_2",
    "attack1_skill2",
    "attack1_2_skill3",
    "attack1_die",
    "hit1_2loop",
    "skill2_1",
    "jumpin2",
    "attack1_jian",
    "hit2_2",
    "hit3",
    "skill3_Poose_3",
    "sprint",
    "hit1_loop",
    "skill1_QuanTao",
    "hit2_1",
    "skill3_Loop2",
    "attack1_2",
    "skill0",
    "attack1",
    "hit2_fly",
    "idlewind",
    "jumpin1",
    "attack1_1",
    "hit2_spin",
    "skill3_attack1",
    "hit2_fiyend",
    "jumpin1_she",
    "skill3_Loop3",
    "hit2_2fly",
    "hit",
    "hit1loop",
    "skill3_attack",
    "hit2",
    "attack1_3",
    "skill2",
    "run",
    "battle_idle",
    "battle_idle_skill2",
    "skill",
    "skill2_attack1",
    "skill2_2",
    "skill2_skill3",
    "jupmin2",
    "reload_loop",
    "skill3_1",
    "attack1_3_skill3",
    "attack1_1_skill3",
    "idle_2",
    "hit1_2",
    "skill2_skill0",
    "hit2_fiy",
    "skill1_skill3",
    "skill1_end",
    "skill3_loop",
    "hit1_1_loop",
    "skill3_Poose_2",
    "common",
    "skill3_end",
    "spawn",
    "skill_end",
    "attack1_skill3",
    "attack1_skill0",
    "skill3_Poose_1",
    "skill1_attack1",
    "hit1_1",
    "debuff",
    "hit2_2flyend",
    "attack",
    "hit2_2flycnd",
    "battleidle",
    "skill2_start",
    "skill2_end",
    "skill2_1end",
    "skill2_loop",
    "hit1_1end",
    "hit2_fiyloop",
    "attack2",
    "skill3_Loop1",
    "skill1_loop",
    "skill3",
    "skill3_2",
    "hit1_2end",
    "hit1_1loop",
    "debuff1",
    "reload_end",
    "hit2_2flyloop",
    "hit1_end",
    "battle_idle_2",
    "hit2_spine",
    "hit1",
    "skill0_end",
    "skill3_End",
    "hit1_1_end",
    "reload",
    "skill1_1",
    "die_into",
    "skill3_1_skill2",
    "hit2_flyend_skill2",
    "debuff1_skill2",
    "die_skill2",
    "hit1_1end_skill2",
    "hit3_skill2",
    "hit2_1_skill2",
    "hit1_1_skill2",
    "hit1_1loop_skill2",
    "skill3_3_skill2",
    "skill3_2_skill2",
    "idle_skill2",
    "run_skill2",
    "skill2_skill2",
    "hit2_spin_skill2",
    "stand",
    "skill1_skill2",
    "skill3_skill2",
    "return",
    "idle_circlewalk",
    "idle_hunt",
    "idle_walk",
    "idle_walk2",
    "stay_dahaqian",
    "stay_down",
    "stay_down_end",
    "stay_down_loop",
    "stay_sit",
    "touch_ask",
    "touch_lay",
    "touch_yawn",
    "xiezhanattack1",
    "xiezhanskill1",
    "skill1_1end",
    "skill2_run",
    "skill4",
    "skill4_1",
    "idle_circle",
    "stay_jump",
    "idle_fly2",
    "dragon_touch_playfire",
    "idle_fly",
    "stay_sleep",
    "dragon_touch_fire",
    "stay_laugh",
    "dragon_touch_down",
    "downfly_loop",
    "downfly_end",
    "downfly",
    "xiezhanskill1_2",
    "touch_circle",
    "fly",
    "downfly_shake",
    "downfly_sing",
    "downfly_eat",
    "downfly_fetter",
    "stay_stand",
    "rush",
    "eat",
    "touch_jump",
    "walk",
    "touch_chaise",
    "stay_sit_loop",
    "xiezhanattack1_2",
    "idle01",
    "die_1",
    "skill3_plus_loop",
    "skill3_plus_end",
    "skill0_plus",
    "skill1_plus",
    "skill2_plus",
    "skill3_plus",
    "skill1_plus_1",
    "skill2_plus_1",
    "skill3_plus_1",
    "hit_1end",
    "hit_1loop",
    "skill3_start",
    "skill3_plus_start",
}

function M:checkAnimEvtKeys()
    if GameVersionConfig.Debug then
        local tempTab = {}
        for i, v in ipairs(Battle.BattleGlobalConfig.AnimEvtKeys) do
            if tempTab[v] == nil then
                tempTab[v] = 1
            else
                Logger.logError("AnimEvtKeys 中有重名动作 ".. tostring(v))
            end
        end
    end
end

-- 已经处理过的角色属性，没有处理应该要提示一个错误，需要修复
-- 每当添加了新属性后，需要在这个表里面标记一下，防止误报
M.HandleHeroDataKeys = {
    hp = true,
    atk = true,
    def = true,
    critrate = true,
    crit = true,
    rage = true,
    weight = true,
    hurtrageregen = true,
    atkrageregen = true,
    rageregenper = true,
    magicdamage = true,
    physicaldamage = true,
    hr = true,
    dodge = true,
    haste = true,
    leeching = true,
    res = true,
    resi = true,
    atd = true,
    cureRate = true,
    hpRecover = true,
    discontrol = true,
    resatd = true,
    pmdamage = true,
    rediscontrol = true,
    disres = true,
    disatd = true,
    role_type = true,
    cdup = true,
    magicdef = true,
    discrit = true,
    physicaldef = true,
    power = true,
}

return M
