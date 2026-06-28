------------ UserDataManager

local DataUpdateHandlers = require("DataCenter.DataUpdateHandlers")

local M = {}

function M:init()
	self.local_data = require("DataCenter.UserData.LocalData")
	self.local_data:init()
	self.client_data = require("DataCenter.UserData.ClientData")
	self.server_data = require("DataCenter.UserData.ServerData")
	self.hero_data = require("DataCenter.UserData.HeroData")
	self.item_data = require("DataCenter.UserData.ItemData")
	self.user_data = require("DataCenter.UserData.UserData")
	self.equip_data = require("DataCenter.UserData.EquipData")
	self.talis_data = require("DataCenter.UserData.TalisData")
	self.guide_data = require("DataCenter.UserData.GuideData")
	self.artifact_data = require("DataCenter.UserData.ArtifactData")
	self.mystic_data = require("DataCenter.UserData.MysticData")
	self.skillImprove_data = require("DataCenter.UserData.SkillImproveData")
	self.pet_data = require("DataCenter.UserData.PetData")
	self.title_data = require("DataCenter.UserData.TitleData") -- 称号数据中心
	self.jewel_data = require("DataCenter.UserData.JewelData") --宝物数据
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.netDataUpdateEvent})
	self.last_request_time = 0
	self.server_time = 0
	self.collect = {} -- 图鉴解锁数据，未解锁的不在数据中  key是hero配置: 0：解锁未领奖，1：解锁已领奖
	self.tower_floor = 0 -- 天机楼层数
	self.race_floor = {} -- 种族塔
	self.race_tower_status = {} -- 种族塔开启状态
	self.race_floor_times = {} --种族塔剩余次数
	self.guide = {} -- 新手引导数据
	self.quest = {} -- 任务 main_quests : 主线任务 daily_quests : 日常任务 weekly_quests : 周常任务
	self.is_first_name = 0 -- 是否第一次起名 0 未起名 1 起名
	self.temp_data = {}
	self.richman = {} --Cache 聚宝山数据
	self.troop_ids = {} --茶馆激活的羁绊
	self.guild_lv = 0 -- 公会等级
	self.tripods = {} --神炉
	self.hero_roles = {} --图鉴升级职业属性加成
	self.deployment_data = {} -- 阵法
	self.mystic_effect_data = {} -- 秘籍生效效果
	self.mystic_slots = {} -- 秘籍参悟
	self.red_dot = {} -- # 红点数据
	self.enable_ending = {} -- # rpg属性计算数据
	self.bounty_info = {} --悬赏数据
	self.cur_map_id = 0; --当前大地图id
	self.map_pos = {0,0};
	self.map_event = {} -- 江湖事件
	self.complete_teams = {} --  限时任务已完成group
	self.ongoing_teams = {} --限时任务正在进行的group
	self.e_ongoing_teams = {} -- 奇遇
	self.e_complete_teams = {} -- 奇遇已完成group
	self.e_next_trigger_ts = 0 -- 奇遇下一次可触发事件的时间戳
	self.e_today_event_count = 0 -- 奇遇每日已触发事件的次数
	self.ongoing_task = {} -- 大地图进行中的支线任务
	self.tasks = {} -- 大地图进行中的所有任务
	self.regional_task_done = {} --  # 已完成过的支线任务,完成度数据，缓存更新,对应缓存字段`map_regional.task_done`
	self.articles = {} -- 剧情场景数据
	self.close_option = {} -- 已消失的选项，不会再出来
	self.delegation_ids = {} -- 江湖委托委托
	self.scene_lines = {} -- 场景线路图
	self.tasks_activity = {} -- 三侠五义, 所有任务
	self.regional_task_done_activity = {} -- 三侠五义,  已完成过的支线任务,完成度数据，缓存更新,对应缓存字段`map_regional.task_done`
	self.articles_activity = {} -- 三侠五义, 剧情场景数据
	self.close_option_activity = {} -- 三侠五义, 已消失的选项，不会再出来
	self.delegation_ids_activity = {} -- 三侠五义, 江湖委托委托
	self.scene_lines_activity = {} -- 三侠五义, 场景线路图
	self.notice = {} -- sdk公告数据
	self.active_double_id = 0 --双倍活动信息
	self.cfg_heros_data = {} --英雄数据
	self.rollings = {} -- 跑马灯
	self.vip_received = {} --领取过的vip奖励
	self.active_links = {} --激活的羁绊数据 {id,lv}
	self.can_rcvd = {} --可领取的羁绊奖励 { id:{lv3,lv4}}
	self.sig = {} -- 英雄经脉
	self.welfare_npc_guide = {} -- 福利人设 引导领奖过的id
	self.m_recruit_shop = {} --大侠试炼折扣购买记录
	self.m_draw_shop = {} -- 卦签商品购买记录
	self.quest_special = {} --主线任务拆分的特殊任务
	self.end_ts = 0 -- 今天结束的时间
	self.m_actives = {} --开启的活动
	self.m_active_recharge = {} --开启的付费活动
	self.frames = {} -- 头像框
	self.avatars = {} -- 头像
	self.hero_skins = {} -- 英雄皮肤
	self.m_subscribe = {} -- 订阅
	self.m_sub_received = {} --已领奖励的特权配置id
	self.reset_times   = 0 -- 英雄回退品质次数，每个礼拜重置
	self.m_rollback_buy_times = 0 --英雄归隐次数
	self.m_exchange_vsn = 0 --限时兑换活动版本号
	self.m_limit_push = {} --推送礼包
	self.m_push_gifts_extra = {} --推送礼包
	self.m_top_arena = {} --巅峰赛数据
	self.top_arena_final = {} --巅峰赛决赛结果数据
	self.charge_sum = 0 --充值金额
	self.m_friendliness = {} --好感度数据
	self.m_invite_times = 0 --好感度温泉数据
	self.m_bless_look_times = 0 --是否查看了祝福侠客界面end
	self.m_gvg_teams = {} -- 帮会战队伍
	self.m_gvg_team_set_reward = {} -- 帮会战队伍设置奖励
	self.m_gvg_team_set_reward_flag = false --帮会战队伍设置奖励标识
	self.m_relics = {} -- 法宝数据
	self.m_slots = {} --法宝槽位数据
	self.m_thrones = {} -- 装备套装
	self.m_mult_relics = {} -- 多阵容法宝数据
	self.m_season_data = {} -- 赛季信息
	self.m_emoji = {} -- 动态表情包
	self.m_sig_reset_times = 0 --经脉重置次数
	self.m_black_list = {} --黑名单列表 数组格式
	self.m_black_map = {} --黑名单列表 key 是uid
	self.m_choice_gifts = {} --3he1推送礼包
	self.m_clv = 0 
	self.m_clv_limit = 0
	self.m_thrones_upgrade = {}--神兵升级
	self.m_thrones_phase = {}--神兵升阶
	self.m_fund_status = 0 -- 成长基金是否付费
	self.m_sign_fund = {} -- 签到基金数据
	self.m_war_order = {} --战令数据
	self.m_fund_quests = {} --成长基金数据
	self.m_cur_calendar_id = 0 --古剑日历id用来获取古剑双倍数据
	self.new_map_attrs = {} -- 随机江湖属性
	self.new_map_puzzle_groups = {} -- 完成的拼图组id
	self.new_map_puzzle_ids = {} -- 完成的拼图id
	self.new_map_hour = 0 -- 随机江湖时辰
	self.new_map_weather = 0 -- 随机江湖天气
	self.new_map_ongoing_task = {} -- 随机江湖进行中的支线任务
	self.new_map_tasks = {} -- 随机江湖进行中的所有任务
	self.new_map_regional_task_done = {} --  # 已完成过的支线任务,完成度数据，缓存更新,对应缓存字段`map_regional.task_done`
	self.new_map_articles = {} -- 剧情场景数据
	self.new_map_close_option = {} -- 已消失的选项，不会再出来
	self.new_map_delegation_ids = {} -- 江湖委托委托
	self.new_map_scene_lines = {} -- 场景线路图
	self.m_medals = {} --奇遇
	self.m_fate_building = {} --星楼
	self.m_fate_master = {} --天命化星宗师
	self.m_normal_array = {} --阵法
	self.m_mult_normal_array = {} -- 阵法多队
	self.m_common_quest = {} --小浣熊通关领奖
	self.m_battle_pet = 0 --单队宠物
	self.m_mult_battle_pet = {} --多队宠物
	self.m_pet_pvp_season_data = {} --宠物竞技场赛季
	self.m_fenghua_record_data = {} --风华录
	self.m_prestige_pieces = {} --威望系统棋子
	self.m_prestige_board = {} --威望系统棋盘
	self.m_hero_prestige_data = {} --侠客界面领取棋子
	self.m_global_repress_data = {} --全局的战力压制模块
	self.m_awaken_system_data = {} --登仙楼
	self.guild_talent_coin = 0  --巅峰科技版 帮会coin
	self.red_packet_data = {} --红包
	self.m_main_bgs = {} --主界面背景开启
	self.m_gacha_predestined_end = 0 --前缘招募结束时间
	self.gacha_open_race_pools = {} --种族招募每日开启种族列表
	self.m_activity_name = nil
	self.m_hero_isle_vsn = 0 --侠客岛当前开启的版本
end

function M:initOhterData()
	
end

--[[--
   缓存更新
]]
function M:clientCacheUpdate(jsonData)
    if jsonData == nil then return end
    for k,v in pairs(jsonData) do
        if DataUpdateHandlers[k] then
            DataUpdateHandlers[k](self, k, v)
        else
            Logger.log("update handler not found, key is : " .. tostring(k))
        end
    end
end

function M:netDataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "net_data_back" then
		Logger.log(data,"netDataUpdateEvent ==== ")
		self:responseGameData(data.data)
	elseif curEvent == "net_data_sync" then
		self:responseSyncData(data.data)
	end
end

function M:responseGameData(data)
	self:setLastRequestTime()
	self:setServerTime(data.server_time)
	self:clientCacheUpdate(data.client_cache_update)
	self:clientCacheUpdate(data.client_cache_update2)
	self.user_data:setUserData(data.user_status)
	if static_rootControl and static_rootControl.m_heart_cd then
		static_rootControl.m_heart_cd = 60
	end
end

--equips   items   heros  替换原来的数据
function M:responseSyncData(data)
	if data == nil then return end
	local equips = data.equips
	if equips and self.equip_data then
		self.equip_data:resetData()
		self.equip_data:updateMoreEquipData(equips)
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "equips_update", data = equips})
	end
	local items = data.items
	if items and self.item_data then
		self.item_data:resetData()
		self.item_data:updateMoreItemData(items)
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "items_update", data = items})
	end
	local heros = data.heros
	if heros and self.hero_data then
		self.hero_data:resetData()
		self.hero_data:updateMoreHeroData(heros)
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "heros_update", data = heros})
	end
	local need_sync = false
	local map_tasks = data.map_tasks
	if map_tasks then
		self:setTasksData(map_tasks)
		need_sync = true
	end
	local map_task_done = data.map_task_done
	if map_task_done then
		self:setRegionalTaskDoneData(map_task_done)
		need_sync = true
	end
	local map_articles = data.map_articles
	if map_articles then
		self:setArticlesData(map_articles)
		need_sync = true
	end
	local chivalrous_map_tasks = data.chivalrous_map_tasks
	if chivalrous_map_tasks then
		self:setTasksActivityData(chivalrous_map_tasks)
		need_sync = true
	end
	local chivalrous_map_task_done = data.chivalrous_map_task_done
	if chivalrous_map_task_done then
		self:setRegionalTaskDoneActivityData(chivalrous_map_task_done)
		need_sync = true
	end
	local chivalrous_map_articles = data.chivalrous_map_articles
	if chivalrous_map_articles then
		self:setArticlesActivityData(chivalrous_map_articles)
		need_sync = true
	end
	
	if need_sync then
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "sync_map_task"})
	end 
end

function M:setLastRequestTime()
    self.last_request_time = TimeUtil.getUTCTime()
end

function M:getLastRequestTime()
    return self.last_request_time
end

function M:setServerTime(server_time)
    self.server_time = server_time or self.server_time
end

function M:getServerTime()
    local server_time = self.server_time + self:getTimeDifference()
    return server_time
end

--[[--
   获得时间差
]]
function M:getTimeDifference(time)
    time = time or self:getLastRequestTime()
    return TimeUtil.getUTCTime() - time
end

function M:getTimeZone()
	return self.timezone or 0
end

function M:setTimeZone(timezone)
	self.timezone = timezone or 0
end

--[[--
   更新user.game_info接口数据
]]
function M:updateUserGameInfo(data)
	if data == nil then return end
	self.hero_data:updateMoreHeroData(data.heros)
	self.hero_data:resetSigRedPointData()
	-- self.hero_data:setMainTeam(data.main_team)
	self.hero_data:updateFormation(data.formation)
	-- self.hero_data:setCityTeam(data.city_team)
	self.hero_data:updateTeams(data.teams)
	self.hero_data:updateMultTeams(data.mult_teams)
	self.hero_data:updateDeployments(data.deployments)
	self.hero_data:updateMultDeployments(data.mult_deployments)
	self.hero_data:setLevelTop(data.level_top)
	self.hero_data:setCrystalSlot(data.crystal_slot)
	self.hero_data:updateHeroCollect(data.collect)
	--self.pet_data:updatePetData(data.pets)
	--self.pet_data:updateCollectPetData(data.pet_collect)
	--self.pet_data:updatePetFactoryData(data.pet_factory)
	self.equip_data:updateMoreEquipData(data.equips)
	self.talis_data:updateMoreTalisData(data.seal_character)
	self.artifact_data:updateArtifactData(data.artifacts)
	self.item_data:updateMoreItemData(data.items)
	self.mystic_data:updateMoreMysticData(data.mystics)
	self.mystic_data:updateInlayMysticData(data.inlay_mystics)
	self.title_data:updateMoreTitleData(data.titles)
	self.title_data:updateMoreTitlePackageData(data.title_packages)
	self.skillImprove_data:updateSkillImproveData(data.improve_skills)
	self.jewel_data:updateData(data.jewels)
	self.stage_id = data.stage_id
	self.chapter_over = data.chapter_over
	self.stage_id_gu_jian = 101
	self.chapter_over_gu_jian = false
	self.timezone = data.timezone or self.timezone
	self.collect = data.collect or {}
	self.extra_hero_grid = data.extra_hero_grid or 0
	self.m_sig_reset_times = data.sig_reset_times
	self.idle_info = data.idle_info
	self.end_ts = data.end_ts
	self.tower_floor = data.tower_floor
	self.race_floor = data.race_floor
	self.race_floor_times = data.race_floor_times
	self.reg_ts = data.reg_ts
	self.elite_hero_nums = data.elite_hero_nums
	self.guide = data.guide or {}
	self.quest = data.quest or {} --main_quests : 主线任务 daily_quests : 日常任务 weekly_quests : 周常任务
	self.is_first_name = data.is_first_name or 0
	self.troop_ids = data.troop_ids or {} --茶馆激活的羁绊
	self.guild_lv = data.guild_lv or 0 -- 公会等级
	self.tripods = data.tripods or {} --神炉
	self.hero_roles = data.hero_roles or {} -- 图鉴升级职业属性加成
	self.mystic_effect_data = data.mystic_effect_data or {}
	self.mystic_slots = data.mystic_slots or {}
	self.red_dot = data.red_dot or {}
	self.enable_ending = data.enable_ending or {}
	self.questions = data.questions or {}
	self.m_thrones = data.thrones or {}
	self.m_thrones_upgrade = data.thrones_upgrade or {}
	self.m_thrones_phase = data.thrones_phase or {}
	self.m_slots = data.slots or {}
	self:initDeploymentData()
	self:updateDeploymentData()
	--self.cur_map_id = data.cur_map_id;
	--self.map_pos = data.map_pos;
	self.map_event = data.map_event or {}
	self.complete_teams = data.complete_teams or {} --  限时任务已完成group
	self.ongoing_teams = data.ongoing_teams or {} --限时任务正在进行的group
	self.e_ongoing_teams = data.e_ongoing_teams or {} -- 奇遇
	self.e_complete_teams = data.e_complete_teams or {} --  奇遇已完成group
	self.e_next_trigger_ts = data.e_next_trigger_ts or 0 -- 奇遇下一次可触发事件的时间戳
	self.e_today_event_count = data.e_today_event_count or 0 -- 奇遇每日已触发事件的次数
	self.cfg_heros_data = data.cfg_heros or {}
	self.rollings = data.rollings or {} -- 跑马灯数据
	self.vip_received = data.vip_received or {}
	self.active_links = data.active_links or {}
	self.can_rcvd = data.can_rcvd or {}
	self.m_recruit_shop = data.recruit_shop or {}
	self.m_draw_shop = data.draw_shop or {}
	self.sig = data.sig or {} -- 英雄经脉
	self.welfare_npc_guide = data.welfare_npc_guide --福利人设 引导领奖过的id
	self.quest_special = data.quest_special or {} --主线任务拆分的特殊任务
	self.frames = data.frames or {} -- 头像框
	self.avatars = data.avatars or {} -- 头像
	self.hero_skins = data.hero_skins or {} -- 英雄皮肤
	self.m_subscribe = data.subscribe or {} --订阅
	self.m_sub_received = data.sub_received
	self.reset_times = data.reset_times or self.reset_times -- 英雄回退品质次数
	self.m_rollback_buy_times = data.rollback_buy_times or self.m_rollback_buy_times -- 英雄回退品质次数
	self.m_friendliness = data.friendliness or {}
	self.m_relics = data.relics or {}
	self.m_invite_times = data.invite_times or 0	
	self.begin_pailian = data.pailiantu	
	self:updateBlackList(data.blacklist, true)
	self.m_mult_relics = data.mult_relics or {}
	self.m_emoji = data.emoji or {} -- 动态表情包
	self.comeback_status = data.comeback_status or 0 --回归活动状态 (0未触发, 1触发待选择, 2选择留在老服, 3选择去新服)
	self.comeback_rcvd = data.comeback_rcvd or {} --选择留在老服后, 已领取的七日登陆奖励 [day1, day2]
	self.comeback_ts = data.comeback_ts --老服回归的时间戳, 用来判断回归活动的奖励能不能领取
	self.new_comeback_ts = data.new_comeback_ts -- 新服回归的时间戳
	self.comeback_vip = data.comeback_vip --回归的vip经验值
	self.fates = data.fates or {} --天命化星
	self.m_medals = data.medals or {} --奇遇
	self.m_fate_building = data.fate_building or {} --星楼
	self.m_fate_master = data.fate_master or {} --天命化星宗师
	--self.m_battle_pet = data.battle_pet or 0
	--self.m_mult_battle_pet = data.mult_battle_pet or {}
	if self.stage_id == 0 then
		UserDataManager.local_data:setUserDataByKey("open_map", {})
	end
	--self:setRegionalTaskDoneData(data.regional_task_done)
	self:initClientRedPoint()
	self.m_clv = data.clv or 0	
	self.m_normal_array = data.normal_arrays or {}
	self.m_mult_normal_array = data.mult_normal_arrays or {}
	self.m_clv_limit = data.clv_limit or 0
	self.m_prestige_pieces = data.prestige_pieces or {}
	self.m_prestige_board = data.checkerboard_info or {}
	self.m_fenghua_record_data = data.fenghua_record or {}
	self.m_hero_prestige_data = data.hero_prestige or {}
	self.m_play_download_status = data.play_download or 1 --边玩边下奖励领取状态，0 未领取，1 以领取
	self.m_global_repress_data = data.combat_repress or {}
	self.m_awaken_system_data = data.awaken or {}
	self.full_service_need_invitation = data.full_service_need_invitation or 0
	self.guild_talent_coin = data.guild_talent_coin or 0
	self.red_packet_data = data.red_envelope or {}
	self.m_main_bgs = data.main_bgs or {}
	self.env_name = data.env_name or ""
	self:updateRiseArenaId(data.rise_arena_id)--争锋联赛当前赛事id
	--助战系统数据
	self.help_heros = data.help_heros
	--阵法等级
	self.m_normal_teams_lv = data.normal_team_lv or {} --法阵等级: key: 法阵TeamID, value:等级, 不存在时候默认等级1
	--秘宝效果——战斗x倍速
	self.jewel_data:initEffect(data.jewel_effects)
