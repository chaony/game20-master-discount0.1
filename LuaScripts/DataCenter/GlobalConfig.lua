----------- GlobalConfig
local M = {
	GET = "GET",
	POST = "POST",
	EVENT_KEYS = {
		EQUIP_UPDATE_EVENT = "equip_update_event",
		DATA_UPDATE_EVENT = Battle.BattleGlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT,
		NET_DATA_UPDATE_EVENT = Battle.BattleGlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT,
		CLOSE_VIEW = Battle.BattleGlobalConfig.EVENT_KEYS.CLOSE_VIEW,
        OPEN_VIEW = Battle.BattleGlobalConfig.EVENT_KEYS.OPEN_VIEW,
        CHAT_INIT = 'chat_init!!', -- 连接到聊天服务器TCP
        CHAT_REFRESH = 'chat_refresh!!',
        CHAT_ADD_CHANNEL = 'chat_add_channel!!',
        CHANGE_OUTSKIRTS_SCENE = "change_outskirts_scene",
        SCREEN_CLICK_EVENT = "screen_click_event",
        CHARGE_BACK = "charge_update_event", -- 充值事件
        ON_APPLICATION_WAKE_UP = "on_application_wake_up", -- 唤醒事件
        CHAT_NEW_PRIVATE = "chat_new_private",
        EVERY_DAY_EVENT = "every_day_event",  -- 跨天事件
        BATTLE_EVENT = "battle_event",  -- 战斗事件
        COMMON_REFRESH = "common_refresh", --通知刷新活动
        RTA_SYNC="rta_sync"
    },
    UI_TOP_OFFSET_Y = -60,
    UI_BOTTOM_OFFSET_Y = 60,
    UI_LEFT_OFFSET_X = 60,
    UI_RIGHT_OFFSET_X = -60,
    ASSIST_SUMMARIES_LIMIT_NUM = 3, -- 好友的外援英雄限定数量
    SENSITIVE_WORDS_CODE = "503",
    UI_DESIGN_WIDTH = 1280,
    UI_DESIGN_HEIGHT = 720,
    BG_UI_DESIGN_WIDTH = 1630,
    BG_UI_DESIGN_HEIGHT = 720,
    MULTI_FORMATION_MAX = 10,
    UNION_WAR_BUILDINGS_COUNT = 20,
}

--[[
    frame_name 装备&物品 方形边框 
    card_frame_name 英雄 方形边框 
    card_frame_name2 英雄卡牌（长方形）
    is_add-是否有附加精英边框
    icon 品质图标
    hero_half_bg 菱形小 悬赏用
]]
--三个sp类型：妖刀、器灵(人杰)、魂剑()
M.SP_TYPE_SETTING=
{
    {name="new_str_1136",icon="sp_yaodao_icon",sp_bg_name="sp_yaodao_bg",sp_bg_effect_name="UI_sp_flag_003"},
    {name="new_str_1137",icon="sp_qiling_icon",sp_bg_name="sp_qiling_bg",sp_bg_effect_name="UI_sp_flag_002"},
    {name="new_str_1138",icon="sp_hunjian_icon",sp_bg_name="sp_hunjian_bg",sp_bg_effect_name="UI_sp_flag_001"},
    {name="new_str_1154",icon="sp_jueshi_icon",sp_bg_name="sp_jueshi_bg"},--絕世
    {name="new_str_1155",icon="sp_hundun_icon",sp_bg_name="sp_hundun_bg",sp_bg_effect_name="UI_sp_flag_005"},--混沌
    {name="new_str_1156",icon="sp_zhixu_icon",sp_bg_name="sp_zhixu_bg",sp_bg_effect_name="UI_sp_flag_004"},--秩序
}

