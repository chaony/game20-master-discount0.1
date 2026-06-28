------------------- RewardUtil

local M = {}

local REWARD_TYPE_KEYS = {
	HEROS = 101, --英雄
	EQUIPS = 102, --装备
	ITEM = 103, --道具
	COIN = 104, --金币
	EXP = 105, --经验
	DUST = 106, --粉尘
	DIAMOND = 107, --元宝
	VIP_EXP = 108, --VIP经验
	MAZE_COIN = 109, --迷宫币
	HERO_EXP = 110, --英雄经验
	HERO_COIN = 111, --英灵币，遣散时获得，在商店中使用
	CRYSTAL = 112, --水晶币，开水晶栏位时使用
	HEROSEXT = 113, --CARD = 113, --卡牌(带品质的英雄)
	FRIEND_COIN = 114, --友情点
	GUILD_COIN = 115, --公会币
	VALOR_MEDALS = 116, --骑士勋章
	HEROIC_MERIT = 117, --勇士之证
	ARENA_COIN = 118, --竞技场币
	ARTIFACTS = 119, --神器
	GUILD_EXP = 120, --公会建设
	MYSTIC = 121, --秘籍
	FRAME = 122, --玩家头像框
	WAIGONG_EXP = 123, -- 外功心得
	SHENFA_EXP = 124, -- 身法心得
	NEIGONG_EXP = 125, -- 内功心得
	JUEJI_EXP = 126, -- 绝技心得
	TRIPOD_COIN = 127, -- 神炉币
	AVATAR = 129, -- 玩家头像
	HERO_SKIN = 130, -- 英雄皮肤
	THIEF_COIN = 131, -- 盗帅令
	RACE_ARENA_COIN = 132, -- 争霸玉佩
	HIGH_ARENA_COIN = 133, -- 高阶竞技场币
	TOP_ARENA_COIN = 134, -- 巅峰币
	QUIZ_COIN = 135, -- 竞猜币
	RICHMAN_POINT = 136, --交子
	VOUCHER = 137, --代金券
	HEROS_EXT = 1010, --后端发的展示英雄，带有品质，等级等
	RECHARGE_DIAMOND = 1,--充值元宝
	TOP_RACE_ARENA_COIN = 138,--充值元宝
	RELIC_COIN = 139,--法宝消耗资源
	HEIRLOOM = 141,--遗物
	TITLE = 142, -- 称号
	EQUIP_AFFIX = 143, -- 带词缀的装备
	MINING_GOLD_COIN = 145, -- 森罗币(苗疆金)
	MINING_WOOD_COIN = 146, -- 寒山币(苗疆木)
	MINING_WATER_COIN = 147, -- 万岛币(苗疆水)
	MINING_FIRE_COIN = 148, -- 炎火币(苗疆火)
	SEASON_COIN = 149, --赛季成就积分
	TITLE_PIECE_COIN = 150, --称号碎片货币
	UNION_COIN = 152, --帮会币
	EQUIP_EXP = 153, --玄铁尘
	ARENA_MOUNTAIN_HUA_COIN = 155, -- 华山论剑币
	ACT_MINING_SILVER = 156, -- 苗疆银帕(夺宝奇兵币)
	ACT_MINING_COIN = 157, -- 苗疆绣饰(夺宝奇兵币)
	FLAGON = 158, -- 游戏模拟器货币
	MEDAL = 159,--奇遇
	MYTH_COIN = 160,--武林通宝
	PETS = 161,--宠物
	PET_EXP = 162,--宠物经验
	PET_COIN = 163, --宠物商店货币
	FENGHUA_RECORD_SKIN = 166, -- 风华录货币
	PRESTIGE_PIECE = 168, -- 威望命格道具
	SEAL_CHARACTER = 170, -- 符篆
	GHW_COIN = 171, -- 巅峰币
	FULL_SERVICE_COIN = 172, -- 剑试币
	GUILD_TALENT_COIN = 174, -- 助威神兽货币1
	TALENT_ATTR_COIN = 175, -- 厉兵秣马货币1
	TALENT_BUFF_COIN= 176, -- 天工巧夺货币1
	RED_ENVELOPE = 177, -- 红包
	HERO_ISLE_COIN = 178, -- 侠隐宝玉
	RISE_ARENA_COIN=180,--争锋刀币
	HOTEL_COIN = 181, -- 酒楼金券
	RTA_WD_COIN = 182,  --rta问道币
	RTA_HM_COIN = 183,  --rta鸿蒙币
	JEWEL = 199, --秘宝
	MAIN_BG = 202,--主界面背景
}