end

function M:updateRiseArenaId(rise_arena_id)
	self.m_rise_arena_id=rise_arena_id
end

function M:getEnvName()
	return self.env_name
end

function M:updateBlackList(black_list, isInit)
	if black_list then
		self.m_black_list = black_list
		self:updateBlackMap(self.m_black_list)
	end
end

function M:updateBlackMap(black_list)
	self.m_black_map = {}
	if black_list and next(black_list) then
		for i = 1, #black_list do
			self.m_black_map[tostring(black_list[i])] = true
		end
	end
end

function M:initClientRedPoint()
	local tian_b1 = RedPointUtil:checkTaskStatus(1013) --日常任务1013未完成时 点击后消失
	if tian_b1 == true then
		self.red_dot.task_red_point_1013 = {status = 1}
	end
	local tian_b1 = RedPointUtil:checkTaskStatus(1018) --日常任务1018未完成时 侠客试炼点击后消失
	if tian_b1 == true then
		self.red_dot.hero_train_login = {status = 1}
	end
	for k = 1,4 do--种族塔挑战次数
		local tower_tab = ConfigManager:getCfgByName("tower_race")
    	local tower_cfg = tower_tab[k]
		local use_num = UserDataManager.race_floor_times[tostring(k)] or 0
		if tower_cfg.floors_per_day - use_num > 0 then
			self.red_dot["tower_race_once_"..k] = {status = 1}
		end
	end
	--探宝营地一次性红点
	local red_flag = false
	for i=1, 2 do
		local one_need = nil
		if i == 2 then
			one_need = ConfigManager:getCommonValueById(376)
			local itemData = RewardUtil:getProcessRewardData(one_need)
			if itemData.user_num >= 10 then
				red_flag = true
				break
			end
		else
			one_need = ConfigManager:getCommonValueById(375)
			local itemData = RewardUtil:getProcessRewardData(one_need)
			if itemData.user_num >= 8 then
				red_flag = true
				break
			end
		end
	end
	if red_flag == true then
		self.red_dot["roulette_once"] = {status = 1}
	end
	--前缘
	local rgacha_flag = false
	local gacha = ConfigManager:getCfgByName("gacha")[7]
	local cost = gacha.cost
	local itemData = RewardUtil:getProcessRewardData(cost[1])
	if itemData.user_num >= 10 then
		rgacha_flag = true
	end
	if rgacha_flag == true then
		self.red_dot["gacha7_once"] = {status = 1}
	end
	--盗帅
	local item_data = UserDataManager.item_data:getItemDataById(1104)
	local ds_red_flag = item_data.num > 10
	if ds_red_flag == true then
		self.red_dot["daoshuai_once"] = {status = 1}
	end
	local seven_tour = UserDataManager:getRedDotByKey("seven_tour")
	if seven_tour ~= 0 then
		self.red_dot["seven_tour_once"] = {status = 1}
	end
	--神炉红点
	local min_tripod_lv = 0
	local min_tripod_num = 20
	local min_tripod_k = 0
	local min_condition_lv = 0
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	for k,v in pairs(guild_tripod) do
		local type_cfg = guild_tripod[k] or {}
		local lv = UserDataManager.tripods[tostring(k)] or 1
		local cfg = type_cfg.config[lv+1]
		if cfg then
			if min_tripod_lv == 0 or min_tripod_lv < lv then
				min_tripod_num = cfg.lvup_cost[3]
				min_tripod_k = k
				min_condition_lv= cfg.condition_lv
			end
		end
	end
	if self.guild_lv >= min_condition_lv then
		local tripod_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.TRIPOD_COIN,0,0})
		if tripod_data.user_num >= min_tripod_num then
			self.red_dot["tripod_once"] = {status = 1}
		end
	end
	self.red_dot["main_bag_once"] = {status = 1}
	self.red_dot["vip_bag_once"] = {status = 1} --人设特权一次性红点
	self.red_dot["five_once"] = {status = 1} --四象阵一次性红点
	self.red_dot["compass_red_point_click"] = {status = 1} -- 1 点过 1个， 2 俩都点多
end

function M:updateClientRedPoint(items)
	for k,v in pairs(items) do
		local get_item_data = RewardUtil:getProcessRewardData({103, tonumber(k), v.num})
		if get_item_data == nil then
			return
		end
		--探宝营地一次性红点
		local red_flag = false
		for i=1, 2 do
			local one_need = nil
			if i == 2 then
				one_need = ConfigManager:getCommonValueById(376)
				local itemData = RewardUtil:getProcessRewardData(one_need)
				if get_item_data.data_id == itemData.data_id and itemData.user_num >= 10 then
					red_flag = true
					break
				end
			else
				one_need = ConfigManager:getCommonValueById(375)
				local itemData = RewardUtil:getProcessRewardData(one_need)
				if get_item_data.data_id == itemData.data_id and itemData.user_num >= 8 then
					red_flag = true
					break
				end
			end
		end
		if red_flag == true then
			self.red_dot["roulette_once"] = {status = 1}
		end
		--前缘
		local rgacha_flag = false
		local gacha = ConfigManager:getCfgByName("gacha")[7]
		local cost = gacha.cost
		local itemData = RewardUtil:getProcessRewardData(cost[1])
		if itemData.data_id == tonumber(k) and itemData.user_num >= 10 then
			rgacha_flag = true
		end
		if rgacha_flag == true then
			self.red_dot["gacha7_once"] = {status = 1}
		end
		--盗帅
		local ds_red_flag = false
		local itemData = UserDataManager.item_data:getItemDataById(1104)
		if k == "1104" and itemData.num >= 10 then
			ds_red_flag = true
		end
		if ds_red_flag == true then
			self.red_dot["daoshuai_once"] = {status = 1}
		end
		--限时兑换
		local xs_red_flag = false
		local exchange_limit_tab = ConfigManager:getCfgByName("exchange") or {}
		for n,m in pairs(exchange_limit_tab) do
			if tonumber(k) == m.item_id[1] then
				xs_red_flag = true
				break
			end
		end
		if xs_red_flag == true then
			self.red_dot["exchange"] = {status = 1}
		end

		--满月兑换
		local my_red_flag = false
		local month_exchange_limit_tab = ConfigManager:getCfgByName("month_exchange") or {}
		for n,m in pairs(month_exchange_limit_tab) do
			if m.item_id and next(m.item_id) ~= nil then
				for id_k,id_v in pairs(m.item_id) do
					if tonumber(k) == id_v then
						my_red_flag = true
						break
					end 
				end
			end
		end
		if my_red_flag == true then
			self.red_dot["month_exchange"] = {status = 1}
		end
		if self:getActivesByOpenId(251) == true then 
			--神飨兑换
			local eat_red_flag = false
			local eat_vsn = {}
			local active_exchange_tab = ConfigManager:getCfgByName("active_exchange") or {}
			for n,m in pairs(active_exchange_tab) do
				if m.item_id and next(m.item_id) ~= nil then
					for id_k,id_v in pairs(m.item_id) do
						if tonumber(k) == id_v then
							eat_red_flag = true
							table.insert( eat_vsn, n)
							break
						end 
					end
				end
			end
			if eat_red_flag == true then
				self.red_dot["eat_exchange"] =  {status = 1, eat_vsn = eat_vsn}
			end
		end
		if RedPointUtil:checkItemRedPointById(k) == true then
			self.red_dot["main_bag_once"] = {status = 1}
		end
	end
end


function M:getCurStage()
	local stage_id = self.stage_id or 0
	return stage_id
end

function M:getCurStageCfg()
	local cur_stage = UserDataManager:getCurStage()
	local stage = ConfigManager:getCfgByName("stage")
	local stage_item = stage[cur_stage]
	return stage_item
end

function M:getBattleStage()
	local battle_stage = self.stage_id or 0
	if not self.chapter_over then
		local stage = ConfigManager:getCfgByName("stage")
		local stage_item = stage[battle_stage]
		if stage_item ~= nil then
			local next_stage = stage_item.next_stage
			battle_stage = stage[next_stage] ~= nil and next_stage or battle_stage
		else
			Logger.logError(battle_stage, "battle_stage id not found : ")
		end
	end
	return battle_stage
end

function M:getChapterOver()
	return self.chapter_over
end

function M:getTowerFloor()
	return self.tower_floor or 0
end

function M:getGuJianStage(stage_id)
	local battle_stage = stage_id or 0
	if not self.chapter_over then
		local stage = ConfigManager:getCfgByName("sword_main")
		local stage_item = stage[battle_stage]
		if stage_item ~= nil then
			local next_stage = stage_item.next_id
			battle_stage = stage[next_stage] ~= nil and next_stage or battle_stage
		else
			Logger.logError(battle_stage, "battle_stage id not found : ")
		end
	end
	return battle_stage
end

function M:delete()
	if self.local_data then
		self.local_data:delete()
		self.local_data = nil
	end
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.netDataUpdateEvent})
end

--[[
	cfg_atttrs: 配置属性格式{{901,14}}
	all_attrs: kv格式{hp = 1,atk = 1}
]]
function M:appendAttrs(cfg_atttrs, all_attrs)
	all_attrs = all_attrs or {}
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for k,v in pairs(cfg_atttrs) do
		local hero_enumeration_item = hero_enumeration[v[1]]
		if hero_enumeration_item then
			if hero_enumeration_item.is_percent and hero_enumeration_item.is_percent == 1 then
				all_attrs[hero_enumeration_item.user_key] = v[2] * 100 + (all_attrs[hero_enumeration_item.user_key] or 0)
			else
				all_attrs[hero_enumeration_item.user_key] = v[2] + (all_attrs[hero_enumeration_item.user_key] or 0)
			end
		end
	end
	return all_attrs
end

	--[[    								-----------新的附加属性
	cfg_atttrs: 配置属性格式{{901,14}}
	all_attrs: kv格式{901 = 1, 902 = 1}
]]
function M:newAppendAttrs(cfg_atttrs, all_attrs)
	all_attrs = all_attrs or {}
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for k,v in pairs(cfg_atttrs) do
		local id = v[1]
		local hero_enumeration_item = hero_enumeration[id]
		if hero_enumeration_item then
			if hero_enumeration_item.is_percent and hero_enumeration_item.is_percent == 1 then
				all_attrs[id] = v[2] * 100 + (all_attrs[id] or 0)
			else
				all_attrs[id] = v[2] + (all_attrs[id] or 0)
			end
		end
	end
	return all_attrs
end

function M:getNewAttrsNameByAttrId(attrId)
	if attrId == 999999 then		-- "lv" 是999999
		return Language:getTextByKey("new_str_0436")
	end
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	local itemData = hero_enumeration[attrId]
	local nameValue = itemData.name
	if itemData.name1 ~= nil and itemData.name1 ~= "" then
		nameValue = itemData.name1
	end
	return Language:getTextByKey(nameValue)
end

--[[
	cfg_attrs: 配置属性格式{{901,14}}
	all_attrs: kv格式{hp = {oldAttr , newAttr},atk = {oldAttr , newAttr}}
]]
function M:appendNewAndOldAttrs(old_cfg_attrs, new_cfg_attrs)
	local old_attrs = self:appendAttrs(old_cfg_attrs)
	local new_attrs = self:appendAttrs(new_cfg_attrs)
	local all_attrs = {}
	local set_flag = false
	for m, n in pairs(new_attrs) do
		set_flag = false
		for k,v in pairs(old_attrs) do
			if k == m then
				all_attrs[m] = {v,n}
				set_flag = true
			end
		end
		if set_flag == false then
			all_attrs[m] = {0, n}
		end
	end
	return all_attrs
end

--[[
	cfg_attrs: 配置属性格式{{901,14}}				--------- 新方法，返回id
	all_attrs: kv格式{901 = {oldAttr , newAttr},902 = {oldAttr , newAttr}}
]]
function M:appendNewAndOldAttrIds(old_cfg_attrs, new_cfg_attrs)
	local old_attrs = self:newAppendAttrs(old_cfg_attrs)
	local new_attrs = self:newAppendAttrs(new_cfg_attrs)
	local all_attrs = {}
	local set_flag = false
	for m, n in pairs(new_attrs) do
		set_flag = false
		for k,v in pairs(old_attrs) do
			if k == m then
				all_attrs[m] = {v,n}
				set_flag = true
			end
		end
		if set_flag == false then
			all_attrs[m] = {0, n}
		end
	end
	return all_attrs
end

--[[
	-- {[id] = value}
]]
function M:appendCfgAttrs(cfg_atttrs, all_attrs)
	all_attrs = all_attrs or {}
	for k,v in pairs(cfg_atttrs) do
		all_attrs[v[1]] = (all_attrs[v[1]] or 0) + v[2]
	end
	return all_attrs
end

function M:getAllHeroAttrs(add_cfg_attrs, all_attrs,iscombat)
	all_attrs = all_attrs or {}
	local base_attrs_percent = self:mergeAttrs(add_cfg_attrs,all_attrs)
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for attr_k,attr_v in pairs(add_cfg_attrs) do
		local hero_enumeration_item = hero_enumeration[attr_k]
		if hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0 then -- 百分比加成
			local attr_name = GameUtil:getAttrsKey(hero_enumeration_item.base_on_id)
			local attr_value = (all_attrs[attr_name] or 0) * (1 + attr_v)
			if hero_enumeration_item.max and hero_enumeration_item.max ~= 0 then
				local max = hero_enumeration_item.max
				attr_value = math.min(attr_value,max)
			end
			all_attrs[attr_name] = attr_value
		end
	end
	for attr_name,value in pairs(base_attrs_percent) do
		local attr_value = (all_attrs[attr_name] or 0) * (1 + value)
		all_attrs[attr_name] = attr_value
	end
	for attr_k,attr_v in pairs(add_cfg_attrs) do
		local hero_enumeration_item = hero_enumeration[attr_k]
		if not (hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0) then -- 值加成
			local attr_name = hero_enumeration_item.user_key
			local attr_value = attr_v + (all_attrs[attr_name] or 0)
			if hero_enumeration_item.max and hero_enumeration_item.max ~= 0 then
				local max = hero_enumeration_item.max
				attr_value = math.min(attr_value,max)
			end
			all_attrs[attr_name] = attr_value
		end
	end
	----分解复合属性为基础属性   处理后只影响战力计算，不影响属性计算，稳定玩家
	if iscombat == true then
		for attr_k,attr_v in pairs(add_cfg_attrs) do
			local hero_enumeration_item = hero_enumeration[attr_k]
			if not (hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0) and hero_enumeration_item.key[2] ~= nil then -- 由于目前没有其他的加成，为了程序的稳定性，只修改值加成
				local attr_name = hero_enumeration_item.key[1]
				local attr2_name = hero_enumeration_item.key[2]
				all_attrs[attr_name] = attr_v + (all_attrs[attr_name] or 0)
				all_attrs[attr2_name] = attr_v + (all_attrs[attr2_name] or 0)
			end
		end
	end
	return all_attrs