M.QUALITY_COMMON_SETTING = {
    {name = "new_str_0335", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_hui",      mystic_frame_name = "a_ui_currency_dj_hui",       hero_item_frame = "a_ui_currency_ws_kong_small",  card_frame_name = "a_ui_currency_ws_lv",   card_frame_name2 = "a_zd_lv",   card_frame_name3 = "a_ui_lv_s",   is_add = false, add_img = "",                       icon = "icon_hui",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255),  HC = "3A485E", hero_3d_base = "Fx_Formation_Grey01", pet_frame = "a_ui_currency_dj_zi" }, --1 灰色
    {name = "new_str_0334", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",     frame_name = "a_ui_currency_dj_lv",       mystic_frame_name = "a_ui_currency_dj_lv",        hero_item_frame = "a_ui_currency_ws_lv_small",  card_frame_name = "a_ui_currency_ws_lv",   card_frame_name2 = "a_zd_lv",   card_frame_name3 = "a_ui_lv_s",   is_add = false, add_img = "",                       icon = "icon_lv",    item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Grey01", pet_frame = "a_ui_currency_dj_jin" }, --2 绿色
    {name = "new_str_0333", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_lan",      mystic_frame_name = "a_ui_currency_dj_lan",       hero_item_frame = "a_ui_currency_ws_lan_small",  card_frame_name = "a_ui_currency_ws_lan",  card_frame_name2 = "a_ui_lan",  card_frame_name3 = "a_ui_lan_s",  is_add = false, add_img = "a_ui_currency_dj_lan+",                       icon = "icon_lan",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Blue01", pet_frame = "a_ui_currency_dj_hong" }, --3 蓝色
    {name = "new_str_0332", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_lan",      mystic_frame_name = "a_ui_currency_dj_lan",       hero_item_frame = "a_ui_currency_ws_lan_small",  card_frame_name = "a_ui_currency_ws_lan",  card_frame_name2 = "a_ui_lan",  card_frame_name3 = "a_ui_lan_s",  is_add = true,  add_img = "a_ui_currency_dj_lan+",  icon = "icon_lan+",  item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Blue01", pet_frame = "a_ui_currency_dj_bojin" }, --4 蓝+ 有外框
    {name = "new_str_0331", hero_show_name = "new_str_0458", hero_half_bg = "a_tainjilou_dengji_zise",   frame_name = "a_ui_currency_dj_zi",       mystic_frame_name = "a_ui_currency_dj_zi",        hero_item_frame = "a_ui_currency_ws_zi_small",   card_frame_name = "a_ui_currency_ws_zi",   card_frame_name2 = "a_ui_zi",   card_frame_name3 = "a_ui_zi_s",   is_add = false, add_img = "a_ui_currency_dj_zi+",                       icon = "icon_zi",    item_effect = "fx_ItemNode_01", RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Violet01", pet_frame = "a_ui_currency_dj_cai" }, --5 紫色
    --{name = "new_str_0330", hero_show_name = "new_str_0458", hero_half_bg = "a_tainjilou_dengji_zise",   frame_name = "a_ui_currency_dj_zi",       mystic_frame_name = "a_ui_currency_dj_zi",        hero_item_frame = "a_ui_currency_ws_zi_small",   card_frame_name = "a_ui_currency_ws_zi",   card_frame_name2 = "a_ui_zi",   card_frame_name3 = "a_ui_zi_s",   is_add = true,  add_img = "a_ui_currency_dj_zi+",   icon = "icon_zi+",   item_effect = "fx_ItemNode_01", RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "Fx_Formation_Violet01" }, --6 紫+ 有外框
    {name = "new_str_0329", hero_show_name = "new_str_0459", hero_half_bg = "a_tainjilou_dengji_juse",  frame_name = "a_ui_currency_dj_jin",      mystic_frame_name = "a_ui_currency_dj_jin",       hero_item_frame = "a_ui_currency_ws_jin_small",  card_frame_name = "a_ui_currency_ws_jin",  card_frame_name2 = "a_ui_jin",  card_frame_name3 = "a_ui_jin_s",  is_add = false, add_img = "a_ui_currency_dj_jin+",                       icon = "icon_jin",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) ,  HC = "3A485E", hero_3d_base = "Fx_Formation_Yellow01", pet_frame = "a_ui_currency_dj_cai" }, --6 金
    --{name = "new_str_0328", hero_show_name = "new_str_0459", hero_half_bg = "a_tainjilou_dengji_juse",  frame_name = "a_ui_currency_dj_jin",      mystic_frame_name = "a_ui_currency_dj_jin",       hero_item_frame = "a_ui_currency_ws_jin_small",  card_frame_name = "a_ui_currency_ws_jin",  card_frame_name2 = "a_ui_jin",  card_frame_name3 = "a_ui_jin_s",  is_add = true,  add_img = "a_ui_currency_dj_jin+",  icon = "icon_jin+",  item_effect = nil,              RGBA = Color.New(255/255, 227/255, 70/255) ,  HC = "FFE346", hero_3d_base = "Fx_Formation_Yellow01" }, --8 金+ 有外框
    {name = "new_str_0327", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",      hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = false, add_img = "a_ui_currency_dj_hong+",                       icon = "icon_hong",  item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Red01", pet_frame = "a_ui_currency_dj_cai" }, --7 红
    --{name = "new_str_0326", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",      hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = true,  add_img = "a_ui_currency_dj_hong+", icon = "icon_hong+", item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01" }, --10 红+ 有外框
    {name = "new_str_0710", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false, add_img = "a_ui_currency_dj_bojin+",                       icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Col01", pet_frame = "a_ui_currency_dj_cai" }, --8 白
    {name = "new_str_0804", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_dj_bojin+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Col01",t_corner_mark = 1, pet_frame = "a_ui_currency_dj_cai" }, --9 白1星
    {name = "new_str_0805", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_dj_bojin+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Col01",t_corner_mark = 2, pet_frame = "a_ui_currency_dj_cai"}, --10 白2星
    {name = "new_str_0806", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_dj_bojin+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Col01",t_corner_mark = 3, pet_frame = "a_ui_currency_dj_cai" }, --11 白3星
    {name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_dj_bojin+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(58/255, 72/255, 94/255) , HC = "3A485E", hero_3d_base = "Fx_Formation_Col01" }, --12 彩
    --{name = "new_str_0320", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",mystic_frame_name = "a_ui_currency_dj_bojin", hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_dj_bojin+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" }, --13 彩1
}

M.HERO_QUALITY_COMMON_SETTING = {
    {name = "new_str_0335", base_name = "new_str_0335", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_hui",      mystic_frame_name = "a_ui_currency_dj_hui",          hero_item_frame = "a_ui_currency_ws_kong_small",  card_frame_name = "a_ui_currency_ws_lv",   card_frame_name2 = "a_zd_lv",   card_frame_name3 = "a_ui_lv_s",   is_add = false, add_img = "",                       icon = "icon_hui",   item_effect = nil,              RGBA = Color.New(166/255, 166/255, 166/255),  HC = "A6A6A6", hero_3d_base = "Fx_Formation_Grey01" ,hero_star = 0}, --1 灰色
    {name = "new_str_0334", base_name = "new_str_0334", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",     frame_name = "a_ui_currency_dj_lv",       mystic_frame_name = "a_ui_currency_dj_lv",        hero_item_frame = "a_ui_currency_ws_lv_small",      card_frame_name = "a_ui_currency_ws_lv",   card_frame_name2 = "a_zd_lv",   card_frame_name3 = "a_ui_lv_s",   is_add = false, add_img = "",                       icon = "icon_lv",    item_effect = nil,              RGBA = Color.New(154/255, 207/255, 129/255) , HC = "9ACF81", hero_3d_base = "Fx_Formation_Grey01" ,hero_star = 0}, --2 绿色
    {name = "new_str_0333", base_name = "new_str_0333", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_lan",      mystic_frame_name = "a_ui_currency_dj_lan",          hero_item_frame = "a_ui_currency_ws_lan_small",  card_frame_name = "a_ui_currency_ws_lan",  card_frame_name2 = "a_ui_lan",  card_frame_name3 = "a_ui_lan_s",  is_add = false, add_img = "a_ui_currency_ws_lan+",   icon = "icon_lan",   item_effect = nil,              RGBA = Color.New(109/255, 196/255, 244/255) , HC = "6DC4F4", hero_3d_base = "Fx_Formation_Blue01" ,hero_star = 0}, --3 蓝色
    {name = "new_str_0332", base_name = "new_str_0333", hero_show_name = "new_str_0457", hero_half_bg = "a_tainjilou_dengji_lanse",  frame_name = "a_ui_currency_dj_lan",      mystic_frame_name = "a_ui_currency_dj_lan",          hero_item_frame = "a_ui_currency_ws_lan_small",  card_frame_name = "a_ui_currency_ws_lan",  card_frame_name2 = "a_ui_lan",  card_frame_name3 = "a_ui_lan_s",  is_add = true,  add_img = "a_ui_currency_ws_lan+",  icon = "icon_lan+",  item_effect = nil,              RGBA = Color.New(109/255, 196/255, 244/255) , HC = "6DC4F4", hero_3d_base = "Fx_Formation_Blue01" ,hero_star = 1}, --4 蓝+ 有外框
    {name = "new_str_0331", base_name = "new_str_0331", hero_show_name = "new_str_0458", hero_half_bg = "a_tainjilou_dengji_zise",   frame_name = "a_ui_currency_dj_zi",       mystic_frame_name = "a_ui_currency_dj_zi",           hero_item_frame = "a_ui_currency_ws_zi_small",   card_frame_name = "a_ui_currency_ws_zi",   card_frame_name2 = "a_ui_zi",   card_frame_name3 = "a_ui_zi_s",   is_add = false, add_img = "a_ui_currency_ws_zi+",    icon = "icon_zi",    item_effect = "fx_ItemNode_01", RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "Fx_Formation_Violet01" ,hero_star = 0}, --5 紫色
    {name = "new_str_0330", base_name = "new_str_0331", hero_show_name = "new_str_0458", hero_half_bg = "a_tainjilou_dengji_zise",   frame_name = "a_ui_currency_dj_zi",       mystic_frame_name = "a_ui_currency_dj_zi",           hero_item_frame = "a_ui_currency_ws_zi_small",   card_frame_name = "a_ui_currency_ws_zi",   card_frame_name2 = "a_ui_zi",   card_frame_name3 = "a_ui_zi_s",   is_add = true,  add_img = "a_ui_currency_ws_zi+",   icon = "icon_zi+",   item_effect = "fx_ItemNode_01", RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "Fx_Formation_Violet01" ,hero_star = 1}, --6 紫+ 有外框
    {name = "new_str_0329", base_name = "new_str_0329", hero_show_name = "new_str_0459", hero_half_bg = "a_tainjilou_dengji_juse",  frame_name = "a_ui_currency_dj_jin",      mystic_frame_name = "a_ui_currency_dj_jin",           hero_item_frame = "a_ui_currency_ws_jin_small",  card_frame_name = "a_ui_currency_ws_jin",  card_frame_name2 = "a_ui_jin",  card_frame_name3 = "a_ui_jin_s",  is_add = false, add_img = "a_ui_currency_ws_jin+",   icon = "icon_jin",   item_effect = nil,              RGBA = Color.New(255/255, 227/255, 70/255) ,  HC = "FFE346", hero_3d_base = "Fx_Formation_Yellow01" ,hero_star = 0}, --7 金
    {name = "new_str_0328", base_name = "new_str_0329", hero_show_name = "new_str_0459", hero_half_bg = "a_tainjilou_dengji_juse",  frame_name = "a_ui_currency_dj_jin",      mystic_frame_name = "a_ui_currency_dj_jin",           hero_item_frame = "a_ui_currency_ws_jin_small",  card_frame_name = "a_ui_currency_ws_jin",  card_frame_name2 = "a_ui_jin",  card_frame_name3 = "a_ui_jin_s",  is_add = true,  add_img = "a_ui_currency_ws_jin+",  icon = "icon_jin+",  item_effect = nil,              RGBA = Color.New(255/255, 227/255, 70/255) ,  HC = "FFE346", hero_3d_base = "Fx_Formation_Yellow01" ,hero_star = 1}, --8 金+ 有外框
    {name = "new_str_0750", base_name = "new_str_0329", hero_show_name = "new_str_0459", hero_half_bg = "a_tainjilou_dengji_juse",  frame_name = "a_ui_currency_dj_jin",      mystic_frame_name = "a_ui_currency_dj_jin",           hero_item_frame = "a_ui_currency_ws_jin_small",  card_frame_name = "a_ui_currency_ws_jin",  card_frame_name2 = "a_ui_jin",  card_frame_name3 = "a_ui_jin_s",  is_add = true,  add_img = "a_ui_currency_ws_jin+",  icon = "icon_jin+",  item_effect = nil,              RGBA = Color.New(255/255, 227/255, 70/255) ,  HC = "FFE346", hero_3d_base = "Fx_Formation_Yellow01" ,hero_star = 2}, --9 金++ 有外框
    {name = "new_str_0327", base_name = "new_str_0327", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",         hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = false, add_img = "a_ui_currency_ws_hong+",  icon = "icon_hong",  item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01" ,hero_star = 0}, --10 红
    {name = "new_str_0326", base_name = "new_str_0327", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",         hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = true,  add_img = "a_ui_currency_ws_hong+", icon = "icon_hong+", item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01" ,hero_star = 1}, --11 红+ 有外框
    {name = "new_str_0747", base_name = "new_str_0327", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",         hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = true,  add_img = "a_ui_currency_ws_hong+", icon = "icon_hong+", item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01" ,hero_star = 2}, --12 红++ 有外框
    {name = "new_str_0748", base_name = "new_str_0327", hero_show_name = "new_str_0460", hero_half_bg = "a_tainjilou_dengji_hongse", frame_name = "a_ui_currency_dj_hong",     mystic_frame_name = "a_ui_currency_dj_hong",         hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong", card_frame_name2 = "a_ui_hong", card_frame_name3 = "a_ui_hong_s", is_add = true,  add_img = "a_ui_currency_ws_hong+", icon = "icon_hong+", item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01" ,hero_star = 3}, --13 红+++ 有外框
    {name = "new_str_0710", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",      mystic_frame_name = "a_ui_currency_dj_bojin",          hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false, add_img = "a_ui_currency_ws_cai+",   icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01" ,hero_star = 0}, --14 彩 -> 白
    {name = "new_str_0804", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",      mystic_frame_name = "a_ui_currency_dj_bojin",          hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01" ,hero_star = 1}, --15 1星
    {name = "new_str_0805", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",      mystic_frame_name = "a_ui_currency_dj_bojin",          hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01" ,hero_star = 2}, --16 2星
    {name = "new_str_0806", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",      mystic_frame_name = "a_ui_currency_dj_bojin",          hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01" ,hero_star = 3}, --17 3星
    {name = "new_str_0807", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_bojin",      mystic_frame_name = "a_ui_currency_dj_bojin",          hero_item_frame = "a_ui_currency_ws_bojin_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01" ,hero_star = 4}, --18 4星
    {name = "new_str_0325", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false, add_img = "a_ui_currency_ws_cai+",   icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 0}, --19 彩  TODO: 之后改成彩0星
    {name = "new_str_0324", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 1}, --20 1星
    {name = "new_str_0323", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 2}, --21 2星
    {name = "new_str_0322", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 3}, --22 3星
    {name = "new_str_0321", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 4}, --23 4星
    {name = "new_str_0320", base_name = "new_str_0325", hero_show_name = "new_str_0461", hero_half_bg = "a_tainjilou_dengji_baise",  frame_name = "a_ui_currency_dj_cai",      mystic_frame_name = "a_ui_currency_dj_cai",          hero_item_frame = "a_ui_currency_ws_cai_small",  card_frame_name = "a_ui_currency_ws_cai",  card_frame_name2 = "a_ui_cai",  card_frame_name3 = "a_ui_cai_s",  is_add = false,  add_img = "a_ui_currency_ws_cai+",  icon = "icon_cai",   item_effect = nil,              RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01" ,hero_star = 5}, --24 5星
}

--[[
hero_item_frame --装备&物品 方形边框
card_frame_name --长方形品质框
star_frame_name --星级满星
star_half_frame_name --星级半星
line_frame_name --英雄界面线形品质框
battle_card_frame_name --战斗中侠客卡牌品质框
]]--
M.HERO_QUALITY_SETTING = {
    {name = "new_str_0335", hero_item_frame = "a_ui_currency_ws_lan_small", card_frame_name = "a_ui_currency_ws_lan_big", star_frame_name = "a_ui_currency_ws_lan_big_xing", star_half_frame_name = "a_ui_currency_ws_lan_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_lv", battle_card_frame_name = "a_zd_kapai_lan", RGBA = Color.New(166/255, 166/255, 166/255),  HC = "A6A6A6", hero_3d_base = "Fx_Formation_Grey01"},--1灰色
    {name = "new_str_0334", hero_item_frame = "a_ui_currency_ws_lan_small", card_frame_name = "a_ui_currency_ws_lan_big", star_frame_name = "a_ui_currency_ws_lan_big_xing", star_half_frame_name = "a_ui_currency_ws_lan_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_lv", battle_card_frame_name = "a_zd_kapai_lan", RGBA = Color.New(154/255, 207/255, 129/255) , HC = "9ACF81", hero_3d_base = "Fx_Formation_Grey01"},--2绿色
    {name = "new_str_0333", hero_item_frame = "a_ui_currency_ws_lan_small", card_frame_name = "a_ui_currency_ws_lan_big", star_frame_name = "a_ui_currency_ws_lan_big_xing", star_half_frame_name = "a_ui_currency_ws_lan_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_lan", battle_card_frame_name = "a_zd_kapai_lan", RGBA = Color.New(109/255, 196/255, 244/255) , HC = "6DC4F4", hero_3d_base = "Fx_Formation_Blue01"},--3蓝色
    {name = "new_str_0331", hero_item_frame = "a_ui_currency_ws_zi_small", card_frame_name = "a_ui_currency_ws_zi_big", star_frame_name = "a_ui_currency_ws_zi_big_xing", star_half_frame_name = "a_ui_currency_ws_zi_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_zi", battle_card_frame_name = "a_zd_kapai_zi",  RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "Fx_Formation_Violet01"},--4紫色
    {name = "new_str_0329", hero_item_frame = "a_ui_currency_ws_jin_small", card_frame_name = "a_ui_currency_ws_jin_big", star_frame_name = "a_ui_currency_ws_jin_big_xing", star_half_frame_name = "a_ui_currency_ws_jin_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_cheng", battle_card_frame_name = "a_zd_kapai_cheng", RGBA = Color.New(255/255, 227/255, 70/255) ,  HC = "FFE346", hero_3d_base = "Fx_Formation_Yellow01"},--5金色
    {name = "new_str_0327", hero_item_frame = "a_ui_currency_ws_hong_small", card_frame_name = "a_ui_currency_ws_hong_big", star_frame_name = "a_ui_currency_ws_hong_big_xing", star_half_frame_name = "a_ui_currency_ws_hong_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_hong", battle_card_frame_name = "a_zd_kapai_hong", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Red01"},--6红色
    {name = "new_str_0326", hero_item_frame = "a_ui_currency_ws_bojin_small", card_frame_name = "a_ui_currency_ws_bojin_big", star_frame_name = "a_ui_currency_ws_bojin_big_xing", star_half_frame_name = "a_ui_currency_ws_bojin_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_bojin", battle_card_frame_name = "a_zd_kapai_bojin", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_white01"},--7白色
    {name = "new_str_0325", hero_item_frame = "a_ui_currency_ws_cai_small", card_frame_name = "a_ui_currency_ws_cai_big", star_frame_name = "a_ui_currency_ws_cai_big_xing", star_half_frame_name = "a_ui_currency_ws_cai_big_xing-", line_frame_name = "a_ui_currency_pinzhidi_cai", battle_card_frame_name = "a_zd_kapai_cai", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "Fx_Formation_Col01"},--8彩色
}

M.HERO_GACHA_QUALITY_SETTING = {
    {card_frame_name = "a_ck_pinjie_green", card_frame_name2 = "a_ck_pinjie_green_shang", item_card_frame_name = "a_xn_daojudi_lvse", wenli = false},--1灰
    {card_frame_name = "a_ck_pinjie_green", card_frame_name2 = "a_ck_pinjie_green_shang", item_card_frame_name = "a_xn_daojudi_lvse", wenli = false},--2绿
    {card_frame_name = "a_ck_pinjie_lan",card_frame_name2 = "a_ck_pinjie_lan_shang",  item_card_frame_name = "a_xn_daojudi_lanse", wenli = false},--3蓝
    {card_frame_name = "a_ck_pinjie_zi", card_frame_name2 = "a_ck_pinjie_zi_shang", item_card_frame_name = "a_xn_daojudi_zise", wenli = true},--4紫
    {card_frame_name = "a_ck_pinjie_jin", card_frame_name2 = "a_ck_pinjie_jin_shang", item_card_frame_name = "a_xn_daojudi_jin", wenli = true},--5金色
    {card_frame_name = "a_ck_pinjie_hong", card_frame_name2 = "a_ck_pinjie_hong_shang", item_card_frame_name = "a_xn_daojudi_hong", wenli = true},--6红色
    {card_frame_name = "a_ck_pinjie_bojin", card_frame_name2 = "a_ck_pinjie_bojin_shang", item_card_frame_name = "a_xn_daojudi_bojin", wenli = true},--7白色
    {card_frame_name = "a_ck_pinjie_cai", card_frame_name2 = "a_ck_pinjie_cai_shang", item_card_frame_name = "a_xn_daojudi_cai", wenli = true},--8彩色
}

--[[
    card_frame_name --长方形品质框
    big_frame_add_name --长方形品质框+
    line_frame_name --英雄界面线形品质框
    rhomb_frame_name --英雄界面菱形品质框
]]
M.QUALITY_FRAME = {
    {card_frame_name = "a_ui_currency_ws_lan_big", line_frame_name = "a_ui_currency_pinzhidi_lv", rhomb_frame_name = "a_ws_daojukuang_hui" ,hero_star = 0, evo_name = "global_hero_evo1"}, --1 灰色
    {card_frame_name = "a_ui_currency_ws_lan_big", line_frame_name = "a_ui_currency_pinzhidi_lv", rhomb_frame_name = "a_ws_daojukuang_lv"  ,hero_star = 0, evo_name = "global_hero_evo2"}, --2 绿色
    {card_frame_name = "a_ui_currency_ws_lan_big", big_frame_add_name = "a_ui_currency_ws_lan+", line_frame_name = "a_ui_currency_pinzhidi_lan", rhomb_frame_name = "a_ws_daojukuang_lan" ,hero_star = 0, evo_name = "global_hero_evo3"}, --3 蓝色
    {card_frame_name = "a_ui_currency_ws_lan_big", big_frame_add_name = "a_ui_currency_ws_lan+", line_frame_name = "a_ui_currency_pinzhidi_lan", rhomb_frame_name = "a_ws_daojukuang_lan" ,hero_star = 1, evo_name = "global_hero_evo4"}, --4 蓝+ 
    {card_frame_name = "a_ui_currency_ws_zi_big", big_frame_add_name = "a_ui_currency_ws_zi+", line_frame_name = "a_ui_currency_pinzhidi_zi", rhomb_frame_name = "a_ws_daojukuang_zi"  ,hero_star = 0, evo_name = "global_hero_evo5"}, --5 紫色
    {card_frame_name = "a_ui_currency_ws_zi_big", big_frame_add_name = "a_ui_currency_ws_zi+",line_frame_name = "a_ui_currency_pinzhidi_zi", rhomb_frame_name = "a_ws_daojukuang_zi" ,hero_star = 1, evo_name = "global_hero_evo6"}, --6 紫+ 
    {card_frame_name = "a_ui_currency_ws_jin_big", big_frame_add_name = "a_ui_currency_ws_jin+", line_frame_name = "a_ui_currency_pinzhidi_cheng", rhomb_frame_name = "a_ws_daojukuang_jin" ,hero_star = 0, evo_name = "global_hero_evo7"}, --7 金
    {card_frame_name = "a_ui_currency_ws_jin_big", big_frame_add_name = "a_ui_currency_ws_jin+", line_frame_name = "a_ui_currency_pinzhidi_cheng", rhomb_frame_name = "a_ws_daojukuang_jin" ,hero_star = 1, evo_name = "global_hero_evo8"}, --8 金+
    {card_frame_name = "a_ui_currency_ws_jin_big", big_frame_add_name = "a_ui_currency_ws_jin+", line_frame_name = "a_ui_currency_pinzhidi_cheng", rhomb_frame_name = "a_ws_daojukuang_jin" ,hero_star = 2, evo_name = "global_hero_evo9"}, --9 金++
    {card_frame_name = "a_ui_currency_ws_hong_big", big_frame_add_name = "a_ui_currency_ws_hong+", line_frame_name = "a_ui_currency_pinzhidi_hong", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 0, evo_name = "global_hero_evo10"}, --10 红 
    {card_frame_name = "a_ui_currency_ws_hong_big", big_frame_add_name = "a_ui_currency_ws_hong+", line_frame_name = "a_ui_currency_pinzhidi_hong", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 1, evo_name = "global_hero_evo11"}, --11 红 +
    {card_frame_name = "a_ui_currency_ws_hong_big", big_frame_add_name = "a_ui_currency_ws_hong+", line_frame_name = "a_ui_currency_pinzhidi_hong", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 2, evo_name = "global_hero_evo12"}, --12 红 ++
    {card_frame_name = "a_ui_currency_ws_hong_big", big_frame_add_name = "a_ui_currency_ws_hong+", line_frame_name = "a_ui_currency_pinzhidi_hong", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 3, evo_name = "global_hero_evo13"}, --13 红 +++
    {card_frame_name = "a_ui_currency_ws_bojin_big", big_frame_add_name = "a_ui_currency_ws_bojin+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 0, evo_name = "global_hero_evo14"}, --14 白
    {card_frame_name = "a_ui_currency_ws_bojin_big", big_frame_add_name = "a_ui_currency_ws_bojin+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 1, evo_name = "global_hero_evo15"}, --15 1
    {card_frame_name = "a_ui_currency_ws_bojin_big", big_frame_add_name = "a_ui_currency_ws_bojin+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 2, evo_name = "global_hero_evo16"}, --16 2
    {card_frame_name = "a_ui_currency_ws_bojin_big", big_frame_add_name = "a_ui_currency_ws_bojin+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 3, evo_name = "global_hero_evo17"}, --17 3
    {card_frame_name = "a_ui_currency_ws_bojin_big", big_frame_add_name = "a_ui_currency_ws_bojin+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 4, evo_name = "global_hero_evo18"}, --18 4
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 0, evo_name = "global_hero_evo19"}, --19 彩
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 1, evo_name = "global_hero_evo20"}, --20 1
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 2, evo_name = "global_hero_evo21"}, --21 2
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 3, evo_name = "global_hero_evo22"}, --22 3
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 4, evo_name = "global_hero_evo23"}, --22 4
    {card_frame_name = "a_ui_currency_ws_cai_big", big_frame_add_name = "a_ui_currency_ws_cai+", line_frame_name = "a_ui_currency_pinzhidi_cai", rhomb_frame_name = "a_ws_daojukuang_hong" ,hero_star = 5, evo_name = "global_hero_evo24"}, --22 5
}

M.HERO_SKIN_QUALITY = {
    [1] = {icon = "a_hero_skin_01"},
    [2] = {icon = "a_hero_skin_02"},
    [3] = {icon = "a_hero_skin_03"},
    [4] = {icon = "a_hero_skin_04"},
    [5] = {icon = "a_hero_skin_05"},
    [6] = {icon = "a_hero_skin_06"},
    [7] = {icon = "a_hero_skin_07"},
}


M.HEIRLOOM_LIBRARY_QUALITY = {
    [3] = {bg = "a_ui_currency_dj_lan", icon = "a_cwbz_icon_lan"},
    [5] = {bg = "a_ui_currency_dj_zi", icon = "a_cwbz_icon_zi"},
    [6] = {bg = "a_ui_currency_dj_jin", icon = "a_cwbz_icon_jin"},
}

--[[
   英雄属性种类
]]
M.TYPE_HERO_PROPERTY = {
    [0] ={pro_icon = "a_ws_dingwei_bili", name =  "new_str_1033" , des = "tid#herotype4" }, --1 通用
    {pro_icon = "a_ws_dingwei_bili", name =  "new_str_0146" , des = "tid#herotype4" }, --1 力量
    {pro_icon = "a_ws_dingwei_shenfa", name =  "new_str_0147" , des = "tid#herotype5" }, --2 敏捷
    {pro_icon = "a_ws_dingwei_wuxing", name =  "new_str_0148", des = "tid#herotype6" }, --3 内力
}

M.TYPE_MYSTIC = {
    { name =  "mystic_str_0015", pro_icon = "a_lhg_xiantian"   }, --1 先天
    { name =  "mystic_str_0016", pro_icon = "a_lhg_juexue"   }, --2 绝学
    { name =  "mystic_str_0017", pro_icon = "a_lhg_shenpin"   }, --3 神技
}

--槽位对应的经脉深度
M.SLOTPOS_SIGDEEP=
{
    [1]=3,--圆满
    [2]=5,--筑基
    [3]=7,--金丹
    [4]=8,--元婴
    [5]=9--化神
}

---经脉种类对应经脉深度
M.MERIDIANTYPE_SIGDEEP={
    XIAOZHOUTIAN=1,--小周天
    DAZHOUTIAN=2,--大周天
    YUANMAN=3,--圆满
    HUAJING=4,--化境
    ZHUJI=5,--筑基
    JIEJING=6,--结晶
    JINDAN=7,--金丹
    YUANYING=8,--元婴
    HUASHEN=9--化神
}


-- 1.冲、2：带、3：任、4：督
M.TYPE_MERIDIAN_OLD = {
    { name =  "hero_ui_str_0022", pro_icon = "a_cjg_icon_wai", short_name = "new_str_0753", open_point_img = "a_jm_chongmai_kedianliang", no_open_point_img = "a_jm_chongmai", pass_line_img = "a_jm_chongmai_Linelight", no_pass_line_img = "a_jm_chongmai_Line", cur_active_effect = "UI_HeroInfo_QiJing_001" , name_color = Color( 157/255, 225/255, 238/255)  }, --1 冲脉
    { name =  "hero_ui_str_0025", pro_icon = "a_cjg_icon_shenfa", short_name = "new_str_0754", open_point_img = "a_jm_daimai_kedianliang", no_open_point_img = "a_jm_daimai", pass_line_img = "a_jm_daimai_Linelight", no_pass_line_img = "a_jm_daimai_Line", cur_active_effect = "UI_HeroInfo_QiJing_001"  , name_color = Color( 247/255, 139/255, 118/255) }, --2 带脉
    { name =  "hero_ui_str_0023", pro_icon = "a_cjg_icon_nei", short_name = "new_str_0755", open_point_img = "a_jm_ewnmai_kedianliang", no_open_point_img = "a_jm_renmai", pass_line_img = "a_jm_renmai_Linelight", no_pass_line_img = "a_jm_renmai_Line", cur_active_effect = "UI_HeroInfo_RenMai_001" , name_color = Color( 167/255, 224/255, 183/255) }, --3 任脉
    { name =  "hero_ui_str_0021", pro_icon = "a_cjg_icon_jueji", short_name = "new_str_0756", open_point_img = "a_jm_dumai_kedianliang", no_open_point_img = "a_jm_dumai", pass_line_img = "a_jm_dumai_Linelight", no_pass_line_img = "a_jm_dumai_Line", cur_active_effect = "UI_HeroInfo_DuMai_001" , name_color = Color( 255/255, 212/255, 120/255) }, --4 督脉
}

-- 1.天、2：绝、
M.TYPE_MERIDIAN = {
    { name =  "mystic_str_0056", pro_icon = "a_lhg_xiantian", short_name = "mystic_str_0058", open_point_img = "a_jm_chongmai_kedianliang", no_open_point_img = "a_jm_chongmai", pass_line_img = "a_jm_chongmai_Linelight", no_pass_line_img = "a_jm_chongmai_Line", cur_active_effect = "UI_HeroInfo_QiJing_001" , name_color = Color( 157/255, 225/255, 238/255)  }, --1 冲脉
    { name =  "mystic_str_0057", pro_icon = "a_lhg_juexue", short_name = "mystic_str_0059", open_point_img = "a_jm_daimai_kedianliang", no_open_point_img = "a_jm_daimai", pass_line_img = "a_jm_daimai_Linelight", no_pass_line_img = "a_jm_daimai_Line", cur_active_effect = "UI_HeroInfo_QiJing_001"  , name_color = Color( 247/255, 139/255, 118/255) }, --2 带脉
    { name =  "mystic_str_0085", pro_icon = "a_lhg_shenpin", short_name = "mystic_str_0086", open_point_img = "a_jm_ewnmai_kedianliang", no_open_point_img = "a_jm_renmai", pass_line_img = "a_jm_renmai_Linelight", no_pass_line_img = "a_jm_renmai_Line", cur_active_effect = "UI_HeroInfo_RenMai_001" , name_color = Color( 167/255, 224/255, 183/255) }, --3 任脉
    { name =  "hero_ui_str_0021", pro_icon = "a_cjg_icon_jueji", short_name = "new_str_0756", open_point_img = "a_jm_dumai_kedianliang", no_open_point_img = "a_jm_dumai", pass_line_img = "a_jm_dumai_Linelight", no_pass_line_img = "a_jm_dumai_Line", cur_active_effect = "UI_HeroInfo_DuMai_001" , name_color = Color( 255/255, 212/255, 120/255) }, --4 督脉
}

--1坦、2战、3刺客、4游侠、5辅助、6法师
M.CLASS_MERIDIAN = {
    {pro_icon = "a_ui_currency_icon_tan", arena_icon = "a_ui_zy_tan"},
    {pro_icon = "a_ui_currency_icon_zhan", arena_icon = "a_ui_zy_zhan"},
    {pro_icon = "a_ui_currency_icon_ci", arena_icon = "a_ui_zy_ci"},
    {pro_icon = "a_ui_currency_icon_xia", arena_icon = "a_ui_zy_xia"},
    {pro_icon = "a_ui_currency_icon_fu", arena_icon = "a_ui_zy_fu"},
    {pro_icon = "a_ui_currency_icon_fa", arena_icon = "a_ui_zy_shu"},
}

M.QUALITY_MYSTIC_SETTING = {
    {name = "new_str_0333", frame_name = "a_ui_currency_dj_lan", card_frame_name = "ui_YX_lan", card_frame_name2 = "ui_zd_card_lan", is_add = false, icon = "icon_lan", RGBA = Color.New(109/255, 196/255, 244/255) , HC = "6DC4F4", hero_3d_base = "fx_formation_blue_01" }, --3 蓝色
    {name = "new_str_0331", frame_name = "a_ui_currency_dj_zi", card_frame_name = "ui_YX_zi", card_frame_name2 = "ui_zd_card_zi", is_add = false, icon = "icon_zi", RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "fx_formation_purple_01" }, --5 紫色
    {name = "new_str_0329", frame_name = "a_ui_currency_dj_jin", card_frame_name = "ui_YX_jin", card_frame_name2 = "ui_zd_card_huang", is_add = false, icon = "icon_jin", RGBA = Color.New(255/255, 227/255, 70/255) , HC = "FFE346", hero_3d_base = "fx_formation_yellow_01" }, --7 金
    {name = "new_str_0327", frame_name = "a_ui_currency_dj_hong", card_frame_name = "ui_YX_hong", card_frame_name2 = "ui_zd_card_bai", is_add = false, icon = "icon_hong", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_red_01" }, --9 红
    {name = "new_str_0325", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --11 彩
    {name = "new_str_0324", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai1", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --12 彩1星
    {name = "new_str_0323", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai2", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --13 彩2星
    {name = "new_str_0322", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai3", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --14 3星
    {name = "new_str_0321", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai4", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --15 4星
    {name = "new_str_0320", frame_name = "a_ui_currency_dj_jia", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai5", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --16 5星
}

--[[
    属性id表 {"atk", "hp", "def", "dodge", "critrate", "hr", "res", "atd", "resi", "sunder"}
    与common表的战力参数对应
]]
M.ATTRS_TAB = {
    [1] = "atk",  -- 攻击
    [2] = "hp",  -- 生命
    [3] = "def", -- 防御
    [4] = "dodge", -- 闪避
    [5] = "critrate", -- 暴击
    [6] = "hr", -- 命中
    [7] = "res", -- 内伤减免
    [8] = "atd", -- 外伤减免
    [9] =  "resi", -- 抗暴率
    [10] = "sunder", -- 斗气特攻率
    [12] =  "magicdamage", -- 内伤增加
    [13] =  "physicaldamage", -- 外伤增加
    [14] =  "haste", -- 攻击速度
    [15] =  "discontrol", -- 坚韧
    [16] =  "rediscontrol", -- 坚韧抵抗
    [17] =  "disres", -- 内伤加深
    [18] =  "disatd", -- 外伤加深
    [19] =  "discrit", --爆伤抵抗
}

--[[
    英雄种族
    龙庭（青龙）金--race_id 1
    草莽（朱雀）火--race_id 2
    世族（玄武）木--race_id 3
    异族（白虎) 水--race_id 4
    阳--race_id 5
    阴--race_id 6
    元--race_id 7
]]
M.TYPE_HERO_RACE = {
    { race_icon = "a_ui_qinglong", big_race_icon = "a_ui_qinglong", advanced_race_icon = "a_ui_currency_wszhenying_jin", name =  "new_str_0142", jc_icon = "a_szjc_jin", arena_icon = "a_ljsz_jinshili" }, --1 帝王丘 青龙 龙庭 金
    { race_icon = "a_ui_zhuque", big_race_icon = "a_ui_zhuque", advanced_race_icon = "a_ui_currency_wszhenying_huo", name =  "new_str_0144", jc_icon = "a_szjc__huo", arena_icon = "a_ljsz_huoshili"   }, --2 弘武郡 朱雀 草莽 火
    { race_icon = "a_ui_xuanwu", big_race_icon = "a_ui_xuanwu", advanced_race_icon = "a_ui_currency_wszhenying_mu", name =  "new_str_0143", jc_icon = "a_szjc_mu", arena_icon = "a_ljsz_mushili"   }, --3 金安国 玄武 世族 木
    { race_icon = "a_ui_baihu", big_race_icon = "a_ui_baihu", advanced_race_icon = "a_ui_currency_wszhenying_shui", name =  "new_str_0145", jc_icon = "a_szjc_shui", arena_icon = "a_ljsz_shuishili"   }, --4 不详谷 白虎 异族 水
    { race_icon = "a_ui_guangming", big_race_icon = "a_ui_guangming", advanced_race_icon = "a_ui_currency_wszhenying_shui", name =  "new_str_0237", jc_icon = "a_szjc_yang", arena_icon = "a_ljsz_yangshili"   }, --5 道
    { race_icon = "a_ui_heian", big_race_icon = "a_ui_heian", advanced_race_icon = "a_ui_currency_wszhenying_shui", name =  "new_str_0238", jc_icon = "a_szjc_yin", arena_icon = "a_ljsz_yinshili"   }, --6 鬼
    { race_icon = "a_ui_yuan", big_race_icon = "a_ui_yuan", advanced_race_icon = "a_ui_currency_wszhenying_shui", name =  "new_str_1089", jc_icon = "a_szjc_yang", arena_icon = "a_ui_xuan1"   }, --7 元
    --{ race_icon = "a_ui_yuan", big_race_icon = "a_ui_yuan", advanced_race_icon = "a_ui_currency_wszhenying_shui", name =  "new_str_1089", jc_icon = "a_szjc_yang", arena_icon = "a_ui_xuan1"   }, --8 SP
}

--[[
    英雄定位
]]
M.TYPE_HERO_LOCATION_1 = {
    { loc_icon = "a_ws_dingwei_fanghu", name =  "fanghu_text", des = "tid#herolocate4" }, --1 防护
    { loc_icon = "a_ws_dingwei_waigong", name =   "waigong_text", des = "tid#herolocate5" }, --2 外功
    { loc_icon = "a_ws_dingwei_neigong", name =   "neigong_text", des = "tid#herolocate6" }, --3 内功
    { loc_icon = "a_ws_dingwei_teshu", name =   "teshu_text", des = "tid#herolocate7" }, --4 特殊
}

--[[
    英雄定位
]]
M.TYPE_HERO_LOCATION_2 = {
    { loc_icon = "a_ws_dingwei_jinzhan", name =  "new_str_0940", des = "tid#herolocate1" }, --1 近战
    { loc_icon = "a_ws_dingwei_yuancheng", name =   "new_str_0939", des = "tid#herolocate2" }, --2 远程
    { loc_icon = "a_ws_dingwei_cike", name =   "new_str_0938", des = "tid#herolocate3" }, --3 刺杀
}


-- 常用颜色
M.COMMON_COLLOR = {
    COMMON_1 = Color( 255/255, 241/255, 205/255),
    COMMON_2 = Color( 120/255, 64/255, 40/255),
    --COMMON_1 = Color( 255/255, 255/255, 255/255),
    --COMMON_2 = Color( 243/255, 240/255, 227/255),
    COMMON_3 = Color( 207/255, 193/255, 162/255),
    COMMON_4 = Color( 184/255, 186/255, 210/255),
    COMMON_5 = Color( 155/255, 173/255, 213/255),
    COMMON_6 = Color( 117/255, 123/255, 202/255),
    COMMON_7 = Color( 96/255, 105/255, 138/255),
    COMMON_8 = Color( 85/255, 113/255, 142/255),
    COMMON_9 = Color( 81/255, 99/255, 145/255),
    COMMON_10 = Color( 58/255, 72/255, 94/255),
    COMMON_11 = Color( 243/255, 53/255, 53/255),
    COMMON_12 = Color( 175/255, 108/255, 64/255),
    COMMON_13 = Color( 61/255, 116/255, 13/255),
    COMMON_14 = Color( 19/255, 27/255, 39/255),
    COMMON_15 = Color( 0/255, 0/255, 0/255),
    COMMON_16 = Color( 46/255, 73/255, 76/255),
    COMMON_17 = Color( 41/255, 136/255, 137/255),
    COMMON_18 = Color( 74/255, 237/255, 109/255),
    COMMON_19 = Color( 230/255, 45/255, 45/255),
    COMMON_20 = Color( 19/255, 27/255, 39/255,127/255),
    COMMON_21 = Color( 141/255, 80/255, 15/255),
    COMMON_22 = Color( 99/255, 238/255, 255/255),
    COMMON_23 = Color( 183/255, 65/255, 65/255),
    COMMON_24 = Color( 255/255, 241/255, 205/255),
    COMMON_25 = Color( 120/255, 49/255, 14/255),
    COMMON_26 = Color( 210/255, 70/255, 70/255),
    COMMON_27 = Color( 176/255, 90/255, 47/255),
    COMMON_28 = Color( 47/255, 255/255, 0/255),
    COMMON_TOGGLE = Color( 255/255, 241/255, 205/255),
    COMMON_TOGGLE_FOCUS = Color( 120/255, 64/255, 40/255),
}

-- 描边常用颜色
M.COMMON_COLLOR_OUTLINE = {
    COMMON_1 = Color( 255/255, 255/255, 255/255, 100/255),
    COMMON_2 = Color( 243/255, 240/255, 227/255, 100/255),
    COMMON_3 = Color( 207/255, 193/255, 162/255, 100/255),
    COMMON_4 = Color( 184/255, 186/255, 210/255, 100/255),
    COMMON_5 = Color( 155/255, 173/255, 213/255, 100/255),
    COMMON_6 = Color( 117/255, 123/255, 202/255, 100/255),
    COMMON_7 = Color( 96/255, 105/255, 138/255, 100/255),
    COMMON_8 = Color( 85/255, 113/255, 142/255, 100/255),
    COMMON_9 = Color( 81/255, 99/255, 145/255, 100/255),
    COMMON_10 = Color( 58/255, 72/255, 94/255, 100/255),
    COMMON_11 = Color( 243/255, 53/255, 53/255, 100/255),
    COMMON_12 = Color( 175/255, 108/255, 64/255, 100/255),
    COMMON_13 = Color( 61/255, 116/255, 13/255, 100/255),
    COMMON_14 = Color( 19/255, 27/255, 39/255, 100/255),
    COMMON_15 = Color( 0/255, 0/255, 0/255, 100/255),
    COMMON_16 = Color( 46/255, 73/255, 76/255, 100/255),
    COMMON_17 = Color( 41/255, 136/255, 137/255, 100/255),
    COMMON_18 = Color( 74/255, 237/255, 109/255, 100/255),
    COMMON_19 = Color( 230/255, 45/255, 45/255, 100/255),
}

--BOUNTY_RANK
M.BOUNTY_RANK = {
    { name = "new_str_0101", icon = "a_tainjilou_dengji_baise", frame = "a_ui_currency_dj_hui", RGBA = Color.New(1, 1, 1)  }, -- 白  
    { name = "new_str_0102", icon = "a_tainjilou_dengji_lvse", frame = "a_ui_currency_dj_lv ", RGBA = Color.New(153/255, 255/255, 43/255)  }, -- 绿 
    { name = "new_str_0103", icon = "a_tainjilou_dengji_lanse", frame = "a_ui_currency_dj_lan ", RGBA = Color.New(128/255, 215/255, 255/255) }, --蓝 
    { name = "new_str_0104", icon = "a_tainjilou_dengji_zise", frame = "a_ui_currency_dj_zi ", RGBA = Color.New(250/255, 165/255, 244/255)  }, --紫 
    { name = "new_str_0105", icon = "a_tainjilou_dengji_juse", frame = "a_ui_currency_dj_jin ", RGBA = Color.New(255/255, 232/255, 90/255) }, --橙 
    { name = "new_str_0106", icon = "a_tainjilou_dengji_hongse", frame = "a_ui_currency_dj_jia", RGBA = Color.New(255/255, 0/255, 0/255) }, -- 红  
}

M.RANK_TOP_THREE_IMG = {
    [1] = {rank = "a_phb_icon_1", atlas = "common_ui", rank2 = "a_dflj_yi", atlas2 = "active_ui"},
    [2] = {rank = "a_phb_icon_2", atlas = "common_ui", rank2 = "a_dflj_er", atlas2 = "active_ui"},
    [3] = {rank = "a_phb_icon_3", atlas = "common_ui", rank2 = "a_dflj_san", atlas2 = "active_ui"},
    [4] = {rank = "a_phb_icon_4", atlas = "common_ui", rank2 = ""},
    [5] = {rank = "a_phb_icon_5", atlas = "common_ui", rank2 = ""},
}

-- 0: 女  1: 男  -1: 未设置
M.GENDER_CFG = {
    [0] = {icon = "tjl_nvxing", atlas = "common_ui", name = "new_str_0213"},
    [1] = {icon = "tjl_nanxing", atlas = "common_ui", name = "new_str_0212"},
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
M.BATTLE_MODE = Battle.BattleGlobalConfig.BATTLE_MODE

M.BATTLE_MODE_CFG = Battle.BattleGlobalConfig.BATTLE_MODE_CFG

-- 联盟职位
M.UNION_POS = {
    PRESIDENT = 1, -- 会长
    PRESIDENT_VICE = 2, -- 副会长
    COMMON = 3, -- 普通
}

-- 对成员的操作
M.UNION_HANDLE_ID = {
    PROMOTE_ELDER = 1, -- 提升到副会长
    CHANGE_ELITE = 2, -- 提升到无谓之手
    DEMOTE = 3, -- 撤销副会长
    DELETE = 4,  -- 提出公会
    BLACK = 5, -- 加入黑名单
    ABDICATE = 6, -- 转让会长
    SEND_MAIL = 7, --发送邮件
}

-- 联盟职位操作
M.UNION_POS_HANDLE = {
    [M.UNION_POS.PRESIDENT] = {
        [M.UNION_POS.PRESIDENT] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.SEND_MAIL},
        [M.UNION_POS.PRESIDENT_VICE] = {M.UNION_HANDLE_ID.ABDICATE, M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DEMOTE, M.UNION_HANDLE_ID.DELETE, M.UNION_HANDLE_ID.SEND_MAIL},
        [M.UNION_POS.COMMON] = {M.UNION_HANDLE_ID.ABDICATE, M.UNION_HANDLE_ID.PROMOTE_ELDER, M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DELETE, M.UNION_HANDLE_ID.SEND_MAIL},
    },
    [M.UNION_POS.PRESIDENT_VICE] = {
        [M.UNION_POS.PRESIDENT] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.SEND_MAIL},
        [M.UNION_POS.PRESIDENT_VICE] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.SEND_MAIL},
        [M.UNION_POS.COMMON] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DELETE, M.UNION_HANDLE_ID.SEND_MAIL},
    },
}

M.MYSTIC_TYPE = {
    EXTERNAL = 1,
    INTERNAL = 2,
    STEPS = 3,
    MASTER = 4,
}

-- 高阶竞技场段位颜色
M.ARENA_SEGMENT_COLLOR = {
    [1] = Color( 255/255, 216/255, 111/255),
    [2] = Color( 209/255, 231/255, 255/255),
    [3] = Color( 231/255, 236/255, 244/255),
    [4] = Color( 230/255, 242/255, 243/255),
    [5] = Color( 255/255, 226/255, 137/255),
    [6] = Color( 240/255, 255/255, 252/255),
    [7] = Color( 210/255, 250/255, 241/255),
    [8] = Color( 252/255, 255/255, 255/255),
}

-- 元素属性
M.ELEMENT_ATTR = {
    {name ="木"},
    {name ="火"},
    {name ="土"},
    {name ="金"},
    {name ="水"},
}

M.WORLD_MAP_EVENT = {
    ADVENTURE_EVENT = 1, --奇遇
    LIMIT_TIME_EVENT = 2, -- 限时
    NORMAL_EVENT = 3, -- 普通
    REGIONAL_EVENT = 4, -- 剧情
    MAIN_EVENT = 5, -- 主线
    BRANCH_EVENT = 6, -- 支线
    BIOGRAPHY = 7, -- 传记
}

M.WORLD_MAP_POINT_MODE = 
{
    AssetPoint = 0, --资源点
    TransPoint = 1, -- //传送点
    Npc = 2, -- //NPC点
    FunctionPoint = 3, -- //功能点
    NpcTrigger = 4, -- 触发奇遇事件
    RewardAssetPoint = 6, -- 宝箱资源点
}

--1 : CHEST 容器类道具           配置内容: [[类型，id，数量],[类型，id，数量]]
--2:  RANDOM_CHEST 需要随机的容器类道具  配置内容:  item_box表 id
--3 : 可选1个内容的容器           配置内容: [类型，id，数量],[类型，id，数量]
--4 : IDLE_COIN 挂机金币        配置内容 :  挂机时长秒
--5 : IDLE_HERO_EXP 挂机英雄经验  配置内容 :  挂机时长秒
--6 : IDLE_DUST 挂机粉尘        配置内容 :  挂机时长秒
--7 : IDLE_CHD 挂机金币+英雄经验+粉尘  配置内容 :  挂机时长秒
--8 : 系统消耗的功能性道具
--9 : 按种族开的卡,4选1,只有种族1,2,3,4按顺序填写    配置内容[gacha_hero的hero_pool_id,hero_pool_id,hero_pool_id,hero_pool_id]
--10 : 装备经验                配置内容 : 装备经验值数量
--11：代币                      配置内容 : RMB金额
--12：双倍充值卷            配置内容：RMB金额
--13：走gacha_hero卡池的道具        配置内容：gacha_hero的hero_pool_id
--14: 可选多份内容的容器       配置内容: [类型，id，数量],[类型，id，数量]
--15：任务道具
--16：阿闲好感度道具
--17：条件礼包
--18：赛季英雄兑换道具

M.ITEM_TYPE =
{
    CHEST = 1,
    RANDOM_CHEST = 2,
    ONE_BOX = 3,
    IDLE_COIN = 4,
    IDLE_HERO_EXP = 5,
    IDLE_DUST = 6,
    IDLE_CHD = 7,
    FUNC_TIEM = 8,
    RACE_HERO = 9,
    EQUIP_EXP = 10,
    TOKEN_MONEY = 11,
    DOUBLE_RECHARGE_VOLUME = 12,
    GACHA_HERO_ITEM = 13,
    MUL_BOX = 14,
    TASK_ITEM = 15,
    FAVOR_ITEM = 16,
    CONDITION_BOX = 17,
    SEASON_BOX = 20,
    SEASON_CHANGE_HERO = 24,
}

--五行对应类型数据
M.FIVE_ELEMENT_TYPE =
{
    {img = "a_ui_xuanwu", name = "new_str_0143"}, --木
    {img = "a_ui_zhuque", name = "new_str_0144"}, --火
    {img = "a_ui_baihu", name = "土"}, --土
    {img = "a_ui_qinglong", name = "new_str_0142"}, --金
    {img = "a_ui_baihu", name = "new_str_0145"}, --水
}

M.RACE_TOGGLE_TAB_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text",},
    {btn = "martial_1_toggle", name = "martial_1_text",},
    {btn = "martial_2_toggle", name = "martial_2_text",},
    {btn = "martial_3_toggle", name = "martial_3_text",},
    {btn = "martial_4_toggle", name = "martial_4_text",},
    {btn = "martial_5_toggle", name = "martial_5_text",},
    {btn = "martial_6_toggle", name = "martial_6_text",},
}

M.MULTI_FORMATION_ICON = {
    "a_zd_sz_biandui_1",
    "a_zd_sz_biandui_2",
    "a_zd_sz_biandui_3",
    "a_zd_sz_biandui_yu",
}

M.TYPE_MONEY = {
    {name = "CNY", sign_name = "¥",},
    {name = "USD", sign_name = "$",},
    {name = "GBP", sign_name = "£",},
    {name = "EUR", sign_name = "€",},
    {name = "KRW", sign_name = "₩",},
    {name = "RUB", sign_name = "₽",},
    {name = "INR", sign_name = "₹",},
    {name = "THB", sign_name = "฿",},
    {name = "VND", sign_name = "₫",},
    {name = "HKD", sign_name = "HK$",},
    {name = "TWD", sign_name = "NT$",},
    {name = "SGD", sign_name = "S$",},
    {name = "MYR", sign_name = "RM",},
    {name = "MOP", sign_name = "MOP$",},
    {name = "JPY", sign_name = "¥",},
    {name = "PHP", sign_name = "₱",},
    {name = "CAD", sign_name = "C$",},
}

--装备类型
M.TYPE_EQUIP = {
    "equip_str_001",
    "equip_str_002",
    "equip_str_003",
    "equip_str_004",
    "equip_str_005"
}

M.CHINESE_NUM_LAN = {"num_str_0000", "num_str_0001", "num_str_0002", "num_str_0003", "num_str_0004", "num_str_0005", "num_str_0006", "num_str_0007", "num_str_0008", "num_str_0009"}
M.CHINESE_UNIT_LAN = {"", "unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0004", "unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0005","unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0004"}


M.MYSTIC_ICON_COMMON_SETTING = {
    [5] = {mask_img = "a_lhg_zise", icon_img_di = "a_lhg_zise_di"},
    [7] = {mask_img = "a_lhg_chengse", icon_img_di = "a_lhg_chengse_di"},
    [9] = {mask_img = "a_lhg_hongse", icon_img_di = "a_lhg_hongse_di"},
}

M.RACE_TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text",},
    {btn = "martial_1_toggle", name = "martial_1_text",},
    {btn = "martial_4_toggle", name = "martial_4_text",},
    {btn = "martial_2_toggle", name = "martial_2_text",},
    {btn = "martial_3_toggle", name = "martial_3_text",},
    {btn = "martial_6_toggle", name = "martial_6_text",},
    {btn = "martial_5_toggle", name = "martial_5_text",},
    {btn = "martial_7_toggle", name = "martial_7_text",},
    {btn = "martial_sp_toggle", name = "martial_sp_text",},
}

M.HERO_SIG_NUM = 4

M.HERO_SIG_MAX_LV = 50

M.HERO_SIG_DEEP_MAX = 9

M.MYSTIC_MAX_LV=50


--[[
    英雄种族
   金--race_id 1
   火--race_id 2
   木--race_id 3
   水--race_id 4
]]
M.MINING_RACE_ICON = {
    {name = "a_mjxb_jin" },
    {name = "a_mjxb_huo" },
    {name = "a_mjxb_mu" },
    {name = "a_mjxb_shui" },
}

--[[
    英雄种族
   金--race_id 1
   火--race_id 2
   木--race_id 3
   水--race_id 4
]]
M.ACTIVE_MINING_RACE_ICON = {
    {name = "a_mjxb_plt_jin" },
    {name = "a_mjxb_plt_huo" },
    {name = "a_mjxb_plt_mu" },
    {name = "a_mjxb_plt_shui" },
    {name = "a_mjxb_plt_yang" },
    {name = "a_mjxb_plt_yin" },
    {name = "a_mjxb_plt_jin" },
}


M.HERO_FETTER_TYPE = {
    {name = "item_str_0001" }, --1
    {name = "item_str_0002" }, --2
    {name = "item_str_0003" }, --3 
    {name = "item_str_0004" }, --4
    {name = "item_str_0005" }, --5
    {name = "item_str_0006" }, --6
    {name = "item_str_0007" }, --7
    {name = "item_str_0008" }, --8
    {name = "item_str_0009" }, --9
    {name = "item_str_0010" }, --10
}

M.HERO_ROLE_UPGRADE_TYPE = {
    {icon = "a_tjsj_zhiye_1green",   color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 35/255, 106/255, 50/255,1)},
    {icon = "a_tjsj_zhiye_2blue",    color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 33/255, 102/255, 122/255,1)},
    {icon = "a_tjsj_zhiye_3purple",  color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 100/255, 49/255, 195/255,1)},
    {icon = "a_tjsj_zhiye_4gold",    color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 170/255, 114/255, 35/255,1)},
    {icon = "a_tjsj_zhiye_5red",     color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 160/255, 61/255, 66/255,1)},
    {icon = "a_tjsj_zhiye_6platinum",color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 61/255, 145/255, 142/255,1)},
    {icon = "a_tjsj_zhiye_7polor",   color = Color( 255/255, 255/255, 255/255), outLineColor = Color( 36/255, 21/255, 99/255,0.5)},
}

M.QUALITY_FRIEND_ITEM = {
    {RGBA = Color.New(99/255, 162/255, 239/255) , outLineColor = Color( 39/255, 41/255, 60/255)}, --1 蓝色
    {RGBA = Color.New(99/255, 162/255, 239/255) , outLineColor = Color( 39/255, 41/255, 60/255)}, --2 蓝色
    {RGBA = Color.New(99/255, 162/255, 239/255) , outLineColor = Color( 39/255, 41/255, 60/255)}, --3 蓝色
    {RGBA = Color.New(99/255, 162/255, 239/255) , outLineColor = Color( 39/255, 41/255, 60/255)}, --4 蓝色
    {RGBA = Color.New(169/255, 108/255, 244/255) ,  outLineColor = Color( 42/255, 39/255, 60/255)}, --5 紫色
    {RGBA = Color.New(220/255, 126/255, 43/255) , outLineColor = Color( 60/255, 46/255, 39/255)}, --6 金
    {RGBA = Color.New(251/255, 115/255, 113/255) , outLineColor = Color( 59/255, 38/255, 38/255)}, --7 红
    {RGBA = Color.New(255/255, 255/255, 255/255) , outLineColor = Color( 0/255, 0/255, 0/255)}, --8 白
}

M.GridType = {
    -- 无格子
    Empty = 0,
    -- 普通格子
    Normal = 1,
    -- 怪物
    Monster = 2,
    -- 宝箱
    GiftBag = 3,
    -- 铸剑台
    SwordDesk = 4,
    -- 能量点
    --Energy = 5,
    -- 出生点
    BirthPoint = 6,
    -- 力量雕像
    ForceStatue = 7,
    -- 联盟
    League = 8,
    -- 商店
    Shop = 9,
    -- 八卦阵
    Wuzhuang = 10,
    -- 柱子
    Pillar = 11,
    -- 附属格子类型
    Dependency = 9999,
}

M.SimulateTalentValues = {
    --红
    "a_hd_jhmnq_tfjc_xuanxiang_hong",
    --黄
    "a_hd_jhmnq_tfjc_xuanxiang_huang",
    --紫
    "a_hd_jhmnq_tfjc_xuanxiang_zi",
    --蓝
    "a_hd_jhmnq_tfjc_xuanxiang_lan",
    --绿
    "a_hd_jhmnq_tfjc_xuanxiang_lv",
}

M.SimulateQualityValues = {
    "simulateLeft_text_0040",
    "simulateLeft_text_0041",
    "simulateLeft_text_0042",
    "simulateLeft_text_0043",
    "simulateLeft_text_0044",
}

M.SimulateQualityColourValues = {
    -- 甲
    {193/255, 71/255, 72/255},
    -- 乙
    {198/255, 150/255, 51/255},
    -- 丙
    {123/255, 109/255, 188/255},
    -- 丁
    {103/255, 136/255, 166/255},
    -- 戊
    {97/255, 137/255, 112/255},
}

M.SimulateBgQualityName = {
    "a_hd_jhmnq_ttzs_yuan_hong",
    "a_hd_jhmnq_ttzs_yuan_huang",
    "a_hd_jhmnq_ttzs_yuan_zi",
    "a_hd_jhmnq_ttzs_yuan_lan",
    "a_hd_jhmnq_ttzs_yuan_lv",
}

M.EnjoySpringPowerColor = {
    Color(220/255, 126/255, 43/255),
    Color(220/255, 90/255, 43/255),
    Color(220/255, 43/255, 84/255),
}
-- 巅峰公会战
M.GUILD_HIGH_WAR_POSTS = {
    MANAGER = 1, -- 管理
    COMMON = 2, -- 成员
    OBSERVER = 3, -- 观众
}

-- 对成员的操作
M.GUILD_HIGH_WAR_POSTS_RIGHT = {
    TALKING_AKT = 1, -- 宣战
    FORMATION = 2, -- 布阵
    GET_REWARD = 3, -- 领取每日奖励
    BATTLE_TEAM = 4,  -- 参战队伍
}

--服务器返回的当前阶段
M.SERVER_GHW_STAGE = {
    NO_OPEN = 1, --未开启
    INVAITE = 2, --邀请阶段
    PREPARE = 3, --准备阶段
    FORMATION = 4,--战斗布阵阶段
    BATTLE = 5, --战斗中阶段
    DECLARE = 6,-- 战斗宣战阶段
    AFTER_BATTLE = 7,--战斗结束阶段
    MATCH = 8,--匹配阶段
    FORMULA = 9,--公式阶段
}

--符篆系统品阶颜色
M.FUZHUAN_GRADE_COLOR = {
    [1] = Color( 96/255, 197/255, 107/255), --绿
    [3] = Color( 96/255, 197/255, 183/255), --蓝
    [5] = Color( 158/255, 96/255, 197/255),--紫
    [7] = Color( 241/255, 150/255, 58/255),--黄
    [10] = Color( 241/255, 58/255, 72/255),--红
}

M.GACHA_YUAN_ID = 10 --元卡池id
M.GACHA_SP_ID = 11 --SP卡池id
M.GACHA_SCORE_ID = 12 --积分抽卡卡池id

return M