M.REWARD_TYPE_KEYS = REWARD_TYPE_KEYS

local ERROR_GIFT = {
	ERROR_GIFT_COIN_NUM = 3001,                  --金币不足 ok
	ERROR_GIFT_DIAMOND_NUM = 3002,               --元宝不足 ok
	ERROR_GIFT_ARENA_COIN_NUM = 3003,            --竞技场币不足 ok
	ERROR_GIFT_DUST_NUM = 3004,                  --粉尘(突破丹)不足 ok
	ERROR_GIFT_MAZE_COIN_NUM = 3005,             --迷宫币不足 ok
	ERROR_GIFT_HERO_COIN_NUM = 3006,             --武魂币不足 ok
	ERROR_GIFT_CRYSTAL_NUM = 3007,               --水晶币不足 ok
	ERROR_GIFT_FRIEND_COIN_NUM = 3008,           --友情点不足 ok
	ERROR_GIFT_GUILD_COIN_NUM = 3009,            --帮会币不足 ok
	ERROR_GIFT_HERO_EXP_NUM = 3010,              --英雄经验(修为)不足 ok
	ERROR_GIFT_TRIPOD_COIN_NUM = 3011,              --祈福点不足 ok
	ERROR_GIFT_PET_EXP_NUM = 3012,               --宠物经验不足 ok
}

local SERVER_ERROR_GIFT_CODE = {
	[ERROR_GIFT.ERROR_GIFT_COIN_NUM] = REWARD_TYPE_KEYS.COIN,                  --金币不足 ok
	[ERROR_GIFT.ERROR_GIFT_DIAMOND_NUM] = REWARD_TYPE_KEYS.DIAMOND,               --元宝不足 ok
	[ERROR_GIFT.ERROR_GIFT_ARENA_COIN_NUM] = REWARD_TYPE_KEYS.ARENA_COIN,            --竞技场币不足 ok
	[ERROR_GIFT.ERROR_GIFT_DUST_NUM] = REWARD_TYPE_KEYS.DUST,                  --粉尘(突破丹)不足 ok
	[ERROR_GIFT.ERROR_GIFT_MAZE_COIN_NUM] = REWARD_TYPE_KEYS.MAZE_COIN,             --迷宫币不足 ok
	[ERROR_GIFT.ERROR_GIFT_HERO_COIN_NUM] = REWARD_TYPE_KEYS.HERO_COIN,             --武魂币不足 ok
	[ERROR_GIFT.ERROR_GIFT_CRYSTAL_NUM] = REWARD_TYPE_KEYS.CRYSTAL,               --水晶币不足 ok
	[ERROR_GIFT.ERROR_GIFT_FRIEND_COIN_NUM] = REWARD_TYPE_KEYS.FRIEND_COIN,           --友情点不足 ok
	[ERROR_GIFT.ERROR_GIFT_GUILD_COIN_NUM] = REWARD_TYPE_KEYS.GUILD_COIN,            --帮会币不足 ok
	[ERROR_GIFT.ERROR_GIFT_HERO_EXP_NUM] = REWARD_TYPE_KEYS.HERO_EXP,              --英雄经验(修为)不足 ok
	[ERROR_GIFT.ERROR_GIFT_TRIPOD_COIN_NUM] = REWARD_TYPE_KEYS.TRIPOD_COIN,              --祈福点不足 ok
	[ERROR_GIFT.ERROR_GIFT_PET_EXP_NUM] = REWARD_TYPE_KEYS.PET_EXP,              --祈福点不足 ok
}

M.SERVER_ERROR_GIFT_CODE = SERVER_ERROR_GIFT_CODE
M.ERROR_GIFT = ERROR_GIFT