end

--对于同一类的加成，进行合并
function M:mergeAttrs(add_cfg_attrs, all_attrs)
	local percent_attrs = {}
	local percent_attrs_id = {}
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for attr_k,attr_v in pairs(add_cfg_attrs) do
		local hero_enumeration_item = hero_enumeration[attr_k]
		if hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0 then -- 百分比加成
			percent_attrs_id[attr_k] = 1
			local attr_name = GameUtil:getAttrsKey(hero_enumeration_item.base_on_id)
			local attr_value = (percent_attrs[attr_name] or 0) + (attr_v)
			percent_attrs[attr_name] = attr_value
			add_cfg_attrs[attr_k] = 0
		end
	end
	return percent_attrs
end

--[[
	通过基础值计算出的新属性
]]
function M:getAddHeroAttrs(add_cfg_attrs, base_attrs)
	local new_attrs = {}
	base_attrs = base_attrs or {}
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for attr_k,attr_v in pairs(add_cfg_attrs) do
		local hero_enumeration_item = hero_enumeration[attr_k]
		if hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0 then -- 百分比加成
			local attr_name = GameUtil:getAttrsKey(hero_enumeration_item.base_on_id)
			local attr_value = (base_attrs[attr_name] or 0) * attr_v
			new_attrs[attr_name] = attr_value
		end
	end
	for attr_k,attr_v in pairs(add_cfg_attrs) do
		local hero_enumeration_item = hero_enumeration[attr_k]
		if not (hero_enumeration_item.base_on_id and hero_enumeration_item.base_on_id ~= 0) then -- 值加成
			local attr_name = hero_enumeration_item.user_key
			new_attrs[attr_name] = attr_v + (new_attrs[attr_name] or 0)
		end
	end
	return new_attrs
end

--[[
	获取英雄属性
]]
function M:getHeroAttrsById(card_id)
    local data, cfg = self.hero_data:getHeroDataById(card_id)
    return self:getHeroAttrsByData(data, cfg,nil, nil,nil, true)
end

--[[
	获取英雄属性
	后端返回的属性是裸体属性
	面板 = 裸体属性 * [ 1 + 生命之树职业百分比 + 羁绊百分比 + 神器百分比 + 专属百分比 ] + 羁绊常量 + 生命之树基础常量 + 生命之树职业常量 + 装备常量 + 神器常量
]]
function M:getHeroAttrsByData(data, cfg, decimals, own_flag, ohter_player_data,thrones_add)
	if data == nil then
		return {}
	end
	if own_flag == nil then
		own_flag = true
	end
	-- 卡牌属性
	local base_attrs = table.copy(data.attrs) or {}
	local add_cfg_attrs = {} -- {id:value}
	-- 装备属性
	local equips = data.equips or {}
	for k,v in pairs(equips) do
		if _G.next(v) then
			local equip_cfg = self.equip_data:getEquipConfigByCid(v.id)
			local equip_attrs = self:getEquipAttrsByData(v, equip_cfg, cfg.race, thrones_add,own_flag, ohter_player_data)
			self:appendCfgAttrs(equip_attrs, add_cfg_attrs)
			--装备词缀属性
			local affix_attrs = self:getEquipAffixAttrs(v,data.id)
			self:appendCfgAttrs(affix_attrs, add_cfg_attrs)
			if equip_cfg.quality >= 12 then
				local god_eqp_affix = self:getIntenEquipLvUp(v, data)
				self:appendCfgAttrs(god_eqp_affix, add_cfg_attrs)
			end
		end
	end

	-- 神器
	local artifact_attrs = self:getArtifactAttrs(data, cfg)
	self:appendCfgAttrs(artifact_attrs, add_cfg_attrs)

	-- 专属装备 经脉
	local sig_attrs = self:getEquipHeroesAttrs(data, cfg)
	self:appendCfgAttrs(sig_attrs, add_cfg_attrs)

	local tripods = self.tripods
	local troop_ids = self.troop_ids
	local hero_roles = self.hero_roles -- 图鉴升级职业属性加成
	local enable_ending = self.enable_ending
	local mystics_data = self.mystic_data:getMysticesData()
	local inlay_mystic =  self.mystic_data:getAllInlayMysticData() --秘籍镶嵌
	local titles_data = self.title_data:getTitlesData() -- 收集的称号
	local wear_title_id = self.user_data:getUserStatusDataByKey("title") -- 佩戴的称号
	local thrones = self.m_thrones ---- 装备套装
	local thrones_upgrade = self.m_thrones_upgrade
	local friendliness = self.m_friendliness
	local slots = self.m_slots
	local relics = self.m_relics
	local fates = self.fates
	local fate_master = self.m_fate_master
	local fates_building = self.m_fate_building
	local fenghua = self.m_fenghua_record_data
	local prestige_pieces = self.m_prestige_pieces
	local prestige_board = self.m_prestige_board
	local real_guild_lv = self.guild_lv
	local awaken_system = self.m_awaken_system_data
	if own_flag == false then
		ohter_player_data = ohter_player_data or {}
		tripods = ohter_player_data.tripods or {}
		hero_roles = ohter_player_data.hero_roles or {} -- 图鉴升级职业属性加成
		troop_ids = ohter_player_data.troop_ids or {}
		thrones = ohter_player_data.thrones or {}
		enable_ending = ohter_player_data.enable_ending or {}
		inlay_mystic = ohter_player_data.inlay_mystic or {}
		titles_data = ohter_player_data.titles or {} -- 收集的称号
		thrones_upgrade = ohter_player_data.thrones_upgrade or {}
		friendliness = ohter_player_data.friendliness or {}
		thrones = ohter_player_data.thrones or {}
		slots = ohter_player_data.relic or {}
		relics = ohter_player_data.self_relics or {}
		fates = ohter_player_data.fates or {}
		fate_master = ohter_player_data.fate_master or {}
		fates_building = ohter_player_data.fate_building or {}
		fenghua = ohter_player_data.fenghua_record or {}
		awaken_system = ohter_player_data.awaken or {}

		mystics_data=ohter_player_data.user.mystics
		if ohter_player_data.prestige then
			prestige_pieces = ohter_player_data.prestige.piece_info or {}
			prestige_board = ohter_player_data.prestige.checkerboard_info or {}
		end
		if ohter_player_data.user then
			wear_title_id = ohter_player_data.user.title -- 佩戴的称号
			real_guild_lv = ohter_player_data.user.guild_lv -- 帮会id
		end
	end

	-- 装备的秘籍加成
	--if data and data.mystics then
	--	for i, v in pairs(data.mystics) do
	--		v.owner = data.oid
	--	end
	--end
	local mystic_slots_attrs = self:getMysticsAttrs(data.mystics, mystics_data, data,inlay_mystic)
	self:appendCfgAttrs(mystic_slots_attrs, add_cfg_attrs)

	local hero_role_attrs = self:getHeroRoleAttrs(data, cfg) -- 职业等级加成
	self:appendCfgAttrs(hero_role_attrs, add_cfg_attrs)

	-- 称号加成
	local titles_attrs = self:getTitlesAttrs(titles_data, wear_title_id, data)
	self:appendCfgAttrs(titles_attrs, add_cfg_attrs)

	-- 茶馆
	--local troops_attrs = self:getTroopsAttrs(troop_ids, data, cfg)
	--self:appendCfgAttrs(troops_attrs, add_cfg_attrs)

	-- 羁绊
	local fetter_attrs = self:getFettersAttrs(data, cfg)
	self:appendCfgAttrs(fetter_attrs, add_cfg_attrs)

	-- 装备套装收集属性
	local thrones_attrs = self:getEquipThronesAttrs(thrones)
	self:appendCfgAttrs(thrones_attrs, add_cfg_attrs)

	--装备图鉴属性
	local thrones_upgrade_attrs = self:getEquipThronesUpgradeAttrs(thrones_upgrade,equips)
	self:appendCfgAttrs(thrones_upgrade_attrs, add_cfg_attrs)

	-- rpg属性加成
	--local rpg_attrs = self:getRPGAttrs(enable_ending, data, cfg)
	--self:appendCfgAttrs(rpg_attrs, add_cfg_attrs)

	-- 皮肤属性加成
	local skin_attrs = self:getSkinAttrs(data, cfg)
	self:appendCfgAttrs(skin_attrs, add_cfg_attrs)

	-- 帮会神炉
	local guild_tripod_attrs = self:getGuildTripodAttrs(tripods, data, cfg,real_guild_lv)
	self:appendCfgAttrs(guild_tripod_attrs, add_cfg_attrs)

	-- 图鉴升级职业属性加成
	local hero_roles_attrs = self:getHeroRoleUpGradeAttrs(hero_roles, data, cfg)
	self:appendCfgAttrs(hero_roles_attrs, add_cfg_attrs)

	--英雄好感
	local hero_friend_attrs = self:getHeroFriendAttrs(cfg, friendliness)
	self:appendCfgAttrs(hero_friend_attrs, add_cfg_attrs)

	--英雄法宝属性
	local hero_wea_attrs = self:getHeroWeaAttrs(cfg,slots,relics)
	self:appendCfgAttrs(hero_wea_attrs, add_cfg_attrs)

	--天命化星属性
	local hero_destiny_star_attrs = self:getHeroDestinyStarAttrs(data,cfg,fates,fates_building)
	self:appendCfgAttrs(hero_destiny_star_attrs,add_cfg_attrs)

	--风华录属性
	--local fenghua_attrs = self:getFengHuaAttrs(fenghua)
	--self:appendCfgAttrs(fenghua_attrs,add_cfg_attrs)

	--威望系统属性
	local prestige_attrs = self:getPrestigeAttrs(data,prestige_pieces,prestige_board)
	self:appendCfgAttrs(prestige_attrs, add_cfg_attrs)

	--符篆系统属性
	local seal_character_attrs = self:getSealCharaterAttrs(data.seal_character)
	self:appendCfgAttrs(seal_character_attrs, add_cfg_attrs)

	local awaken_system_attrs = self:getAwakenSystemAttrs(data,awaken_system)
	self:appendCfgAttrs(awaken_system_attrs, add_cfg_attrs)

	--共鸣系统属性
	local echo_attrs = self:getHeroEchoTotalAttrs(data)
	if echo_attrs ~= nil then
		self:appendCfgAttrs(echo_attrs, add_cfg_attrs)
	end

	-- 宝物
	local jewel_attrs_list = self:getJewelAttrs(data, cfg)
	for i, v in pairs(jewel_attrs_list or {}) do
		self:appendCfgAttrs(v, add_cfg_attrs)
	end

	local all_attrs = self:getAllHeroAttrs(add_cfg_attrs, base_attrs,false)

	--宗师加成属性 所有属性算完之后再加
	local master_add_hp, master_add_atk, master_add_def = self:getFateMasterAddAttr(data, cfg,fate_master)
	all_attrs.hp = all_attrs.hp + master_add_hp
	all_attrs.atk = all_attrs.atk + master_add_atk
	all_attrs.def = all_attrs.def + master_add_def

	local attr_user_keys = ConfigManager:getHeroEnumerationUserKeys()
	-- 属性四舍五入
	if decimals then
	for k,v in pairs(all_attrs) do
	all_attrs[k] = math.floor(v*10000 + 0.5)/10000
	end
	else--只显示用
	for k,v in pairs(all_attrs) do
	if attr_user_keys[k].is_percent == 1 then
	all_attrs[k] = math.floor(v*1000 + 0.5)/10
	else
	all_attrs[k] = math.floor(v + 0.5)
	end
	end
	end
	return all_attrs
	end

--获取宗师属性最终加成 
function M:getFateMasterAddAttr(hero_data, hero_cfg,master_data)
	local hp_value, atk_value, def_value = 0,0,0
	for i, v in pairs(master_data) do
		if v.master == hero_data.oid then
			for hero_i, slaves_hero_id in pairs(v.slaves) do
				if slaves_hero_id and slaves_hero_id ~= "" then
					local slaves_hero_data,slaves_hero_cfg
					if v.heros then
						slaves_hero_data = v.heros[slaves_hero_id]
						slaves_hero_cfg = self.hero_data:getHeroConfigByCid(v.heros[slaves_hero_id].id)
					else
						slaves_hero_data, slaves_hero_cfg = UserDataManager.hero_data:getHeroDataById(slaves_hero_id)
					end
					local add_nums = self:getMasterSlotAddNumsByIndex(i, slaves_hero_cfg.role_type == hero_cfg.role_type)
					hp_value = slaves_hero_data.attrs.hp * add_nums + hp_value
					atk_value = slaves_hero_data.attrs.atk * add_nums + atk_value
					def_value = slaves_hero_data.attrs.def * add_nums + def_value
				end
			end
		end
	end
	return hp_value, atk_value, def_value
end

--宗师属性加成的配置
function M:getMasterSlotAddNumsByIndex(index, is_same_role_type)
	local fate_master_cfg = ConfigManager:getCfgByName("fate_master") or {}
	local cur_cfg = fate_master_cfg[tonumber(index)] or {}
	local add_nums = 0
	if is_same_role_type then
		add_nums = cur_cfg.master_attr1 or 0
	else
		add_nums = cur_cfg.master_attr2 or 0
	end
	return add_nums
end

--英雄好感属性
function M:getHeroFriendAttrs(cfg, friendliness)
	local data = friendliness[tostring(cfg.id)] or {point=0,lv=0}
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	local attr_tab = {}
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[cfg.role_type or 1] or {}
		local cur_cfg = fet_tab[data.lv]
		if cur_cfg then
			table.insertto(attr_tab,cur_cfg.Meridian_attr)
		end
	end
	return attr_tab
end

--法宝属性加成
function M:getHeroWeaAttrs(cfg, wea_solts, relics)
	--wea_solts 法宝列表 有内容优先使用此数据
	local attr_tab = {}
	local tab_cfg = ConfigManager:getCfgByName("treasure_config")
	if wea_solts and next(wea_solts) then
		relics = relics or {}
		for k,v in pairs(wea_solts) do
			if v > 0 then
				local trea_cfg = tab_cfg[v]
				local cur_data = relics[tostring(v)] or self.m_relics[tostring(v)] or {new = 0, lv = 1}
				local show_cfg = trea_cfg.detail[cur_data.lv] or trea_cfg.detail[1]
				if next(show_cfg.att_unit_list) == nil then
					table.insertto(attr_tab,show_cfg.att)
				else
					for kk,vv in pairs(show_cfg.att_unit_list) do
						if cfg.id == vv then
							table.insertto(attr_tab,show_cfg.att)
						end
					end
				end
			end
		end
	else
		for k,v in pairs(self.m_slots) do
			if v > 0 then
				local trea_cfg = tab_cfg[v]
				local cur_data = self.m_relics[tostring(v)]
				local show_cfg = trea_cfg.detail[cur_data.lv] or trea_cfg.detail[1]
				if next(show_cfg.att_unit_list) == nil then
					table.insertto(attr_tab,show_cfg.att)
				else
					for kk,vv in pairs(show_cfg.att_unit_list) do
						if cfg.id == vv then
							table.insertto(attr_tab,show_cfg.att)
						end
					end
				end
			end
		end
	end
	return attr_tab
end

--[[
	获取装备属性 = 装备基础值*（1+强化成长率*lv+种族30%）
]]
function M:getEquipAttrsById(equip_id,thrones_add, own_flag, ohter_player_data)
	local equip, equip_cfg = self.equip_data:getEquipDataById(equip_id)
	return self:getEquipAttrsByData(equip, equip_cfg, nil, thrones_add ,own_flag, ohter_player_data)
end

