------------------- NetUrl
--[[--
    游戏逻辑接口，访问的是各个应用服务器，没有固定域名和ip
]]
local game_url = {
    -- config_version = "/config/?method=config_version",--获取配置版本号  
    check_version = "/config/?method=check_version", -- 热更资源和配置信息
    -- all_config = "/config/?method=all_config",--获取具体配置    &config_name=hero_basis
    stream = "/stream?", --腾讯安全  

    user_game_info = "/api/?method=user.game_info",--获取用户信息 &user_token=gtt11234567
    user_main = "/api/?method=user.main",--主界面
    user_set_desc = "/api/?method=user.set_desc",--设置签名  desc: ""  签名
    user_set_avatar = "/api/?method=user.set_avatar",--设置玩家头像  avatar: ""
    user_set_frame = "/api/?method=user.set_frame",--设置玩家头像框  frame: ""
    user_set_title = "/api/?method=user.set_title", -- 设置玩家称号
    user_heartbeat = "/api/?method=user.heartbeat", -- 心跳
    user_get_idle_connector = "/api/?method=user.get_idle_connector", -- 获取聊天服务器ip和端口
    user_receive_comeback = "/api/?method=user.receive_comeback", -- 领取老用户回归奖励
    user_comeback_choose = "/api/?method=user.comeback_choose", -- 选择回归福利类型
    user_inherit_account = "/api/?method=user.inherit_account", -- 选择继承数据的新服
    user_get_idle_connector = "/api/?method=user.get_idle_connector", -- 获取聊天服务器ip和端口 
    user_get_users_info = "/api?method=user.get_users_info", -- 获取多个用户数据
    
    download_play_recv = "/api?method=user.recv_play_download", -- 边玩边下，领奖励

    title_title_upgrade = "/api/?method=title.title_upgrade", -- 称号升级
    title_auto_title_upgrade = "/api/?method=title.auto_title_upgrade", -- 称号一键升级
    title_sell_title = "/api/?method=title.sell_title", -- 称号兑换元宝

    hope_report = "/api/?method=hope.report", -- 中控防沉迷上报接口  rule_name: xx  hope数据中的   instr_trace_id: hope数据中的trace_id

    gacha_active_index = "/api/?method=gacha_active.index",--通用抽奖活动-首页
    gacha_active_draw = "/api/?method=gacha_active.draw",--通用抽奖活动-抽奖
    gacha_active_quest_score = "/api/?method=gacha_active.quest_score",--通用抽奖活动-全服进度
    gacha_active_rank_info = "/api/?method=gacha_active.rank_info",--通用抽奖活动-排行榜

    gacha_index = "/api/?method=gacha.gacha_index",--抽卡
    gacha_get_gacha = "/api/?method=gacha.get_gacha",--抽卡
    gacha_open_new_gacha_race = "/api/?method=gacha.open_new_gacha_race",--开启今日新的可抽取种族
    gacha_checkout_cur_gacha_race = "/api/?method=gacha.checkout_cur_gacha_race",--切换抽取种族
    gacha_use_race_hero_card = "/api/?method=gacha.use_race_hero_card", -- 使用自选种族紫卡 card_id: 1  第几张卡
    gacha_set_hero_wish_list = "/api/?method=gacha.set_hero_wish_list", -- 设置英雄心愿单 POST wish_list: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    gacha_wish_list_index = "/api?method=gacha.wish_list_index", --心愿单首页
    gacha_receive_chest_reward = "/api/?method=gacha.receive_chest_reward",--抽卡
    gacha_set_bless_hero = "/api?method=gacha.set_bless_hero", --设置祝福英雄
    gacha_receive_bless_hero = "/api?method=gacha.receive_bless_hero", --领取祝福英雄
    user_test_reward = "/api/?method=user.test_reward",--奖励测试

    hero_equip_wear = "/api/?method=hero.equip_wear",--英雄穿装备 hero_oid: 英雄唯一id equip_oid: 装备唯一id auto: 一键穿装, 0:穿指定装备，1：一键穿装
    hero_equip_down = "/api/?method=hero.equip_down",--英雄脱装备 hero_oid: 英雄唯一id pos: 1-4 装备位置 auto: 一键脱装, 0:脱指定装备，1：一键脱装
    hero_auto_equip_wear = "/api/?method=hero.auto_equip_wear",--英雄一键穿装备 hero_oid: 英雄唯一id
    hero_set_team = "/api?method=hero.set_team", --设置队伍  type: 队伍分类，{main:主页挂机队伍，city:推图队伍，formation:编队}, index: 编队使用，编队编号, team: 队伍数据，xx_xx_xx_xx_xx, 下划线分割英雄id，空字符串站位
    hero_level_up ="/api?method=hero.level_up",--英雄升级   hero_oid: 英雄唯一id
    hero_fast_level_up ="/api?method=hero.fast_level_up",--英雄快速升级  hero_oid: 英雄唯一id  level: 指定等级
    hero_evolution = "/api?method=hero.evolution", --英雄进阶 hero_data: { hero_oid: [ hero_oid1, hero_oid2 ] }, {主英雄: [材料英雄]}
    hero_select_evolution_hero = "/api?method=hero.select_evolution_hero", -- 查询英雄智能进阶和一键进化
    hero_resolve = "/api?method=hero.resolve", -- 英雄遣散  material: [ hero_oid1, hero_oid2 ], [材料英雄id,材料英雄id]
    hero_reset = "/api?method=hero.reset", -- 英雄重置  hero_oid: 英雄唯一id
    hero_rollback = "/api?method=hero.rollback", -- 英雄回退  hero_oid: 英雄唯一id
    equip_level_up = "/api?method=equip.level_up",-- 装备升级 hero_oid: 英雄唯一id pos: 装备的位置，1-4 items: 消耗道具, {item_id: num}  equips: 消耗装备 {equip_oid: num}
    hero_lock = "/api?method=hero.lock", -- 锁定英雄  hero_oid :英雄唯一id
    hero_unlock = "/api?method=hero.unlock", -- 锁定英雄  hero_oid :英雄唯一id
    hero_buy_hero_grid = "/api?method=hero.buy_hero_grid", --购买英雄格子
    hero_collect = "/api?method=hero.collect_index", --图鉴
    hero_collect_receive = "/api?method=hero.collect_receive", --图鉴领奖
    hero_formation_name = "/api?method=hero.formation_name", --编队修改名字  name: 编队名字  index: 编队使用，编队编号
    hero_formation_receive = "/api?method=hero.formation_receive", --编队修改名字  name: 编队名字  index: 编队使用，编队编号
    hero_mystic_wear = "/api?method=hero.mystic_wear", --英雄-穿戴秘籍 hero_oid: 英雄唯一id pos: 位置，1-4 mystic_id: 秘籍id
    hero_mystic_down = "/api?method=hero.mystic_down", --英雄-卸下秘籍 hero_oid: 英雄唯一id pos: 位置，1-4

    hero_mystic_inlay = "/api?method=hero.mystic_inlay", -- 镶嵌秘籍
    hero_mystic_inlay_take_off = "/api?method=hero.mystic_inlay_take_off", -- 镶嵌摘下秘籍

    artifact_wear = "/api?method=hero.artifact_wear", --穿神器 (穿戴背包里的神器：hero_oid，artifact_oid 穿戴其他英雄身上的神器：hero_oid，artifact_owner)
    artifact_down = "/api?method=hero.artifact_down", --脱神器
    artifact_lvlup = "/api?method=hero.artifact_lvlup", --神器强化
    sig_enable = "/api?method=hero.sig_enable", --激活专属 经脉
    sig_lvlup = "/api?method=hero.sig_lvlup", --专属强化 经脉
    hero_sig_reset = "/api?method=hero.sig_reset", --专属重置 经脉
    hero_sig_break = "/api?method=hero.sig_break", --经脉突破 hero_oid
    eqp_evolution = "/api?method=equip.evolution", --装备进阶
    eqp_recast = "/api?method=equip.recast", --装备重铸
    cancel_recast_recast = "/api?method=equip.cancel_recast", --装备取消重铸
    giving_gifts = "/api?method=hero.giving_gifts", --英雄-赠送侠客好感度道具
    awake = "/api?method=equip.awake", --装备觉醒
    affix_protect = "/api?method=equip.affix_protect", --装备词缀保护
    affix_random = "/api?method=equip.affix_random", --装备词缀洗练
    cancel_affix_random = "/api?method=equip.cancel_affix_random", --装备取消词缀洗练   
    batch_affix_random = "/api?method=equip.batch_affix_random", --装备词缀批量洗练
    select_affix_random = "/api?method=equip.select_affix_random", --装备选择批量词缀洗练
    strengthen_divine_equip = "/api?method=equip.strengthen_divine_equip", --神兵强化


    hero_crystal_index= "/api?method=hero.crystal_index", -- 共鸣水晶-首页 
    hero_crystal_open_slot= "/api?method=hero.crystal_open_slot", -- 共鸣水晶-解锁槽位  pos: 1 槽位id，从1开始
    hero_crystal_add= "/api?method=hero.crystal_add", -- 共鸣水晶-槽位放入英雄  pos: 1 槽位id，从1开始 hero_oid: 'x1' 英雄唯一id
    hero_crystal_remove= "/api?method=hero.crystal_remove", -- 共鸣水晶-槽位卸下英雄 pos: 1 槽位id，从1开始
    hero_crystal_clear= "/api?method=hero.crystal_clear", -- 共鸣水晶-清空槽位冷却时间 pos: 1 槽位id，从1开始
    hero_crystal_levelup= "/api?method=hero.crystal_levelup", -- 共鸣水晶-升级水晶
    hero_crystal_unlock= "/api?method=hero.crystal_unlock", -- 共鸣水晶-解锁等级上限

    hero_crystal_get_rank= "/api?method=hero.crystal_get_rank", -- 练武场-获取排行榜

    hero_use_hero_skin = "/api?method=hero.use_hero_skin", -- 英雄-切换皮肤 hero_oid: 英雄唯一id  skin_id: 皮肤id
    hero_exchange_hero_skin = "/api?method=hero.exchange_hero_skin", -- 英雄-兑换皮肤  skin_id: 皮肤id
    equip_smelt = "/api?method=equip.smelt", -- 装备熔炼 参数 equips [oid1, oid2] 熔炼的装备列表

    hero_link = "/api?method=hero.link", -- 武神 结义
    hero_unlink = "/api?method=hero.unlink", -- 武神 结义解除
    hero_link_lvlup = "/api?method=hero.link_lvlup", -- 武神 结义加深


    mail_index = "/api?method=mail.index", -- 邮箱主页 mail_ids: [], 查看邮件的id列表,首次进入邮件主页是为空
    mail_read = "/api?method=mail.read", -- 阅读邮件 mail_id: 邮件id
    mail_receive = "/api?method=mail.receive", -- 领取邮件 mail_id: 邮件id
    mail_receive_all = "/api?method=mail.receive_all", -- 领取全部邮件 
    mail_delete_all = "/api?method=mail.delete_all", -- 删除所有邮件 
    mail_delete_mail = "/api?method=mail.delete_mail", -- 删除邮件 mail_id: 邮件id
    mail_send = "/api?method=mail.send", -- 发送邮件 f_uid: 好友uid sort: 邮件sort content: 邮件内容
    recommend_friend = "/api?method=friend.recommend_friend", --推荐好友首页

    item_use_item = "/api?method=item.use_item", -- 使用道具item_id: 道具id item_num: 道具数量 item_index: 玩家自选道具

    quest_index = "/api?method=quest.index", -- 任务入口
    quest_recv_main_reward = "/api?method=quest.recv_main_reward", -- 领取主线奖励 quest_id: 任务id
    quest_recv_daily_reward = "/api?method=quest.recv_daily_reward", -- 领取日常奖励 quest_id: 任务id
    quest_recv_daily_score_reward = "/api?method=quest.recv_daily_score_reward", -- 领取日常积分奖励 score_id: 积分表id
    quest_recv_weekly_reward = "/api?method=quest.recv_weekly_reward", -- 领取周常奖励 quest_id: 任务id
    quest_recv_weekly_score_reward = "/api?method=quest.recv_weekly_score_reward", -- 领取周常积分奖励 score_id: 积分表id
    quest_recv_special = "/api?method=quest.recv_special", -- 特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
    quest_auto_recv_daily_reward = "/api?method=quest.auto_recv_daily_reward", -- 一键领取日常奖励
    quest_auto_recv_weekly_reward = "/api?method=quest.auto_recv_weekly_reward", -- 一键领取周常奖励
    quest_auto_recv_special = "/api?method=quest.auto_recv_special", -- 一键领取特殊任务奖励
    quest_auto_recv_main_reward = "/api?method=quest.auto_recv_main_reward", -- 一键领取主线任务奖励

    rank_index = "/api?method=rank.index", -- 排行入口
    rank_rank_info = "/api?method=rank.rank_info", -- 一个排行信息 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名
    rank_rank_quest_info = "/api?method=rank.rank_quest_info", -- 排行榜任务信息 sort: 排行榜类型
    rank_rank_quest_log = "/api?method=rank.rank_quest_log", -- 每个任务的排行信息 sort: 排行榜类型 quest_id: 任务id
    rank_rank_quest_recv = "/api?method=rank.rank_quest_recv", -- 领取排行榜任务奖励 sort: 排行榜类型 quest_id: 任务id
    rank_enter = "/api?method=rank.enter", -- 排行榜入口 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名

    user_user_detail_info = "/api?method=user.user_detail_info", -- 用户详情 target_uid: 0     查询用户的uid

    shop_index = "/api?method=shop.index", -- 商店首页 shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店
    shop_buy = "/api?method=shop.buy", -- 商店购买 shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店 pos: 物品位置，从1开始
    shop_refresh = "/api?method=shop.refresh", -- 商店刷新 shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店

    item_score_index = "/api?method=item_score.index", -- 道具积分

    friend_friends_basic_info = "/api?method=friend.friends_basic_info", -- 全部好友数据列表
    friend_search_friend = "/api?method=friend.search_friend", -- 查找好友 name: 好友uid / 好友名称
    friend_friend_apply_index = "/api?method=friend.friend_apply_index", -- 好友申请首页
    friend_apply_friend = "/api?method=friend.apply_friend", -- 申请好友 f_uid: 好友uid
    friend_agree_friend = "/api?method=friend.agree_friend", -- 同意好友申请 f_uid: 好友uid
    friend_agree_friend_all = "/api?method=friend.agree_friend_all", -- 同意所有好友申请 
    friend_refuse_friend = "/api?method=friend.refuse_friend", -- 拒绝/忽略 好友申请 f_uid: 好友uid 
    friend_refuse_friend_all = "/api?method=friend.refuse_friend_all", -- 拒绝/忽略 所有好友申请
    friend_remove_friend = "/api?method=friend.remove_friend", -- 删除好友 f_uid: 好友uid
    friend_blacklist_index = "/api?method=friend.blacklist_index", -- 黑名单首页
    friend_add_to_blacklist = "/api?method=friend.add_to_blacklist", -- 添加到黑名单
    friend_delete_from_blacklist = "/api?method=friend.delete_from_blacklist", -- 移除黑名单
    friend_send_friend_gift = "/api?method=friend.send_friend_gift", -- 赠送友情点 f_uid: 1234567
    friend_receive_friend_gift = "/api?method=friend.receive_friend_gift", -- 领取友情点 f_uid: 1234567
    friend_auto_send_receive_gift = "/api?method=friend.auto_send_receive_gift", -- 一键发送和领取友情点

    apostle_index = "/api?method=apostle.index", -- 佣兵首页
    apostle_friend_apostle = "/api?method=apostle.friend_apostle", -- 可雇佣英雄列表
    apostle_apply_info = "/api?method=apostle.apply_info", -- 申请列表信息
    apostle_lend_info = "/api?method=apostle.lend_info", -- 租出的信息列表
    apostle_apply = "/api?method=apostle.apply", -- 申请 租借好友佣兵 target_uid：20971510   # 好友uid  hero_oid：'xx-xx-xx'   # 租借的英雄唯一id
    apostle_cancel_apply = "/api?method=apostle.cancel_apply", -- 取消申请 租借好友佣兵 target_uid：20971510   # 好友uid  hero_oid：'xx-xx-xx'   # 租借的英雄唯一id
    apostle_agree = "/api?method=apostle.agree", -- 同意 租借 target_uid：20971510   # 租借人 hero_oid：'xx-xx-xx'   # 租借的英雄唯一id is_all：1              # 是否一键同意，1:全部同意
    apostle_reject = "/api?method=apostle.reject", -- 不同意 租借 target_uid：20971510   # 租借人 hero_oid：'xx-xx-xx'   # 租借的英雄唯一id is_all：1              # 是否一键拒绝，1:全部拒绝
    apostle_give_back = "/api?method=apostle.give_back", -- 归还好友佣兵 hero_oid：'xx-xx-xx'   # 租借的英雄唯一id

    tower_get_cur_floor_id = "/api?method=tower.get_cur_floor_id", -- 获取爬塔当前floor_id
    tower_query_friends_data = "/api?method=tower.query_friends_data", -- 获取好友以及工会好友信息
    tower_query_combat_data = "/api?method=tower.query_combat_data", -- 查询对应层级所有好友的 过关战力信息  floor_id: 1
    tower_battle_start = "/api?method=tower.battle_start", -- 战斗前获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍
    tower_battle_end = "/api?method=tower.battle_end", -- 战斗后获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍 result: 0 or 1  # 战斗结果，0：失败，1：胜利
    tower_get_battle_team = "/api?method=tower.get_battle_team", -- 获取指定user的通关阵容 f_uid

    -- bounty_info = "/api?method=bounty.bounty_index", --悬赏入口
    -- bounty_do_quest = "/api?method=bounty.do_quest", --做悬赏任务 quest_id:任务id  quest_type:任务类型  1: 个人, 2:团队 self_hero:自己的上阵英雄[hero_id]  friend_hero:{1234568: '6-1577692678-jYK4We'}好友或公会成员英雄信息{uid: hero_id}   (个人任务可不传此字段)
    -- bounty_refresh = "/api?method=bounty.refresh_quest", --刷新悬赏任务
    -- bounty_receive = "/api?method=bounty.receive", --领取悬赏任务
    -- mercenary = "/api?method=library.mercenary", --我的外援首页
    -- mercenary_add = "/api?method=library.mercenary_add", --添加外援
    -- mercenary_del = "/api?method=library.mercenary_del", --移除外援 
    -- get_mercenarys = "/api?method=bounty.get_mercenarys", --获得好友和公会的外援 


    battle_array_data ="/api?method=battle.array_data" , --布阵界面数据
    battle_start ="/api?method=stage.battle_start" , --战斗前获取 
    battle_end ="/api?method=stage.battle_end" , --战斗结果获取 
    stage_battle_start2 ="/api?method=stage.battle_start2" , --战斗前获取 
    stage_battle_end2 ="/api?method=stage.battle_end2" , --战斗结果获取 
    chapter_unlock ="/api?method=stage.chapter_unlock" , --解锁新章节 
    min_combat_data ="/api?method=stage.min_combat_data" , --关卡查看通关阵容 
    stage_quick_pass_stage ="/api?method=stage.quick_pass_stage" , --关卡快速通关
    five_combat_data ="/api?method=five_element.min_combat_data" , --五行阵查看通关阵容 
    tower_combat_data ="/api?method=tower.min_combat_data" , --爬塔查看通关阵容 

    hero_friend = "/api?method=hero_friend.recv_reward", -- 领取羁绊激活奖励

    get_idle_reward ="/api?method=idle.get_idle_reward" , --领取普通挂机奖励 
    get_quick_idle_reward ="/api?method=idle.get_quick_idle_reward" , --领取快速挂机奖励 
    idle_reward_show = "/api?method=idle.idle_reward_show",--挂机奖励展示 

    double_twelve_index = "/api?method=double_twelve.index", -- 花火大赏-首页
    double_twelve_receive_quest = "/api?method=double_twelve.receive_quest", -- 花火大赏-领取任务奖励
    double_twelve_receive_sign = "/api?method=double_twelve.receive_sign", --花火大赏-领取限时登录(签到)奖励
    double_twelve_recv_score_reward = "/api?method=double_twelve.recv_score_reward", -- 花火大赏-领取积分奖励
    double_twelve_exchange_goods = "/api?method=double_twelve.exchange_goods", -- 花火大赏-兑换商品

    active_common_gift_index = "/api?method=active.common_gift_index", -- 通用阶梯礼包-礼包首页
    active_common_gift_buy = "/api?method=active.common_gift_buy", -- 通用阶梯礼包-礼包购买
    active_common_gift_recv_hot = "/api?method=active.common_gift_recv_hot", -- 通用阶梯礼包-领取热力值奖励

    new_year_index = "/api?method=active.new_year_index", -- 双旦-首页
    new_year_egg = "/api?method=active.new_year_egg", --双旦-砸金蛋
    new_year_egg_recv = "/api?method=active.new_year_egg_recv", -- 双旦-砸金蛋领取奖励
    new_year_recv_quest = "/api?method=active.new_year_recv_quest", -- 双旦-许愿树领取任务奖励
    new_year_tree_shake = "/api?method=active.new_year_tree_shake", -- 双旦-许愿树摇一摇
    new_year_exchange = "/api?method=active.new_year_exchange", -- 双旦-灵鹿集市，限时兑换
    new_year_daily_recv = "/api?method=user_payment.new_year_daily_recv", -- 双旦-双旦礼包屋免费领奖

    mystery_shop_index = "/api?method=user_payment.mystery_shop_index",--神秘商店初始化
    mystery_shop_receive = "/api?method=user_payment.mystery_shop_receive",--领取免费奖励+签到
    mystery_shop_discount = "/api?method=user_payment.mystery_shop_discount",--抽取折扣
    mystery_shop_attendance = "/api?method=user_payment.mystery_shop_attendance",--领取全勤奖
    
    sword_quest_index = "/api?method=active.sword_quest_index", --铸件大会--全民铸剑首页
    sword_recv_quest_reward = "/api?method=active.sword_recv_quest_reward", --全民铸剑--领取任务奖励
    sword_recv_score_reward = "/api?method=active.sword_recv_score_reward", --全民铸剑--领取积分奖励
    sword_share_index = "/api?method=active.sword_share_index", --江湖召集首页(分享)
    sword_title_index = "/api?method=active.sword_title_index", --武林邀约-首页
    sword_recv_title_reward = "/api?method=active.sword_recv_title_reward", --武林邀约-领取任务奖励
    sword_recv_share_reward = "/api?method=active.sword_recv_share_reward", --江湖召集--领取分享任务奖励
    sword_login_index = "/api?method=active.sword_login_index", --明星好礼-首页
    sword_recv_login_reward = "/api?method=active.sword_recv_login_reward", --明星好礼-领取签到奖励
    sword_login_exchange = "/api?method=active.sword_login_exchange", --明星好礼-信物兑换
    war_order_index = "/api?method=war_order.war_order_index", --江湖行侠令--勇者犒赏令--首页
    war_order_valor_index = "/api?method=war_order.war_order_valor_index", --武林行侠令--皇家犒赏令--首页
    receive_royal_reward = "/api?method=war_order.receive_royal_reward",  --领取皇家犒赏令奖励
    receive_warrior_reward = "/api?method=war_order.receive_warrior_reward",  --领取勇者犒赏令奖励
    auto_receive_royal_reward = "/api?method=war_order.auto_receive_royal_reward",  --一键领取皇家犒赏令奖励
    auto_receive_warrior_reward = "/api?method=war_order.auto_receive_warrior_reward",  --一键领取勇者犒赏令奖励
    buy_royal_unreached_reward = "/api?method=war_order.buy_royal_unreached_reward",  --购买皇家犒赏令未达成奖励
    buy_warrior_unreached_reward = "/api?method=war_order.buy_warrior_unreached_reward",  --购买勇者犒赏令未达成奖励
    war_goal_common_index = "/api?method=war_order.goal_common_index", --战令达标
    receive_goal_common_reward = "/api?method=war_order.goal_common_recv_one",  --战令达标 领取单个奖励
    auto_receive_goal_common_reward = "/api?method=war_order.goal_common_recv_all",  --战令达标 一键领取奖励
    buy_goal_common_reward = "/api?method=war_order.goal_common_buy",  --战令达标 购买未达成奖励
    month_card = "/api?method=user_payment.month_card_index", --月卡首页
    open_week_card = "/api?method=user_payment.open_week_card", --周卡开启
    open_month_card = "/api?method=user_payment.open_month_card", --月卡开启
    fund_index = "/api?method=user_payment.fund_index", --成长基金
    auto_receive_fund = "/api?method=user_payment.auto_receive_fund", --一键领取成长基金
    receive_fund_reward = "/api?method=user_payment.receive_fund_reward", --领取成长基金
    activity_gift_index = "/api?method=user_payment.activity_gift_index", --锦囊礼包首页
    hero_rank_index = "/api?method=active.hero_rank_index", --侠客争锋入口
    hero_rank2_index = "/api?method=active.hero_rank2_index", --赛季冲榜入口
    hero_effect_recv = "/api?method=active.hero_effect_recv", --侠客争锋领取
    show_hero_rank = "/api?method=active.show_hero_rank",        -- 侠客争锋排行
    producer_index = "/api?method=active.producer_index", --制作人赠礼入口
    producer_recv = "/api?method=active.producer_recv", --制作人赠礼领奖
    bowl_index = "/api?method=active.bowl_index", --聚宝盆入口(充值返利)
    wish_index = "/api?method=active.wish_index", --鸿运祈福-入口
    set_wish = "/api?method=active.set_wish", --鸿运祈福-设置许愿奖
    wish_blessing = "/api?method=active.wish_blessing", --鸿运祈福-进行许愿
    received_wish = "/api?method=active.received_wish", --鸿运祈福-领取许愿奖
    receive_bowl_gifts = "/api?method=active.receive_bowl_gifts", --充值返利领奖
    skin_gift_index = "/api?method=user_payment.skin_gift_index", --皮肤礼包首页
    activity_limit_index = "/api?method=user_payment.activity_limit_index", --限时礼包首页
    merchant_index = "/api?method=user_payment.merchant_index", --普通商船首页
    continuous_index = "/api?method=user_payment.continuous_index", --连续充值入口
    receive_continuous = "/api?method=user_payment.receive_continuous", --领取连续充值奖励
    gift_off_index = "/api?method=user_payment.gift_off_index", --特惠礼包入口
    receive_gift_off = "/api?method=user_payment.receive_gift_off", --领取特惠礼包
    gift_new_index = "/api?method=user_payment.gift_new_index", --新手礼包入口
    gift_supervalue_index = "/api?method=user_payment.gift_supervalue_index", --超值礼包入口
    receive_gift_supervalue = "/api?method=user_payment.receive_gift_supervalue", --领取免费超值礼包
    pay_shop_index = "/api?method=user_payment.shop_index", --元宝商店
    sign_daily_index = "/api?method=active.sign_daily_index", --签到首页
    receive_sign_daily = "/api?method=active.receive_sign_daily", --领取签到奖励
    receive_recharge_sign_daily = "/api?method=active.receive_recharge_sign_daily", --领取充值签到奖励
    receive_box_sign_daily = "/api?method=active.receive_box_sign_daily", --领取宝箱签到奖励
    first_payment_index = "/api?method=user_payment.first_payment_index", -- 首充入口
    receive_first_payment = "/api?method=user_payment.receive_first_payment", --领取首充
    receive_push_gifts = "/api?method=user_payment.receive_push_gifts", --领取首充
    recv_vip_reward = "/api?method=user.recv_vip_reward", --领取vip奖励
    send_gifts = "/api?method=welfare_npc.send_gifts", --送礼物 items: {item_id: num}     # 道具
    receive_guide_reward = "/api?method=welfare_npc.receive_guide_reward", --官方人设 - 领取引导奖励 guide_id: 0     # 配置npc_guide的id
    bright_bless_index = "/api?method=user_payment.bright_bless_index", --新手福利首页
    receive_bright_bless = "/api?method=user_payment.receive_bright_bless", -- 领取新手福利
    draw_index = "/api?method=active.draw_index", --卦签-首页
    draw_random_draw = "/api?method=active.draw_random_draw", --卦签-抽签
    draw_buy = "/api?method=active.draw_buy", --卦签-购买
    draw_recv_login = "/api?method=active.draw_recv_login", --卦签-领取登录奖励
    draw_recv_task = "/api?method=active.draw_recv_task", --卦签-领取任务奖励
    draw_recv_all = "/api?method=active.draw_recv_all", --卦签-全部领取任务奖励
    scroll_index = "/api?method=active.scroll_index", --锦囊玉轴--首页
    scroll_set_big_prize = "/api?method=active.scroll_set_big_prize", --锦囊玉轴-设置大奖
    open_scroll = "/api?method=active.open_scroll", -- 锦囊玉轴-打开锦囊
    buy_scroll_goods = "/api?method=active.buy_scroll_goods",  --锦囊玉轴-购买每日限购商品
    scroll_receive_quest = "/api?method=active.scroll_receive_quest", --锦囊玉轴-领取任务奖励
    scroll_receive_all = "/api?method=active.scroll_receive_all", --锦囊玉轴-领取全部任务奖励
    scroll_enter_next = "/api?method=active.scroll_enter_next", --锦囊玉轴-下一层
    custom_gift_index = "/api?method=user_payment.custom_gift_index", --定制礼包首页
    set_custom_gift_gift_pos = "/api?method=user_payment.set_custom_gift_gift_pos", --设置定制礼包奖励位置
    receive_custom_gift = "/api?method=user_payment.receive_custom_gift", --免费领取定制礼包奖励

    hero_gift_index = "/api?method=user_payment.hero_gift_index", --英雄成长礼包
    receive_hero_gift = "/api?method=user_payment.receive_hero_gift", --英雄成长礼包-领取免费礼包
    equip_gift_index = "/api?method=user_payment.equip_gift_index", --神兵成长礼包
    receive_equip_gift = "/api?method=user_payment.receive_equip_gift", --神兵成长礼包-领取免费礼包
    cmlt_recharge_index = "/api?method=user_payment.cmlt_recharge_index", --累计充值首页
    gift_value_index = "/api?method=user_payment.gift_value_index", --阶梯礼包首页
    gift_value_daily_index = "/api?method=user_payment.gift_value_daily_index", --每日阶梯礼包首页
    gift_value_week_index = "/api?method=user_payment.gift_value_week_index", --每周阶梯礼包首页
    gift_value_limit_index = "/api?method=user_payment.gift_value_limit_index", --限时阶梯礼包首页(阶梯礼包2)
    gift_value_daily_recv = "/api?method=user_payment.gift_value_daily_recv", --领取免费阶梯礼包
    receive_cmlt_recharge = "/api?method=user_payment.receive_cmlt_recharge", --领取累计充值奖励
    daily_charge_index = "/api?method=user_payment.daily_charge_index", --每日充值首页
    daily_charge_receive = "/api?method=user_payment.daily_charge_receive", --每日充值领奖
    treasure_index = "/api?method=active.treasure_index", --藏宝图-首页
    treasure_activate = "/api?method=active.treasure_activate", --藏宝图-激活
    treasure_receive = "/api?method=active.treasure_receive", --藏宝图-领取
    hero_train_index = "/api?method=hero_train.hero_train_index", --侠客试炼 首页
    hero_train_rank = "/api?method=hero_train.hero_train_rank", --侠客试炼 排行榜
    hero_train_battle_start = "/api?method=hero_train.battle_start", --侠客试炼 战前数据
    hero_train_battle_end = "/api?method=hero_train.battle_end", --侠客试炼 战后数据
    hero_reain_recv_reward = "/api?method=hero_train.recv_reward", --侠客试炼 领取任务奖励

    one_key_sweep_index = "/api?method=train_challenge.one_key_sweep_index", -- 阿闲课程表首页
    one_key_sweep_raid = "/api?method=train_challenge.one_key_sweep_raid", -- 扫荡武道场
    one_key_sweep_world_boss = "/api?method=train_challenge.one_key_sweep_world_boss", -- 扫荡玄武遗迹
    one_key_sweep_train = "/api?method=train_challenge.one_key_sweep_train", -- 扫荡侠客试炼
    one_key_sweep_world_legend = "/api?method=train_challenge.one_key_sweep_legend", -- 扫荡侠客传奇
    one_key_sweep = "/api?method=train_challenge.one_key_sweep", -- 一键扫荡
    
    sign_fund_index = "/api?method=user_payment.sign_fund_index", --签到基金首页
    sign_fund_receive = "/api?method=user_payment.sign_fund_receive", --领取签到基金奖励
    sign_fund_auto_receive = "/api?method=user_payment.sign_fund_auto_receive", --一键领取签到基金奖励
    bounty_auto_buy = "/api?method=bounty.auto_buy", --购买悬赏特权
    recv_subscribe_reward = "/api?method=user_payment.recv_subscribe_reward", --购买悬赏特权
    user_payment_charge = "/api?method=user_payment.charge", -- 虚拟充值 charge_id : 1
    exchange_index = "/api?method=active.exchange_index", -- 限时兑换-首页
    exchange = "/api?method=active.exchange", --限时兑换-兑换
    month_exchange_index = "/api?method=active.month_exchange_index", -- 满月兑换-首页
    month_exchange = "/api?method=active.month_exchange", --满月兑换-兑换
    receive_exchange_quest = "/api?method=active.receive_exchange_quest", --限时兑换-领取任务奖励
    card_exchange_index = "/api?method=active.card_exchange_index", -- 侠客兑换-首页
    card_exchange = "/api?method=active.card_exchange", --侠客兑换-兑换
    active_exchange = "/api?method=active.active_exchange", --兑换-兑换2
    gift_mould_index = "/api?method=user_payment.gift_mould_index", --多期阶梯礼包
    gift_mould_daily_recv = "/api?method=user_payment.gift_mould_daily_recv", --多期阶梯礼包免费领奖 vsn: 1  // 版本 place: 1  // 位置
    growth_gift_index = "/api?method=user_payment.growth_gift_index", --成长礼包-首页
    receive_growth_gift = "/api?method=user_payment.receive_growth_gift", --成长礼包-领取免费礼包
    wl_relics_index = "/api?method=user_payment.wl_relics_index", --月连续充值
    
    payment = "/api?method=user.payment", --支付接口 - 做统计使用
    voucher = "/api?method=item.use_voucher", --使用代金券 charge_id  
    tiktok_data = "/api?method=active.tiktok_index", --一键关注抖音官号 
    tiktok_req_reward = "/api?method=active.tiktok_recv", --一键关注抖音官号 
    maze_index = "/api?method=maze.index",  --迷宫首页
    maze_detail = "/api?method=maze.detail",  --格子详情 cell_id: 格子id
    maze_buy = "/api?method=maze.buy",  --奇珍阁购买 pos: 商品的位置
    maze_give_up = "/api?method=maze.give_up",  --放弃当前格子
    maze_employ = "/api?method=maze.employ",  --客栈雇佣 hero_oid: 英雄唯一id
    maze_goto = "/api?method=maze.goto",  --前往格子 cell_id: 格子id
    maze_add_blood = "/api?method=maze.add_blood",  --医馆回血
    maze_revive_one = "/api?method=maze.revive_one",  --药王庙随机复活一人
    maze_revive_all = "/api?method=maze.revive_all",  --使用还魂丹复活所有
    maze_recv_reward = "/api?method=maze.recv_reward",  --领取当前层奖励
    maze_enter_next = "/api?method=maze.enter_next",  --进入下一层 floor_id: 层id
    maze_select_heirloom = "/api?method=maze.select_heirloom",  --选择遗物 heirloom_id: 遗物id
    maze_battle_start = "/api?method=maze.battle_start",  --战斗前数据 team: []  队伍
    maze_battle_end = "/api?method=maze.battle_end",  --战斗后接口
    maze_battle_start2 = "/api?method=maze.battle_start2",  --战斗前数据 team: []  队伍
    maze_battle_end2 = "/api?method=maze.battle_end2",  --战斗后接口
    maze_choose_floor = "/api?method=maze.choose_floor",  --迷宫选择进入的初始页
    maze_unlock_maze_group = "/api?method=maze.unlock_maze_group",  --升级迷宫
    maze_encounter_choice_option = "/api?method=maze.encounter_choice_option",  --迷宫选择奇遇事件
    maze_encounter_battle_start = "/api?method=maze.encounter_battle_start",  --迷宫选择奇遇事件
    maze_encounter_battle_end = "/api?method=maze.encounter_battle_end",  --迷宫选择奇遇事件
    maze_auto_battle = "/api?method=maze.auto_battle",  --快速战斗
    maze_recv_explore_reward = "/api?method=maze.recv_explore_reward",  --领取探索宝箱
    maze_set_all_passed = "/api?method=maze.set_all_passed",  --迷宫所有格子升起
    maze_sweep = "/api?method=maze.sweep",  --扫荡

    active_active_index = "/api?method=active.active_index",  -- 活动入口
    active_seven_tour_index = "/api?method=active.seven_tour_index",  -- --14日登陆入口
    active_receive_seven_tour = "/api?method=active.receive_seven_tour",  -- 七日巡礼领奖 day: 1 领取第几天
    active_hero_gather_index = "/api?method=active.hero_gather_index",  -- 英雄集结入口
    active_receive_hero_gather = "/api?method=active.receive_hero_gather",  -- 英雄集结领奖 reward_id: 1 领取第几个奖励
    quest_recruit_index = "/api?method=quest.recruit_index",  -- 新兵任务入口 
    quest_recv_recruit_reward = "/api?method=quest.recv_recruit_reward",  -- 领取新兵奖励 quest_id: 任务id 
    recv_recruit_score = "/api?method=quest.recv_recruit_score", --领取大侠试炼积分奖励
    recruit_shop_buy = "/api?method=quest.recruit_shop_buy", --大侠试炼折扣商品购买
    recv_login_reward = "/api?method=quest.recv_recruit_login", --大侠试炼签到
    online_reward_index = "/api?method=active.online_reward_index", --在线奖励入口
    receive_online_reward = "/api?method=active.receive_online_reward", --领取在线奖励
    active_hero_gather_active_index = "/api?method=active.hero_gather_active_index",  -- 侠客集结入口
    active_receive_hero_gather_active = "/api?method=active.receive_hero_gather_active",  -- 侠客集结领奖 reward_id: 1 领取第几个奖励

    active_enter = "/api?method=active_enter.active_enter", --活动-总入口
    welfare_enter = "/api?method=active_enter.welfare_enter", --活动-福利入口
    payment_enter = "/api?method=active_enter.payment_enter", --活动-充值入口



    chat_send = '/api?method=chat.send_msg', -- 短链接临时聊天发送
    chat_get = '/api?method=chat.get_msg', -- 短链接临时聊天获取

    user_guide = "/api?method=user.guide",  -- 新手引导 sort 引导组 guide_id 引导id skip 0 1 是否跳过
    user_skip_guide = "/api?method=user.skip_guide", -- 跳过指定新手引导 skip_data:{sort:guide_id}
    user_set_name = "/api?method=user.set_name", -- 设置玩家姓名 name: ""  名字
    user_dialogue = "/api?method=user.dialogue", -- 剧情统计 sort: ""  类型 plotpop: 章节诗词,  tid: 0  章节诗词为章节 其他剧情对话为teamid, status: 0  1. 开始 2. 结束 3. 跳过
    user_guide_goto = "/api?method=user.guide_goto", -- 关卡解锁是否点击前往  config_id 引导组id action 0 未前往  1 前往

    arena_index = "/api?method=arena.index", -- 竞技场入口
    arena_arena_index = "/api?method=arena.arena_index", -- 竞技场入口
    arena_select_arena_rank = "/api?method=arena.select_arena_rank",  -- 竞技场排名 start: 开始的排名 stop: 结束的排名
    arena_battle_start = "/api?method=arena.battle_start",  -- 战斗前获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍  defend_uid: 敌人
    arena_battle_end = "/api?method=arena.battle_end",  -- 战斗后获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍 result: 0 or 1  # 战斗结果，0：失败，1：胜利
    arena_set_defend_team = "/api?method=arena.set_defend_team",  -- 竞技场设置防守阵容 team: [hero_oid]
    arena_select_defend_team = "/api?method=arena.select_defend_team",  -- 获取防守队伍 defend_uid
    arena_buy_arena_ticket = "/api?method=arena.buy_arena_ticket",  -- 购买竞技场门票  count: 0 门票数量
    arena_arena_logs = "/api?method=arena.arena_logs",  -- 获取战斗日志
    arena_refresh_challenges = "/api?method=arena.refresh_challenges",  -- 竞技场刷新敌人
    arena_select_top_arena_rank = "/api?method=arena.select_top_arena_rank",  -- 刷新top排名
    arena_battle_end_sync = "/api?method=arena.battle_end_sync",  -- 战斗前获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍  defend_uid: 敌人
    arena_battle_start_sync = "/api?method=arena.battle_start_sync",  -- 战斗后获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍 result: 0 or 1  # 战斗结果，0：失败，1：胜利
    arena_battle_end_sync2 = "/api?method=arena.battle_end_sync2",  -- 战斗前获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍  defend_uid: 敌人
    arena_battle_start_sync2 = "/api?method=arena.battle_start_sync2",  -- 战斗后获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍 result: 0 or 1  # 战斗结果，0：失败，1：胜利
    arena_recv_week_reward = "/api?method=arena.recv_week_reward",  -- 领取周奖励 reward_id: 1  奖励id
    arena_quick_pass_arena = "/api?method=arena.quick_pass_arena",  -- 战斗快速通过 defend_uid: 敌人
    arena_like = "/api?method=arena.like",  -- 点赞 
    arena_outer_index = "/api?method=top_arena.arena_outer_index", -- 巅峰竞技场外层入口
    arena_inner_index = "/api?method=top_arena.arena_inner_index", -- 巅峰竞技场内层入口
    top_arena_set_teams = "/api?method=top_arena.set_teams", -- 巅峰论剑阵容 teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
    arena_quiz_index = "/api?method=top_arena.arena_quiz_index", -- 巅峰论剑竞猜入口
    guess = "/api?method=top_arena.guess", -- 巅峰论剑竞猜
    select_top_arena_rank = "/api?method=top_arena.select_top_arena_rank", -- 巅峰论剑排行榜
    top_arena_like = "/api?method=top_arena.like", -- 巅峰论剑点赞
    season_top3 = "/api?method=top_arena.season_top3", -- 获取赛季前三名

    race_arena_race_arena_index = "/api?method=race_arena.race_arena_index", -- 种族竞技场 入口  ok
    race_arena_select_arena_rank = "/api?method=race_arena.select_arena_rank", -- 种族竞技场 排名  ok
    race_arena_refresh_challenges = "/api?method=race_arena.refresh_challenges", -- 种族竞技场 刷新敌人 ok
    race_arena_set_defend_team = "/api?method=race_arena.set_defend_team", -- 种族竞技场 设置防守阵容 ok
    race_arena_buy_arena_ticket = "/api?method=race_arena.buy_arena_ticket", -- 种族竞技场 购买门票 ok 
    race_arena_battle_start = "/api?method=race_arena.battle_start", -- 种族竞技场 战斗数据PVP 
    race_arena_select_defend_team = "/api?method=race_arena.select_defend_team", -- 种族竞技场 获取防守方阵容  ok
    race_arena_arena_logs = "/api?method=race_arena.arena_logs", -- 种族竞技场 获取战斗日志  ok
    race_arena_recv_week_reward = "/api?method=race_arena.recv_week_reward", -- 种族竞技场 领取周奖励  ok
    race_arena_like = "/api?method=race_arena.like", -- 种族竞技场 点赞 
    race_arena_battle_start_sync = "/api?method=race_arena.battle_start_sync", -- 种族竞技场 战斗前数据PVE  ok 
    race_arena_battle_end_sync = "/api?method=race_arena.battle_end_sync", -- 种族竞技场 战斗后数据PVE  ok
    race_arena_quick_pass_race_arena = "/api?method=race_arena.quick_pass_race_arena", -- 快速通过
    race_arena_top_battle_start = "/api?method=race_arena.top_battle_start", -- 天级赛
    race_arena_season_battle_start = "/api?method=race_arena.season_battle_start", -- 五行联赛
    
    race_arena_season_race_arena_index = "/api?method=race_arena.season_race_arena_index", -- 五行联赛 入口  ok
    race_arena_season_like = "/api?method=race_arena.season_like", -- 五行联赛 点赞 
    race_arena_season_recv_week_reward = "/api?method=race_arena.season_recv_week_reward", -- 五行联赛 领取周奖励 
    race_arena_season_refresh_challenges = "/api?method=race_arena.season_refresh_challenges", -- 五行联赛 刷新敌人 ok
    race_arena_season_select_defend_team = "/api?method=race_arena.season_select_defend_team", -- 五行联赛 获取防守方阵容  ok
    race_arena_season_quick_pass_race_arena = "/api?method=race_arena.season_quick_pass_race_arena", -- 五行联赛 快速通过
    race_arena_season_arena_logs = "/api?method=race_arena.season_arena_logs", -- 五行联赛 获取战斗日志  ok
    race_arena_season_select_arena_rank = "/api?method=race_arena.season_select_arena_rank", -- 五行联赛 排名  ok
    race_arena_season_buy_arena_ticket = "/api?method=race_arena.season_buy_arena_ticket", -- 五行联赛 购买门票 ok 
    race_arena_season_set_defend_team = "/api?method=race_arena.season_set_defend_team", -- 五行联赛 设置防守阵容 ok

    rise_arena_index = "/api?method=rise_arena.index", --联赛争锋
    rise_arena_rank_info = "/api?method=rise_arena.rank_info", --联赛争锋排行榜
    rise_arena_refresh_rivals = "/api?method=rise_arena.refresh_rivals", --联赛争锋挑战刷新
    rise_arena_rivals_info = "/api?method=rise_arena.rivals_info", --联赛争锋挑战列表请求
    rise_arena_rival_defends = "/api?method=rise_arena.rival_defends", --联赛争锋挑战
    rise_arena_do_battle_sgl = "/api?method=rise_arena.do_battle_sgl", --联赛争锋开始战斗_单队伍
    rise_arena_do_battle_mul = "/api?method=rise_arena.do_battle_mul", --联赛争锋开始战斗_多队伍
    rise_arena_decide_promote = "/api?method=rise_arena.decide_promote", --联赛争锋晋级
    rise_arena_recv_week_award = "/api?method=rise_arena.recv_week_award", --联赛争锋领取周奖励
    rise_arena_set_defends= "/api?method=rise_arena.set_defends", --联赛争锋阵容设置
    rise_arena_do_battle= "/api?method=rise_arena.do_battle", --联赛争锋战斗开始
    rise_arena_battle_logs= "/api?method=rise_arena.battle_logs", --联赛争锋对战日志
    rise_arena_do_like= "/api?method=rise_arena.do_like", --联赛争锋对战点赞

    rta_index= "/api?method=rta.index", --rta主界面
    rta_apply= "/api?method=rta.apply", --rta报名
    rta_cancel= "/api?method=rta.cancel", --rta取消报名
    rta_self_battle_logs= "/api?method=rta.self_battle_logs", --rta个人日志列表
    rta_server_battle_logs= "/api?method=rta.server_battle_logs", --rta全服战斗日志列表
    rta_rank_info= "/api?method=rta.rank_info", --rta排行榜
    rta_battle_log_detail= "/api?method=rta.battle_log_detail", --战斗日志详情
    rta_choose_hero= "/api?method=rta.choose_hero", --rta选侠客
    rta_ban_rival_hero= "/api?method=rta.ban_rival_hero", --rta中Ban选侠客
    rta_sync= "/api?method=rta.sync", --rta请求同步信息
    rta_do_battle= "/api?method=rta.do_battle", --rta开始战斗
    rta_pre_ban_hero= "/api?method=rta.pre_ban_hero", --rta的ban操作
    rta_decide_promote= "/api?method=rta.decide_promote", --rta的晋升选择


    user_main = "/api?method=user.main",  -- 主界面接口

    guild_index = "/api?method=guild.index",  -- 公会首页
    guild_create_guild = "/api?method=guild.create_guild",  -- 创建公会 name: ''  公会名. flag: 1   公会ICON 对应配置guild_flag的id
    guild_search_guild = "/api?method=guild.search_guild",  -- 搜索公会. name: ''  公会名
    guild_join_guild = "/api?method=guild.join_guild", -- 加入公会. guild_id: 1  公会id
    guild_apply_info = "/api?method=guild.apply_info", -- 公会申请列表
    guild_apply_handler = "/api?method=guild.apply_handler", -- 公会申请处理. apply_uid: 0. sort: 1   1：同意申请，2：拒绝申请，3：同意所有，4：拒绝所有
    guild_leave_guild = "/api?method=guild.leave_guild", -- 离开公会
    guild_kick_member = "/api?method=guild.kick_member", -- 提出会员
    guild_tripod_upgrade = "/api?method=guild.tripod_upgrade", --公会神炉升级 -- tripod: 1   神炉类型 - 对应配置type
    guild_tripod_reset = "/api?method=guild.tripod_reset", --公会神炉重置 tripod: 1   神炉类型 - 对应配置type
    guild_doing_contribution = "/api?method=guild.doing_contribution", --捐赠  times: 1   捐献次数
    guild_edit_guild = "/api?method=guild.edit_guild", -- 编辑公会 name: ''  公会名 flag: 1   公会ICON 对应配置guild_flag的id lang: ''  语言 desc: ''  公会描述 apply_desc: ''  申请描述 apply: 1  申请状态， 1：开放 2：不可加入，3：需要申请 apply_lv: 1  申请等级
    guild_send_mail = "/api?method=guild.send_mail", --发送全员邮件  mail_title: ''  邮件标题  content: ''   邮件内容
    guild_promote_elder = "/api?method=guild.promote_elder", --提升到长老  member: uid  公会成员uid
    guild_change_npc = "/api?method=guild.change_npc", --修改无畏之手  member: uid  公会成员uid
    guild_demote_member = "/api?method=guild.demote_member", --降级成员  member: uid  公会成员uid
    guild_recommend = "/api?method=guild.recommend", --推荐公会 
    guild_log_index = "/api?method=guild.log_index", --公会日志 
    guild_tripod_index = "/api?method=guild.tripod_index", --神炉入口 
    guild_levelup = "/api?method=guild.levelup", --公会升级 
    guild_auto_join = "/api?method=guild.auto_join", --公会一键加入
    guild_sign = "/api?method=guild.sign", --公会签到
    guild_impeach_president = "/api?method=guild.impeach_president", --弹劾会长
    guild_guild_transfer = "/api?method=guild.guild_transfer", --转让帮主 member : uid
    guild_guild_members = "/api?method=guild.guild_members", --刷新成员列表

    high_arena_arena_index = "/api?method=high_arena.arena_index", -- 高阶竞技场入口
    high_arena_select_arena_rank = "/api?method=high_arena.select_arena_rank", -- 高阶竞技场排名
    high_arena_refresh_challenges = "/api?method=high_arena.refresh_challenges", -- 高阶竞技场刷新敌人
    high_arena_set_defend_teams = "/api?method=high_arena.set_defend_teams", -- 高阶竞技场设置防守阵容 teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
    high_arena_buy_arena_ticket = "/api?method=high_arena.buy_arena_ticket", -- 购买竞技场门票 count: 0 门票数量
    high_arena_arena_logs = "/api?method=high_arena.arena_logs", -- 获取战斗日志
    high_arena_battle_start = "/api?method=high_arena.battle_start",  -- 战斗前获取数据 teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]} 英雄队伍  defend_uid: 敌人
    high_arena_battle_end = "/api?method=high_arena.battle_end",  -- 战斗后获取数据 teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]} 英雄队伍 result: 0 or 1  # 战斗结果，0：失败，1：胜利
    high_arena_select_defend_teams = "/api?method=high_arena.select_defend_teams",  -- 获取防守方阵容 defend_uid: 玩家uid
    high_arena_receive_arena_coin = "/api?method=high_arena.receive_arena_coin",  -- 领取竞技场币
    high_arena_select_arena_score_rank = "/api?method=high_arena.select_arena_score_rank",  -- 高阶竞技场积分排名
    high_arena_like = "/api?method=high_arena.like",  -- 点赞 
    high_arena_receive_quest = "/api?method=high_arena.receive_quest",  -- 领取日常任务奖励 quest_id: 任务id
    high_arena_quick_pass_arena = "/api?method=high_arena.quick_pass_arena",  -- 战斗快速通过 efend_uid: 敌人

    world_boss_trial_index = "/api?method=world_boss.trial_index", -- 试炼遗迹入口
    world_boss_index = "/api?method=world_boss.index", -- 世界boss入口
    world_boss_buy_world_boss_battle_times = "/api?method=world_boss.buy_world_boss_battle_times", -- 世界boss购买次数
    world_boss_battle_start = "/api?method=world_boss.battle_start", -- 世界boss战斗前 team: [hero_oid, hero_oid, ''] 英雄队伍
    world_boss_battle_end = "/api?method=world_boss.battle_end", -- 世界boss战斗后  team: [hero_oid, hero_oid, ''] 英雄队伍  damage: 1003234  伤害值
    world_boss_battle_start2 = "/api?method=world_boss.battle_start2", -- 世界boss战斗前 team: [hero_oid, hero_oid, ''] 英雄队伍
    world_boss_battle_end2 = "/api?method=world_boss.battle_end2", -- 世界boss战斗后  team: [hero_oid, hero_oid, ''] 英雄队伍  damage: 1003234  伤害值
    world_boss_get_ranks = "/api?method=world_boss.get_ranks", -- 获取排名数据  start: 1 stop: 50 yesterday: 1    # 1: 获取昨天的   0: 获取今天的排行榜数据(也可不填)
    world_boss_sweep = "/api?method=world_boss.sweep", -- 世界boss扫荡
    world_boss_like = "/api?method=world_boss.like", -- 世界boss点赞  rank: 1 1-5
    world_boss_recv_reward = "/api?method=world_boss.recv_reward", -- 世界boss点赞  rank: 1 1-5
    world_boss_auto_recv_reward = "/api?method=world_boss.auto_recv_reward", -- 自动领取  rank: 1 1-5
    
    train_index = "/api?method=train_challenge.train_index", --侠客试炼boss 首页
    train_rank = "/api?method=train_challenge.train_rank", --侠客试炼boss 排行
    train_challenge_battle_start = "/api?method=train_challenge.battle_start", --侠客试炼boss 战前数据
    train_challenge_battle_end = "/api?method=train_challenge.battle_end", --侠客试炼boss 战后数据
    train_challenge_recv_reward = "/api?method=train_challenge.recv_reward", --领取任务奖励
    train_challenge_recv_reward_all = "/api?method=train_challenge.recv_reward_all", --一键领取任务奖励

    guild_boss_index = "/api?method=guild_boss.index", --帮会boss首页
    guild_boss_battle_start = "/api?method=guild_boss.battle_start",  --帮会boss战前获取
    guild_boss_battle_end = "/api?method=guild_boss.battle_end",  --帮会boss战后获取
    guild_boss_select_heirloom = "/api?method=guild_boss.select_heirloom",  --帮会boss选择遗物
    guild_boss_recv_killed_reward = "/api?method=guild_boss.recv_killed_reward",  --帮会boss领取击杀奖励

    battle_replay = "/api?method=battle.replay", -- 战斗回放 battle_id: 0  战斗id

    library_troop_index = "/api?method=library.troop_index", -- 羁绊首页
    library_troop_add = "/api?method=library.troop_add", -- 羁绊添加英雄 type_id: 1    羁绊组id hero_oid: 8-1587524311-noTZVH  英雄唯一id target_uid: 2097151   所选英雄的拥有者
    rpg_map_index = "/api?method=rpg_map.map_index", -- 地图-首页 chapter_id: 
    rpg_goto = "/api?method=rpg_map.goto", -- 地图-前往某点 chapter_id: 1001  block_id: 10010000  path: [10010000, 10010001]
    rpg_click_obj = "/api?method=rpg_map.click", -- 地图-点击某物件 chapter_id: 1001  block_id: 10010000
    rpg_map_reset = "/api?method=rpg.reset_chapter", -- 地图-重置 chapter_id: 0
    rpg_battle_start = "/api?method=rpg_map.battle_start", -- 地图-战斗开始 team: [hero_oid, hero_oid, ''] 英雄队伍 chapter_id: 1001  block_id: 10010000
    rpg_battle_end = "/api?method=rpg_map.battle_end", -- 地图-战斗结束 esult: 0 or 1    # 战斗结果，0：失败，1：胜 利  rounds: []  # 战斗操作数据 cli_ver: '' # 战斗版本 chapter_id: 1001 block_id: 10010000
    rpg_choice_option = "/api?method=rpg_map.choice_option", -- 地图-选择一个互动选项 method: rpg.choice_option chapter_id: 1001  关卡id event_id: 10010000  事件id     option_id: 1  第几个选项1，2，3

    mystic_index = "/api?method=mystic.index", -- 藏经阁首页 
    -- mystic_put_mystic_in_slot = "/api?method=mystic.put_mystic_in_slot", -- 秘籍入藏 slot_id: 1     栏位id    取值范围(0, 1, 2, 3, 4). mystic_oid: 1   秘籍唯一id
    mystic_take_out_mystic = "/api?method=mystic.take_out_mystic", -- 取出秘籍  slot_id: 0    栏位id    取值范围(0, 1, 2, 3, 4) 
    mystic_evolution = "/api?method=mystic.evolution", -- 秘籍进化. 参数(POST, JSON)  mystic_data: { mystic_oid: [ mystic_oid1, mystic_oid2 ] }, {主秘籍: [材料秘籍, 材料秘籍]}
    mystic_slot_up_lv = "/api?method=mystic.mystic_slot_up_lv", --秘籍栏位升级
    mystic_put_mystic_in_slot = "/api?method=mystic.put_mystic_in_slot", --秘籍参悟
    mystic_up_sta = "/api?method=mystic.mystic_up_star", --秘籍升星
    mystic_synthetic = "/api?method=mystic.synthetic", --合成秘籍  mystic_id: 1   秘籍id (秘籍唯一id)
    mystic_show_rate = "/api?method=mystic.show_rate", --合成秘籍概率
    mystic_deduce = "/api?method=mystic.deduce", --秘籍推演  mystic_oid: 1   秘籍id (秘籍唯一id)
    mystic_cancel_deduce = "/api?method=mystic.cancel_deduce", --秘籍取消推演  mystic_oid: 1   秘籍id (秘籍唯一id)
    mystic_activate = "/api?method=mystic.activate", --秘籍激活
    mystic_levelup = "/api?method=mystic.levelup", --秘籍强化升级
    mystic_starup = "/api?method=mystic.starup", --秘籍升星
    mystic_chip_convert = "/api?method=mystic.chip_convert", --秘籍碎片转换

    mentorship_index = "/api?method=mentorship.index", -- 师徒首页 
    mentorship_info = "/api?method=mentorship.info", -- 师徒信息 
    mentorship_set_desc = "/api?method=mentorship.set_desc", -- 设置宣言 
    mentorship_set_flag = "/api?method=mentorship.set_flag", -- 设置免打扰状态 
    mentorship_recommend = "/api?method=mentorship.recommend", -- 刷新推荐 
    mentorship_doing_apply = "/api?method=mentorship.doing_apply", -- 申请拜师or收徒
    mentorship_handle_apply = "/api?method=mentorship.handle_apply", -- 处理申请拜师or收徒
    mentorship_relieve_mentor = "/api?method=mentorship.relieve_mentor", -- 解除师傅
    mentorship_relieve_pupil = "/api?method=mentorship.relieve_pupil", --  解除收徒
    mentorship_receive_red_packet = "/api?method=mentorship.receive_red_packet", --  领红包
    mentorship_doing_mentorship_apostle = "/api?method=apostle.doing_mentorship_apostle", --  雇佣师傅的英雄
    mentorship_msg_info = "/api?method=mentorship.msg_info", --  师门经历
    mentorship_quest_index = "/api?method=mentorship.quest_index", --  师门任务
    mentorship_receive_quest = "/api?method=mentorship.receive_quest", --  领取师门任务
    revenge_battle_start = "/api?method=arena.revenge_battle_start", --  复仇
    revoke_relieve_mentor = "/api?method=mentorship.revoke_relieve_mentor", --  撤销解除师傅
    revoke_relieve_pupil = "/api?method=mentorship.revoke_relieve_pupil", --  撤销解除徒弟
    red_packet = "/api?method=mentorship.red_packet", --红包首页

    revoke_relieve_pupil = "/api?method=mentorship.revoke_relieve_pupil", --  撤销解除徒弟

    rpg_index = "/api?method=rpg.index", -- 逸侠绘卷首页
    rpg_unlock = "/api?method=rpg.unlock", -- 绘卷解锁
    rpg_chapter = "/api?method=rpg.unlock_chapter", -- 绘卷关卡解锁
    rpg_enter_chapter = "/api?method=rpg.enter_chapter", -- 绘卷关卡进入
    rpg_reset_chapter = "/api?method=rpg.reset_chapter", -- 绘卷关卡重置

    code_use_code = "/api?method=code.use_code", -- 兑换码. code: afk666

    question_start = "/api?method=question.start", -- 开始问卷
    question_do = "/api?method=question.do_question", --做题

    five_element_index = "/api?method=five_element.index", --五行首页
    five_element_reset = "/api?method=five_element.reset_floor", --五行重置
    five_element_battle_start = "/api?method=five_element.battle_start", -- 五行战斗前获取数据 
    five_element_battle_end = "/api?method=five_element.battle_end", -- 五行战斗后获取数据 
    five_element_battle_start2 = "/api?method=five_element.battle_start2", -- 五行战斗前获取数据 
    five_element_battle_end2 = "/api?method=five_element.battle_end2", -- 五行战斗后获取数据 
    filv_friends_data = "/api?method=five_element.query_friends_data", --获取好友以及工会好友信息
    filv_combat_data = "/api?method=five_element.query_combat_data", --获取好友以及工会好友信息
    receive_rewards = "/api?method=five_element.receive_rewards", -- 五行领取奖励
    five_element_enable = "/api?method=five_element.enable", --五行阵激活
    five_element_sweep = "/api?method=five_element.sweep", --五行阵扫荡

    five_element_receive_reward = "/api?method=five_element.receive_rewards", --五行阵 开启宝箱奖励 
    five_element_over = "/api?method=five_element.over", --五行阵 结束 

    five_element_enter_next_floor = "/api?method=five_element.enter_next_floor", --五行阵进入下一层
    
    --四象阵
    four_tower_index = "/api?method=four_tower.index", --四象阵主页
    four_tower_battle_start = "/api?method=four_tower.battle_start", --四象阵战前获取数据
    four_tower_battle_end = "/api?method=four_tower.battle_end", --四象阵战后获取数据
    four_tower_receive_box = "/api?method=four_tower.receive_box", --四象领取宝箱
    four_tower_receive_heirloom = "/api?method=four_tower.receive_heirloom", --四象领取遗物
    four_tower_auto_battle = "/api?method=four_tower.auto_battle", --四象碾压
    four_tower_enter_next_floor = "/api?method=four_tower.enter_next_floor", --四象阵下一关
    four_tower_receive_ques = "/api?method=four_tower.receive_quest", --四象阵领取任务奖励

    --月影传说
    mood_shadow_index = "/api?method=mood_shadow.index", --月影传说-主页
    mood_shadow_receive_quest = "/api?method=mood_shadow.receive_quest", --月影传说-领取任务奖励
    mood_shadow_recv_score_reward = "/api?method=mood_shadow.recv_score_reward", --月影传说-领取积分奖励
    mood_shadow_battle_start = "/api?method=mood_shadow.battle_start", --月影传说-战前数据
    mood_shadow_battle_end = "/api?method=mood_shadow.battle_end", --月影传说-战后数据
    mood_shadow_rank_info = "/api?method=mood_shadow.rank_info", --月影传说-排行榜数据
    mood_shadow_train_index = "/api?method=mood_shadow.train_index", --月影传说-试炼首页
    mood_shadow_receive_free_gift = "/api?method=mood_shadow.receive_free_gift", --月影传说--购买免费礼包

    --邪极魅影
    evil_shadow_index = "/api?method=evil_shadow.index", --邪极魅影-主页
    evil_shadow_receive_quest = "/api?method=evil_shadow.receive_quest", --邪极魅影-领取任务奖励
    evil_shadow_recv_score_reward = "/api?method=evil_shadow.recv_score_reward", --邪极魅影-领取积分奖励
    evil_shadow_battle_start = "/api?method=evil_shadow.battle_start", --邪极魅影-战前数据
    evil_shadow_battle_end = "/api?method=evil_shadow.battle_end", --邪极魅影-战后数据
    evil_shadow_rank_info = "/api?method=evil_shadow.rank_info", --邪极魅影-排行榜数据
    evil_shadow_train_index = "/api?method=evil_shadow.train_index", --邪极魅影-试炼首页
    evil_shadow_receive_free_gift = "/api?method=evil_shadow.receive_free_gift", --邪极魅影--购买免费礼包
    evil_shadow_exchange = "/api?method=evil_shadow.exchange", --邪极魅影--兑换奖励礼包
    
    --古剑奇谭
    ancient_sword_and_wonderland_index ="/api?method=ancient_sword_and_wonderland.index" , --古剑现世
    ancient_sword_and_wonderland_battle_start ="/api?method=ancient_sword_and_wonderland.battle_start" , --古剑现世，战前获取
    ancient_sword_and_wonderland_battle_end ="/api?method=ancient_sword_and_wonderland.battle_end" , --古剑现世，战后获取 
    ancient_sword_and_wonderland_sword_sign_index ="/api?method=ancient_sword_and_wonderland.sword_sign_index" , --煞剑出鞘
    ancient_sword_and_wonderland_sword_sign_bubble_interact ="/api?method=ancient_sword_and_wonderland.sword_sign_bubble_interact" , --煞剑出鞘，气泡交互
    ancient_sword_and_wonderland_sword_sign_progress_bar ="/api?method=ancient_sword_and_wonderland.sword_sign_progress_bar" , --煞剑出鞘，进度条奖励
    
    ancient_sword_and_wonderland_akuma_index ="/api?method=ancient_sword_and_wonderland.akuma_index" , --剑魔地宫-首页
    ancient_sword_and_wonderland_employ ="/api?method=ancient_sword_and_wonderland.employ" , --剑剑魔地宫-雇佣援兵守卫
    ancient_sword_and_wonderland_goto ="/api?method=ancient_sword_and_wonderland.goto" , --剑魔地宫-前往格子
    ancient_sword_and_wonderland_add_blood ="/api?method=ancient_sword_and_wonderland.add_blood" , --剑魔地宫-药泉治疗(回血)
    ancient_sword_and_wonderland_revive_one ="/api?method=ancient_sword_and_wonderland.revive_one" , --剑魔地宫-供奉济世罗汉(随机复活一位)
    ancient_sword_and_wonderland_recv_reward ="/api?method=ancient_sword_and_wonderland.recv_reward" , --剑魔地宫-领取奖励
    ancient_sword_and_wonderland_enter_next ="/api?method=ancient_sword_and_wonderland.enter_next" , --剑魔地宫-进入下一层
    ancient_sword_and_wonderland_encounter_choice_option ="/api?method=ancient_sword_and_wonderland.encounter_choice_option" , --剑魔地宫-奇遇选择事件
    ancient_sword_and_wonderland_set_all_passed ="/api?method=ancient_sword_and_wonderland.set_all_passed" , --剑魔地宫-设置所有格子为已通过
    ancient_sword_and_wonderland_recv_key ="/api?method=ancient_sword_and_wonderland.recv_key" , --剑魔地宫-领取钥匙
    ancient_sword_and_wonderland_messenger_of_blessings ="/api?method=ancient_sword_and_wonderland.messenger_of_blessings" , --剑魔地宫-祝福使者
    ancient_sword_and_wonderland_evil_sword_melting_pot ="/api?method=ancient_sword_and_wonderland.evil_sword_melting_pot" , --剑魔地宫-邪剑熔炉
    ancient_sword_and_wonderland_battle_start2 ="/api?method=ancient_sword_and_wonderland.battle_start2" , --剑魔地宫-战斗前数据
    ancient_sword_and_wonderland_battle_end2 ="/api?method=ancient_sword_and_wonderland.battle_end2" , --剑魔地宫-战斗后接口
    

    big_map_index = "/api?method=big_map.index",
    big_map_move = "/api?method=big_map.move",
    big_map_enter_map = "/api?method=big_map.enter_map",
    big_map_query_friend = "/api?method=big_map.query_friend",
    big_map_choice_option = "/api?method=big_map.choice_option",
    big_map_event_battle_start = "/api?method=big_map.event_battle_start",
    big_map_event_battle_end = "/api?method=big_map.event_battle_end",
    --big_map_enter_map_event = "/api?method=big_map.enter_map_event",
    big_map_close_encounter = "/api?method=big_map.close_encounter", -- 奇遇触发后，点击关闭 -- event_id: 1 事件id
    big_map_encounter_trigger = "/api?method=big_map.encounter_trigger", --奇遇事件触发 npc_id: 1
    big_map_enter_scene = "/api?method=big_map.enter_scene",
    big_map_enter_child_scene = "/api?method=big_map.enter_child_scene",
    big_map_start_task = "/api?method=big_map.start_task",
    big_map_finish_task = "/api?method=big_map.finish_task",
    big_map_select_task = "/api?method=big_map.select_task",
    big_map_giveup_task = "/api?method=big_map.giveup_task",
    big_map_interact = "/api?method=big_map.interact",
    big_map_regional_battle_start = "/api?method=big_map.regional_battle_start",
    big_map_regional_battle_end = "/api?method=big_map.regional_battle_end",
    big_map_receice_area_cpd = "/api?method=big_map.receice_area_cpd", -- 领取区域完成度奖励  area_id: 1    # 区域id
    big_map_receice_scene_cpd = "/api?method=big_map.receice_scene_cpd", -- 领取场景完成度奖励  area_id: 1    # 区域id   scene_id: 1   # 场景id
    big_map_travel_log_index = "/api?method=big_map.travel_log_index", --查看游历日志

    big_map_plunder_occupy_front = "/api?method=big_map.occupy_battle_start", --大地图占领 战斗前数据
    big_map_plunder_occupy_back = "/api?method=big_map.occupy_battle_end", --大地图占领 战斗后数据
    big_map_plunder_seize_front = "/api?method=big_map.plunder_battle_start", --大地图掠夺 战斗前数据
    big_map_plunder_seize_back = "/api?method=big_map.plunder_battle_end", --大地图掠夺 战斗后数据
    big_map_plunder_station = "/api?method=big_map.station_list", --大地图驻地列表
    big_map_plunder_station_details = "/api?method=big_map.station_list", --大地图驻地详情读取
    big_map_plunder_get_earnings = "/api?method=big_map.receive_income", --大地图驻地领取收益
    big_map_plunder_dispatch = "/api?method=big_map.dispatch", --大地图驻地派遣驻守队伍
    big_map_plunder_dispatch_onekey = "/api?method=big_map.auto_dispatch", --大地图驻地一键派遣驻守队伍
    big_map_plunder_evacuate = "/api?method=big_map.retreat", --大地图驻地撤离驻守队伍

    big_map_encounter_quest_index = "/api?method=big_map.encounter_quest_index", --奇遇任务首页
    big_map_receive_eg_quest = "/api?method=big_map.receive_eg_quest", --领取奖励(奇遇group获取成就点任务)  quest_id: 1
    big_map_receive_e_quest = "/api?method=big_map.receive_e_quest", --领取奖励(奇遇完成事件次数任务)  quest_id: 10101002

    -- big_map_bounty_index = "/api?method=bounty.bounty_index", 
    -- big_map_bounty_do_quest = "/api?method=bounty.do_quest", --大地图悬赏 做悬赏任务
    -- big_map_bounty_refresh_quest = "/api?method=bounty.refresh_quest", --大地图悬赏 刷新任务
    -- big_map_bounty_receive = "/api?method=bounty.receive", --大地图悬赏 领取任务奖励
    -- big_map_bounty_get_mercenarys = "/api?method=bounty.get_mercenarys", --大地图悬赏 获取好友和工会成员的外援
    -- big_map_bounty_mercenary = "/api?method=library.mercenary", --大地图悬赏 我的外援首页
    -- big_map_bounty_mercenary_add = "/api?method=library.mercenary_add", --大地图悬赏 我的外援设置外援
    -- big_map_bounty_mercenary_del = "/api?method=library.mercenary_del", --大地图悬赏 我的外援移除外援
    -- big_map_bounty_get_master_info = "/api?method=bounty.get_master_info", --大地图悬赏 获取师傅的简易信息和英雄去重数据
    -- big_map_bounty_get_pupils_info = "/api?method=bounty.get_pupils_info", --大地图悬赏 获取徒弟们的悬赏数据
    -- big_map_bounty_refresh_log = "/api?method=bounty.refresh_log", --大地图悬赏 刷新悬赏日志

    big_map_prestige_index ="/api?method=big_map.prestige_index", --威望首页
    big_map_prestige_receive ="/api?method=big_map.prestige_receive", --威望领奖
    big_map_prestige_rank ="/api?method=big_map.prestige_rank", --威望排行
    big_map_receive_world_box_reward ="/api?method=big_map.receive_world_box_reward", --领取江湖宝箱奖励  npc_id: 1    map_pos: [1, 2]   

    welfare_npc_index = "/api?method=welfare_npc.index", --官方人设入口
    read_notice = "/api?method=welfare_npc.read_notice", --官方人设-读取公告
    read_mail = "/api?method=welfare_npc.read_mail", --官方人设-读取邮件
    receive_mail = "/api?method=welfare_npc.receive_mail", --官方人设-领取邮件
    read_welfare = "/api?method=welfare_npc.read_welfare", --官方人设-读取福利
    receive_welfare = "/api?method=welfare_npc.receive_welfare", --官方人设-领取
    receive_all_mail = "/api?method=welfare_npc.receive_all_mail", -- 人设邮件一键领取
    remove_all_mail = "/api?method=welfare_npc.remove_all_mail", -- 人设邮件一键删除
    read_code = "/api?method=welfare_npc.read_code", -- 读取cdk
    remove_code = "/api?method=welfare_npc.remove_code", -- 删除cdk

    bounty_bounty_index = "/api?method=bounty.bounty_index", --悬赏入口
    bounty_do_quest = "/api?method=bounty.do_quest", --做悬赏任务 quest_id:任务id  quest_type:任务类型  1: 个人, 2:团队 self_hero:自己的上阵英雄[hero_id]  friend_hero:{1234568: '6-1577692678-jYK4We'}好友或公会成员英雄信息{uid: hero_id}   (个人任务可不传此字段)
    bounty_refresh_quest = "/api?method=bounty.refresh_quest", --刷新悬赏任务
    bounty_receive = "/api?method=bounty.receive", --领取悬赏任务
    mercenary = "/api?method=troop.mercenary", --我的外援首页
    mercenary_add = "/api?method=troop.mercenary_add", --添加外援 设置外援
    mercenary_del = "/api?method=troop.mercenary_del", --移除外援 
    get_mercenarys = "/api?method=bounty.get_mercenarys", --获得好友和公会的外援 
    get_master_info = "/api?method=bounty.get_master_info", --获取师傅的简易信息和英雄去重数据
    get_pupils_info = "/api?method=bounty.get_pupils_info", --获取徒弟们的悬赏数据
    bounty_refresh_log = "/api?method=bounty.refresh_log", --刷新悬赏日志
    bounty_auto_receive = "/api?method=bounty.auto_receive", --一键领取
    auto_view = "/api?method=bounty.auto_view", --一键派遣预览
    auto_do_quest = "/api?method=bounty.auto_do_quest", --一键派遣预览
    quick_finish = "/api?method=bounty.quick_finish", --元宝加速派遣
    auto_do_quest = "/api?method=bounty.auto_do_quest", --一键派遣

    quick_pass_tower = "/api?method=tower.quick_pass_tower", --爬塔快速通关


    scenario_index = "/api?method= scenario.index", --剧情关首页
    --参数 s_id: 剧情关id
    scenario_finish = "/api?method= scenario.finish", --剧情关 完成对话节点
    --参数 s_id: 剧情关id node_id: 节点id
    scenario_battle_start = "/api?method= scenario.battle_start", --战斗前获取数据
    --参数 s_id: 节点id
    scenario_battle_end = "/api?method= scenario.battle_end", --战斗后获取数据
    --参数 s_id: 节点id

    biography_index = "/api?method=biography.index", --传记-首页
    biography_battle_start = "/api?method=biography.battle_start", --传记-战斗前获取数据 team: [hero_oid, hero_oid, ''] 英雄队伍deployment: 1 bio_id: 1 传记id chapter_id: 1 章节id  stage_id: 1 关卡id
    biography_battle_end = "/api?method=biography.battle_end", --传记-战斗后获取数据  result: 0 or 1    # 战斗结果，0：失败，1：胜利 rounds: [] # 战斗操作数据 cli_ver: '' # 战斗版本 bio_id: 1 传记id chapter_id: 1 章节id stage_id: 1 关卡id
    biography_recv_chapter_reward = "/api?method=biography.recv_chapter_reward", --传记-领取章节奖励  bio_id: 1 传记id chapter_id: 1 章节id
    biography_recv_bio_reward = "/api?method=biography.recv_bio_reward", --传记-领取传记奖励 bio_id: 1 传记id

    legend_index = "/api?method=legend.index", --江湖传说-首页
    legend_battle_start = "/api?method=legend.battle_start", --江湖传说-战前数据
    legend_battle_end = "/api?method=legend.battle_end", --江湖传说-战后数据
    legend_recv_daily_reward = "/api?method=legend.recv_daily_reward", -- 江湖传说-日常奖励
    legend_recv_weekly_reward = "/api?method=legend.recv_weekly_reward", -- 江湖传说-周常奖励
    legend_select_rank = "/api?method=legend.select_rank", -- 江湖传说-排行
    legend_recv_reward_all = "/api?method=legend.recv_reward_all", -- 江湖传说-日常奖励-一键领取
    legend_quick_pass = "/api?method=legend.quick_pass", -- 江湖传说-扫荡

    hero_evaluate_index = "/api?method=hero_evaluate.index",--英雄评价首页
    hero_evaluate_comments_by_range ="/api?method=hero_evaluate.comments_by_range",--获取指定范围的评论
    hero_evaluate_add_comment = "/api?method=hero_evaluate.add_comment",--添加评论内容
    hero_evaluate_like = "/api?method=hero_evaluate.like",--点赞评论内容
    hero_evaluate_unlike = "/api?method=hero_evaluate.unlike", --取消点在评论内容
    hero_evaluate_update_score = "/api?method=hero_evaluate.update_score", --更新英雄评分

    hero_resonance_level_up = "/api?method=hero.resonance_level_up",--sp侠客共鸣升级

    high_gacha_index = "/api?method=high_gacha.index", --前缘桥入口
    high_gacha_set_aim_hero = "/api?method=high_gacha.set_aim_hero", --设置目标侠客 hero_id: 101
    high_gacha_get_gacha = "/api?method=high_gacha.get_gacha", --抽卡 pool_id: 7  卡池id  7: 占星抽  gacha_type: 1  1: 单抽,  10: 十连抽
    high_gacha_voyage_recv_box = "/api?method=high_gacha.voyage_recv_box", --box_id

    --SP抽卡
    high_gacha_sp_index = "/api?method=high_gacha.sp_index", --前缘桥入口
    high_gacha_sp_set_aim_hero = "/api?method=high_gacha.sp_set_aim_hero", --设置目标侠客 hero_id: 101
    high_gacha_sp_get_gacha = "/api?method=high_gacha.sp_get_gacha", --抽卡 pool_id: 7  卡池id  7: 占星抽  gacha_type: 1  1: 单抽,  10: 十连抽

    guild_war_index = "/api?method=guild_war.index", --公会战首页
    guild_war_battle_field = "/api?method=guild_war.battlefield", --公会战战场
    guild_war_formation_index = "/api?method=guild_war.formation_index", --公会战编队首页    
    guild_war_set_formation = "/api?method=guild_war.set_formation", --公会战设置编队
    guild_war_dispatch = "/api?method=guild_war.dispatch", --公会战驻扎
    guild_war_recall = "/api?method=guild_war.recall", --公会战解除驻扎
    guild_war_cell_info = "/api?method=guild_war.cell_info", --公会战地块信息
    guild_war_rank = "/api?method=guild_war.rank", --公会战排行榜信息
    guild_war_event = "/api?method=guild_war.event_info", --公会战事件信息
    guild_war_score = "/api?method=guild_war.score_info", --公会战积分信息
    guild_war_battle_info = "/api?method=guild_war.battle_info", --公会战战斗录像
    guild_war_sign_up = "/api?method=guild_war.sign_up", --公会战报名
    guild_war_cancel_sign_up = "/api?method=guild_war.cancel_sign_up", --公会战取消报名
    guild_war_get_last_report = "/api?method=guild_war.get_last_report", --概况战报
    guild_war_report_like = "/api?method=guild_war.report_like", --概况战报点赞

    -- 新公会战接口
    gvg_index = "/api?method=gvg.index", --公会战首页
    gvg_sign_up = "/api?method=gvg.sign_up", --公会战报名
    gvg_battle_field = "/api?method=gvg.battlefield", --公会战战场
    gvg_formation_index = "/api?method=gvg.formation_index", --公会战编队首页
    gvg_set_formation = "/api?method=gvg.set_formation", --公会战设置编队
    gvg_atk_formation_index = "/api?method=gvg.atk_formation_index", --公会战-攻击编队首页
    gvg_set_atk_formation = "/api?method=gvg.set_atk_formation", --公会战-设置攻击编队
    gvg_cell_info = "/api?method=gvg.cell_info", --公会战-地块详情 -- cell_id: 1
    gvg_battle_start = "/api?method=gvg.battle_start", --公会战-战斗
    gvg_battle_info = "/api?method=gvg.battle_info", --公会战-战报
    gvg_get_last_report = "/api?method=gvg.get_last_report", --概况战报
    gvg_save_mock = "/api?method=gvg.save_mock", --公会战-模拟挑战保存战绩
    gvg_rank = "/api?method=gvg.rank", --公会战排行榜信息
    gvg_active_rank = "/api?method=gvg.active_rank", --公会活跃度战排行榜信息
    gvg_report_like = "/api?method=gvg.report_like", --公会点赞信息
    
    --烁玉流金     
    hero_chest_index = "/api?method=hero_chest.index",--烁玉流金首页     
    hero_chest_receive_quest = "/api?method=hero_chest.receive_quest",--材料获取
    hero_chest_buy_shop_goods = "/api?method=hero_chest.buy_shop_goods",--乘龙有礼
    hero_chest_receive_login = "/api?method=hero_chest.receive_login", --限时登录
    hero_chest_receive_draw_gift = "/api?method=hero_chest.receive_draw_gift", --天机觅宝
    hero_chest_random_draw = "/api?method=hero_chest.random_draw", --天机觅宝抽奖
    user_payment_daily_charge_index = "s7/api?method=user_payment.daily_charge_index",--每日18元首页
    user_payment_daily_charge_receive = "s7/api?method=user_payment.daily_charge_receive", --每日18元领奖

    high_gacha_voyage_index = "/api?method=high_gacha.voyage_index", --盗帅迷踪入口
    high_gacha_voyage_get_gacha = "/api?method=high_gacha.voyage_get_gacha", --盗帅迷踪抽卡  pool_id: 8 gacha_type: 抽卡次数
    high_gacha_voyage_buy_gift = "/api?method=high_gacha.voyage_buy_gift", --盗帅迷踪购买元宝礼包 gift_id: 1

    --幸运罗盘
    roulette_roulette_index = "/api?method=roulette.roulette_index",
    roulette_refresh = "/api?method=roulette.refresh",
    roulette_treasure = "/api?method=roulette.treasure",
    roulette_point = "/api?method=roulette.point",

    red_dot_clear = "/api?method=red_dot.clear", -- 清除红点， red_dot_type : "hero_evolution"
    red_dot = "/api?method=red_dot.show", -- 获取红点
    
    user_payment_recommend_index = "/api?method=user_payment.recommend_index", --推荐
    
    --江湖进度
    stage_server_level_index = "/api?method=stage.server_level_index", --江湖进度首页
    stage_server_level_rank ="/api?method=stage.server_level_rank", --江湖进度排名信息
    stage_server_level_receive ="/api?method=stage.server_level_receive", --江湖进度领取奖励
    
    --武道场
    raid_index = "/api?method=raid.index",
    raid_battle_start = "/api?method=raid.battle_start", -- team: [hero_oid, hero_oid, ''] 英雄队伍  deployment: 1
    raid_battle_end = "/api?method=raid.battle_end",-- result: 0 or 1    # 战斗结果，0：失败，1：胜利  rounds: []        # 战斗操作数据  cli_ver: ''       # 战斗版本  raid_sort: 0 配置类型
    raid_quick_pass_raid = "/api?method=raid.quick_pass_raid",  --raid_sort: 0 配置类型
    raid_sweep = "/api?method=raid.sweep",  --raid_sort: 0 配置类型  raid_id: 0 配置id
    raid_auto_sweep = "/api?method=raid.auto_sweep",  --一键扫荡

    --聚宝山
    richman_index = "/api?method=richman.index", --聚宝山主页
    richman_roll = "/api?method=richman.roll",  --聚宝山掷骰子
    richman_building_dispatch_view = "/api?method=richman.building_dispatch_view",  --建筑一键派遣
    richman_building_dispatch = "/api?method=richman.building_dispatch",    --建筑派遣
    richman_bank_dispatch_view = "/api?method=richman.bank_dispatch_view",  --钱庄一键派遣
    richman_bank_dispatch = "/api?method=richman.bank_dispatch",  --钱庄派遣
    richman_buy_times = "/api?method=richman.buy_times",  --购买掷骰子次数
    richman_recv_special = "/api?method=richman.recv_special",  --任务id
    richman_buy_gift = "/api?method=richman.buy_gift",  --购买礼包
    richman_cell_detail = "/api?method=richman.cell_detail",  --格子详情

    game_street_index = "/api?method=game_street.index",  --首页
    game_street_receive = "/api?method=game_street.receive",  --领奖 group_id: 组id  reward_id: 奖励id
    game_street_settlement = "/api?method=game_street.settlement",  --结算积分 group_id: 组id  score: 积分
    game_street_rank_info = "/api?method=game_street.rank_info",  --领奖 start: 1  stop: 10
    game_street_common_settlement = "/api?method=game_street.common_settlement",  --结算积分 group_id: 组id  score: 积分
    game_street_common_index = "/api?method=game_street.common_index",  --小游戏通用首页接口

    --字节相关
    bytedance_report = "/api?method=bytedance.report",  --举报
    round_action = "/api?method=bytedance.round_action",  --战斗中途操作统计

    --苗疆觅宝
    mining_index = "/api?method=mining.index", --苗疆觅宝首页
    mining_map_index = "/api?method=mining.map_index", --苗疆觅宝大地图首页
    mining_region_index = "/api?method=mining.region_index", --苗疆觅宝区域首页 region_id: 1  # 区域id
    mining_location_index = "/api?method=mining.location_index", --苗疆觅宝地区index region_id: 1   # 区域id location_id: 1  # 地区id
    mining_set_defend_team = "/api?method=mining.set_defend_team", --苗疆觅宝设置防守阵容 teams: [[hero_oid],[hero_oid],[hero_oid]] deployments: [1, 1, 1]
    mining_mine_detail = "/api?method=mining.mine_detail", --苗疆觅宝矿坑详情 mine_oid: 1   # 矿坑唯一idmine_oid: 1 
    mining_battle_start = "/api?method=mining.battle_start", --苗疆觅宝战斗 mine_oid: 1   # 矿坑唯一id team: [hero_oid, hero_oid, ''] 英雄队伍 deployment: 阵法id
    mining_recall_team = "/api?method=mining.recall_team", --苗疆撤离 team_id: 1    # 队伍id，1，2，3
    mining_receive_income = "/api?method=mining.receive_income", --苗疆领奖 mine_oid: 1   # 矿坑唯一id
    mining_my_mine = "/api?method=mining.my_mine", --苗疆我的矿洞
    mining_battle_info = "/api?method=mining.battle_info", --苗疆我的战报
    mining_set_desc = "/api?method=mining.set_desc", --苗疆设置发言 desc: ''  # 发言内容
    mining_buy_plunder_times = "/api?method=mining.buy_plunder_times", --购买掠夺次数 times
    mining_receive_scale = "/api?method=mining.receive_scale", --领取里程碑 参数scale
    
    --法宝/遗物
    relic_index = "/api?method=relic.index", --首页
    relic_up_lv = "/api?method=relic.up_lv", --升级
    relic_select_relic = "/api?method=relic.select_relic", --上阵
    relic_reset_relic = "/api?method=relic.reset_relic", --重置

    --天下首页
    world_index = "/api?method=world.index",

    --天下跨服分组
    world_group_index = "/api?method=world.group_index",
    world_all_rank = "/api?method=world.all_rank", -- 跨服排行  is_cross: 0:本服，1：跨服
    world_rank_info = "/api?method=world.rank_info", -- 单个跨服排行 is_cross: 0:本服，1：跨服 sort: 排行榜类型，1：帮会战，2：苗疆觅宝，3：天下演武，4：秘籍，5：装备，6：法宝 start: 1  开始排名 stop: 10  结束排名
    world_recv_season_reward = "/api?method=world.recv_season_reward", --领取赛季预览奖励

    charge_check = "/api?method=user_payment.charge_check", --充值检查
    payment_ios = "/api?method=payment.pay", --ios
    bytedance_report = "/api?method=bytedance.report", -- 举报

    user_share = "/api?method=user.share", -- 分享

    quest_season_index = "/api?method=quest_season.index", -- 赛季成就主页
    quest_season_recv_chapter_reward = "/api?method=quest_season.recv_chapter_reward", -- 赛季成就奖励领取
    quest_season_select_top_rank = "/api?method=quest_season.select_top_rank", -- 排行榜
    quest_season_recv_quest_reward = "/api?method=quest_season.recv_quest_reward", -- 赛季领取任务奖励

    hero_book_lvlup = "/api?method=hero.book_lvlup", -- 武神-图鉴升级
    hero_book_reset = "/api?method=hero.book_reset", -- 武神-图鉴重置
    active_kingsoft_index = "/api?method=active.kingsoft_index", -- 金山游侠联动 首页
    active_kingsoft_find = "/api?method=active.kingsoft_find", -- 金山游侠联动 搜索params vsn:1版本号"value": 1  // 搜索值
    active_kingsoft_modify = "/api?method=active.kingsoft_modify", -- 金山游侠联动修改 params vsn:1版本号 date_id 对应select中的第一个值
    active_kingsoft_select = "/api?method=active.kingsoft_select", -- 金山游侠联动选择到存储列表 params vsn:1版本号 date_id 对应select中的第一个值
    
    tower_active_index = "/api?method=tower_active.index", -- 天机秘境
    tower_active_battle_start = "/api?method=tower_active.battle_start", -- 天机秘境战斗开始"deployment": 1,"relic": {},"team": [],"layer": 1,     // 层
    tower_active_battle_end = "/api?method=tower_active.battle_end", -- 天机秘境战斗开始 "result": 0,"rounds": [],"cli_ver": 0,
    tower_active_show_hero = "/api?method=tower_active.show_hero", -- 天机秘境群英谱 "result": 0,"rounds": [],"cli_ver": 0,
    tower_active_show_rank = "/api?method=tower_active.show_rank", -- 天机秘境排行 params start 1 stop 10
    tower_active_show_cross_rank = "/api?method=tower_active.show_cross_rank", -- 天机秘境跨服排行 params start 1 stop 10
    tower_active_receive_free_reward = "/api?method=tower_active.receive_free_reward", -- 领取免费奖励 参数(POST, JSON) "day": 1,
    
    dark_tower_index = "/api?method=dark_tower.index", -- 极阴塔主页
    dark_tower_battle_start = "/api?method=dark_tower.battle_start", -- 极阴塔战前数据
    dark_tower_battle_end = "/api?method=dark_tower.battle_end", -- 极阴塔战后数据
    dark_tower_receive_free_gifts = "/api?method=dark_tower.receive_free_gifts", -- 领取免费奖励 "vsn": 1,  // 版本 "gift_id": 1  // yinyang_tower_gift表的礼包id
    dark_tower_rank_info = "/api?method=dark_tower.rank_info", -- 伤害排行榜 "vsn": 1,  // 版本 "gift_id": 1  // yinyang_tower_gift表的礼包id
    dark_tower_auto_battle = "/api?method=dark_tower.auto_battle", -- 极阴塔碾压接口 position "vsn": 1,  //
    dark_tower_quick_pass_tower = "/api?method=dark_tower.quick_pass_tower", -- 极阴塔一键碾压接口 position "vsn": 1,  //
    
    hero_enable_fate = "/api?method=hero.enable_fate", -- 天命化星，领悟

    --龙泉剑影
    active_dragonsword_quest_index = "/api?method=active.dragonsword_quest_index", --首页
    active_dragonsword_recv_quest_reward = "/api?method=active.dragonsword_recv_quest_reward", --领取任务奖励
    active_dragonsword_recv_score_reward = "/api?method=active.dragonsword_recv_score_reward", --领取积分奖励
    active_dragonsword_recv_login_reward = "/api?method=active.dragonsword_recv_login_reward", --领取签到奖励
    active_dragonsword_doing_melting = "/api?method=active.dragonsword_doing_melting", --进行熔炼
    active_dragonsword_battle_start = "/api?method=active.dragonsword_battle_start", --战前
    active_dragonsword_battle_end = "/api?method=active.dragonsword_battle_end", --战斗结束
    active_dragonsword_rank_info = "/api?method=active.dragonsword_rank_info", --排名信息
    
    --唐伯虎活动
    hero_event_index = "/api?method=hero_event.index", --首页
    hero_event_train_index = "/api?method=hero_event.train_index", --试炼
    hero_event_receive_free_gift = "/api?method=hero_event.receive_free_gift", --免费礼包
    hero_event_receive_quest = "/api?method=hero_event.receive_quest", --任务奖励
    hero_event_exchange = "/api?method=hero_event.exchange", --兑换奖励
    hero_event_recv_score_reward = "/api?method=hero_event.recv_score_reward", --积分奖励
    hero_event_battle_start = "/api?method=hero_event.battle_start", --战前
    hero_event_battle_end = "/api?method=hero_event.battle_end", --战后
    hero_event_rank_info = "/api?method=hero_event.rank_info", --伤害排行榜
    hero_event_lottery_draw = "/api?method=hero_event.lottery_draw", --抽奖
    hero_event_get_combat_rank = "/api?method=hero_event.get_combat_rank", --获取战力排行榜数据version: 版本 start: 分页起始值 stop: 分页终止值
    hero_event_receive_daily_reward = "/api?method=hero_event.receive_daily_reward", --领取每日奖励 version: 版本 reward_id: 奖励id

    stage_mul_team_battle_start = "/api?method=stage.mul_team_battle_start", --多队伍战斗前获取数据 teams: []侠客队伍deployments: [1,1] relics: [{}, {}]
    stage_mul_team_battle_end = "/api?method=stage.mul_team_battle_end", --多队伍战斗后获取数据 teams: []侠客队伍deployments: [1,1] relics: [{}, {}]

    --奇门遁甲
    gve_index                   =        "/api?method=gve.index",                   --主页
    gve_detail                  =        "/api?method=gve.detail",                  --格子详情
    gve_goto                    =        "/api?method=gve.goto",                    --前往格子
    gve_recv_reward             =        "/api?method=gve.recv_reward",             --领取宝箱奖励
    gve_recv_explore_reward     =        "/api?method=gve.recv_explore_reward",     --领取里程碑奖励
    gve_recv_quest_reward       =        "/api?method=gve.recv_quest_reward",       --领取任务奖励
    gve_auto_recv               =        "/api?method=gve.auto_recv",               --领取全部任务奖励
    gve_recv_buff               =        "/api?method=gve.recv_buff",               --力量雕像
    gve_enable_relic            =        "/api?method=gve.enable_relic",            --激活铸剑台
    gve_recv_mystic             =        "/api?method=gve.recv_mystic",             --激活藏经阁
    gve_guild_relic_lvlup       =        "/api?method=gve.guild_relic_lvlup",       --升级帮会法宝
    gve_guild_reward_index      =        "/api?method=gve.guild_reward_index",      --帮会奖励界面
    gve_guild_reward_recv       =        "/api?method=gve.guild_reward_recv",       --帮会奖励领取界面
    gve_rank_inside             =        "/api?method=gve.rank_inside",             --帮贡排行榜
    gve_quest_index             =        "/api?method=gve.quest_index",             --任务首页
    gve_battle_start            =        "/api?method=gve.battle_start",            --战前获取数据
    gve_battle_start_back       =        "/api?method=gve.battle_start_back",       --战前获取数据，跳过战斗
    gve_battle_end              =        "/api?method=gve.battle_end",              --战后获取数据
    gve_get_new_cells           =        "/api?method=gve.get_new_cells",           --客户端更新格子数据 
    gve_lock_hero               =        "/api?method=gve.lock_hero",               --锁定英雄
    gve_buy_health              =        "/api?method=gve.buy_health",              --购买体力
    enable_pillars              =        "/api?method=gve.enable_pillars",          --激活柱子


    --七夕佳节
    valentine_festival_box_index                 =        "/api?method=valentine_festival.box_index",                   --团购狂欢-首页
    valentine_festival_box_rank                  =        "/api?method=valentine_festival.box_rank",                    --团购狂欢-购买排行榜
    valentine_festival_moon_index                =        "/api?method=valentine_festival.moon_index",                  --明月献礼-首页
    valentine_festival_receive_moon_reward       =        "/api?method=valentine_festival.receive_moon_reward",         --明月献礼-领奖

    dark_tower_auto_battle = "/api?method=dark_tower.auto_battle", -- 极阴塔碾压接口 position "vsn": 1,  // 

    thrones_up_lv = "/api?method=equip.thrones_up_lv", --图鉴升级
    thrones_evolution = "/api?method=equip.thrones_evolution", --图鉴升阶
    
    common_login_index = "/api?method=active.common_login_index", --通用签到-清明节活动--签到首页--
    common_login = "/api?method=active.common_login", --通用签到-清明节活动--签到 

    enjoy_spring_index = "/api?method=enjoy_spring.index", -- 游园赏春-首页
    enjoy_spring_answer = "/api?method=enjoy_spring.answer", -- 游园赏春-答题
    enjoy_spring_add_wenqu = "/api?method=enjoy_spring.add_wenqu", -- 游园赏春-加入文曲榜
    enjoy_spring_exit_wenqu = "/api?method=enjoy_spring.exit_wenqu", -- 游园赏春-退出文曲榜
    enjoy_spring_rank_info = "/api?method=enjoy_spring.rank_info", -- 游园赏春-排行榜(分页)
    enjoy_spring_wenqu_index = "/api?method=enjoy_spring.wenqu_index", -- 游园赏春-文曲榜-首页
    enjoy_spring_refresh_task = "/api?method=enjoy_spring.refresh_task", -- 游园赏春-刷新任务
    enjoy_spring_abandon_task = "/api?method=enjoy_spring.abandon_task", -- 游园赏春-放弃任务
    enjoy_spring_cull_friend = "/api?method=enjoy_spring.cull_friend", -- 游园赏春-踢人
    enjoy_spring_my_task_reward = "/api?method=enjoy_spring.my_task_reward", -- 游园赏春-我的任务领奖
    enjoy_spring_friend_task_reward = "/api?method=enjoy_spring.friend_task_reward", -- 游园赏春-好友任务领奖
    enjoy_spring_receive_invite = "/api?method=enjoy_spring.receive_invite", -- 游园赏春-接受邀请
    
    --新年活动
    --春节活动-首页
    spring_festival_index = "/api?method=spring_festival.index",
    --春节活动-领取登录(签到)奖励
    -- version: 1  # version
    -- day: 1  第几天
    spring_festival_receive_sign = "/api?method=spring_festival.receive_sign",
    --春节活动-抽奖(砸罐子)
    -- version: 1  # version
    -- times: 1  # 抽奖次数  取值(1, 10)
    spring_festival_draw = "/api?method=spring_festival.draw",
    --春节活动-购买碎碎平安元宝礼包
    -- version: 1  # version
    -- gift_id: 1  礼包id
    spring_festival_buy_draw_gift = "/api?method=spring_festival.buy_draw_gift",
    --春节活动-领取春节礼包免费礼包
    -- version: 1  # version
    -- place_id: 1  位置id
    -- gift_id: 1  礼包id
    spring_festival_receive_spring_gift = "/api?method=spring_festival.receive_spring_gift",
    -- 春节活动-领取/购买 年夜饭礼包
    -- version: 1  # version
    -- place_id: 1  位置id
    -- gift_id: 1  礼包id
    spring_festival_buy_dinner_gift = "/api?method=spring_festival.buy_dinner_gift",
    -- 春节活动-帮会积分排行榜信息
    -- start: 开始的排名
    -- stop: 结束的排名
    -- version: 版本
    spring_festival_guild_rank_info = "/api?method=spring_festival.guild_rank_info",
    -- 春节活动-个人贡献排行榜信息
    -- start: 开始的排名
    -- stop: 结束的排名
    -- version: 版本
    -- rank_type: 0或不传:个人排行  1:个人每日排行
    spring_festival_member_rank_info = "/api?method=spring_festival.member_rank_info",
    receive_dinner_score = "/api?method=spring_festival.receive_dinner_score",--春节活动-领取团圆饭进度奖励
    mult_index = "/api?method=game_street.mult_index", --市街合集 首页
    mult_receive = "/api?method=game_street.mult_receive", --市街合集 领奖
    mult_settlement = "/api?method=game_street.mult_settlement", --市街合集 结算积分
    mult_rank_info = "/api?method=game_street.mult_rank_info", --市街合集 排行榜
    spring_festival_enter_check = "/api?method=spring_festival.enter_check", -- 阖家团圆

    --上元灯会
    active_lantern_index = "/api?method=active.lantern_index", -- 首页
    active_lantern_riddle = "/api?method=active.lantern_riddle", --猜灯谜
    active_lantern_recv_quest = "/api?method=active.lantern_recv_quest", --领取任务
    active_lantern_draw = "/api?method=active.lantern_draw", --抽奖
    active_lantern_exchange = "/api?method=active.lantern_exchange", --兑换

    arena_mountain_hua_arena_index = "/api?method=arena_mountain_hua.arena_index", --华山论剑入口
    arena_mountain_hua_select_arena_rank = "/api?method=arena_mountain_hua.select_arena_rank", --华山论剑排行榜 start: 开始的排名 stop: 结束的排名
    arena_mountain_hua_refresh_challenges = "/api?method=arena_mountain_hua.refresh_challenges", --华山论剑刷新敌人
    arena_mountain_hua_set_defend_teams = "/api?method=arena_mountain_hua.set_defend_teams", --华山论剑设置防守阵容
    arena_mountain_hua_select_defend_teams = "/api?method=arena_mountain_hua.select_defend_teams", --获取防守方阵容  defend_uid: 玩家uid
    arena_mountain_hua_battle_start = "/api?method=arena_mountain_hua.battle_start", --战斗前获取数据
    arena_mountain_hua_arena_logs = "/api?method=arena_mountain_hua.arena_logs", --获取战斗日志
    arena_mountain_hua_like = "/api?method=arena_mountain_hua.like", --点赞  target_uid: 玩家uid
    arena_mountain_hua_quick_pass_arena = "/api?method=arena_mountain_hua.quick_pass_arena", --战斗快速通过: 敌人
    arena_mountain_hua_receive_arena_coin = "/api?method=arena_mountain_hua.receive_arena_coin", --领取剑气碎片

    --夺宝奇兵（苗疆觅宝活动）
    active_mining_index = "/api?method=active_mining.index", --苗疆觅宝首页
    active_mining_region_index = "/api?method=active_mining.region_index", --苗疆觅宝区域首页 region_id: 1  # 区域id
    active_mining_location_index = "/api?method=active_mining.location_index", --苗疆觅宝地区index region_id: 1   # 区域id location_id: 1  # 地区id
    active_mining_set_defend_team = "/api?method=active_mining.set_defend_team", --苗疆觅宝设置防守阵容 teams: [[hero_oid],[hero_oid],[hero_oid]] deployments: [1, 1, 1]
    active_mining_mine_detail = "/api?method=active_mining.mine_detail", --苗疆觅宝矿坑详情 mine_oid: 1   # 矿坑唯一idmine_oid: 1 
    active_mining_battle_start = "/api?method=active_mining.battle_start", --苗疆觅宝战斗 mine_oid: 1   # 矿坑唯一id team: [hero_oid, hero_oid, ''] 英雄队伍 deployment: 阵法id
    active_mining_recall_team = "/api?method=active_mining.recall_team", --苗疆撤离 team_id: 1    # 队伍id，1，2，3
    active_mining_receive_income = "/api?method=active_mining.receive_income", --苗疆领奖 mine_oid: 1   # 矿坑唯一id
    active_mining_my_mine = "/api?method=active_mining.my_mine", --苗疆我的矿洞
    active_mining_battle_info = "/api?method=active_mining.battle_info", --苗疆我的战报
    active_mining_set_desc = "/api?method=active_mining.set_desc", --苗疆设置发言 desc: ''  # 发言内容
    active_mining_buy_plunder_times = "/api?method=active_mining.buy_plunder_times", --购买掠夺次数 times
    active_mining_group_index = "/api?method=active_mining.group_index", --万国组
    active_mining_rank = "/api?method=active_mining.rank", -- 奇门遁甲-帮会排行

    game_index = "/api?method=game_box.game_index", -- 小游戏合集 (人生模拟器/)
    game_start = "/api?method=game_box.game_start", -- 游戏开始
    select_role = "/api?method=game_box.select_role", -- 选择角色(重启人生)
    select_talents = "/api?method=game_box.select_talents", -- 选择天赋(重启人生)
    update_front_index = "/api?method=game_box.update_front_index", -- 更新播放进度(重启人生)
    select_choice = "/api?method=game_box.select_choice", -- 选择选项(重启人生)
    select_inherit = "/api?method=game_box.select_inherit", -- 继承天赋(重启人生)
    book_index = "/api?method=game_box.book_index", -- 图鉴首页(重启人生)
    reset_role_data = "/api?method=game_box.reset_role_data",   -- 重置角色数据(重启人生)
    
    mini_game_index = "/api?method=war_order.mini_game_index",   -- 小游戏战令 首页
    receive_mini_game = "/api?method=war_order.receive_mini_game",     -- 小游戏战令-领取奖励
    auto_receive_mini_game = "/api?method=war_order.auto_receive_mini_game",    -- 小游戏战令-一键领取奖励
    buy_mini_game_unreached_reward = "/api?method=war_order.buy_mini_game_unreached_reward", -- 购买皇家犒赏令未达成奖励
    war_order_receive_common_reward = "/api?method=war_order.receive_common_reward", -- 通用战令 - 领取通用奖励
    war_order_common_war_order_index = "/api?method=war_order.common_war_order_index", --通用战令 首页
    war_order_buy_common_unreach_reward= "/api?method=war_order.buy_common_unreached_reward", --购买通用战令
    -- 秘境探宝
    secret_index = "/api?method=secret.index",  --秘境探宝入口
    secret_go_forward = "/api?method=secret.go_forward", -- 秘境探宝前进
    secret_get_milepost_reward = "/api?method=secret.get_milepost_reward", -- 秘境探宝领取里程碑奖励
    secret_gift_index = "/api?method=user_payment.secret_gift_index", --秘境探宝礼包首页
    secret_receive_quest = "/api?method=secret.receive_quest", --秘境探宝领取任务奖励
    secret_receive_all_quest = "/api?method=secret.receive_all_quest", --秘境探宝领取所有任务奖励
    secret_buy_gift = "/api?method=secret.buy_gift", --秘境探宝使用元宝购买礼包

    -- 花朝佳节
    common_quest_index = "/api?method=active.common_quest_index",    -- 连连看首页index
    common_quest_unlock = "/api?method=active.common_quest_unlock",  -- 连连看解锁格子
    common_quest_recv = "/api?method=active.common_quest_recv", -- 连连看领取奖励
    common_quest_recv_task = "/api?method=active.common_quest_recv_task",  -- 领取任务奖励
    common_quest_recv_score = "/api?method=active.common_quest_recv_score",  -- 领取任务积分奖励
    common_quest_buy = "/api?method=active.common_quest_buy",  -- 购买
    common_quest_recv_login = "/api?method=active.common_quest_recv_login",  -- 领取登陆奖励
    active_common_quest_card = "/api?method=active.common_quest_card",  -- 集卡册合成礼包
    flower_festival = "/api?method=flower_festival.index",  -- 花朝佳节 总入口
    active_common_exchange = "/api?method=active.common_exchange", -- 兑换
    active_common_exchange_index = "/api?method=active.common_exchange_index", -- 兑换index
    active_common_gift_index = "/api?method=active.common_gift_index", --通用阶梯礼包-礼包首页
    active_common_gift_buy = "/api?method=active.common_gift_buy", --通用阶梯礼包-购买
    flower_index = "/api?method=flower_festival.flower_index", -- 花团锦簇-首页 排行
    send_flower = "/api?method=flower_festival.send_flower", -- 送花
    self_flower_rank = "/api?method=flower_festival.self_flower_rank" ,  -- 花团锦簇-赠礼排名-赠礼日志
    common_quest_recv_union = "/api?method=active.common_quest_recv_union" ,  -- 赵云壮胆 领取侠客
     

    wdtower_index = "/api?method=wdtower.index", -- 罗天摘星首页
    wdtower_battle_start = "/api?method=wdtower.battle_start", -- 罗天摘星战前数据
    wdtower_battle_end = "/api?method=wdtower.battle_end", -- 罗天摘星战后数据
    wdtower_receive_free_gifts = "/api?method=wdtower.receive_free_gifts", -- 罗天摘星领取免费奖励   "vsn": 1,  // 版本 "gift_id": 1  // yinyang_tower_gift表的礼包id
    wdtower_rank_info = "/api?method=wdtower.rank_info", -- 罗天摘星积分排行榜 start: 开始的排名 stop: 结束的排名vsn: 版本
    wdtower_reset_floor = "/api?method=wdtower.reset_floor", -- 罗天摘星重置层数 version 版本号

    new_big_map_home = "/api?method=new_big_map.home", -- 江湖选择接口
    new_big_map_index = "/api?method=new_big_map.index", -- 随机江湖主页
    new_big_map_start_task = "/api?method=new_big_map.start_task", -- 接取一个任务
    new_big_map_finish_task = "/api?method=new_big_map.finish_task", --完成一个任务
    new_big_map_select_task = "/api?method=new_big_map.select_task", -- 选择一个任务
    new_big_map_interact = "/api?method=new_big_map.interact",   -- 和物件互动
    new_big_map_regional_battle_start = "/api?method=new_big_map.regional_battle_start", -- 支线任务 战斗前数据
    new_big_map_regional_battle_end = "/api?method=new_big_map.regional_battle_end", -- 支线任务 战斗后接口
    new_big_map_receice_area_cpd = "/api?method=new_big_map.receice_area_cpd", -- 领取区域完成度奖励  area_id: 1    # 区域id
    new_big_map_receice_scene_cpd = "/api?method=new_big_map.receice_scene_cpd", -- 领取场景完成度奖励  area_id: 1    # 区域id   scene_id: 1   # 场景id
    new_big_map_enter_scene = "/api?method=new_big_map.enter_scene", --进入母场景
    new_big_map_enter_child_scene = "/api?method=new_big_map.enter_child_scene", -- 进入子场景

    friend_arena_index = "/api?method=friend_arena.index", --风云擂台入口
    friend_arena_get_friends = "/api?method=friend_arena.get_friends", -- 获取好友数据列表
    friend_arena_set_defend_teams = "/api?method=friend_arena.set_defend_teams", -- 风云擂台设置防守阵容
    friend_arena_select_defend_teams = "/api?method=friend_arena.select_defend_teams",    -- 获取防守方阵容
    friend_arena_select_battle_start_team = "/api?method=friend_arena.battle_start_team",   -- 单队伍战斗前获取数据
    friend_arena_select_battle_start_teams = "/api?method=friend_arena.battle_start_teams",   -- 多队伍战斗前获取数据
    friend_arena_logs = "/api?method=friend_arena.arena_logs",  -- 获取战斗日志
    
    hero_fate_upgrade_building_lv = "/api?method=hero.fate_upgrade_building_lv",  -- 天命化星升级建造等级   "add_lv": 1,  // 增加建筑等级
    hero_fate_enable_master = "/api?method=hero.fate_enable_master",  -- 天命化星激活宗师槽位    "master_id": 1,  // 宗师id
    hero_fate_master_add_major_hero = "/api?method=hero.fate_master_add_major_hero",  -- 天命化星宗师设置主英雄 "master_id": 1,// 宗师id  "hero_oid": "",     // 英雄唯一id
    hero_fate_master_add_slaves_hero = "/api?method=hero.fate_master_add_slaves_hero",  -- 天命化星宗师设置辅助英雄 "master_id": 1,// 宗师id  "hero_oid": "", // 英雄唯一id  "pos": 0,// 辅助英雄位置 从0开始

    friend_arena_create_ring = "/api?method=friend_arena.create_ring", --创建擂台
    friend_arena_edit_ring = "/api?method=friend_arena.edit_ring", --修改擂台
    friend_arena_join_ring = "/api?method=friend_arena.join_ring", --加入擂台
    friend_arena_exit_ring = "/api?method=friend_arena.exit_ring", --退出擂台
    friend_arena_random_ring_list = "/api?method=friend_arena.random_ring_list", --随机获取擂台列表
    friend_arena_ring_list = "/api?method=friend_arena.ring_list", --通过擂台id获取擂台详情（轮询）
    friend_arena_ring_info = "/api?method=friend_arena.ring_info", --获取房间内的状态（轮询）
    friend_arena_ready = "/api?method=friend_arena.ready", --准备/取消准备
    friend_arena_remove_player = "/api?method=friend_arena.remove_player", --踢人
    friend_arena_battle_pvp = "/api?method=friend_arena.battle_pvp", --开战

    myth_arena_index = "/api?method=myth_arena.index",  -- 武林神话大赛 入口
    myth_arena_enter = "/api?method=myth_arena.enter",  -- 武林神话大赛 前往参赛
    myth_arena_select_arena_rank = "/api?method=myth_arena.select_arena_rank",  -- 竞技场排名
    myth_arena_refresh_challenges = "/api?method=myth_arena.refresh_challenges",  -- 竞技场刷新敌人
    myth_arena_set_defend_teams = "/api?method=myth_arena.set_defend_teams",  -- 武林神话大赛 设置防守阵容
    myth_arena_arena_logs = "/api?method=myth_arena.arena_logs",  -- 武林神话大赛 获取战斗日志
    myth_arena_select_defend_teams = "/api?method=myth_arena.select_defend_teams",  -- 武林神话大赛 获取防守方阵容
    myth_arena_battle_start = "/api?method=myth_arena.battle_start",  -- 武林神话大赛 战斗前获取数据
    myth_arena_quick_pass_arena = "/api?method=myth_arena.quick_pass_arena",  -- 战斗快速通过
    myth_arena_guess = "/api?method=myth_arena.guess", --竞猜
    myth_arena_stage_logs = "/api?method=myth_arena.stage_logs", --晋级赛阶段战报
    myth_arena_group_logs = "/api?method=myth_arena.group_logs", --晋级赛单组战报
    
    feast_main_index = "/api?method=meituan.index", --主界面  实际上是任务
    feast_rank = "/api?method=meituan.rank_info", --排行
    feast_recv_quest_reward = "/api?method=meituan.recv_quest_reward", --领奖
    feast_pray = "/api?method=meituan.doing_pray", --祈愿
    feast_taste = "/api?method=meituan.doing_synthesis", --美味尝鲜
    meituan_get_milepost_reward = "/api?method=meituan.get_milepost_reward", --领取里程碑奖励
    
    half_year_quest_index = "/api?method=half_year.quest_index", --庆典装扮首页
    half_year_quest_reward = "/api?method=half_year.recv_quest_reward", --庆典装扮任务领奖
    half_year_score_reward = "/api?method=half_year.recv_score_reward", --庆典装扮里程碑领奖
    
    gift_grouping_index = "/api?method=public_gift.index", --蓬莱集市入口
    gift_create_group = "/api?method=public_gift.create_group", --发起拼团
    gift_join_group = "/api?method=public_gift.join_group", --加入拼团
    gift_exit_group = "/api?method=public_gift.exit_group", --退出拼团
    gift_random_group_list = "/api?method=public_gift.random_group_list", --随机拼团列表（初始化、刷新）
    gift_group_list = "/api?method=public_gift.group_list", --拼团列表（查找、轮询）
    gift_my_group_list = "/api?method=public_gift.my_groups", --我的拼团列表
    gift_check_can_buy = "/api?method=public_gift.can_pay", --检查是否可买

    common_world_boss_index = "/api?method=common_world_boss.index", --通用世界boss入口
    common_world_boss_battle_start = "/api?method=common_world_boss.battle_start", -- 通用世界boss战斗前
    common_world_boss_battle_end = "/api?method=common_world_boss.battle_end", -- 通用世界boss战斗后
    common_world_boss_sweep = "/api?method=common_world_boss.sweep", -- 通用世界boss扫荡
    common_world_boss_like = "/api?method=common_world_boss.like", -- 通用世界boss点赞
    common_world_boss_recv_reward = "/api?method=common_world_boss.recv_reward", -- 通用世界boss领取排行榜奖励
    common_world_boss_auto_recv_reward = "/api?method=common_world_boss.auto_recv_reward", -- 通用世界boss自动领取排行榜奖励
    common_world_boss_recv_kill_num_reward = "/api?method=common_world_boss.recv_kill_num_reward", -- 通用世界boss领取击杀里程碑奖励
    common_world_boss_select_combat_rank = "/api?method=common_world_boss.select_damage_rank", -- 通用世界boss查询伤害排名(夏日清凉)
    common_world_boss_recv_quest_reward = "/api?method=common_world_boss.recv_quest_reward", -- 通用世界boss领取任务奖励(夏日清凉)

    active_monster_index = "/api?method=active.monster_index", -- 神兽秘境-首页
    active_monster_set_big_prize = "/api?method=active.monster_set_big_prize", -- 神兽秘境-设置大奖
    active_open_monster = "/api?method=active.open_monster", -- 神兽秘境-打开锦囊
    active_monster_enter_next = "/api?method=active.monster_enter_next", -- 神兽秘境-进入下一层

    lottery_tiket_lottery_tiket_index = "/api?method=lottery_tiket.lottery_tiket_index", --彩票首页
    lottery_tiket_lottery_tiket_get_number = "/api?method=lottery_tiket.lottery_tiket_get_number", --获取彩票号码
    lottery_tiket_lottery_tiket_history = "/api?method=lottery_tiket.lottery_tiket_history", --查看某期数据
    lottery_tiket_lottery_tiket_recv = "/api?method=lottery_tiket.lottery_tiket_recv", --领奖


    user_payment_common_lottery_index = "/api?method=user_payment.common_lottery_index", --通用18元抽奖-index
    user_payment_common_lottery = "/api?method=user_payment.common_lottery", --通用18元抽奖-index

    raccon_index = "/api?method=raccon.index", --小浣熊-首页
    raccon_chapter_recv = "/api?method=raccon.chapter_recv", --领取章节宝箱 "chapter_id": 1,  // 章节id "score_id": 1,  // 宝箱id
    raccon_stage_recv = "/api?method=raccon.stage_recv", --领取关卡宝箱 "hero_id": 1,  // 英雄id "score_id": 1,  // 宝箱id
    raccon_stage_index = "/api?method=raccon.stage_index", --小浣熊-关卡首页 "hero_id": 1,  // 英雄id  "stage_id": 1,  // 关卡id
    raccon_event_end = "/api?method=raccon.event_end", --小浣熊-剧情结束   "hero_id": 1,  // 英雄id  "stage_id": 1,  // 关卡id "option_id": 1,  // 选项id
    raccon_battle_start = "/api?method=raccon.battle_start", --小浣熊-战前数据 
    raccon_battle_end = "/api?method=raccon.battle_end", --小浣熊-战后数据 
    raccon_chapter_recv = "/api?method=raccon.chapter_recv", --小浣熊-领取章节宝箱 "chapter_id": 1,  // 章节id "score_id": 1,  // 宝箱id
    raccon_stage_recv = "/api?method=raccon.stage_recv", --小浣熊-领取关卡宝箱 "hero_id": 1,  // 英雄id "score_id": 1,  // 宝箱id
    
    
    pet_index = "/api?method=pet.index", --宠物-首页
    pet_set_show = "/api?method=pet.set_show", --宠物-设置展示
    pet_evolution = "/api?method=pet.evolution", --宠物进化
    pet_disband = "/api?method=pet.disband", --宠物归林 
    pet_level_up = "/api?method=pet.level_up", --宠物升级
    pet_interact = "/api?method=pet.interact", --宠物-互动
    pet_check_egg = "/api?method=pet.check_egg", --宠物背包-检查宠物蛋孵化

    pet_factory_index = "/api?method=pet_factory.index", -- 宠物工坊-首页
    pet_factory_dispatch = "/api?method=pet_factory.dispatch", -- 宠物工坊-派遣 // "pet_oid" = 宠物唯一ID，"pos" = 位置，从 0 开始
    pet_factory_quick_dispatch = "/api?method=pet_factory.quick_dispatch", -- 宠物工坊-一键派遣
    pet_factory_add_food = "/api?method=pet_factory.add_food", -- 宠物工坊-添加食物 // "num" = 数量
    pet_factory_collect = "/api?method=pet_factory.collect", -- 宠物工坊-领取奖励
    pet_factory_recall = "/api?method=pet_factory.recall", -- 宠物工坊-召回 // "pos" = 位置索引，从 0 开始
    pet_lock = "/api?method=pet.lock", --宠物-锁定
    pet_unlock = "/api?method=pet.unlock", --宠物-解锁

    set_defend_team = "/api?method=pet.set_defend_team", --宠物斗技-设置防守队伍
    pet_battle_start = "/api?method=pet.battle_start", --宠物斗技-战斗
    pet_arena_index = "/api?method=pet.pvp_index", --宠物斗技-首页
    pet_arena_week_recv = "/api?method=pet.pvp_week_recv", --宠物斗技-领取奖励
    pet_arena_feed = "/api?method=pet.pvp_feed", --宠物斗技-喂养

    bazaar_index = "/api?method=bazaar.index", -- 蓬莱集市(种菜) -- 入口
    bazaar_build = "/api?method=bazaar.build", -- 蓬莱集市(种菜) -- 摊位建造 // "build_id" = 建筑配置ID, "pos" = 位置索引，从 0 开始
    bazaar_build_quick = "/api?method=bazaar.quick_build", -- 蓬莱集市(种菜) -- 摊位一键建造 // "build_id" = 建筑配置ID
    bazaar_collect = "/api?method=bazaar.collect", -- 蓬莱集市(种菜) -- 收集 // "pos" = 位置索引，从 0 开始
    bazaar_collect_quick = "/api?method=bazaar.quick_collect", -- 蓬莱集市(种菜) -- 一键收集
    bazaar_finish_quick = "/api?method=bazaar.quick_finish", -- 蓬莱集市(种菜) -- 快速完成 // "pos" = 位置索引，从 0 开始
    
    fenghua_record_index = "/api?method=fenghua_record.index", -- 风华录  index
    fenghua_record_buy_record = "/api?method=fenghua_record.buy_record", -- 风华录  购买
    fenghua_record_change_skin = "/api?method=fenghua_record.change_skin", -- 风华录  切换角色
    guild_high_war_formation_index = "/api?method=guild_high_war.formation_index", -- 巅峰公会战-编队首页
    guild_high_war_set_formation = "/api?method=guild_high_war.set_formation", -- 巅峰公会战-设置编队
    guild_high_war_rank_info = "/api?method=guild_high_war.rank_info", -- 巅峰公会战-榜单"sort": 1,"start": 1,// 开始的排名 "stop": 10,     // 结束的排名
    guild_high_war_battlefield = "/api?method=guild_high_war.battlefield", -- 战场数据
    guild_high_war_declare_war = "/api?method=guild_high_war.declare_war", -- 宣战 "city_id"：1,  // 城市id
    guild_high_war_dispatch = "/api?method=guild_high_war.dispatch", -- 驻扎队伍 "city_id"：1,  // 城市id "team_id"：1,  // 队伍id
    guild_high_war_recall = "/api?method=guild_high_war.recall", -- 解除驻扎 "team_id"：1,  // 队伍id
    guild_high_war_dispatch_teams = "/api?method=guild_high_war.dispatch_teams", -- 参战队伍 "city_id"：1,
    guild_high_war_battle_teams = "/api?method=guild_high_war.battle_teams", -- 交战队伍 "city_id"：1,
    guild_high_war_battle_logs = "/api?method=guild_high_war.battle_logs", -- 所有战报 "city_id"：1,
    guild_high_war_city_logs = "/api?method=guild_high_war.city_logs", -- 城市战报 "city_id"：  "start": 1,  "stop": 10,
    guild_high_war_daily_gift_index = "/api?method=guild_high_war.daily_gift_index", -- 每日奖励首页 "city_id"：  "start": 1,  "stop": 10,
    guild_high_war_daily_gift_recv = "/api?method=guild_high_war.daily_gift_recv", -- 领取每日奖励 "gift_id": 1  // 第几个宝箱
    guild_high_war_daily_report_like = "/api?method=guild_high_war.report_like", -- 点赞
    guild_high_war_index = "/api?method=guild_high_war.index", -- 巅峰帮会战主页
    guild_high_war_talent_index = "/api?method=guild_talent.index", -- 巅峰帮会战主页  科技般
    guild_high_war_update_user_talent = "/api?method=guild_talent.update_user_talent", -- 巅峰帮会战主页  升级天赋 个人
    guild_high_war_update_guild_level = "/api?method=guild_talent.update_guild_level", -- 巅峰帮会战主页  升级天赋 帮会
    guild_high_war_reset_one_point = "/api?method=guild_talent.reset_one_point", -- 巅峰帮会战科技  重置天赋 个人
    guild_high_war_reset_all_point = "/api?method=guild_talent.reset_all_point", -- 巅峰帮会战主页  重置天赋 帮会
    guild_high_war_change_team_sort = "/api?method=guild_high_war.change_team_sort", -- 参与队伍 交换位置
    guild_high_war_dispatch_teams_page = "/api?method=guild_high_war.dispatch_teams_page", -- 参与队伍 分页请求
    guild_high_war_learn_point_num = "/api?method=guild_talent.learn_point_num", -- 科技  获取天赋学习人数
    guild_high_war_dispatch_boss = "/api?method=guild_high_war.dispatch_boss", -- 科技  驻扎boss
    guild_high_war_recall_boss = "/api?method=guild_high_war.recall_boss", -- 科技  解除boss
 
    prestige_index = "/api?method=prestige.index",  -- 棋盘、棋子数据
    prestige_fetter = "/api?method=prestige.fetter",  -- 镶嵌棋子
    prestige_upgrade = "/api?method=prestige.upgrade",  -- 棋盘升级
    prestige_recv_piece = "/api?method=prestige.recv_piece",  --领取棋子
    prestige_resolve = "/api?method=prestige.resolve",  -- 棋子分解
    prestige_cancel_new = "/api?method=prestige.cancel_new",  -- 棋子新棋子展示已经通知

    limit_hero_index = "/api?method=user_payment.limit_hero_index",  -- 限时侠客
    limit_hero_receive = "/api?method=user_payment.limit_hero_receive",  -- 领奖

    --天赐祈福
    weekend_sevent_index =  "/api?method=weekendsevent.index",      --天赐祈福首页
    weekend_sevent_save_ids = "/api?method=weekendsevent.save_ids",      --保存选择的奖励
    weekend_sevent_receive = "/api?method=weekendsevent.draw_gift",        --抽奖
    weekend_sevent_receive_stage = "/api?method=weekendsevent.receive_stage",        --阶段奖励
    
    --三侠五义
    chivalrous_index = "/api?method=chivalrous.index", -- 首页
    chivalrous_choose = "/api?method=chivalrous.choose", -- 选择阵营
    chivalrous_ranks = "/api?method=chivalrous.ranks", -- 查看排行榜  侠义排行榜
    chivalrous_recv_dust_of_dreams = "/api?method=chivalrous.recv_dust_of_dreams", -- 前尘往事 领取侠义值奖励
    chivalrous_enter_scene = "/api?method=chivalrous.enter_scene", -- 前尘往事 进入母场景
    chivalrous_enter_child_scene = "/api?method=chivalrous.enter_child_scene", -- 前尘往事 进入子场景
    chivalrous_start_task = "/api?method=chivalrous.start_task", -- 前尘往事 接取一个任务
    chivalrous_finish_task = "/api?method=chivalrous.finish_task", -- 前尘往事 完成一个任务
    chivalrous_select_task = "/api?method=chivalrous.select_task", -- 前尘往事 选择一个任务
    chivalrous_interact = "/api?method=chivalrous.interact", -- 前尘往事 物件交互
    chivalrous_rank_info = "/api?method=chivalrous.rank_info", -- 查看排行榜  伤害排行榜
    chivalrous_train_index = "/api?method=chivalrous.train_index", -- 试炼首页
    chivalrous_battle_start = "/api?method=chivalrous.battle_start", -- 战前
    chivalrous_battle_end = "/api?method=chivalrous.battle_end", -- 战后
    chivalrous_recv_reward = "/api?method=chivalrous.recv_reward", -- 江湖侠行-领取任务奖励
    chivalrous_recv_reward_all = "/api?method=chivalrous.recv_reward_all", -- 江湖侠行-一键领取任务奖励
    

    seal_character_use = "/api?method=item.seal_character_use",  -- 使用符篆
    seal_character_save = "/api?method=item.seal_character_save",  -- 保存属性
    seal_character_lock_attr = "/api?method=item.seal_character_lock_attr", --锁定属性
    
    --通用试炼
    common_train_challenge_index = "/api?method=common_train_challenge.index", -- 通用试炼  首页
    common_train_challenge_battle_start = "/api?method=common_train_challenge.battle_start", -- 通用试炼  战前数据
    common_train_challenge_battle_end = "/api?method=common_train_challenge.battle_end", -- 通用试炼  战后数据
    common_train_challenge_recv_reward = "/api?method=common_train_challenge.recv_reward", -- 通用试炼  (一键)领取任务奖励
    common_train_challenge_ranks = "/api?method=common_train_challenge.ranks", -- 通用试炼  排行榜
    common_train_challenge_recv_attack_reward = "/api?method=common_train_challenge.recv_attack_reward", -- 通用试炼  领取击破奖励
    
    --侠客行  翰林书院
    fillword_index = "/api?method=fillword.index", -- 首页
    fillword_save_word = "/api?method=fillword.save_word", -- 保存
    fillword_receive_stage = "/api?method=fillword.receive_stage", -- 领奖
    --风云际会
    --通用元宝返积分 
    active_diamond_rebate_index = "/api?method=active.diamond_rebate_index", -- 首页
    active_diamond_rebate_recv = "/api?method=active.diamond_rebate_recv", -- 领奖
    active_diamond_rebate_ranks = "/api?method=active.diamond_rebate_ranks", -- 排行榜
    redbag_receive_draw_gift = "/api?method=redbag.receive_draw_gift", --名扬四海 打开宝箱奖励
    redbag_index = "/api?method=redbag.index", --名扬四海 主界面
    red_packet_index = "/api?method=redbag.index_redbag", --红包界面初始化
    red_packet_send = "/api?method=redbag.send_redbag", --发送红包
    red_packet_receive = "/api?method=redbag.receive_redbag", --发送红包
    redbag_send_rank = "/api?method=redbag.sent_rank", --红包排行
    redbag_red_dot = "/api?method=redbag.red_dot", --红包红点

    --国色天香  天香群英榜
    active_common_favor_index = "/api?method=active.common_favor_index", --首页
    active_common_favor_ranks = "/api?method=active.common_favor_ranks", --排行榜
    active_common_favor_send = "/api?method=active.common_favor_send", --赠送
    active_common_favor_recv = "/api?method=active.common_favor_recv", --领取奖励
    raccon_common_index = "/api?method=common_raccon.index", --巾帼红颜 --通用侠客志
    raccon_common_chapter_recv = "/api?method=common_raccon.chapter_recv", --巾帼红颜 --领取章节宝箱 
    raccon_common_satge_recv = "/api?method=common_raccon.stage_recv",--巾帼红颜 --领取关卡宝箱 
    raccon_common_satge_index = "/api?method=common_raccon.stage_index",--巾帼红颜 --关卡首页 
    raccon_common_event_end = "/api?method=common_raccon.event_end",--巾帼红颜 --剧情结束 
    raccon_common_battle_start = "/api?method=common_raccon.battle_start",--巾帼红颜 --战斗前获取数据 
    raccon_common_battle_end = "/api?method=common_raccon.battle_end",--巾帼红颜 --战斗结束获取数据

    awaken_index = "/api?method=awaken.index", --登仙楼首页
    awaken_get_heros = "/api?method=awaken.get_heros", --所有可羽化登仙的英雄
    awaken_change_hero = "/api?method=awaken.change_hero", --更换英雄
    awaken_fly = "/api?method=awaken.fly", --开启羽化
    awaken_submit_quest = "/api?method=awaken.submit_quest", --羽化台提交任务
    awaken_cultivation = "/api?method=awaken.cultivation", --登仙楼修炼
    awaken_kill_self = "/api?method=awaken.kill_self", --登仙楼渡劫
    awaken_friend_help = "/api?method=awaken.friend_help", --好友助力
    awaken_replace_skill = "/api?method=awaken.replace_skill", --替换技能
    awaken_stage_unlock = "/api?method=awaken.stage_unlock", --入梦铃解锁关卡
    awaken_stage_recv = "/api?method=awaken.stage_recv", --入梦铃领取通关奖励
    awaken_stage_battle_start = "/api?method=awaken.stage_battle_start", --入梦铃战斗前数据
    awaken_stage_battle_end = "/api?method=awaken.stage_battle_end", --入梦铃战斗前数据
    awaken_recycle = "/api?method=awaken.recycle", --熔炼

    guild_high_war_new_sign_up = "/api?method=guild_high_war.sign_up", --新巅峰帮会战 报名
    guild_high_war_new_quest_index = "/api?method=guild_high_war.quest_index", --新巅峰帮会战 每日任务
    guild_high_war_new_quest_recy = "/api?method=guild_high_war.quest_recv", --新巅峰帮会战 领取每日任务
    
    fukubukuro_luckbag_index = "/api?method=luckybag.index",--终身福袋 首页 
    fukubukuro_luckbag_receive_daily = "/api?method=luckybag.receive_daily",--终身福袋 领日常奖励
    fukubukuro_luckbag_login_stage = "/api?method=luckybag.receive_login_stage",--终身福袋 领累计登陆奖励
    fukubukuro_luckbag_share = "/api?method=user.share",--终身福袋 分享
    

    --幸运夺宝
    lucky_treasure_index = "/api?method=lucky_treasure.index",  --首页
    lucky_treasure_loot = "/api?method=lucky_treasure.loot",  --夺宝
    lucky_treasure_draw_index = "/api?method=lucky_treasure.draw_index",  --积分商店-首页
    lucky_treasure_draw = "/api?method=lucky_treasure.draw",  --积分商店-抽奖
    lucky_treasure_refresh = "/api?method=lucky_treasure.refresh",  --积分商店-抽奖
    
    --拯救狗头
    big_game_index = "/api?method=big_game.index",  --首页
    big_game_receive = "/api?method=big_game.receive",  --领关卡奖
    big_game_complete = "/api?method=big_game.complete",  --完成关卡
    
    --瑞兔小斋
    rabbit_index =  "/api?method=rabbit.index",
    rabbit_draw =  "/api?method=rabbit.draw",
    rabbit_rank_info =  "/api?method=rabbit.rank_info",
    

    --剑试天下
    full_service_index = "/api?method=full_service.index", --剑试天下首页
    full_service_battle_start = "/api?method=full_service.battle_start", --剑试天下boss战前
    full_service_battle_end = "/api?method=full_service.battle_end", --剑试天下boss战后数据
    full_service_get_boss_damage_rank = "/api?method=full_service.get_boss_damage_rank",--伤害排行榜
    full_service_set_defend_teams = "/api?method=full_service.set_defend_teams",--获取防守方阵容
    full_service_read_invitation = "/api?method=full_service.read_invitation",--已读邀请函
    full_service_point_race_guess = "/api?method=full_service.point_race_guess",--积分赛竞猜
    full_service_point_race_battle_group_info = "/api?method=full_service.point_race_battle_group_info",--积分赛对战信息
    full_service_point_race_battle_log = "/api?method=full_service.point_race_battle_log",--积分赛获取战报`
    full_service_point_race_ranks = "/api?method=full_service.get_point_race_ranks",--积分赛排名
    full_service_point_race_schedule = "/api?method=full_service.point_race_battle_schedule",--用户赛程
    full_service_my_guess = "/api?method=full_service.my_guess",--我的竞猜
    full_service_my_guess_v2 = "/api?method=full_service.my_guess_v2",--我的竞猜 接口2
    full_service_point_race_user_battle_log = "/api?method=full_service.point_race_user_battle_log",--我的战报 天数
    full_service_get_top_10_team = "/api?method=full_service.get_top_10_team",--我的战报 天数
    --晋级赛
    full_service_top_chart = "/api?method=full_service.top_chart",  --晋级赛晋级图
    full_service_top_enter = "/api?method=full_service.top_enter",  --晋级赛比赛界面
    full_service_top_my_battle = "/api?method=full_service.top_my_battle",  --晋级赛我的战况
    full_service_top_guess_index = "/api?method=full_service.top_guess_index",  --晋级赛竞猜首页
    full_service_top_guess = "/api?method=full_service.top_guess",     --晋级赛竞猜
    full_service_top_battle_log = "/api?method=full_service.top_battle_log",     --晋级赛总战报
    full_service_top_personal_battle_log = "/api?method=full_service.top_personal_battle_log",     --晋级赛个人战报
    full_service_top_rank_info = "/api?method=full_service.top_rank_info",     --晋级赛榜单
    full_service_history_top3 = "/api?method=full_service.history_top3",     --获取往届前三甲
    
    --全民竞猜
    world_cup_index = "/api?method=world_cup.index",  --首页
    world_cup_bet = "/api?method=world_cup.bet",  --下注
    world_cup_ranks = "/api?method=world_cup.ranks",  --排行榜
    
    --大富翁
    user_payment_mult_step_rebate_index = "/api?method=user_payment.mult_step_rebate_index",  --首页
    --全民福利
    red_envelope_send_envelope = "/api?method=red_envelope.send_envelope",  --发送红包
    red_envelope_recv_envelope = "/api?method=red_envelope.recv_envelope",  --领取红包
    red_envelope_personal_rank = "/api?method=red_envelope.personal_rank",  --福星高照 - 个人榜
    red_envelope_guild_rank = "/api?method=red_envelope.guild_rank",  --福星高照 - 帮会榜
    red_envelope_recv_ids = "/api?method=red_envelope.recv_ids",  --已领取红包列表

    --侠客岛
    hero_isle_index="/api?method=hero_isle.index",--侠客岛主页
    hero_isle_battle_start="/api?method=hero_isle.battle_start",--单队伍战斗前获取数据
    hero_isle_battle_end="/api?method=hero_isle.battle_end",--单队伍战斗后获取数据
    hero_isle_mul_team_battle_start="/api?method=hero_isle.mul_team_battle_start",--多队伍战斗前获取数据
    hero_isle_mul_team_battle_end="/api?method=hero_isle.mul_team_battle_end",--多队伍战斗后获取数据
    hero_isle_heirloom_rev="/api?method=hero_isle.heirloom_rev",--选择遗物
    hero_isle_rank_info="/api?method=hero_isle.rank_info",--排行榜
    hero_isle_idle_show="/api?method=hero_isle.idle_show",--参悟
    hero_isle_idle_reward="/api?method=hero_isle.idle_reward",--参悟
    hero_isle_privilege_show="/api?method=hero_isle.privilege_show",--岛主特权

    --江湖情缘
    lakes_love_index = "/api?method=lakes_love.index",--首页
    lakes_love_decide_hero = "/api?method=lakes_love.decide_hero",--侠客选择
    lakes_love_unlock = "/api?method=lakes_love.unlock",--侠客解锁

    --充值返利
    sea_rebate_index = "/api?method=rebate.index", --首页
    sea_rebate_award = "/api?method=rebate.award", --领奖

    --酒楼
    hotel_index = "/api?method=hotel.index",
    hotel_main = "/api?method=hotel.main",
    hotel_run = "/api?method=hotel.run",
    hotel_room_level_up = "/api?method=hotel.room_level_up",
    hotel_room_dispatch = "/api?method=hotel.room_dispatch",
    hotel_daily_award = "/api?method=hotel.daily_award",
    hotel_submit_quest = "/api?method=hotel.submit_quest",

    hotel_love_info = "/api?method=hotel.love_info",
    hotel_love_listen = "/api?method=hotel.love_listen",
    hotel_love_battle_start = "/api?method=hotel.love_battle_start",
    hotel_love_battle_end = "/api?method=hotel.love_battle_end",
    hotel_love_clear_recv = "/api?method=hotel.love_clear_recv",

    hotel_gacha_index = "/api?method=hotel.gacha_index",
    hotel_gacha_hero = "/api?method=hotel.gacha_hero",
    hotel_gacha_done = "/api?method=hotel.gacha_done",

    --天府夺刀
    hero_boss_index = "/api?method=hero_boss.index",
    hero_boss_guild_rank = "/api?method=hero_boss.guild_rank",
    hero_boss_battle_start = "/api?method=hero_boss.battle_start",
    hero_boss_battle_end = "/api?method=hero_boss.battle_end",
    hero_boss_loot_rivals = "/api?method=hero_boss.loot_rivals",
    hero_boss_rival_defends = "/api?method=hero_boss.rival_defends",
    hero_boss_loot_battle = "/api?method=hero_boss.loot_battle",

    --助战
    hero_help_index= "/api?method=hero_help.index",
    hero_help_help= "/api?method=hero_help.help",

    --天地战阵升级
    hero_normal_array_levelup = "/api?method=hero.normal_array_levelup",

    --秘宝
    jewel_index = "/api?method=jewel.index",
    jewel_activate = "/api?method=jewel.activate",
    jewel_evo_up = "/api?method=jewel.evo_up",
    jewel_awake = "/api?method=jewel.awake",
    jewel_do_gacha = "/api?method=jewel.do_gacha",
    jewel_set_wish = "/api?method=jewel.set_wish",
    jewel_do_wish = "/api?method=jewel.do_wish",
}

--[[--
    用于登录的服务器，域名和ip基本不变（不保证
    sdk的登录和付费都放在login_url_config表中
]]
local login_url_config = {  -- 走master服务器的配置
    register = "/login/?method=register",--账号注册   &account=kongliang&passwd=123456
    login = "/login/?method=login",--账号登录  &account=kongliang&passwd=123456
    platform_access = "/login/?method=platform_access",--验证 &pre_pf=test&channel=test&openid=1234567
    new_account = "/login/?method=new_account", -- 如果用户没有账户，给他一个临时的
    server_list = "/login/?method=server_list",--前端通过保存的account，获得用户的server_list数据
    login_server = "/login/?method=login_server", -- 登录服
    new_user = "/login/?method=new_user",     --  增加name 和is_new
    notice = "/login/?method=notice", -- 公告
    device_action = "/login/?method=device_action", -- 统计接口,
    bitrack = "/login/?method=bitrack", --bitrack 统计接口
}
local M = {}

--[[--
    获得完整的url
]]
function M.getUrlForKey(key)
    local url = nil
    if game_url[key] then
        url = GameVersionConfig.SERVICE_URL .. game_url[key]
    elseif login_url_config[key] then
        url = GameVersionConfig.MASTER_URL .. login_url_config[key]
    end
    if url ~= nil then
        url = url .. "&" .. M.getExtUrlParam()
    end
    return url
end

function M.getExtUrlParam()
    local client_data = UserDataManager.client_data
    local params = {}
    table.insert(params, "uid=" .. UserDataManager.user_data:getUid())
    --table.insert(params, "uid=" .. 1048584)
    --table.insert(params, "frontwindow=" .. "5e3b4530b293b5c1f4eeca4638ab4dc1")
    --table.insert(params, "uid=" .. 1048584)
    if client_data.user_token then
        table.insert(params, "user_token=" .. client_data.user_token)
    end
    table.insert(params, "c_ver=" .. GameVersionConfig.CLIENT_VERSION)
    table.insert(params, "r_ver=" .. GameVersionConfig.GAME_RESOURCES_VERION)
    if SDKUtil.is_oneSDK then
        table.insert(params, "b_c_ver=" .. SDKUtil.sdkVersion)
    else
        table.insert(params, "b_c_ver=" .. tostring(GameVersionConfig.BYTE_DANCE_SERVER_VERSION))
    end
    
    table.insert(params, "device_mark=" .. UserDataManager.client_data:getDeviceMark())
    table.insert(params, "vcd=" .. (GameVersionConfig.vcd or ""))
    return table.concat(params, "&")
end

local __crypto_url_keys = {
    check_version = 1,
    register = 1,
    login = 1,
    bitrack = 1,
    platform_access = 1,
    new_account = 1,
    server_list = 1,
    login_server = 1,
    new_user = 1,
    notice = 1,
    device_action = 1,
    front_err = 2,
}

function M.getCryptoUrlValue(key)
    return __crypto_url_keys[tostring(key)]
end

return M