--[[
    处理数据  
    @param data 通用数据格式 [类型,id,数量]
]]
function M:getProcessRewardData(data, hero_show_evo)
    data = data or {}
    local data_type, data_id, data_num = data[1] or -1, data[2] or -1, data[3] or 0
	local hero_show_evo = hero_show_evo and hero_show_evo or 0
    local item_data = {
        name = "???",
        icon_name = "item_icon_wenhao",
        quality = 0,
        user_num = 0,
        story = "???",
        is_piece = false, --用于道具角标
        data_type = data_type,
        data_id = data_id,
        data_num = data_num,
        atlas_name = "item_icon",
		isFristReward = data.isFristReward
    }
    local user_num = 0
    local item_cfg = nil
    local money_guide = ConfigManager:getCfgByName("money_guide")
    local info = money_guide[data_type] or {}
    local oid = data[4]
    if info.itype == 1 then--货币类型
		user_num = UserDataManager.user_data:getUserStatusDataByKey(info.user_key) or 0
		--if data_type == RewardUtil.REWARD_TYPE_KEYS.GIFT_SORT_GUILD_HIGH_WAR_GUILD_COIN then  --特殊处理巅峰科技货币 加入到  gameInfo
			--user_num = UserDataManager:getGuildTalentCoin()
		--end
		self:setMoneyQuality(item_data)
		self:setDataByCfg(item_data, info)
    elseif info.itype == 2 then
		if data_type == REWARD_TYPE_KEYS.HEROS then   -- 英雄
			local hero_data = nil
			item_cfg = UserDataManager.hero_data:getHeroConfigByCid(data_id)
			if oid then
				hero_data = UserDataManager.hero_data:getHeroDataById(oid)
				if hero_data then
					item_data.quality = hero_data.evo
				else
					item_data.quality = item_cfg and item_cfg.evo or 1
				end
			elseif hero_show_evo and hero_show_evo > 0 then
				item_data.quality = hero_show_evo
			else
				item_data.quality = item_cfg and item_cfg.evo or 1
			end
			self:setDataByCfg(item_data, item_cfg)
			local cur_hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, item_cfg)
			if cur_hero_skin_cfg and next(cur_hero_skin_cfg) ~= nil then
				item_data.icon_name = cur_hero_skin_cfg.icon
			end
			item_data.atlas_name = "hero_head_ui"
			item_data.fate = data.fate -- 天命化星
		elseif data_type == REWARD_TYPE_KEYS.HEROSEXT then   -- 英雄
			local card_hero = ConfigManager:getCfgByName("card_hero")
			local card_hero_item = card_hero[data_id]
			item_data.data_id = card_hero_item.hero_id
			item_cfg = UserDataManager.hero_data:getHeroConfigByCid(card_hero_item.hero_id)
			item_data.quality = card_hero_item.hero_evo
			self:setDataByCfg(item_data, item_cfg)
			item_data.atlas_name = "hero_head_ui"
			item_data.fate = data.fate -- 天命化星
		elseif data_type == REWARD_TYPE_KEYS.EQUIPS then   -- 装备
			item_data.data_num = data.equip_num or 1
			item_cfg = UserDataManager.equip_data:getEquipConfigByCid(data_id)
			self:setDataByCfg(item_data, item_cfg)
			item_data.race = data[3] or 0
			item_data.quality = item_cfg and item_cfg.quality or 0
			item_data.pos = (item_cfg and item_cfg.pos) and item_cfg.pos or 0
			item_data.atlas_name = "equip_icon"
			user_num = UserDataManager.equip_data:getEquipNumByCid(data_id)
			user_num = user_num + UserDataManager.hero_data:getEquipNumByCid(data_id)
		elseif data_type == REWARD_TYPE_KEYS.EQUIP_AFFIX then   -- 装备
			item_data.data_num = data.equip_num or 1
			local item_good_cfg = UserDataManager.equip_data:getEquipGoodsConfigByCid(data_id)
			item_cfg = UserDataManager.equip_data:getEquipConfigByCid(item_good_cfg.equip_id)
			self:setDataByCfg(item_data, item_cfg)
			item_data.equip_id = item_good_cfg.equip_id
			item_data.race = item_good_cfg.race or 0
			item_data.affix_id = item_good_cfg.hero_affix or 0
			item_data.quality = item_cfg and item_cfg.quality or 0
			item_data.atlas_name = "equip_icon"
		elseif data_type == REWARD_TYPE_KEYS.ITEM then   -- 道具
			local data = nil
			data, item_cfg = UserDataManager.item_data:getItemDataById(data_id)
			user_num = data.num
			self:setDataByCfg(item_data, item_cfg)
			if item_cfg then
				item_data.quality = item_cfg.quality or 0
				item_data.is_piece = item_cfg.sort == 2 or item_cfg.sort == 28 --碎片
			end
			if item_data.is_piece or (item_cfg and item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_CHANGE_HERO) then
				item_data.atlas_name = "hero_head_ui"
			end
		elseif data_type == REWARD_TYPE_KEYS.ARTIFACTS then   -- 神器	
			user_num = 1
			item_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(data_id)
			self:setDataByCfg(item_data, item_cfg)
			item_data.quality = item_cfg and item_cfg.quality or 10
		elseif data_type == REWARD_TYPE_KEYS.MYSTIC then   -- 秘籍 [类型，cid, 数量]
			oid = data.oid
			local cfg = UserDataManager.mystic_data:getMysticConfigByCid(tonumber(data_id))
			item_cfg = cfg
			item_data.data_num = 1
			item_data.quality = cfg.quality and cfg.quality or 1
			self:setDataByCfg(item_data, cfg)
		elseif data_type == REWARD_TYPE_KEYS.TITLE then   -- 称号 [类型，id, 数量]
			local cfg = UserDataManager.title_data:getTitleConfigById(tonumber(data_id))
			item_cfg = cfg
			item_data.data_num = 1
			item_data.quality = cfg.quality and cfg.quality or 1
			item_data.atlas_name = "item_icon"
			self:setDataByCfg(item_data, cfg)
			item_data.icon_name = "icon_chenghao_tongyong"  -- 称号奖励通用图写死
		elseif data_type == REWARD_TYPE_KEYS.AVATAR then   -- 玩家头像
			local player_picture_cfg = ConfigManager:getCfgByName("player_picture")
			item_cfg = player_picture_cfg[data_id]
			item_data.quality = info.quality[1] or 1
			self:setDataByCfg(item_data, item_cfg)
			item_data.story = item_data.story ~= "nil" and item_data.story or info.story
			item_data.atlas_name = "hero_head_ui"
		elseif data_type == REWARD_TYPE_KEYS.HERO_SKIN then   -- 英雄皮肤
			item_cfg = ConfigManager:getHeroSkinCfg(data_id)
			self:setDataByCfg(item_data, item_cfg)
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(item_cfg.hero)
			item_data.story = item_data.story ~= "nil" and item_data.story or Language:getTextByKey("new_str_0716", Language:getTextByKey(hero_cfg.name))
			item_data.quality = info.quality[1] or 1
			item_data.atlas_name = "hero_head_ui"
		elseif data_type == REWARD_TYPE_KEYS.FRAME then -- 玩家头像框
			item_cfg = ConfigManager:getPlayerFrameCfg(data_id)
			self:setDataByCfg(item_data, item_cfg)
			item_data.atlas_name = "hero_head_ui"
			item_data.quality = item_cfg.quality and item_cfg.quality or 1
		elseif data_type == REWARD_TYPE_KEYS.HEIRLOOM then -- 遗物
			item_cfg = ConfigManager:getHeirloomCfg(data_id)
			self:setDataByCfg(item_data, item_cfg)
			item_data.atlas_name = "item_icon"
			item_data.quality = item_cfg.quality and item_cfg.quality or 1
		elseif data_type == REWARD_TYPE_KEYS.PETS then -- 宠物
			local pet_data = nil
			data_num = 1
			if type(oid) == "string" then
				pet_data,item_cfg = UserDataManager.pet_data:getPetDataById(oid)
				item_data.quality = GameUtil:getPetQualityByData(pet_data)
			else
				item_cfg = UserDataManager.pet_data:getPetConfigByCid(data_id)
				item_cfg = item_cfg or {}
				item_data.quality = item_cfg.show_quality or 1
			end
			item_data.atlas_name = "item_icon"
			self:setDataByCfg(item_data, item_cfg)
		elseif data_type == REWARD_TYPE_KEYS.FENGHUA_RECORD_SKIN then -- 风华录
			item_cfg = {}
			local cfg = ConfigManager:getCfgByName("fenghua_record_skin")
			if cfg then
				for  k,v in pairs(cfg) do
					if k == data_id then
						item_cfg.name = v.icon_name
						item_cfg.icon = v.icon_s
						item_cfg.des = v.icon_des
					end
				end
			end
			item_data.quality = 1
			item_data.atlas_name = "hero_head_ui"
			self:setDataByCfg(item_data, item_cfg)
		elseif data_type == REWARD_TYPE_KEYS.PRESTIGE_PIECE then -- 威望系统
			--prestige_piece 
			item_cfg = {}
			local cfg = ConfigManager:getCfgByName("prestige_piece")
			if cfg then
				item_cfg = cfg[tonumber(data_id)]
				item_data.quality = item_cfg.quality
				item_data.atlas_name = "maze_stage_ui"
				self:setDataByCfg(item_data, item_cfg)
			end
			--if cfg then
			--	for  k,v in pairs(cfg) do
			--		if k == data_id then
			--			item_cfg.name = v.name
			--			item_cfg.icon = v.icon
			--			item_cfg.des = v.des
			--			item_data.quality = v.quality or 1
			--			item_data.atlas_name = "maze_stage_ui"
			--			self:setDataByCfg(item_data, item_cfg)
			--		end
			--	end
			--end
		elseif data_type == REWARD_TYPE_KEYS.SEAL_CHARACTER then
			item_cfg = {}
			local cfg = ConfigManager:getCfgByName("seal_character_suit")
			if cfg then
				item_cfg = cfg[tonumber(data_id)]
				item_data.quality = item_cfg.quality
				item_data.atlas_name = "maze_stage_ui"
				self:setDataByCfg(item_data, item_cfg)
			end
		elseif data_type == REWARD_TYPE_KEYS.RED_ENVELOPE then
			item_cfg = {}
			local cfg = ConfigManager:getCfgByName("red_envelope")
			if cfg then
				item_cfg = cfg[tonumber(data_id)]
				item_data.quality = item_cfg.quality
				item_data.atlas_name = "main_ui2"
				self:setDataByCfg(item_data, item_cfg)
			end
		elseif data_type == REWARD_TYPE_KEYS.MAIN_BG then
			item_cfg = {}
			local cfg = ConfigManager:getCfgByName("main_bg")
			if cfg then
				item_cfg = cfg[tonumber(data_id)]
				item_data.quality = 4
				item_data.atlas_name = "item_icon"
				--self:setDataByCfg(item_data, item_cfg)
				item_data.name = Language:getTextByKey(item_cfg.name)
				item_data.icon_name = item_cfg.icon
				item_data.story = Language:getTextByKey(item_cfg.desc)
			end
		end
    else
    	if data_type == REWARD_TYPE_KEYS.HEROS_EXT then   -- 英雄
			oid = nil
			item_cfg = UserDataManager.hero_data:getHeroConfigByCid(data_id)
			item_data.quality = data[4]
			self:setDataByCfg(item_data, item_cfg)
			item_data.atlas_name = "hero_head_ui"
		end
    end
    item_data.user_num = user_num
    item_data.item_cfg = item_cfg or info
    item_data.oid = oid
    item_data.quality = data.quality or item_data.quality
	item_data.money_guide_cfg = info
    return item_data