--[[
	获取装备属性 = 装备基础值 *（1 + 强化成长率 * lv / 100 + 种族 / 100）
	种族现在读配置common id 45
]]
function M:getEquipAttrsByData(equip_data, equip_cfg, hero_race, thrones_add, own_flag, ohter_player_data)
	local attrs = {}
	if equip_data and equip_cfg then
		local equip_lv = 0
		local attr = equip_cfg.attr or {}
		local lv_growth_rate = equip_cfg.lv_growth_rate or 0
		if equip_cfg.quality >= 12 then
			equip_lv = 0
			--神兵从配置的属性上，根据强化等级增加
			for k,v in pairs(attr) do
				table.insert(attrs,{v[1],v[2]*lv_growth_rate*(equip_data.lv)/100})
			end
		else
			equip_lv = equip_data.lv or 0
		end
		local race = equip_data.race or 0
		local race_value = ConfigManager:getCommonValueById(45, 0)
		local race_rate = 0
		if hero_race == race then
			race_rate = race > 0 and race_value or 0
		end
		local equip_attrs = self:getEquipBookAttrNum(equip_cfg, thrones_add, own_flag, ohter_player_data)
		--local equipweapon_attrs = UserDataManager:getEquipWeaponAttrNum(equip_cfg, true, true)
		local merge_attr = self:AttrMergeFoEquip(attr, equip_attrs)
		--local merge_attr = merge_attr1--self:AttrMergeFoEquip(merge_attr1, equipweapon_attrs)
		for attr_k,attr_v in pairs(merge_attr) do
			local exp_book_ratio = self:equipBookAttrRatioById(equip_cfg, attr_v[1], thrones_add, own_flag, ohter_player_data)
			local equip_weapon_ratio = self:equipweaponAttrRatioById(equip_cfg, attr_v[1], thrones_add, own_flag, ohter_player_data)
			local attr_index = attr_v[1] or 0
			local attr_value = attr_v[2] or 0
			local sum_ratio = (1 + lv_growth_rate*(equip_lv)/100 + race_rate/100+ exp_book_ratio/100 + equip_weapon_ratio/100)
			table.insert(attrs,{attr_index, (attr_value) * sum_ratio})
		end
	
	end
	return attrs
end

--神级装备强化属性
function M:getIntenEquipLvUp(equip_data, data)
	local equip_legend_tab = ConfigManager:getCfgByName("equip_legend")
	local cur_eqp = equip_legend_tab[equip_data.id]
	local attrs = {}
	if cur_eqp then
		local cur_lv_data = cur_eqp[equip_data.lv]
		if cur_lv_data then
			for k,v in pairs(cur_lv_data.attr) do					
				table.insert(attrs,v)
			end
		end
	end
	return attrs
end


--属性合并
function M:AttrMergeFoEquip(attr, equip_attr)
	local new_attrs = table.copy(attr)
	for k,v in pairs(equip_attr) do
		local is_merge = false
		for kk,vv in pairs(new_attrs) do
			if v[1] == vv[1] then
				is_merge = true
				local new_attr = table.copy(v)
				new_attr[2] = new_attr[2] + vv[2]
				new_attrs[kk] = new_attr
				break
			end
		end
		if is_merge == false then
			table.insert(new_attrs, v)
		end
	end
	return new_attrs
end

--获取装备图鉴升级继承属性   (图鉴升级继承属性= 图鉴升级属性*自身品质继承比例)
function M:equipBookAttrById(equip_cfg, attr_id, thrones_add, own_flag, ohter_player_data)
	--thrones_add 神装加成
	if thrones_add == false then
		return 0
	end
	if equip_cfg.equip_throne_id == 0 then
		return 0
	end
	if next(self.m_thrones_upgrade) == nil then
		return 0
	end
	local throne_cfg = self.m_thrones_upgrade.level[tostring(equip_cfg.equip_throne_id)]
	if own_flag == false then
		if ohter_player_data ~= nil then
			throne_cfg = ohter_player_data.thrones_upgrade or {lv = 0}
		else
			throne_cfg = nil
		end
	else
		if not thrones_add then
			return 0
		end
	end
	if throne_cfg == nil then
		return 0
	end
	local lv = throne_cfg.lv or 0
	local equip_throne_level_tab = ConfigManager:getCfgByName("equip_throne_level")
	if equip_throne_level_tab == nil then
		return 0
	end
	local ratio = 0
	local equip_throne_inherit_tab = ConfigManager:getCfgByName("equip_throne_inherit")
	if equip_throne_inherit_tab then
		local inherit_cfg = equip_throne_inherit_tab[equip_cfg.quality]
		if inherit_cfg then
			ratio = inherit_cfg.ratio
		end
	end
	local equip_throne_cfg = equip_throne_level_tab[lv]
	local equip_book_attrs = equip_throne_cfg.equip_throne[equip_cfg.equip_throne_id] or {}
	for k,v in pairs(equip_book_attrs) do
		if v[1] == attr_id then
			return v[2]*ratio
		end
	end
	return 0
end

--获取装备的所有图鉴升级继承属性基础属性  (图鉴升级继承属性= 图鉴升级属性*自身品质继承比例)
function M:getEquipBookAttrNum(equip_cfg, thrones_add, own_flag, ohter_player_data)
	local equip_attrs = {}
	if thrones_add == false then
		return {}
	end
	if equip_cfg.equip_throne_id == 0 then
		return {}
	end
	if own_flag == true and next(self.m_thrones_upgrade) == nil then
		return {}
	end
	local throne_cfg = {}
	if own_flag == true then
		throne_cfg = self.m_thrones_upgrade.level[tostring(equip_cfg.equip_throne_id)]
	end
	if own_flag == false then
		if ohter_player_data ~= nil and ohter_player_data.thrones_upgrade and ohter_player_data.thrones_upgrade.level then
			throne_cfg = ohter_player_data.thrones_upgrade.level[tostring(equip_cfg.equip_throne_id)] or {lv = 0}
		else
			throne_cfg = nil
		end
	else
		if not thrones_add then
			return {}
		end
	end
	if throne_cfg == nil then
		return {}
	end
	local equip_throne_level_tab = ConfigManager:getCfgByName("equip_throne_level")
	if equip_throne_level_tab == nil then
		return {}
	end
	local lv = throne_cfg.lv or 0
	local ratio = 0
	local equip_throne_inherit_tab = ConfigManager:getCfgByName("equip_throne_inherit")
	if equip_throne_inherit_tab then
		local inherit_cfg = equip_throne_inherit_tab[equip_cfg.quality]
		if inherit_cfg then
			ratio = inherit_cfg.ratio
		end
	end
	local equip_throne_cfg = equip_throne_level_tab[lv]
	local equip_book_attrs = table.copy(equip_throne_cfg.equip_throne[equip_cfg.equip_throne_id])  or {}
	local new_attr = {}
	for k,v in pairs(equip_book_attrs) do
		table.insert( new_attr, {v[1], v[2]*ratio} )
	end
	return new_attr
end

--获取神兵等级对武器的加成
function M:getEquipWeaponAttrNum(equip_cfg, thrones_add, own_flag, ohter_player_data)
	local equip_attrs = {}
	if thrones_add == false then
		return {}
	end
	if equip_cfg.equip_throne_id == 0 then
		return {}
	end
	if own_flag == true and next(self.m_thrones_phase) == nil then
		return {}
	end
	local lv = 0
	if own_flag == true and self.m_thrones_phase.lv ~= nil then
		lv = self.m_thrones_phase.lv
	end
	if lv == 0 then
		return {}
	end

	local equip_throne_level_tab = ConfigManager:getCfgByName("equip_throne_phase")
	if equip_throne_level_tab == nil then
		return {}
	end

	local equip_throne_cfg = equip_throne_level_tab[lv]
	local equip_book_attrs = table.copy(equip_throne_cfg.equip_throne[equip_cfg.equip_throne_id])  or {}
	local new_attr = {}
	for k,v in pairs(equip_book_attrs) do
		table.insert( new_attr, {v[1], v[2]} )
	end
	return new_attr
end

--获取装备图鉴进阶属性百分比   ****红装以上才有百分比 (只给装备加)
function M:equipBookAttrRatioById(equip_cfg, attr_id, thrones_add, own_flag, ohter_player_data)
	if equip_cfg.equip_throne_id == 0 then
		return 0
	end
	if thrones_add == false then
		return false
	end
	if own_flag == true and next(self.m_thrones_upgrade) == nil then
		return 0
	end
	local quality = self.m_thrones_upgrade.evo or 0
	if own_flag == false then
		if ohter_player_data ~= nil and ohter_player_data.thrones_upgrade then
			quality = ohter_player_data.thrones_upgrade.evo or 0
		else
			quality = 0
		end
	else
		if not thrones_add then
			return 0
		end	
	end
	local equip_throne_evo_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local hero_enumeration_tab = ConfigManager:getCfgByName("hero_enumeration")
	local equip_throne_cfg = equip_throne_evo_tab[quality]
	if equip_throne_cfg then
		for k,v in pairs(equip_throne_cfg.attr1) do
			local enum_attr = hero_enumeration_tab[v[1]]
			if enum_attr.base_on_id == attr_id then
				return v[2]*100
			end
		end
	end
	return 0
end

--获取装备神兵等级属性百分比
function M:equipweaponAttrRatioById(equip_cfg, attr_id, thrones_add, own_flag, ohter_player_data)
	if equip_cfg.equip_throne_id == 0 then
		return 0
	end
	if thrones_add == false then
		return false
	end
	if next(self.m_thrones_phase) == nil then
		return 0
	end
	if own_flag == true and self.m_thrones_phase.lv == nil then
		return 0
	end
	local lv = self.m_thrones_phase.lv or 0
	if own_flag == false then
		if ohter_player_data ~= nil and ohter_player_data.m_thrones_phase then
			lv = ohter_player_data.m_thrones_phase.lv or 0
		else
			lv = 0
		end
	else
		if not thrones_add then
			return 0
		end
	end
	if lv == 0 then
		return 0
	end
	local equip_throne_phase_tab = ConfigManager:getCfgByName("equip_throne_phase")
	local hero_enumeration_tab = ConfigManager:getCfgByName("hero_enumeration")
	local equip_throne_cfg = equip_throne_phase_tab[lv]
	local equip_phase_attrs = table.copy(equip_throne_cfg.equip_throne[equip_cfg.equip_throne_id])  or {}
	for k,v in pairs(equip_phase_attrs) do
		local enum_attr = hero_enumeration_tab[v[1]]
		if enum_attr.base_on_id == attr_id then
			return v[2]*100
		end
	end
	return 0
end

--装备词缀属性
function M:getEquipAffixAttrs(equip_data, id)
	local attrs = {}
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	if equip_data and equip_data.affix then
		for k,v in pairs(equip_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg == nil then
				break
			end
			if affix_cfg.unique == 0 then
				for i,o in pairs(v.value) do
					local attr_index = o[2] or 0
					local attr_value = o[3] or 0
					table.insert(attrs,{attr_index, attr_value})
				end
			else
				if id and affix_cfg.unique_hero then
					if affix_cfg.unique_hero == id or affix_cfg.unique_hero == 0 then 
						for i,o in pairs(v.value) do
							local attr_index = o[2] or 0
							local attr_value = o[3] or 0
							table.insert(attrs,{attr_index, attr_value})
						end
					end
				end
			end
		end
	end
	return attrs
end

--[[
	获取神器属性
]]
function M:getArtifactAttrs(data, cfg)
	local artifact_gs_coef = 1 -- 神器系数
	local artifact_gs_add = 0 -- 额外战力增量
	local attrs = {}
	local a_data = data.artifact
	if a_data then
		local a_cfg = self.artifact_data:getArtifactConfigByCid(a_data.id) 
		if a_cfg then
			local level_up = a_cfg.level_up[a_data.lv] or {}
			attrs = level_up.attr or {}
			artifact_gs_coef = level_up.gs_coef or 1
			artifact_gs_add = level_up.gs_add or 0
		end
	end
	return attrs, artifact_gs_coef, artifact_gs_add
end

--[[
	专属装备属性 - 经脉
]]
function M:getEquipHeroesAttrs(data, cfg)
	local sig_gs_add = 0 -- 专属装备战力增量
	local attrs = {}
	local sig = data.sig or {} -- 专属装备，空为未激活
	local equip_heroes = ConfigManager:getCfgByName("equip_heroes")
	local equip_heroes_id = cfg.equip_heroes_id	or 0
	local cur_equip_heroes = equip_heroes[equip_heroes_id]
	if cur_equip_heroes then
		local sig_deep = 0
		for k,v in pairs(sig) do
			local lv = v.lv or 0
			sig_deep = v.deep or 0
			local cur_equip_heroes_item = cur_equip_heroes[tonumber(k)]
			if cur_equip_heroes_item then
				local level_up = cur_equip_heroes_item.level_up[lv] or {}
				local att = level_up.attr or {}
				table.insertto(attrs, att)
				--sig_gs_add = level_up.gs_add or 0
			end
		end
		-- 经脉重数加成
		local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
		local meridians_cultivation_cfg_item = meridians_cultivation_cfg[sig_deep] or {}
		local attr = meridians_cultivation_cfg_item.attr or {}
		table.insertto(attrs, attr)
	end
	return attrs, sig_gs_add
end

--[[
	rpg属性加成
]]
function M:getRPGAttrs(enable_ending, data, cfg)
	local attrs = {}
	local roleplaying_ending = ConfigManager:getCfgByName("roleplaying_ending")
	for k, v in pairs(enable_ending or {}) do
		local chapter_roleplaying_ending_cfg = roleplaying_ending[tonumber(k)] or {}
		for k1, v1 in pairs(v) do
			local roleplaying_ending_cfg = chapter_roleplaying_ending_cfg[v1] or {}
			local hero = roleplaying_ending_cfg.hero or {}
			for k2, v2 in pairs(hero) do
				if data.id == v2 then
					local att = roleplaying_ending_cfg.att or {}
					table.insertto(attrs, att)
				end
			end
		end
	end
	return attrs
end

--[[
	皮肤属性加成
]]
function M:getSkinAttrs(data, cfg)
	local attrs = {}
	local skin_id = data.skin
	if skin_id ~= nil then
		local skin_cfg = ConfigManager:getHeroSkinCfg(skin_id)
		attrs = skin_cfg.attr
	end
	return attrs
end

--天命属性加成
function M:getHeroDestinyStarAttrs(data,cfg,fates,fates_building)
	local attrs = {}
	local hero_is_fates = self:getHeroIsFates(data.oid,fates)
	if hero_is_fates then
		local star_id,star_list = self:getFatesStarId(data.oid, fates)
		if star_id ~= 0 then
			local num = 0
			for i, v in pairs(star_list) do
				num = num + 1
			end
			local fate_star = ConfigManager:getCfgByName("fate_star")
			local add_base = fate_star[tonumber(star_id)].add_base[num]
			local add_id = fate_star[tonumber(star_id)].add_id
			for i, v in ipairs(add_id) do
				local base = {}
				--星楼属性加成
				local fate_build_add_base = self:getFateBuildAddAttr(v,fates_building)
				table.insert(base,v)
				table.insert(base,add_base*0.01 + fate_build_add_base)
				table.insert(attrs,base)
			end
		end
	end
	return attrs
end

--星楼属性加成
function M:getFateBuildAddAttr(buff_id,fates_building)
	local building_data = fates_building or UserDataManager.m_fate_building 
	local cur_floor = building_data.lv or 0
	local cur_cfg = ConfigManager:getCfgByName("fate_building") or {}
	local add_attr = cur_cfg[cur_floor] and cur_cfg[cur_floor].attr or {}
	for i, v in pairs(add_attr) do
		if tonumber(v[1]) == tonumber(buff_id) then
			return v[2]
		end
	end
	return 0
end

--威望系统属性加成
function M:getPrestigeAttrs(heroData,prestige_pieces,prestige_board)
	local prestige_board_cfg = ConfigManager:getCfgByName("prestige_checkerboard_upgrade") or {}
	local prestige_pieces_cfg = ConfigManager:getCfgByName("prestige_piece_affix") or {}
	local board_cfg = ConfigManager:getCfgByName("prestige_checkerboard") or {}  --用upgrade_recipe  去 restige_board_cfg取
	local board_fetter_cfg = ConfigManager:getCfgByName("prestige_checkerboard_fetter") or {}  --羁绊的属性配置
	
	local attrs = {}
	--棋盘属性
	for k,v in pairs(prestige_board) do
		local upgrade_recipe = board_cfg[tonumber(k)].upgrade_recipe
		if prestige_board_cfg[upgrade_recipe][v.level] then
			local attr = prestige_board_cfg[upgrade_recipe][v.level].attr
			for k1,v1 in ipairs(attr) do
				table.insert(attrs,v1)
			end
		else
			Logger.log("棋盘等级与配置对不上" .. v.level .. "棋盘" ..upgrade_recipe )
		end
	end
	--棋子属性
	local piece_attrs = {}
	for k1,v1 in pairs(prestige_pieces) do
		if v1.status ~= 0 then
			local affix = v1.affix
			for groupid,idgroup in pairs(affix) do
				for key,id in ipairs(idgroup) do
					if prestige_pieces_cfg[id] then
						local piece_attr = prestige_pieces_cfg[id].attr
						local heroDetail = ConfigManager:getCfgByName("hero_detail")
						local curHeroXlsxData = heroDetail[heroData.id] or {}
						local heroSex = curHeroXlsxData.sex
						local heroRace = curHeroXlsxData.race
						local heroJob = curHeroXlsxData.role_type
						local enumerationXlsxData = ConfigManager:getCfgByName("hero_enumeration")
						local curAttrId = piece_attr[1]
						local curAttrXlsx = enumerationXlsxData[curAttrId] or {}
						local isAlikeSex, isAlikeRace, isAlikeJob = self:isConformAttrCondition(curAttrXlsx, heroSex, heroRace, heroJob)
						if isAlikeSex and isAlikeRace and isAlikeJob then
							local base_id = curAttrXlsx.base_on_id
							if base_id ~= 0 and curAttrXlsx.group ~= 0 then
								local prestige_fetter_attr = {}
								prestige_fetter_attr[1] = base_id
								prestige_fetter_attr[2] = piece_attr[2]
								table.insert(attrs, prestige_fetter_attr)
							else
								table.insert(attrs, piece_attr)
							end
						end
					else
						Logger.log("异常id" .. id)
					end
				end
			end
		end
	end
	--羁绊属性
	for k2,v2 in pairs(prestige_board) do
		local coordinate_data = v2.coordinate
		local pieces = {} --棋子id
		local cur_board_fetter_cfg = {}
		for id,id_cfg in ipairs(board_fetter_cfg) do
			if id_cfg.checkerboard == tonumber(k2) then
				table.insert(cur_board_fetter_cfg,id_cfg)
			end
		end
		
		for pos,id in pairs(coordinate_data) do
			local have = false
			for key,piece_id in pairs(pieces) do
				if id == piece_id then
					have = true
					break
				end
			end
			if not have then
				table.insert(pieces,id)
			end
		end
		local hero_ids = {}  --英雄id
		for key,piece_id in pairs(pieces) do
			if prestige_pieces[tostring(piece_id)] then
				local hero = prestige_pieces[tostring(piece_id)].hero
				if not table.indexof(hero_ids,hero) then
					table.insert(hero_ids,hero)
				end
			end
		end
		local middle = hero_ids
		for key1,key1_cfg in ipairs(cur_board_fetter_cfg) do
			local fetter_cfg = key1_cfg.hero_fetter
			local nums = 0
			for key2,fetter_id in ipairs(fetter_cfg) do
				for key3,hero_id in ipairs(hero_ids) do
					if fetter_id == hero_id then
						nums = nums +1 
					end
				end
			end
			local effect = key1_cfg.effect
			local buff = key1_cfg.buff
			local level = 0
			for key4,condition in ipairs(effect) do
				if nums >= condition then
					level = key4																								
				end
			end
			local hero_fetter_attr = buff[level]
			if hero_fetter_attr then
				local heroDetail = ConfigManager:getCfgByName("hero_detail")
				local curHeroXlsxData = heroDetail[heroData.id] or {}
				local heroSex = curHeroXlsxData.sex
				local heroRace = curHeroXlsxData.race
				local heroJob = curHeroXlsxData.role_type
				local enumerationXlsxData = ConfigManager:getCfgByName("hero_enumeration")
				local curAttrId = hero_fetter_attr[1]
				local curAttrXlsx = enumerationXlsxData[curAttrId] or {}
				local isAlikeSex, isAlikeRace, isAlikeJob = self:isConformAttrCondition(curAttrXlsx, heroSex, heroRace, heroJob)
				if isAlikeSex and isAlikeRace and isAlikeJob then
					local base_id = curAttrXlsx.base_on_id
					if base_id ~= 0 and curAttrXlsx.group ~= 0 then
						local prestige_fetter_attr = {}
						prestige_fetter_attr[1] = base_id
						prestige_fetter_attr[2] = hero_fetter_attr[2]
						table.insert(attrs, prestige_fetter_attr)
					else
						table.insert(attrs, hero_fetter_attr)
					end
				end
			end
		end
	end
	return attrs
end

--符篆属性
function M:getSealCharaterAttrs(data)
	local attrs = {}
	local attrs_ = data or {}
	for i,v in pairs(attrs_) do
		local attrs_ptemp = v.attrs
		for m,n in pairs(attrs_ptemp) do
			local value = n.value
			if value then
				table.insert(attrs,{value[1],value[2]})
			end
		end
	end 
	--添加符篆效果
	local aar = {}
	local cfg = ConfigManager:getCfgByName("seal_character_suit")
	for k,v in pairs(attrs_) do
		local t_id = cfg[v.id].team
		local q_id =cfg[v.id].quality
		if aar[v.id] == nil then
			--aar[v.id].team_id = team_id
			--aar[v.id].quaily_id = quaily_id
			aar[v.id] = {team_id = t_id,quaily_id = q_id,num = 1}
		else
			aar[v.id].num = aar[v.id].num + 1
		end
	end
	for k,v in pairs(aar) do 
		if v.num >=2 then 
			local arrs = cfg[tonumber(k)].addition2.attrs
			for m,n in pairs(arrs) do
				table.insert(attrs,{n[1],n[2]})
			end
		end
	end
	return attrs
end

--羽化属性
function M:getAwakenSystemAttrs(data,awaken)
	local attrs = {}
	local fly_heros_data = awaken.fly_heros
	local god_heros_data = awaken.god_heros
	local awaken_god_cfg = ConfigManager:getCfgByName("awaken_god")
	local awaken_fly_cfg = ConfigManager:getCfgByName("awaken_fly")
	local hero_id = data.id
	local attr_fly = self:calculateAwakenAttr(awaken_fly_cfg,fly_heros_data,hero_id)
	local attr_god = self:calculateAwakenAttr(awaken_god_cfg,god_heros_data,hero_id)

	for k1,v1 in pairs(attr_fly) do
		table.insert(attrs,v1)
	end

	for k2,v2 in pairs(attr_god) do
		table.insert(attrs,v2)
	end
	
	return attrs
end

--[[
	获取宝物属性
]]
function M:getJewelAttrs(data, cfg)
	local hero_id = data.id
	local attrs_list = self.jewel_data:getAttrs(hero_id)
	return attrs_list
end

function M:calculateAwakenAttr(cfg,heros,hero_id)
	local attrs = {}
	local lv = 0
	if heros and next(heros) then
		for k,v in pairs(heros) do
			if k == tostring(hero_id) then
				lv = v.lv
			end
		end
	end

	if lv ~= 0 then
		local cur_hero_cfg = cfg[hero_id]
		local cur_level_cfg = cur_hero_cfg and cur_hero_cfg[lv] or {}
		attrs = cur_level_cfg.attr or {}
	end

	return attrs
end

--合并属性
function M:mergeTable(temp_attr)
	local end_attrs = {}
	local hava_attr_type = {}
	if true then
		Logger.log("一个英雄")	
	end
	for k,v in ipairs(temp_attr) do
		local hava = false
		for k1,v1 in ipairs(hava_attr_type) do
			if v[1] == v1 then
				hava = true
				break
			end
		end
		if hava then
			for key,value in ipairs(end_attrs) do
				if v[1] == value[1] then 
					Logger.log(value[2])
					local temp = value[2]
					local temp2 = v[2]
					end_attrs[key][2] = 0
					end_attrs[key][2] = temp + temp2
					--value[2] = nil
					--value[2] = temp + temp2
					--value[2] = value[2] + v[2]
					break
				--Logger.log(v2[2])
				end
			end 
		else
			table.insert(end_attrs,v)
			table.insert(hava_attr_type,v[1])
		end
	end
	
	return end_attrs
end


--风华录属性加成
function M:getFengHuaAttrs(fenghua_record)
	local attr_table = {}
	if fenghua_record and next(fenghua_record) then
		local cfg = ConfigManager:getCfgByName("fenghua_record") or {}
		local show_fenghua_record =  {}
		--找出需要显示的配置
		if next(cfg) then
			for index,value in ipairs(cfg) do
				if value.show == 1 then
					local line_attrs = self:getAttrsByLine(fenghua_record,value)
					for k,v in ipairs(line_attrs) do
						table.insert(attr_table,v)
					end
				end
			end
		end
	end
	return attr_table
end

--逐组计算风华录加成
function M:getAttrsByLine(fenghua_record,line_record)
	local attrs = {}
	local attr_str = "attr"
	local num = 0
	for k,v in ipairs(line_record.group_record) do
		for k1,v1 in ipairs(fenghua_record) do
			if v == v1 then
				num = num + 1
				break
			end
		end
	end
	for i=1,num do
		local nums_name = attr_str .. tostring(i)
		table.insert(attrs,line_record[nums_name][1])
	end
	return attrs
end


-- 秘籍属性
-- mystics 英雄装备的秘籍
-- mystics_data 秘籍数据
function M:getMysticsAttrs(mystics, mystics_data, hero_data,inlay_mystic)
	mystics = mystics or {}
	local mystic_slots_attrs = {}
	for k,id in pairs(mystics) do
		local mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(id)
		local data,_=UserDataManager.mystic_data:getMysticDataById(id)
		if mystics_data then
			data=mystics_data[tostring(id)]
		end

		local attrs = self:getOneMysticAttrs(data, mystic_cfg, hero_data,inlay_mystic)
		table.insertto(mystic_slots_attrs, attrs) -- 基础属性
	end
	return mystic_slots_attrs
end

function M:getHeroRoleAttrs(hero_data, cfg)
	local heroRoleCfg = {}
	local role_level = 0
	local att_list = {}
	if hero_data and hero_data.book and hero_data.book.lv then
		role_level = hero_data.book.lv
		if role_level and cfg then
			local role_type = cfg.role_type or 0
			if role_type ~= 0 then
				local herorole = ConfigManager:getCfgByName("herorole")
				local heroRoleItem = herorole[role_type] or {}
				heroRoleCfg = heroRoleItem[role_level] or {}
				att_list = heroRoleCfg.att or {}
			end
		end
	end
	return att_list
end

--[[
	获取称号属性
	title_data 收集的称号
	wear_title_id 穿戴的称号
]]
function M:getTitlesAttrs(title_data, wear_title_id, heroData)
	title_data = title_data or {}
	local title_attrs = {}
	local heroDetail = ConfigManager:getCfgByName("hero_detail")
	local curHeroXlsxData = heroDetail[heroData.id] or {}
	local heroSex = curHeroXlsxData.sex
	local heroRace = curHeroXlsxData.race
	local heroJob = curHeroXlsxData.role_type
	local enumerationXlsxData = ConfigManager:getCfgByName("hero_enumeration")
	for k,v in pairs(title_data) do
		local addAttrList = {}
		local title_id = v.id or k
		local title_cfg = UserDataManager.title_data:getTitleConfigById(title_id)
		if title_cfg then
			local attrs = title_cfg.attr1
			for _, itemAttr in pairs(attrs) do
				local curAttrId = itemAttr[1]
				local curAttrXlsx = enumerationXlsxData[curAttrId] or {}
				local isAlikeSex, isAlikeRace, isAlikeJob = self:isConformAttrCondition(curAttrXlsx, heroSex, heroRace, heroJob)
				if isAlikeSex and isAlikeRace and isAlikeJob then
					table.insert(addAttrList, itemAttr)
				end
			end
		end
		if table.nums(addAttrList) > 0 then
			table.insertto(title_attrs, addAttrList) -- 基础属性
		end
	end
	if wear_title_id and tonumber(wear_title_id) ~= 0 then
		local addAttrList = {}
		local title_cfg = UserDataManager.title_data:getTitleConfigById(wear_title_id)
		local attrs = title_cfg.attr2
		for _, itemAttr in pairs(attrs) do
			local curAttrId = itemAttr[1]
			local curAttrXlsx = enumerationXlsxData[curAttrId] or {}
			local isAlikeSex, isAlikeRace, isAlikeJob = self:isConformAttrCondition(curAttrXlsx, heroSex, heroRace, heroJob)
			if isAlikeSex and isAlikeRace and isAlikeJob then
				table.insert(addAttrList, itemAttr)
			end
		end
		if table.nums(addAttrList) > 0 then
			table.insertto(title_attrs, addAttrList) -- 基础属性
		end
	end
	return title_attrs
end

function M:isConformAttrCondition(curAttrXlsx, heroSex, heroRace, heroJob)
	local isAlikeSex = true
	if curAttrXlsx.sex ~= 0 then
		isAlikeSex = curAttrXlsx.sex == heroSex
	end
	local isAlikeRace = false
	local raceCount = table.nums(curAttrXlsx.race)
	if raceCount > 0 then
		for index = 1, raceCount do
			local itemXlsxRace = curAttrXlsx.race[index]
			if heroRace == itemXlsxRace then
				isAlikeRace = true
				break
			end
		end
	else
		isAlikeRace = true
	end
	local isAlikeJob = false
	local jobCount = table.nums(curAttrXlsx.role_type)
	if jobCount > 0 then
		for index = 1, jobCount do
			local itemXlsxJob = curAttrXlsx.role_type[index]
			if heroJob == itemXlsxJob then
				isAlikeJob = true
				break
			end
		end
	else
		isAlikeJob = true
	end
	return isAlikeSex, isAlikeRace, isAlikeJob
end

-- 一个秘籍属性
-- mystics 英雄装备的秘籍
-- mystics_data 秘籍数据
function M:getOneMysticAttrs(mystic_data, mystic_cfg, hero_data,inlay_mystic)
	local mystic_slots_attrs = {}
	if  mystic_data then
		--mystic_data,_=UserDataManager.mystic_data:getMysticDataById(mystic_cfg.id)
		local mystic_lv_cfg=UserDataManager.mystic_data:getMysticLvCfg(mystic_data.id,mystic_data.lv)
		local attrs = mystic_lv_cfg.attrs or {}
		table.insertto(mystic_slots_attrs, attrs) -- 基础属性

		--先天秘籍另外增加侠客基础属性
		local star=mystic_data.star or 0
		local mystic_star_cfg=UserDataManager.mystic_data:getMysticStarConfigId(mystic_data.id,star)
		if table.nums(mystic_star_cfg.attrs)>0 then
			local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
			local len=#mystic_star_cfg.attrs
			for i = 1, len do
				local attr=mystic_star_cfg.attrs[i][1]
			    local hero_enumeration_item=hero_enumeration[attr]
				local attri_name=hero_enumeration_item.user_key
				local base_value=0
				local base_on_id=0
				if hero_data.attrs[attri_name]==nil then
					if  hero_enumeration[hero_enumeration_item.base_on_id]==nil then
						    Logger.log("sdssd")
					else
						attri_name=GameUtil:getAttrsKey(hero_enumeration_item.base_on_id)
						base_on_id=hero_enumeration_item.base_on_id
					end
				end
				base_value=hero_data.attrs[attri_name]
				local add_attri_Value=0
				if base_value~=nil then
					 add_attri_Value=mystic_star_cfg.attrs[i][2]
				end

				local added=false
				for ii, attr in pairs(mystic_slots_attrs) do
					if attr[1]==mystic_star_cfg.attrs[i][1] then
						mystic_slots_attrs[ii][2]=mystic_slots_attrs[ii][2]+mystic_star_cfg.attrs[i][2]
						added=true
					end
				end
				if added==false then
					mystic_slots_attrs[#mystic_slots_attrs+1]={[1]=mystic_star_cfg.attrs[i][1],[2]=mystic_star_cfg.attrs[i][2]}
				end
			end

		end
		--local channel_lv = 0
		--if mystic_data.owner and mystic_data.owner ~= "" then
		--
		--end
		--if hero_data == nil then
		--	hero_data = UserDataManager.hero_data:getHeroDataById(mystic_data.owner)
		--end
		--hero_data = hero_data or {}
		--local sig = hero_data.sig or {}
		--for k1,v1 in pairs(mystic_cfg.meridian or {}) do -- k1 是经脉类型 -- 1.冲、2：带、3：任、4：督
		--	local channel = sig[tostring(k1)] or {}
		--	channel_lv = channel and channel.lv or 0
		--	local activation = v1.activation
		--	for m = 1, #activation do
		--		if channel_lv >= activation[m] then
		--			table.insert(mystic_slots_attrs, v1.attr[m]) -- 经脉激活属性
		--		end
		--	end
		--
		--end
		
		-- 镶嵌属性
		--local inset_attrs = UserDataManager.mystic_data:getMysticInsetEfficientAttrs(mystic_data.id,inlay_mystic)
		--table.insertto(mystic_slots_attrs, inset_attrs)
	end
	return mystic_slots_attrs
end

-- 茶馆
function M:getTroopsAttrs(ids, h_data, h_cfg)
	local attrs = {}
	local tea_tab = ConfigManager:getCfgByName("teahouse")
	for k,v in pairs(ids or {}) do
		local tea_house_data = tea_tab[v]
		for kk,vv in pairs(tea_house_data.hero_ids) do
			if vv == h_cfg.id then
				attrs = tea_house_data.attr
			end
		end
	end
	return attrs
end

-- 装备	套装属性加成
function M:getEquipThronesAttrs(thrones)
	local attrs = {}
	local equip_throne_tab = ConfigManager:getCfgByName("equip_throne")
	for i,v in pairs(equip_throne_tab) do
		local have_thrones = thrones[tostring(i)] or {}
		if next(have_thrones) then
			local nums = #have_thrones or 0
			for kk,vv in ipairs(v.add_advance) do
				local add_attr = table.copy(vv) 
				add_attr[2] = add_attr[2]*nums
				table.insert(attrs, add_attr)
			end
		end
	end
	return attrs
end

-- 装备图鉴属性
function M:getEquipThronesUpgradeAttrs(thrones_upgrade,equips)
	local attrs = {}
	local quality = 0
	if next (thrones_upgrade) == nil then
		quality = 0
	else
		quality	= thrones_upgrade.evo 
	end
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local equip_throne_cfg = tag_tab[quality]
	if equip_throne_cfg then
		for id,value in pairs(equips) do   --遍历，有几件装备，增加几次
			for i,v in pairs(equip_throne_cfg.attr2) do
				table.insert(attrs, v)
			end
		end
	end
	return attrs
end


-- 羁绊
function M:getFettersAttrs(h_data, h_cfg)
	local attrs = {}
	local hero_fetter = {}
	local active_fetter = {}
	local friend_tab = ConfigManager:getCfgByName("hero_friend")
	for k,v in pairs(friend_tab) do
		if h_cfg.id == v.main_hero then
			table.insert(hero_fetter, k)
		end
	end
	for k,v in pairs(hero_fetter) do
		for kk,vv in pairs(self.active_links) do
			if v ==  tonumber(kk) then
				active_fetter[kk] = vv
			end
		end
	end
	for k,v in pairs(active_fetter) do
		local temp_cfg = friend_tab[tonumber(k)]
		local fetter_attr = temp_cfg.level_buff[v]
		if fetter_attr then
			table.insertto(attrs, fetter_attr)
		else
			Logger.logError(v, "hero_friend cfg key not found : ")
		end
	end
	return attrs
end

-- 帮会神炉
function M:getGuildTripodAttrs(tripods, data, cfg,real_guild_lv)
	local attrs = {}
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	if real_guild_lv ~= 0 then
		for k,v in pairs(tripods or {}) do
			local guild_tripod_item = guild_tripod[tonumber(k)] or {}
			local heroes_list = guild_tripod_item.heroes_list or {}
			local guild_lv = v
			local config = guild_tripod_item.config[guild_lv]
			while(config and config.condition_lv > real_guild_lv) do
				guild_lv = guild_lv - 1
				config = guild_tripod_item.config[guild_lv]
			end
			if config then
				for kk, vv in pairs(heroes_list) do
					if data.id == vv then
						table.insertto(attrs, config.attr)
					end
				end
			end
		end
	end
	return attrs
end

-- 图鉴升级职业属性加成
function M:getHeroRoleUpGradeAttrs(hero_roles, data, cfg)
	local attrs = {}
	local heroRoleCfg = ConfigManager:getCfgByName("herorole") or {}
	for role_type, v in pairs(hero_roles) do
		if tonumber(cfg.role_type) == tonumber(role_type) then
			local hero_role_item = heroRoleCfg[tonumber(role_type)] or {}
			for lv, oidList in pairs(v) do
				if hero_role_item[tonumber(lv)] then
					for i = 1, table.nums(oidList) do -- 同职业同等级有几个人就循环加几遍
						table.insertto(attrs, hero_role_item[tonumber(lv)].role_att)
					end
				end
			end
		end
	end
	return attrs
end


-- 前端本地计算英雄属性
function M:computeHeroAttrsClient(heroData)
	-- heroData = table.copy(heroData)
	local heroCfg = self.hero_data:getHeroConfigByCid(heroData.id)
	local lv = heroData.clv == 0 and heroData.lv or heroData.clv
	-- local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	-- local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	-- local rate = hero_upgrade[lv].rate
	-- local growth = hero_evolution[heroData.evo].growth
	-- local growth_rate = hero_evolution[heroData.evo].growth_rate
	-- local function computeAttrs(base_value)
	-- 	return base_value*((1+rate)*growth/100 + growth_rate/100)
	-- end 

	-- for k,v in pairs(heroData.attrs) do
	-- 	if heroCfg[k] and k ~= "critrate" then
	-- 		heroData.attrs[k] = computeAttrs(heroCfg[k])
	-- 	else
	-- 		heroData.attrs[k] = v
	-- 	end
	-- end
	-- return self:getHeroAttrsByData(heroData, heroCfg, true)
	return self:computCfgAttrs(heroCfg, lv, heroData.evo)
end

--[[
	获取英雄战力
]]
function M:computeHeroCombatById(card_id)
    local data, cfg = self.hero_data:getHeroDataById(card_id)
    return self:computeHeroCombat(data, cfg)
end

-- 前端本地计算英雄战力
-- 总战斗力 = [ 裸体属性提供的战斗力 ] * 神器系数A + 神器额外战力增量 + 公会神炉百分比属性提供的战斗力 + 公会神炉属性提供的战力 +  装备属性提供的战力 + 经脉属性提供的战斗力 + 经脉额外战力增量 + 秘籍参悟的属性提供的战斗力  +  秘籍参悟提供的百分比属性 提供的战斗力 + 秘籍图鉴属性提供的战斗力
function M:computeHeroCombat(data, cfg, own_flag, ohter_player_data, wea_solts, thrones_add, use_default_solts)
	--wea_solts：法宝列表 有此数据优先使用当前的法宝数据
	--thrones_add 神装加成
	use_default_solts = use_default_solts or 1 -- 是否使用默认的法宝数据，默认使用
	if cfg == nil then
		cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
	end
	if own_flag == nil then
		own_flag = true
	end
	-- 卡牌属性
	local base_attrs = table.copy(data.attrs) or {}

	local other_add_cfg_attrs = {}
	
	local tripods = self.tripods  --神炉
	local hero_roles = self.hero_roles -- 图鉴升级职业属性加成
	local troop_ids = self.troop_ids  --茶馆激活的羁绊
	local enable_ending = self.enable_ending  -- # rpg属性计算数据
	local mystic_effect_data = self.mystic_effect_data  -- 秘籍生效效果
	local mystic_slots = self.mystic_slots  -- 秘籍参悟
	local mystics_data = self.mystic_data:getMysticesData()  -- 秘籍
	local inlay_mystic =  self.mystic_data:getAllInlayMysticData() --秘籍镶嵌
	local titles_data = self.title_data:getTitlesData() -- 收集的称号
	local wear_title_id = self.user_data:getUserStatusDataByKey("title") -- 佩戴的称号
	local thrones = self.m_thrones ---- 装备套装
	local thrones_upgrade = self.m_thrones_upgrade
	local friendliness = self.m_friendliness
	local slots = self.m_slots
	local relics = self.m_relics
	local fates = self.fates
	local fates_building = self.m_fate_building
	local fenghua = self.m_fenghua_record_data
	local prestige_pieces = self.m_prestige_pieces
	local prestige_board = self.m_prestige_board
	local fate_master = self.m_fate_master
	local real_guild_lv = self.guild_lv
	local equips = data.equips or {}
	local awaken_system = self.m_awaken_system_data
	if own_flag == false then
		ohter_player_data = ohter_player_data or {}
		tripods = ohter_player_data.tripods or {}
		hero_roles = ohter_player_data.hero_roles or {} -- 图鉴升级职业属性加成
		troop_ids = ohter_player_data.troop_ids or {}
		enable_ending = ohter_player_data.enable_ending or {}
		mystic_effect_data = ohter_player_data.troop_ids or {}
		mystic_slots = ohter_player_data.mystic_slots or {}
		inlay_mystic = ohter_player_data.inlay_mystic or {}
		titles_data = ohter_player_data.titles or {}
		thrones = ohter_player_data.thrones or {}
		thrones_upgrade = ohter_player_data.thrones_upgrade or {}
		friendliness = ohter_player_data.friendliness or {}
		slots = ohter_player_data.relic or {}
		relics = ohter_player_data.self_relics or {}
		fates = ohter_player_data.fates or {}
		fate_master = ohter_player_data.fate_master or {}
		fates_building = ohter_player_data.fate_building or {}
		fenghua = ohter_player_data.fenghua_record or {}
		awaken_system = ohter_player_data.awaken or {}
		if ohter_player_data.prestige then
			prestige_pieces = ohter_player_data.prestige.piece_info or {}
			prestige_board = ohter_player_data.prestige.checkerboard_info or {}
		end
		if ohter_player_data.user then
			wear_title_id = ohter_player_data.user.title -- 佩戴的称号
			real_guild_lv = ohter_player_data.user.guild_lv or 0 --帮会id
		end
	end
	-- 帮会神炉
	local guild_tripod_attrs = self:getGuildTripodAttrs(tripods, data, cfg,real_guild_lv)
	self:appendCfgAttrs(guild_tripod_attrs, other_add_cfg_attrs)
	-- 图鉴升级职业属性加成
	local hero_roles_attrs = self:getHeroRoleUpGradeAttrs(hero_roles, data, cfg)
	self:appendCfgAttrs(hero_roles_attrs, other_add_cfg_attrs)
	-- 称号加成
	local titles_attrs = self:getTitlesAttrs(titles_data, wear_title_id, data)
	self:appendCfgAttrs(titles_attrs, other_add_cfg_attrs)
	
	-- 秘籍
	self:appendCfgAttrs(mystic_effect_data, other_add_cfg_attrs)
	
	-- 装备的秘籍加成
	--if data and data.mystics then
	--	for i, v in pairs(data.mystics) do
	--		v.owner = data.oid
	--	end
	--end
	local mystic_slots_attrs = self:getMysticsAttrs(data.mystics, mystics_data, data,inlay_mystic)
	self:appendCfgAttrs(mystic_slots_attrs, other_add_cfg_attrs)

	-- 职业等级加成
	local hero_role_attrs = self:getHeroRoleAttrs(data, cfg) 
	self:appendCfgAttrs(hero_role_attrs, other_add_cfg_attrs)
	
	-- 茶馆
	--local troops_attrs = self:getTroopsAttrs(troop_ids, data, cfg)
	--self:appendCfgAttrs(troops_attrs, other_add_cfg_attrs)
	
	-- 羁绊
	local fetter_attrs = self:getFettersAttrs(data, cfg)
	self:appendCfgAttrs(fetter_attrs, other_add_cfg_attrs)

	-- 装备套装
	local thrones_attrs = self:getEquipThronesAttrs(thrones)
	self:appendCfgAttrs(thrones_attrs, other_add_cfg_attrs)
	
	--装备图鉴属性
	local thrones_upgrade_attrs = self:getEquipThronesUpgradeAttrs(thrones_upgrade,equips)
	self:appendCfgAttrs(thrones_upgrade_attrs, other_add_cfg_attrs)
	
	-- 皮肤属性加成
	local skin_attrs = self:getSkinAttrs(data, cfg)
	self:appendCfgAttrs(skin_attrs, other_add_cfg_attrs)
	
	-- rpg属性加成
	--local rpg_attrs = self:getRPGAttrs(enable_ending, data, cfg)
	--self:appendCfgAttrs(rpg_attrs, other_add_cfg_attrs)
	
	--英雄好感
	local hero_friend_attrs = self:getHeroFriendAttrs(cfg,friendliness)
	self:appendCfgAttrs(hero_friend_attrs, other_add_cfg_attrs)

	--英雄法宝属性
	if wea_solts and next(wea_solts) ~= nil then
		local hero_wea_attrs = self:getHeroWeaAttrs(cfg, wea_solts,relics)
		self:appendCfgAttrs(hero_wea_attrs, other_add_cfg_attrs)
	else
		if use_default_solts == 1 then
			local hero_wea_attrs = self:getHeroWeaAttrs(cfg,slots,relics)
			self:appendCfgAttrs(hero_wea_attrs, other_add_cfg_attrs)			
		end
	end

	--天命化星属性
	local hero_destiny_star_attrs = self:getHeroDestinyStarAttrs(data,cfg,fates,fates_building)
	self:appendCfgAttrs(hero_destiny_star_attrs,other_add_cfg_attrs)

	--local fenghua_attrs = self:getFengHuaAttrs(fenghua)
	--self:appendCfgAttrs(fenghua_attrs,other_add_cfg_attrs)

	local prestige_attrs = self:getPrestigeAttrs(data,prestige_pieces,prestige_board)
	self:appendCfgAttrs(prestige_attrs, other_add_cfg_attrs)

	--符篆系统属性
	local seal_character_attrs = self:getSealCharaterAttrs(data.seal_character)
	self:appendCfgAttrs(seal_character_attrs, other_add_cfg_attrs)

	local awaken_system_attrs = self:getAwakenSystemAttrs(data,awaken_system)
	self:appendCfgAttrs(awaken_system_attrs, add_cfg_attrs)
	
    -- 装备属性
	for k,v in pairs(equips) do
		if _G.next(v) then
			local equip_cfg = self.equip_data:getEquipConfigByCid(v.id)
			local equip_attrs = self:getEquipAttrsByData(v, equip_cfg, cfg.race, thrones_add, own_flag, ohter_player_data)
			self:appendCfgAttrs(equip_attrs, other_add_cfg_attrs)
			if equip_cfg.quality >= 12 then
				local god_eqp_affix = self:getIntenEquipLvUp(v, data)
				self:appendCfgAttrs(god_eqp_affix, other_add_cfg_attrs)
			end
		end
	end

	-- 神器
	local artifact_attrs, artifact_gs_coef, artifact_gs_add = self:getArtifactAttrs(data, cfg)
	-- 专属装备[经脉]
	local sig_attrs,sig_gs_add = self:getEquipHeroesAttrs(data, cfg)
	self:appendCfgAttrs(sig_attrs, other_add_cfg_attrs)
	
	local other_all_attrs = self:getAllHeroAttrs(other_add_cfg_attrs, base_attrs,true)

    local master_add_hp, master_add_atk, master_add_def = self:getFateMasterAddAttr(data, cfg,fate_master)
    other_all_attrs.hp = other_all_attrs.hp + master_add_hp
    other_all_attrs.atk = other_all_attrs.atk + master_add_atk
    other_all_attrs.def = other_all_attrs.def + master_add_def
	
	local combat = self:computeAttrsCombat(other_all_attrs, 1)
	combat = combat + artifact_gs_add
	return math.ceil(combat)
end

--装备词缀战力需要额外计算
function M:getEquipAffixCombat(equip_data, hero_id)
	local attrs = {}
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local sum_score = 0
	if equip_data and equip_data.affix then
		for k,v in pairs(equip_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg == nil then
				break
			end
			if affix_cfg.unique == 0 then
				--词缀评分=词缀评分*词缀当前数值/词缀affix1_tier11的第二个值
				for i,o in pairs(v.value) do
					local attr_value = o[3] or 0
					if affix_cfg.effect[i] then
						local effect = affix_cfg.effect[i].random_value[11][2]
						local affix1_score = affix_cfg.effect[i].score  or 1000
						local aff_score = affix1_score * attr_value/effect
						sum_score = sum_score + aff_score
					end
				end
			else
				if hero_id then
				 	if affix_cfg.unique_hero  then
						if affix_cfg.unique_hero == hero_id or affix_cfg.unique_hero == 0 then 
							for i,o in pairs(v.value) do
								local attr_value = o[3] or 0
								if affix_cfg.effect[i] then
									local effect = affix_cfg.effect[i].random_value[11][2]
									local affix_score = affix_cfg.effect[i].score  or 1000
									sum_score = sum_score + affix_score
								end
							end
						end 
					end
				else
					if affix_cfg.unique_hero then
						for i,o in pairs(v.value) do
							local attr_value = o[3] or 0
							if affix_cfg.effect[i] then
								local effect = affix_cfg.effect[i].random_value[11][2]
								local affix_score = affix_cfg.effect[i].score  or 1000
								sum_score = sum_score + affix_score
							end
						end
					end
				end
			end
		end
	end
	return sum_score
end


function M:computeAttrsCombat(attrs, coef)
	coef = coef or 1
	local attrs_keys = GlobalConfig.ATTRS_TAB 
	local combat = 0
	for i,v in pairs(attrs_keys) do
		local attr = attrs[v]
		if attr then
			combat = combat + ConfigManager:getBattleCommonValueById(i,0,false) * attr * coef
		end
	end
	return combat
end

-- 前端本地计算装备战力
function M:computeEquipCombat(attrs)
	local combat = self:computeAttrsCombat(attrs)
	return math.ceil(combat)
end

-- 前端本地计算符篆战力
function M:computeTalisCombat(attrs)
	local combat = self:computeAttrsCombat(attrs)
	return math.ceil(combat)
end

--计算stagebattle_id
function M:computStageBattleCombat(stage_battle_id, hp_coef, dps_coef, def_coef, formation_index)
	hp_coef = hp_coef or 100
	dps_coef = dps_coef or 100
	def_coef = def_coef or 100
	local e_l = {}
	local bs_display = 1
	local sub_combate = 0
    --通过关卡表读取敌人
	--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
	local battle_data = ConfigManager:getCfgStageBattle(stage_battle_id)--stage_battle_tab[stage_battle_id]
	--if battle_data == nil and formation_index then
	--	local stage_battle_tab2 = ConfigManager:getCfgByName("stage_battle" .. (formation_index == 1 and "" or formation_index))
	--	battle_data = stage_battle_tab2[stage_battle_id]
	--	if battle_data == nil then
	--		Logger.logError(stage_battle_id, "computStageBattleCombat stage_battle not found, id = ")
	--		return 0
	--	end
	--end
	local monsters_attrs = battle_data["monster_attrs"] or {}
	local boss_attrs = battle_data["boss_attrs"] or {}
	local boss_position = battle_data["boss_position"]
	if battle_data then
		bs_display = battle_data.bs_display or 1
		local monsters = battle_data["monster"]
		for k, v in pairs(monsters) do
			if v.id ~= "null" and v.id ~= nil and v.id > 0 then
				e_l[k] = v
			else
				e_l[k] = "null"
			end
		end
	end
	local master_hp_coef = monsters_attrs["hp_coef"] or 100
	local boss_hp_coef = boss_attrs["hp_coef"] or 100
	local master_dps_coef = monsters_attrs["dps"] or 100
	local boss_dps_coef = boss_attrs["dps"] or 100
	for k, v in pairs(e_l) do
		if v ~= "null" then
			if k == boss_position then
				local a_c = self:calculateCombat(v, master_hp_coef*boss_hp_coef*hp_coef/10000, master_dps_coef*boss_dps_coef*dps_coef/10000)
				sub_combate = sub_combate + a_c
			else
				local a_c = self:calculateCombat(v, master_hp_coef*hp_coef/100, master_dps_coef*dps_coef/100)
				sub_combate = sub_combate + a_c
			end
		end
	end
	return sub_combate*bs_display
end
-- 奇门遁甲敌方战斗力+墙计算
function M:calculateGveCombat(heros, hp_coef, dps_coef)
	local sub_combate = 0
	for k, v in pairs(heros) do
		if v ~= "null" then
			local a_c = self:calculateCombat(v, hp_coef, dps_coef)
			sub_combate = sub_combate + a_c
		end
	end
	return sub_combate
end

function M:calculateCombat(data, hp_coef, dps)
    local enemy_data = self.hero_data:getHeroConfigByCid(data.id) --英雄配置信息
    local new_attrs = self:computCfgAttrs(enemy_data, data.lv, data.evo, hp_coef, dps)
    local all_attr = {}
    if #data.equips > 0 then
        for i = 1, 5 do
            local id = data.equips[(i * 2) - 1]
            local iv = data.equips[(i * 2)]
            local c_attr = self:computEnemyEqu(id, iv)
            all_attr = self:appendCfgAttrs2(c_attr, all_attr)
        end
    end
    all_attr = self:appendCfgAttrs2(new_attrs, all_attr)
    local enemy_m = self:computeAttrsCombat(all_attr)
    enemy_m = math.ceil(enemy_m)
    return enemy_m
end

function M:appendCfgAttrs2(cfg_atttrs, all_attrs)
    all_attrs = all_attrs or {}
    for k, v in pairs(cfg_atttrs) do
        all_attrs[k] = (all_attrs[k] or 0) + v
    end
    return all_attrs
end

--前端计算配置敌人属性
function M:computCfgAttrs(hero_cfg, lv, evo, hp_coef, dps_coef, def_coef)
	lv = lv or 1
	if lv == "null" then
		lv = 1
	end
	hp_coef = (hp_coef or 100)/100
	dps_coef = (dps_coef or 100)/100
	--def_coef = def_coef or hero_cfg.def_coef
	local attrs = {}

	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	-- 暴击 906 不成长
	for k, v in pairs({906}) do
		local hero_enumeration_item = hero_enumeration[v]
		if hero_enumeration_item then
			local attr_name = hero_enumeration_item.user_key
			attrs[attr_name] = hero_cfg[attr_name .. "_base"]
		end
	end
	
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local hero_evolution = ConfigManager:getCfgByName("hero_quality")
	local hero_rank = ConfigManager:getCfgByName("hero_rank")
	local level_config = hero_upgrade[lv] or {}
	local quality_config = hero_evolution[hero_cfg.id] or {}
	local quality_config2 =  quality_config[evo] or {}
	local hero_rank_item = hero_rank[hero_cfg.id] or {}
	local rank_config = hero_rank_item[level_config.rank or -1] or {}
	-- 基数成长属性 攻击、生命、防御
	for k, v in pairs({901, 902, 903}) do
		local hero_enumeration_item = hero_enumeration[v]
		if hero_enumeration_item then
			local attr_name = hero_enumeration_item.user_key

			local rank_add = rank_config[attr_name .. "_add"] or 0
			local unit_base = hero_cfg[attr_name .. "_base"] or 0
			local unit_coef = hero_cfg[attr_name .. "_coef"] or 1
			local unit_level = level_config[attr_name .. "_coef"] or 0
			local q_coef = quality_config2[attr_name .. "_coef"] or 1
			local q_add = quality_config2[attr_name .. "_add"] or 0
			
			local attr_value = (rank_add + unit_base + unit_coef * unit_level) * q_coef + q_add
            attrs[attr_name] = attr_value
		end
	end
	attrs["hp"] = attrs["hp"] * hp_coef --生命系数
	attrs["atk"] = attrs["atk"] * dps_coef --攻击力系数
	--attrs["def"] = attrs["def"] * def_coef --防御系数
	return attrs
end

--前端计算敌人装备属性
function M:computEnemyEqu(eqp_id, equip_lv)
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	local eqp_cfg = self.equip_data:getEquipConfigByCid(tonumber(eqp_id))
	local new_attrs = {}
	if eqp_cfg then
		local attrs = eqp_cfg.attr
		local lv_growth_rate = eqp_cfg.lv_growth_rate or 0
		local race = eqp_cfg.race or 0
		local race_value = ConfigManager:getCommonValueById(45, 0)
		local race_rate = race > 0 and race_value or 0
		for attr_k,attr_v in pairs(attrs) do
			local attr_index = attr_v[1] or 0
			local hero_enumeration_item = hero_enumeration[attr_index]
			local attr_name = hero_enumeration_item.user_key
			local attr_value = attr_v[2] or 0
			local value = attr_value * (1 + lv_growth_rate*equip_lv/100 + race_rate)
            new_attrs[attr_name] = value
		end
	end
	return new_attrs
end

function M:setQuickIdleTimes(data)
	self.idle_info.quick_idle_times = data.quick_idle_times
	self.idle_info.qi_free_times = data.qi_free_times
	self.idle_info.qi_pay_times = data.qi_pay_times
end

function M:getGuide()
	return self.guide
end

function M:addQuest(show_data, quests, quest_cfg, target_types)
	for k,v in pairs(quests) do
		local key = tonumber(k)
		local cfg = quest_cfg[key]
		if cfg and target_types[cfg.target_type] then
			if v.show_flag then
				v.show_flag = false
				local value = v.value or 0
				local status = v.status or 0 -- 2为领过奖励 - 如果没有领取status没有
				local target_value = cfg.target_value
				if status ~= 2 then
					if value >= target_value then -- 完成可领取
						status = 2 -- 老的状态
					end
					local lock_flag, lock_text = ConfigManager:getQuestLockFlag(cfg.stage_id)
					if cfg.target_type == 1 then -- 关卡单独处理
						local cur_stage = self:getCurStage()
						if cur_stage > target_value then
							lock_flag = true
						end
					end
					if not lock_flag then
						local real_cur_progress, real_target_progress = self:getQuestProgress(cfg, value)
						table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = math.min(value, real_cur_progress), target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text})
					end
				end
			end
		end
	end
end

-- 关卡进度单独处理
function M:getQuestProgress(quest_cfg, cur_progress)
	local real_cur_progress = cur_progress or 0
	local real_target_progress = quest_cfg.target_value or 999
	if quest_cfg.target_type == 1 then
		local stage = ConfigManager:getCfgByName("stage")
		local cur_stage_cfg = stage[real_cur_progress] or {}
		local target_stage_cfg = stage[real_target_progress] or {}
		real_cur_progress = cur_stage_cfg.num or 0
		real_target_progress = target_stage_cfg.num or 999
	end
	return real_cur_progress, real_target_progress
end

function M:getBattleOverQuestsByTargetType(target_types)
	local show_data = {}
	local quest_time = ConfigManager:getCfgByName("quest_time")
	local daily_quests = self.quest.daily_quests or {}
	local weekly_quests = self.quest.weekly_quests or {}
	self:addQuest(show_data, daily_quests, quest_time, target_types)
	self:addQuest(show_data, weekly_quests, quest_time, target_types)

	local quest_main = ConfigManager:getCfgByName("quest_main")
	local main_quests = self.quest.main_quests or {}
	self:addQuest(show_data, main_quests, quest_main, target_types)
	
	table.sort(show_data, function(data1, data2)
		return data1.status > data2.status
	end)
	return show_data
end

function M:getIsFirstName()
	return self.is_first_name
end

function M:setIsFirstName(value)
	self.is_first_name = value or 0
end

function M:getRaceFloorByRace(race)
	local tower_floor = self:getTowerFloor()
	local race = race or 0
	if race > 0 then
		tower_floor = self.race_floor[tostring(race)] or 0
	end
	return tower_floor
end

function M:setTempData(key, data)
	self.temp_data[key] = data
end

function M:getTempData(key)
	return self.temp_data[key]
end

-- 初始化阵法数据
function M:initDeploymentData()
	local cur_stage = self:getCurStage()
	local deployment = ConfigManager:getCfgByName("deployment")
	for k, v in pairs(deployment) do
		table.insert(self.deployment_data, {id = k, cfg = v, unlock_flag = cur_stage >= v.unlock})
	end
	table.sort(self.deployment_data, function(data1, data2)
		return data1.id < data2.id
	end)
end

function M:updateDeploymentData()
	local cur_stage = self:getCurStage()
	for i, v in ipairs(self.deployment_data) do
		if not v.unlock_flag and cur_stage >= v.cfg.unlock then
			v.unlock_flag = true
			v.is_new = true
		end
	end
end

function M:getNetDeploymentFlag()
	local new_flag = false
	local data = {}
	for i, v in ipairs(self.deployment_data) do
		if v.is_new then
			new_flag = true
			break
		end
	end
	return new_flag
end

--[[--
	红点数据
]]
function M:getRedDotByKey(key)
	local red_dot = self.red_dot or {}
	local dot_data = red_dot[key]
	if dot_data then
		if dot_data.start_ts and dot_data.start_ts  < self:getServerTime() then
			dot_data.status = 1
		elseif dot_data.expire_ts and dot_data.expire_ts < self:getServerTime() then
			dot_data.status = 0
		end
		return dot_data.status
	else	
		return 0
	end
end

function M:getRedDotData()
	return self.red_dot or {}
end

function M:updateBlessNeedChange(times)
	self.m_bless_look_times = times
end

function M:getBlessNeedChange(times)
	return self.m_bless_look_times
end
-- 删除红点数据
function M:removeRedDotByKey(key)
	if self.red_dot[key] ~= nil then
		self.red_dot[key] = nil
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "remove_red_dot", data = {key = key}})
	end