end

--通过配置去取英雄数据
function M:getHeroConfigData(data)
	data = data or {}
	local data_type, data_id, data_num = data[1] or -1, data[2] or -1, data[3] or 0
	local item_data = {
		name = "???",
		icon_name = "item_icon_wenhao",
		quality = 0,
		user_num = 0,
		story = "???",
		is_piece = false, --用于道具角标
		data_type = data_type,
		data_id = data_id,
		data_num = data_num,
		atlas_name = "item_icon",
		isFristReward = data.isFristReward
	}
	local item_cfg = nil
	local money_guide = ConfigManager:getCfgByName("money_guide")
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local info = money_guide[data_type] or {}
	local oid = data[4]
	if info.itype == 2 then
		if data_type == REWARD_TYPE_KEYS.HEROS then   -- 英雄
			local hero_data = nil
			item_cfg = hero_detail[data_id]
			if oid then
				hero_data = UserDataManager.hero_data:getHeroDataById(oid)
				if hero_data then
					item_data.quality = hero_data.evo
				end
			else
				item_data.quality = item_cfg and item_cfg.evo or 1
			end
			self:setDataByCfg(item_data, item_cfg)
			local cur_hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, item_cfg)
			if cur_hero_skin_cfg then
				item_data.icon_name = cur_hero_skin_cfg.icon
			end
			item_data.atlas_name = "hero_head_ui"
			item_data.item_cfg = item_cfg;
		end
	end
	return item_data;