end

function M:getMapEventData()
	return self.map_event or {}
end

function M:getLimitMapEventData()
	return self.ongoing_teams or {}
end

function M:getLimitMapEventMinEndTS()
	local min_end_ts = nil
	local event_data = nil
	local data = self:getLimitMapEventData()
	local server_time = self:getServerTime()
	for k,v in pairs(data) do
		local diff_time = v.end_ts - server_time
		if diff_time > 0 then
			if min_end_ts == nil then
				min_end_ts = v.end_ts
				event_data = v
			else
				if v.end_ts < min_end_ts then
					min_end_ts = v.end_ts
					event_data = v
				end
			end
		end
	end
	return min_end_ts or 0 , event_data
end

-- 奇遇事件
function M:getEncounterMapEventData()
	return self.e_ongoing_teams or {}
end

-- 完成的奇遇事件group
function M:getCompleteEncounterMapEventData()
	return self.e_complete_teams or {}
end

-- 通过过team_id 获取完成的奇遇事件
function M:getCompleteEncounterMapEventDataByTeamId(team_id)
	local data = self:getCompleteEncounterMapEventData()
	for k, v in pairs(data) do
		if v.team_id == team_id then
			return v
		end
	end
	return nil
end

--是否能触发奇遇
function M:isCanTriggerEncounter()
	local ts = self.e_next_trigger_ts or 0
	local count = self.e_today_event_count or 0
	local max_count = ConfigManager:getCommonValueById(253, 0)
	local server_time = self:getServerTime()
	if server_time > ts and count < max_count then
		return true
	end
	return false
end

function M:getOngoingTaskData()
	return self.ongoing_task or {}
end

function M:setOngoingTaskData(data)
	self.ongoing_task = data or {} -- 大地图进行中的支线任务
end

function M:getTasksData()
	return self.tasks or {} -- 大地图进行中的所有任务
end

function M:setTasksData(data)
	self.tasks = data or {} -- 大地图进行中的所有任务
end

function M:getRegionalTaskDoneData()
	return self.regional_task_done or {}
end

function M:setRegionalTaskDoneData(data)
	self.regional_task_done = data or {}
end

function M:setArticlesData(data)
	self.articles = data or {}
end

function M:getArticlesData()
	 return self.articles or {}
end

function M:setCloseOptionData(data)
	self.close_option = data or {}
end

function M:getCloseOptionData()
	return self.close_option or {}
end

function M:setDelegationData(data)
	self.delegation_ids = data or {}
end

function M:getDelegationData(data)
	return self.delegation_ids or {}
end

function M:setSceneLineData(data)
	self.scene_lines = data or {}
end

function M:getSceneLineData()
	return self.scene_lines or {}
end

function M:getTasksActivityData()
	return self.tasks_activity or {} -- 三侠五义中的所有任务
end

function M:setTasksActivityData(data)
	self.tasks_activity = data or {} -- 三侠五义中的所有任务
end

function M:getRegionalTaskDoneActivityData()
	return self.regional_task_done_activity or {}
end

function M:setRegionalTaskDoneActivityData(data)
	self.regional_task_done_activity = data or {}
end

function M:setArticlesActivityData(data)
	self.articles_activity = data or {}
end

function M:getArticlesActivityData()
	return self.articles_activity or {}
end

function M:setCloseOptionActivityData(data)
	self.close_option_activity = data or {}
end

function M:getCloseOptionActivityData()
	return self.close_option_activity or {}
end

function M:setDelegationActivityData(data)
	self.delegation_ids_activity = data or {}
end

function M:getDelegationActivityData()
	return self.delegation_ids_activity or {}
end

function M:setSceneLineActivityData(data)
	self.scene_lines_activity = data or {}
end

function M:getSceneLineActivityData()
	return self.scene_lines_activity or {}
end

function M:setNotice(data)
	self.notice = data or {}
end

function M:getNotice()
	return self.notice
end

function M:getCfgHero()
	return self.cfg_heros_data or {}
end

function M:getHeroMaxEvo(id)
	if self.cfg_heros_data[tostring(id)] then
		return self.cfg_heros_data[tostring(id)]
	end	
	return nil
end

function M:getHeroHistoryMaxEvo()
	local max = 0
	for k,v in pairs(self.cfg_heros_data) do
		if v.max_evo and v.max_evo > max then
			local cfg = self.hero_data:getHeroConfigByCid(tonumber(k))
			if cfg and cfg.evo >= 5 then
				max = v.max_evo
			end
		end
	end
	return max
end

-- 英雄配置ID取经脉数据
function M:getSigDataByHeroId(id)
	return self.sig[tostring(id)]
end

-- 更新经脉数据
function M:mergeSigData(data)
	table.merge(self.sig, data or {})
end

function M:getQuestSpecialDataByType(quest_type)
	local quest_special = self.quest_special or {}
	return quest_special[tostring(quest_type)] or {}
end


function M:getQuestJuBaoDataByType(quest_type)
	local richman = self.richman or {}
	return richman[tostring(quest_type)] or {}
end


function M:setRichMan( data )
	self.richman = data;
end

function M:getChapterQuestSpecialData(quest_type, param)
	local quest_type = quest_type or 0
	local show_data = {}
	local quest_special = nil
	local quest_special_data = nil
	if quest_type == 104 then
		quest_special = ConfigManager:getCfgByName("credit_dice")
		quest_special_data = self:getQuestJuBaoDataByType(quest_type)
	else
		quest_special = ConfigManager:getCfgByName("quest_special")
		quest_special_data = self:getQuestSpecialDataByType(quest_type)
	end
	local quest_special_items = quest_special[quest_type] or {}
	if param ~= nil then
		local quest_all = {}
		quest_all.max_num = -1
		quest_all.items = {}
		for i, v in pairs(quest_special_items) do
			if v.num ~= nil then
				if quest_all.items[v.num] == nil then
					quest_all.items[v.num] = {}
				end
				quest_all.items[v.num][i] = v
				if v.num > quest_all.max_num then
					quest_all.max_num = v.num;
				end
			end
		end
		local items = quest_all.items[param]
		if items ~= nil then
			quest_special_items = items
		else
			if quest_all.max_num >= 0 then
				quest_special_items = quest_all.items[quest_all.max_num]
			end
		end
	end
	local cur_stage = quest_special_data.value or 0
	local id = quest_special_data.id or 0 -- 已领取的连续任务id最大的那个
	local done = quest_special_data.done or {} -- id后已领取的任务id
	for key,cfg in pairs(quest_special_items) do
		local value = cur_stage or 0
		local status = 0
		local target_value = cfg.target_value
		if key <= id then -- 已领取
			status = -1
		else
			local idx = table.indexof(done, key)
			if idx then -- 已领取
				status = -1
			else
				if value >= target_value then -- 完成可领取
					status = 2
				end
			end
		end
		local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
		table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = false})
	end
	GameUtil:taskDataSort(show_data)
	return show_data
end