end


function M:setDataByCfg(item_data, item_cfg)
	if item_cfg then
	    item_data.name = Language:getTextByKey(item_cfg.name)
	    item_data.icon_name = item_cfg.icon
	    item_data.story = Language:getTextByKey(item_cfg.story or item_cfg.des)
	    item_data.race = item_cfg.race
	end
end

function M:setMoneyQuality(item_data)
	local money_guide = ConfigManager:getCfgByName("money_guide")
	local info = money_guide[item_data.data_type] or {}
	if info.sort == 1 then -- 按数量分档
		for i,v in ipairs(info.num or {}) do
			if item_data.data_num <= v then
				item_data.quality = info.quality[i] or item_data.quality
				break
			end
		end
	elseif info.sort == 2 then -- 按挂机收益时长分档
		local stage_id = UserDataManager:getCurStage()
		local stage_tab = ConfigManager:getCfgByName("stage")
		local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
		local idle_id =  stage_tab[stage_id].idle_id
		local idle_cfg = stage_idle_tab[idle_id]
		local h_num = 0
		if item_data.data_type == REWARD_TYPE_KEYS.COIN then -- 金币
			h_num = idle_cfg.coin * (3600 / idle_cfg.rewards_cd)
		elseif item_data.data_type == REWARD_TYPE_KEYS.HERO_EXP then -- 英雄经验
			h_num = idle_cfg.hero_exp * (3600 / idle_cfg.rewards_cd)
		end
		for i,v in ipairs(info.num or {}) do
			local num = v * h_num
			if item_data.data_num <= num then
				item_data.quality = info.quality[i] or item_data.quality
				break
			end
		end
	else -- 固定值
		--if info.quality and #info.quality == 1  then
		--	item_data.quality = info.quality[1]
		--end
	end