function M:getActivesByOpenId(id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in ipairs(self.m_actives or {}) do
		local m_a_cfg = active_tab[v.id]
		if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
			return true
		end
	end	
	return false
end

--获得开启的多期活动
function M:getMultActivesByOpenId(id)
	local active_tab = ConfigManager:getCfgByName("active")
	local active_datas = {}
	for i,v in ipairs(self.m_actives or {}) do
		if  v.open_id == id and v.open_status > 0 then
			table.insert(active_datas, v)
		end
	end	
	return active_datas
end

function M:getActivesDataByOpenId(id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in ipairs(self.m_actives or {}) do
		local m_a_cfg = active_tab[v.id]
		if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
			return v
		end
	end	
	return nil
end

function M:getActivesDataAndCfgByOpenId(id)
	local active_tab = ConfigManager:getCfgByName("active")
	local data = nil
	for i,v in ipairs(self.m_actives or {}) do
		local m_a_cfg = active_tab[v.id]
		if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
			data = v
		end
	end
	if data == nil then return nil end
	for k,v in pairs(active_tab) do
		if v.open_id == id and v.version == data.version then
			data.cfg = active_tab[id]
		end
	end
	return data
end

function M:getActivesRechargeByOpenId(id)
	local active_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in ipairs(self.m_active_recharge or {}) do
		local m_a_cfg = active_tab[v.id]
		if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
			return true
		end
	end	
	return false
end

function M:getActivesRechargeDataByOpenId(id, act_id)
	local active_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in ipairs(self.m_active_recharge or {}) do
		local m_a_cfg = active_tab[v.id]
		if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
			if act_id then
				if act_id == v.id then
					return v
				else
					return nil
				end
			else
				return v
			end
		end
	end
	return nil
end

function M:getAvatars()
	return self.avatars or {}
end

function M:getFrames()
	return self.frames or {}
end

function M:getHeroSkins()
	return self.hero_skins or {}
end

function M:existHeroSkin(hero_skin)
	return self.hero_skins[tostring(hero_skin)] ~= nil
end

function M:getSubscribe()
	return self.m_subscribe or {}
end

-- 抽卡特权判断
function M:hasGachaSubscribe()
	local flag = false
	if self.m_subscribe.gacha_auto_etime then
		local server_time = self:getServerTime()
		if self.m_subscribe.gacha_auto_etime > 0 and server_time < self.m_subscribe.gacha_auto_etime then
			flag = true
		elseif self.m_subscribe.gacha_auto_etime == -1 then
			flag = true
		end
	end
	return flag
end

-- 快速挂机特权判断
function M:hasHangRewardSubscribe()
	local flag = false
	if self.m_subscribe.idle_auto_etime then
		local server_time = self:getServerTime()
		if self.m_subscribe.idle_auto_etime > 0 and server_time < self.m_subscribe.idle_auto_etime then
			flag = true
		elseif self.m_subscribe.idle_auto_etime == -1 then
			flag = true
		end
	end
	return flag
end

-- 悬赏特权判断
function M:hasRewardSubscribe()
	local flag = false
	if self.m_subscribe.bounty_auto_etime then
		local server_time = self:getServerTime()
		if self.m_subscribe.bounty_auto_etime > 0 and server_time < self.m_subscribe.bounty_auto_etime then
			flag = true
		elseif self.m_subscribe.bounty_auto_etime == -1 then
			flag = true
		end
	end
	return flag
end

--特权配置领取记录
function M:subRewardReceived(index)
	for k,v in pairs(self.m_sub_received) do
		if v == index then
			return true
		end
	end
	return false
end

-- 帮会战队伍
function M:setGvgTeams(data)
	self.m_gvg_teams = data or {} 
end

-- 帮会战队伍
function M:setGuildHighWarTeams(data)
	self.m_ghw_teams = data or {}
end

function M:getGuildHighWarTeamsByKey()
	local team = self.m_ghw_teams
	if team == nil then--补齐空缺的缺省值
		team = {}
	end
	local ghw_team = {}
	local relic = {}
	for i = 1, 5 do
		local key = tostring(i)
		if self.m_ghw_teams[key] == nil then
			ghw_team[i] = {"","","","",""}
			relic[i] = {}
		else
			ghw_team[i] = self.m_ghw_teams[key].team
			relic[i] = self.m_ghw_teams[key].relic
		end
	end
	return ghw_team, relic
end

-- def_teams 防守队伍
-- atk_teams 攻击队伍
function M:getGvgTeamsByKey(key)
	local team = self.m_gvg_teams[key]
	if team == nil then--补齐空缺的缺省值
		team = {}
	end
	for i = 1, 3 do
		local key = tostring(i)
		if team[key] == nil then
			team[key] = {deployment = 1, team = {"","","","",""}}
		end
	end
	if key == "atk_teams" then
		local first_team = team["1"].team or {}
		local team_is_null = true
		for k,v in pairs(first_team) do
			if v ~= "" then
				team_is_null = false
			end
		end
		if team_is_null then
			team["1"].team = table.copy(self.hero_data:getTeamByKey("stage"))
		end
	end
	return team
end

function M:setGvgTeamSetReward(data)
	self.m_gvg_team_set_reward = data
	EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "gvg_team_set_reward"})
end

function M:resetGvgTeamSetReward()
	self.m_gvg_team_set_reward = {}
end

function M:getGvgTeamSetReward()
	return self.m_gvg_team_set_reward
end

function M:setGvgTeamSetRewardFlag(status)
	self.m_gvg_team_set_reward_flag = status
end

function M:getGvgTeamSetRewardFlag()
	return self.m_gvg_team_set_reward_flag
end

-- 获取充值金额
function M:getChargeSum()
	local charge_sum = self.charge_sum or 0
	return charge_sum
end

function M:getMultWeaByKey(key)
	if self.m_mult_relics[key] then
		return self.m_mult_relics[key]
	else
		self.m_mult_relics[key] = {self.m_slots} 
	end
	return self.m_mult_relics[key]
end

--多阵容阵法（新）
function M:getMultNormalArray(key)
	if self.m_mult_normal_array[key] then
		return self.m_mult_normal_array[key]
	end
	return {}
end

function M:getNormalArray(key)
	if self.m_normal_array[key] then
		return self.m_normal_array[key]
	end
	return 0
end

--多阵容宠物
function M:getMultPets(key)
	if self.m_mult_battle_pet[key] then
		return self.m_mult_battle_pet[key]
	end
	return {}
end

--单阵容宠物
function M:getPet(key)
	if self.m_battle_pet then
		return self.m_battle_pet
	end
	return 0
end

--风华录
function M:getFenghuaRecordData()
	if self.m_fenghua_record_data then
		return self.m_fenghua_record_data
	end
	return {}
end

--威望 侠客界面
function M:getHeroPrestigeData()
	if self.m_hero_prestige_data then
		return self.m_hero_prestige_data
	end
	return {}
end


function M:getPrestigeBoard()
	if self.m_prestige_board then
		return self.m_prestige_board
	end
	return {}
end

-- 获取威望系统数据
function M:getPrestigePieces()
	if self.m_prestige_pieces then
		return self.m_prestige_pieces
	end
	return {}
end

--战力压制全局数据
function M:getGlobalCombatRepressData()
	if self.m_global_repress_data then
		return self.m_global_repress_data
	end
	return {}
end

--羽化
function M:getmAwakenSystemData()
	if self.m_awaken_system_data then
		return self.m_awaken_system_data
	end
	return {}
end

--羽化
function M:getmRedPacketData()
	if self.red_packet_data then
		return self.red_packet_data
	end
	return {}
end

-- 获取当前赛季
function M:getCurSeason()
	local cur_season = 0
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.season then
		cur_season = self.m_season_data.season
	end
	return cur_season
end

-- 获取当前赛季的第几天
function M:getCurSeasonDay()
	local day = 0
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.start_time then
		local time_now = self:getServerTime() or 0
		local time_season_start = self.m_season_data.start_time
		local time_delta = time_now - time_season_start
		day = math.floor(time_delta / (60 * 60 * 24)) + 1
	end
	return day
end

-- 获取当前赛季  0 可领取 1 不可领取
function M:setSeasonPreviewStatus(status)
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.season_recv then
		self.m_season_data.season_recv = status
	end
end

-- 获取当前赛季开始时间
function M:getCurSeasonStartTime()
	local start_time = 0
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.start_time then
		start_time = self.m_season_data.start_time
	end
	return start_time
end

-- 获取当前赛季结束时间
function M:getCurSeasonEndTime()
	local end_time = 0
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.end_time then
		end_time = self.m_season_data.end_time
	end
	return end_time
end

-- 获取当前赛季休赛期
function M:getCurOffSeasonDays()
	local end_time = 0
	if self.m_season_data and next(self.m_season_data) and self.m_season_data.off_season_days then
		return self.m_season_data.off_season_days ~= 0 --true 休赛期
	end
	return false
end

--获取赛季预告显示的赛季
function M:getNextSeason()
	return self.m_season_data.next_season_id
end

-- 检查动态表情包是否可用
function M:checkEmojiCanUse(key)
	local flag = false
	local sever_time = self:getServerTime() -- 获取当前服务器时间
	if self.m_emoji[key] then
		if self.m_emoji[key] == 0 then
			flag = true
		elseif self.m_emoji[key] < sever_time then
			flag = true
		end
	end
	return flag
end

-- 是否在黑名单中
function M:isInBlackList(uid)
	if self.m_black_map and next(self.m_black_map) and self.m_black_map[tostring(uid)] then
		return true
	end
	return false
end

--获取天命化星信息
function M:getFatesInfo()
	return self.fates or {}
end

--获取英雄是否天命
function M:getHeroIsFates(hero_oid,fates)
	if fates then
		for i, v in pairs(fates) do
			for heros_i, heros_v in pairs(v.heros) do
				if hero_oid == heros_v then
					return true
				end
			end
		end
	else
		for i, v in pairs(self.fates) do
			for heros_i, heros_v in pairs(v.heros) do
				if hero_oid == heros_v then
					return true
				end
			end
		end
	end
	return false
end

-- 通过品质获取英雄数量
function M:getHeroCountByQuality(quality)
	local hero_data_list = UserDataManager.hero_data:getHerosData()
	local num = 0
	for i, v in pairs(hero_data_list) do
		if v.evo == quality then
			num = num + 1
		end
	end
	return num
end

--获取天命的英雄个数
function M:getHeroFatesNum()
	local num = 0
	for i, v in pairs(self.fates) do
		for heros_i, heros_v in pairs(v.heros) do
			num = num + 1
		end
	end
	return num
end

--获取开启活动信息
function M:getOpenActiveData(open_id)
	for i, v in pairs(self.m_actives) do
		if v.open_id == open_id then
			return v
		end
	end
	return nil
end

--获取开启活动的版本信息
function M:getOpenActiveVersion(open_id)
	for i, v in pairs(self.m_actives) do
		if v.open_id == open_id then
			return v.version
		end
	end
	return 0
end

--根据hero oid获取星辰
function M:getFatesStarId(hero_oid, fates)
	local fates = fates or self.fates or {}
	for i, v in pairs(fates) do
		for hero_i, hero_v in pairs(v.heros) do
			if hero_v == hero_oid then
				return i,v.heros
			end
		end
	end
	return 0,{}
end

--返回英雄好感度信息
function M:getFriendliness()
	return self.m_friendliness or {}
end

-- 设置随机江湖属性
function M:setNewMapAttrsData(data)
	self.new_map_attrs = data or {}
end
-- 获取随机江湖属性
function M:getNewMapAttrsData()
	return self.new_map_attrs or {}
end
-- 设置完成的拼图组id
function M:setNewMapPuzzleGroupsData(data)
	self.new_map_puzzle_groups = data or {}
end
-- 获取完成的拼图组id
function M:getNewMapPuzzleGroupsData()
	return self.new_map_puzzle_groups or {}
end
-- 设置随机江湖完成的拼图id
function M:setNewMapPuzzleIdsData(data)
	self.new_map_puzzle_ids = data or {}
end
-- 获取随机江湖完成的拼图id
function M:getNewMapPuzzleIdsData()
	return self.new_map_puzzle_ids or {}
end
-- 设置随机江湖时辰
function M:setNewMapHourData(data)
	self.new_map_hour = data or 0
end
-- 获取随机江湖时辰
function M:getNewMapHourData()
	return self.new_map_hour or 0
end
-- 设置随机江湖天气
function M:setNewMapWeatherData(data)
	self.new_map_weather = data or 0
end
-- 获取随机江湖天气
function M:getNewMapWeatherData()
	return self.new_map_weather or 0
end

function M:getNewMapOngoingTaskData()
	return self.new_map_ongoing_task or {}
end

function M:setNewMapOngoingTaskData(data)
	self.new_map_ongoing_task = data or {} -- 大地图进行中的支线任务
end

function M:getNewMapTasksData()
	return self.new_map_tasks or {} -- 大地图进行中的所有任务
end

function M:setNewMapTasksData(data)
	self.new_map_tasks = data or {} -- 大地图进行中的所有任务
end

function M:getNewMapRegionalTaskDoneData()
	return self.new_map_regional_task_done or {}
end

function M:setNewMapRegionalTaskDoneData(data)
	self.new_map_regional_task_done = data or {}
end

function M:setNewMapArticlesData(data)
	self.new_map_articles = data or {}
end

function M:getNewMapArticlesData()
	return self.new_map_articles or {}
end

function M:setNewMapCloseOptionData(data)
	self.new_map_close_option = data or {}
end

function M:getNewMapCloseOptionData()
	return self.new_map_close_option or {}
end

function M:setNewMapDelegationData(data)
	self.new_map_delegation_ids = data or {}
end

function M:getNewMapDelegationData()
	return self.new_map_delegation_ids or {}
end

function M:setNewMapSceneLineData(data)
	self.new_map_scene_lines = data or {}
end

function M:getNewMapSceneLineData()
	return self.new_map_scene_lines or {}
end
-- 检查随机江湖属性变化
function M:checkWorldMemoryAttrUpdate(update_attrs)
	local tips = ""
	for group, v in pairs(update_attrs) do
		local attrCfg = self:getAttrConfigById(group, v.lvlup)
		if attrCfg and not v.lvlup then
			tips = tips .. Language:getTextByKey("world_memory_str_008", attrCfg.name, v.exp)
		elseif attrCfg and v.lvlup then
			tips = tips .. Language:getTextByKey("world_memory_str_011", attrCfg.name, attrCfg.name_lv)
		end
	end
	return tips
end

--通过组id获取属性配置
function M:getAttrConfigById(group, attrId)
	if not group then return end
	local new_regional_attr_cfg = ConfigManager:getCfgByName("new_regional_attr")
	for i, v in pairs(new_regional_attr_cfg) do
		for m, n in pairs(v) do
			if tostring(i) == tostring(group) and not attrId then
				return n
			end
			if tostring(i) == tostring(group) and tostring(m) == tostring(attrId) then
				return n
			end
		end
	end
	return {}
end
function M:getMedalDataById(medal_id)
	if medal_id and self.m_medals[tostring(medal_id)] then 
		return self.m_medals[tostring(medal_id)]
	end
	return nil
end
-- 根据deep获取>=当前deep的经脉养成英雄个数
function M:getHeroSigDeepNum(quality)
	local allHeroData = UserDataManager.hero_data:getHerosData()
	local num = 0
	for i, v in pairs(allHeroData) do
		if v.sig and _G.next(v.sig) then
			for m, n in pairs(v.sig) do
				if quality == 0 and n and n.lv and n.lv >= 0 then
					num = num + 1
					break
				else
					if n and n.deep and n.deep >= quality then
						num = num + 1
						break
					end
				end
			end
		end
	end
	return num
end

function M:updateFateBuilding(data)
	if data and data.fate_building then
		self.m_fate_building = data.fate_building
	end
end

function M:updateFateMaster(data)
	if data and data.fate_master then
		self.m_fate_master = data.fate_master
	end
end

function M:updateCommonQuest(data)
	if data and data.common_quest then
		self.m_common_quest = data.common_quest
	end
end

function M:setPetPvpSeasonData(data)
	if data then
		self.m_pet_pvp_season_data = data
	end
end

function M:getPetPvpSeasonData()
	return self.m_pet_pvp_season_data
end

function M:setPlayAndDownloadStatus(status)
	status = status or 1
	self.m_play_download_status = status
end

function M:getPlayAndDownloadStatus()
	return self.m_play_download_status
end

--0 未开始， 1 倒计时， 2 领奖
function M:setDownloadWhilePlayStage(stage)
	stage = stage or 0
	local key = "DownloadWhilePlay_" .. self.user_data:getUid()
	self.local_data:setLocalDataByKey(key, stage)
end

function M:getDownloadWhilePlayStage()
	local key = "DownloadWhilePlay_" .. self.user_data:getUid()
	local path_effect_stage = self.local_data:getLocalDataByKey(key, 0)
	return path_effect_stage
end

function M:setDownloadWhilePlayRemainTime(time)
	time = time or 0
	local key = "DownloadWhilePlayRemainTime_" .. self.user_data:getUid()
	self.local_data:setLocalDataByKey(key, time)
end

function M:getDownloadWhilePlayRemainTime()
	local key = "DownloadWhilePlayRemainTime_" .. self.user_data:getUid()
	return self.local_data:getLocalDataByKey(key, 0)
end

function M:getGuildTalentCoin()
	return self.guild_talent_coin or 0
end

--获得侠客共鸣斋属性
function M:getHeroEchoTotalAttrs(hero)
	local lv = self.hero_data.m_echo_total_lv or 0
	if lv <= 0 then
		return nil
	end
	local cfg = ConfigManager:getCfgByName("hero_resonance_total")
	if lv > #cfg then
		return cfg[#cfg]
	end
	local attrs = cfg[lv].attr
	return attrs
end

return M