end

--[[
	合并后端奖励
]]
function M:mergeRewardAndFormat(normal_reward, extra_reward)
	if not normal_reward and not extra_reward then
		return {}
	end
	local rewards = {}
	self:processReward(rewards, normal_reward, false)
	if extra_reward then 
		self:processReward(rewards, extra_reward, true)
	end
	return rewards
end

function M:processReward(rewards, reward, is_extra_reward)
	if reward and reward.title_package then --重复获得的称号，按首次获得的时的逻辑来处理
		if reward.title == nil then
			reward.title = {}
		end
		for _, item in pairs(reward.title_package) do
			table.insert(reward.title, item)
		end
		reward.title_package = nil
	end
	
	local data_sync_error = false
	local mystic_piece = reward.mystic_piece
	reward.mystic_piece = nil
	local extra_type = reward.extra_type or 0
	reward.extra_type = nil
	for k,v in pairs(reward) do
		local key = string.upper(k)
		local key_value = REWARD_TYPE_KEYS[key]
		if key_value == REWARD_TYPE_KEYS.HEROS then
			--101 英雄
			for i,id in ipairs(v) do
				local hero_data = UserDataManager.hero_data:getHeroDataById(id)
				if hero_data then
					rewards[#rewards + 1] = {key_value, hero_data.id, 1, id, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("hero data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.EQUIPS then
			--102 装备
			-- for i,id in ipairs(v) do
			-- 	local equip_data = UserDataManager.equip_data:getEquipDataById(id)
			-- 	rewards[#rewards + 1] = {key_value, equip_data.id, 1, id, is_extra_reward = is_extra_reward}
			-- end

			for k,v in pairs(v) do
				local equip_data = UserDataManager.equip_data:getEquipDataById(k)
				if equip_data then
					rewards[#rewards + 1] = {key_value,equip_data.id,equip_data.race,k, equip_num = v, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("equip data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.MYSTIC then
			for m,n in pairs(v) do
				local mystic_data, cfg = UserDataManager.mystic_data:getMysticDataById(n)
				if mystic_data then
					rewards[#rewards + 1] = {key_value, mystic_data.id, cfg.quality, v, mystic_num = 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, oid = v, extra_type = extra_type}
				else
					Logger.logWarning("mystic data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.TITLE then   -- 称号 [类型，id, 数量]
			for m,n in pairs(v) do
				local title_date, cfg = UserDataManager.title_data:getTitleDataById(n)
				if title_date == nil then 
					title_date, cfg = UserDataManager.title_data:getTitlePackageDataById(n)
				end
				if title_date then
					rewards[#rewards + 1] = {key_value, title_date.id, cfg.quality, v, title_num = 1, is_extra_reward = is_extra_reward, oid = v, extra_type = extra_type}
				else
					Logger.logWarning("title data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.ARTIFACTS then
			for k1,v1 in pairs(v) do
				local item_data, _ = UserDataManager.artifact_data:getArtifactDataById(k1)
				if item_data then
					rewards[#rewards + 1] = {key_value, item_data.id, v1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("artifact data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.AVATAR then -- 玩家头像
			local player_picture_cfg = ConfigManager:getCfgByName("player_picture")
			for k1,v1 in pairs(v) do
				local player_picture_id = tonumber(v1)
				local item_cfg = player_picture_cfg[player_picture_id]
				if item_cfg then
					rewards[#rewards + 1] = {key_value, player_picture_id, 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("avatar data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.HERO_SKIN then -- 英雄皮肤
			for k1,v1 in pairs(v) do
				local skin_id = tonumber(v1)
				local item_cfg = ConfigManager:getHeroSkinCfg(skin_id)
				if item_cfg then
					rewards[#rewards + 1] = {key_value, skin_id, 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("hero_shin data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.FRAME then -- 玩家头像框
			for k1,v1 in pairs(v) do
				local id = tonumber(v1)
				local item_cfg = ConfigManager:getPlayerFrameCfg(id)
				if item_cfg then
					rewards[#rewards + 1] = {key_value, id, 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("hero_shin data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.HEIRLOOM then -- 遗物
			for k1,v1 in pairs(v) do
				local id = tonumber(v1)
				local item_cfg = ConfigManager:getHeirloomCfg(id)
				if item_cfg then
					rewards[#rewards + 1] = {key_value, id, 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("heirloom data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value ==REWARD_TYPE_KEYS.MEDAL then --奇遇
			for k1,v1 in pairs(v) do
				local id = tonumber(v1)
				local item_cfg = ConfigManager:getMedalCfgById(id)
				if item_cfg then
					rewards[#rewards + 1] = {key_value, id, 1, extra_type = extra_type}
				else
					Logger.logWarning("MEDAL data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.PETS then
			--161 宠物
			for i,id in ipairs(v) do
				local pet_data = UserDataManager.pet_data:getPetDataById(id)
				if pet_data then
					rewards[#rewards + 1] = {key_value, pet_data.id, 1, id, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				else
					Logger.logWarning("pet data out of sync")
					data_sync_error = true
				end
			end
		elseif key_value == REWARD_TYPE_KEYS.FENGHUA_RECORD_SKIN then --166风华录
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					rewards[#rewards + 1] = {key_value,v1,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		elseif key_value == REWARD_TYPE_KEYS.MAIN_BG then --202主界面背景
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					rewards[#rewards + 1] = {key_value,v1,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		elseif key_value == REWARD_TYPE_KEYS.PRESTIGE_PIECE then --168威望棋子
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					rewards[#rewards + 1] = {key_value,k1,v1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		elseif key_value == REWARD_TYPE_KEYS.SEAL_CHARACTER then --170符篆
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					rewards[#rewards + 1] = {key_value,k1,v1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		elseif key_value == REWARD_TYPE_KEYS.RED_ENVELOPE then --177红包
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					rewards[#rewards + 1] = {key_value,k1,v1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		elseif key_value ~= nil then
			if type(v) == "table" then
				for k,v in pairs(v) do
					rewards[#rewards + 1] = {key_value,k,v, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
				end
			else
				rewards[#rewards + 1] = {key_value,0,v, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
			end
		else
			-- 'old_mystic': [[mystic_id, star]]
			if k == "old_mystic" then
				for k,v in pairs(v) do
					if #v > 1 then
						rewards[#rewards + 1] = {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, v[1], v[2], v, mystic_num = 1, is_extra_reward = is_extra_reward, mystic_piece = mystic_piece, extra_type = extra_type}
					end
				end
			else
				Logger.logWarning("not reward key : " .. k)
			end
		end
	end
	if data_sync_error then
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event="data_sync_error"})
	end
end

--[[
	通用奖励
]]
function M:rewardTipsByData(normal_reward, extra_reward, call_back, extra, show_type_15)
	normal_reward = normal_reward or {}
	local rewards = self:mergeRewardAndFormat( normal_reward, extra_reward )
	self:rewardTipsByRewards( rewards, call_back, extra,show_type_15)
end


function M:mergeRewardList( list )
	local reward_data = {}
	for i, v in ipairs(list) do
		--v = ["item"] = table
		--v = ["coin"] = 100
		for item_i, item_v in pairs(v) do
			if type(item_v) == "table" then
				if reward_data[item_i] == nil then
					reward_data[item_i] = {}
				end
				if item_v[1] == nil then
					table.merge(reward_data[item_i],item_v)
				else
					table.insertto(reward_data[item_i],item_v)
				end
			elseif type(item_v) == "number" then
				if reward_data[item_i] == nil then
					reward_data[item_i] = 0
				end
				reward_data[item_i] = reward_data[item_i] + item_v
			end
		end
	end
	return reward_data;
end

function M:getRewardKeyById( id )
	for i, v in pairs(REWARD_TYPE_KEYS) do
		if v == id then
			return i;
		end
	end
	return "";
end


--[[ 
    通用数据格式 [类型,id,数量]
]]
function M:mergeCfgReward(rewards, add_reward)
	local money_guide = ConfigManager:getCfgByName("money_guide")
	for i,v in ipairs(add_reward) do
		local is_new = true
		for ii,vv in ipairs(rewards) do
			local info = money_guide[vv[1]] or {}
			if info.itype == 1 then--货币类型
				if v[1] == vv[1] then
					vv[3] = vv[3] + v[3]
					is_new = false
					break
				end
			end
		end
		if is_new then
			rewards[#rewards + 1] = table.copy(v)
		end
	end
end

--- 通过奖励表展示奖励提示
function M:rewardTipsByRewards(rewards, call_back, extra, show_type_15)
	rewards = rewards or {}
	local index = 1
	local new_reward_indexs = {}
	if show_type_15 == nil then
		show_type_15 = true
	end
	local function doNextRewardAnim()
		if index > #rewards then
			local reward_count = #rewards
			local show_data = {}
			for i=1,reward_count do
				local item_reward = rewards[i]
				-- if item_reward[1] ~= REWARD_TYPE_KEYS.HEROS then
				if new_reward_indexs[i] == nil then
					table.insert(show_data, item_reward)
				end
			end
			if #show_data > 0 then
				-- TODO:添加通用奖励弹出框
				static_rootControl:openView("Pops.CommonRewardPop", {reward = show_data, callback = call_back, extra = extra}, nil, true)
			else
				if call_back then
					call_back()
				end
			end
		else		
			local item_reward = rewards[index] or {}
			index = index + 1
			if item_reward[1] == REWARD_TYPE_KEYS.HEROS then-- 单独展示
				if UserDataManager.hero_data:isNewHero(item_reward[2]) then
					UserDataManager.hero_data:removeNewHero(item_reward[2])
					--new_reward_indexs[index-1] = item_reward
					static_rootControl:openView("HeroInfo.HeroNewPop", {hero_id = item_reward[2], is_new = true, callback = doNextRewardAnim})
				elseif extra and extra.season_change_hero then
					UserDataManager.hero_data:removeNewHero(item_reward[2])
					--new_reward_indexs[index-1] = item_reward
					static_rootControl:openView("HeroInfo.HeroNewPop", {hero_id = item_reward[2], is_new = true, callback = doNextRewardAnim, evo = 19})
				else
					doNextRewardAnim()
				end
			elseif item_reward[1] == REWARD_TYPE_KEYS.PETS then-- 单独展示 	
				if UserDataManager.pet_data:isNewHero(item_reward[2]) then
					UserDataManager.pet_data:removeNewHero(item_reward[2])
					static_rootControl:openView("PetBreeding.PetGetNewPop", {pet_id = item_reward[4], is_new = true, callback = doNextRewardAnim})
				else
					doNextRewardAnim()
				end
			elseif item_reward[1] == REWARD_TYPE_KEYS.HERO_SKIN then
				local skin_id = item_reward[2]
				static_rootControl:openView("Pops.HeroSkinLookInfo", {is_new = true, skin_id = skin_id, callback = doNextRewardAnim})
			elseif item_reward[1] == REWARD_TYPE_KEYS.ITEM and show_type_15 == true then
				local item = ConfigManager:getCfgByName("item")
				local cfg = item[tonumber(item_reward[2])]
				if cfg.type == 15 then
					new_reward_indexs[index-1] = item_reward
					GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("worldMap_regional_get_item")..Language:getTextByKey(cfg.name), delay_close = 1, finish = doNextRewardAnim})
				else
					doNextRewardAnim()
				end
			else
				doNextRewardAnim()
			end
		end
	end
	doNextRewardAnim()
end

function M:rewardLookInfoTipsByData(normal_reward, extra_reward)
	local rewards = self:mergeRewardAndFormat( normal_reward, extra_reward )
	local tips_str = ""
	local reward_len = #rewards
	for i, v in ipairs(rewards) do
		local data = self:getProcessRewardData(v)
		tips_str = tostring(data.name) .. "x" .. tostring(data.data_num)
		if i ~= reward_len then
			tips_str = tips_str .. "、"
		end
	end
	GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0717", tips_str), delay_close = 2})
end

return M
