---@class ShopModel:OODataBase
local M = class("ShopModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{btn_key = "ordinary_togglebtn", lua_name = "", btn_text = "ordinary_btn_text", text_key = "new_str_0031", open = true, init_open = true, shop_type = 1,show_refresh_btn = true, refresh_key = 1, attr_mode = 10, btn_text_img = "btn_shop_n1", btn_text_img_sel = "btn_shop_h1", open_condition_id = 19, show_tips = true, red_point_img = "ordinary_red_point_img", red_point_id = 123, red_point_key = "shop_refresh"}, -- 商铺
	{btn_key = "fix_togglebtn", lua_name = "", btn_text = "fix_btn_text", text_key = "new_str_0685", open = true, init_open = true, shop_type = 7,show_refresh_btn = false, attr_mode = 10, btn_text_img = "btn_shop_n1", btn_text_img_sel = "btn_shop_h1", open_condition_id = 151, show_tips = true, red_point_img = "fix_red_point_img", red_point_id = 122, red_point_key = "fixed_shop_goods"}, -- 固定商铺
	{btn_key = "decompose_togglebtn", lua_name = "", btn_text = "decompose_btn_text", text_key = "new_str_0032", open = true, init_open = true, shop_type = 3,show_refresh_btn = true, refresh_key = 3, btn_text_img = "btn_qsshop_n1", btn_text_img_sel = "btn_qsshop_h1", open_condition_id = 10, show_tips = false, show_select_race = true }, -- 遣散商店
	{btn_key = "maze_togglebtn", lua_name = "", btn_text = "maze_btn_text", text_key = "new_str_0033", open = false, init_open = false, shop_type = 4,show_refresh_btn = true, refresh_key = 4, btn_text_img = "btn_mjshop_n1", btn_text_img_sel = "btn_mjshop_h1", open_condition_id = 15, show_tips = false, fixed_shop_type = 5, fix_shop_name = "new_str_0196", fixed_tips_key = "new_str_0803", red_point_id = 81, red_point_img = "maze_red_point_img", show_select_race = false }, -- 迷宫商店
	{btn_key = "full_service_btn", lua_name = "", btn_text = "full_service_btn_text", text_key = "compare_sword_race_text_049", open = true, init_open = true, shop_type = 35,show_refresh_btn = false,attr_mode = 46, refresh_key = 19, btn_text_img = "btn_mjshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 414, show_tips = true, fixed_shop_type = 5, fix_shop_name = "new_str_0196", fixed_tips_key = "new_str_0803", red_point_id = 81, red_point_img = "full_service_red_point_img", show_select_race = false }, -- 剑试商店
	{btn_key = "guild_high_war_btn", lua_name = "", btn_text = "guild_high_war_btn_text", text_key = "guild_high_war_new_0037", open = true, init_open = true, shop_type = 34,show_refresh_btn = false,attr_mode = 45, refresh_key = 19, btn_text_img = "btn_mjshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 295, show_tips = true, fixed_shop_type = 5, fix_shop_name = "new_str_0196", fixed_tips_key = "new_str_0803", red_point_id = 81, red_point_img = "guild_high_war_red_point_img", show_select_race = false }, -- 巅峰商店
	{btn_key = "guild_togglebtn", lua_name = "", btn_text = "guild_btn_text", text_key = "new_str_0034", open = true, init_open = true, shop_type = 2,show_refresh_btn = true, refresh_key = 2, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 5, show_tips = true }, -- 公会商店
	{btn_key = "hight_arena_togglebtn", lua_name = "", btn_text = "hight_arena_btn_text", text_key = "new_str_0347", open = true, init_open = true, shop_type = 6,show_refresh_btn = true, refresh_key = 12, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 33, show_tips = true}, -- 高阶竞技场商店
	{btn_key = "maze_floor_togglebtn", lua_name = "", btn_text = "maze_floor_btn_text", text_key = "new_str_0196", open = false, init_open = false, shop_type = 5, show_refresh_btn = false, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 3, show_tips = true, red_point_img = "maze_floor_red_point_img", red_point_id = 81}, -- 狐仙商人
	{btn_key = "race_arena_togglebtn", lua_name = "", btn_text = "race_arena_btn_text", text_key = "new_str_0744", open = true, init_open = true, shop_type = 8,show_refresh_btn = true, attr_mode = 15, refresh_key = 15, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 152, show_tips = false, show_select_race = false}, -- 种族技场商店 论剑商店
	{btn_key = "voyage_togglebtn", lua_name = "", btn_text = "voyage_btn_text", text_key = "new_str_0728", open = false, init_open = false, shop_type = 10, show_refresh_btn = false, attr_mode = 12, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 146, show_tips = false}, -- 盗帅迷踪商店
	{btn_key = "jubaoshan_togglebtn", lua_name = "", btn_text = "jubaoshan_btn_text", text_key = "new_str_0901", open = true, init_open = true, shop_type = 11, show_refresh_btn = true, attr_mode = 19,refresh_key = 19, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 172, show_tips = false}, -- 聚宝山商店
	{btn_key = "hunt_treasures_togglebtn", lua_name = "", btn_text = "hunt_treasures_btn_text", text_key = "new_str_1064", open = true, init_open = true, shop_type = 25, show_refresh_btn = false,attr_mode = 22,refresh_key = 19, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 180, show_tips = false,show_shop_scroll = false,red_point_id = 170,red_point_key = "mining_shop_goods"}, -- 苗疆觅宝商店
	{btn_key = "season_togglebtn", lua_name = "", btn_text = "season_btn_text", text_key = "season_shop_str_001", open = true, init_open = true, shop_type = 26,show_refresh_btn = false, refresh_key = 1, attr_mode = 24, season_attr_mode = 25, season_show_id = 608,  btn_text_img = "btn_shop_n1", btn_text_img_sel = "btn_shop_h1", open_condition_id = 240, show_tips = true, red_point_img = "season_red_point_img", red_point_id = 239, red_point_key = "season_shop_goods"}, -- 赛季商店
	{btn_key = "xingnian_togglebtn", lua_name = "", btn_text = "xingnian_btn_text", text_key = "new_str_1084", open = true, init_open = true, shop_type = 28, show_refresh_btn = false,attr_mode = 29,refresh_key = 19, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 265, show_tips = false,show_shop_scroll = false,red_point_id = 265,red_point_key = "mining_shop_goods"}, -- 新年活动商店
	{btn_key = "huashan_togglebtn", lua_name = "",show_one = true, btn_text = "huashan_btn_text", text_key = "huashan_sword_text0001", open = false, init_open = true, shop_type = 29,attr_mode = 30,show_refresh_btn = true, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 276, show_tips = true}, -- 高阶竞技场商店
	{btn_key = "hunt_treasures_guild_togglebtn", lua_name = "",show_one = true, btn_text = "hunt_treasures_guild_btn_text", text_key = "hunt_treasure_guild_str_008", open = true, init_open = true, shop_type = 30,show_refresh_btn = false, attr_mode = 31, refresh_key = 5, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 287, show_tips = false, show_shop_scroll = false}, -- 夺宝商店
	{btn_key = "ship_togglebtn", lua_name = "", btn_text = "ship_btn_text", text_key = "ship_shop_str_001", open = false, init_open = false, shop_type = 31,show_refresh_btn = false, attr_mode = 34, refresh_key = 5, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 305, show_tips = false, show_shop_scroll = false}, -- 皮肤商店
	{btn_key = "myth_arena_togglebtn", show_one = true, lua_name = "", btn_text = "myth_arena_btn_text", text_key = "wlsh_text_0005", open = true, init_open = true, shop_type = 32,show_refresh_btn = true,attr_mode = 35, refresh_key = 12, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 320, show_tips = true}, -- 武林神话商店
	{btn_key = "pet_togglebtn", show_one = true, lua_name = "", btn_text = "pet_btn_text", text_key = "pet_bag_text_0113", open = false, init_open = false, shop_type = 33,show_refresh_btn = false,attr_mode = 40, refresh_key = 1, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 359, show_tips = true}, -- 宠物商店
	{btn_key = "xiayin_togglebtn", lua_name = "", btn_text = "xiayin_btn_text", text_key = "new_str_1135", open = true, init_open = true, shop_type = 36,show_refresh_btn = false,attr_mode = 53, refresh_key = 1, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 454, show_tips = true}, -- 宠物商店
	{btn_key = "zhengfeng_togglebtn", lua_name = "", btn_text = "zhengfeng_btn_text", text_key = "arena_str_0048", open = true, init_open = true, shop_type = 37,show_refresh_btn = false,attr_mode = 55, refresh_key = 1, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 472, show_tips = false}, -- 争锋商店
	{btn_key = "rta_togglebtn", lua_name = "", btn_text = "rta_togglebtn_text", text_key = "arena_rta_str_0028", open = true, init_open = true, shop_type = 38,show_refresh_btn = false,attr_mode = 57, refresh_key = 1, btn_text_img = "btn_bpshop_n1", btn_text_img_sel = "btn_bpshop_h1", open_condition_id = 474, show_tips = false}, -- 鸿蒙商店
}

--横板商店列表
local __TAB_TYPE_HUNT = {25,28,30,31}

function M:onCreate()
	M.super.onCreate(self)
	-- shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店， 5：狐仙商人
	local shop_type = self.m_params.shop_type
	local cur_show_one = false --左侧页签只展示当前一个商店的页签

	--争锋联赛赛事=========
	self.rise_id=UserDataManager.m_rise_arena_id
	--=====================================
	local fixed_shop_type = self.m_params.fixed_shop_type
	if shop_type then
		self.m_shop_type = shop_type
		for k,v in pairs(__TAB_BTN_NODE) do
			if v.shop_type == shop_type then
				if fixed_shop_type then
					v.fixed_shop_type = fixed_shop_type;
				end
				self.m_open_tab_index = k
				cur_show_one = v.show_one
				break
			end
		end
	else
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		self.m_shop_type = __TAB_BTN_NODE[self.m_open_tab_index].shop_type
	end
	for k, v in pairs(__TAB_BTN_NODE) do

		local open_flag = BtnOpenUtil:isBtnOpen(v.open_condition_id)
		if self.m_shop_type == 10 then
			v.open = v.init_open and open_flag and v.shop_type == 10
		elseif self.m_shop_type == 28 then
			v.open = v.init_open and open_flag and v.shop_type == 28
		elseif v.shop_type == 34 or v.shop_type == 35 then --特殊处理 巅峰商店
		    local flag = self:isOpenActiive(v.open_condition_id)
			v.open = v.init_open and open_flag and flag
		else

			v.open = v.init_open and open_flag and (v.shop_type ~= 10 and v.shop_type ~= 28)
		end
		if cur_show_one then
			if self.m_shop_type == v.shop_type then
				v.open = true
			else
				v.open = false
			end
		elseif v.show_one then
			v.open = false
		end
	end
	self:getData("shop_index", {shop_type = self.m_shop_type})
end

function M:onEnter()
	self.toDay_active = true
	self.m_sel_tab_index = nil
	self.m_select_race_index = 1
	self.m_shop_name = self.m_params.shop_name or nil --同一个商店 名字可能不同 key shop_type value shop_name
	self.m_cache_data = {}
	local open_condition = ConfigManager:getCommonValueById(420,{})
	local cur_stage = UserDataManager:getCurStage()
	self.m_show_index = #open_condition -- 固定商铺显示的最大id
	for i, v in ipairs(open_condition) do
		if cur_stage < v then
			self.m_show_index = i
			break
		end
	end
	--巅峰新增加 武勋
	self.m_guild_feats = 0
	self:initShopGoodsRefreshCfg()
	self:initDataByType(self.m_data, self.m_shop_type)
	--
	self.m_shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
end

function M:initShopGoodsRefreshCfg()
	local shop_goods_refresh_cfg = ConfigManager:getCfgByName("shop_goods_refresh")
	local cfg_ids = {}
	for i, v in pairs(shop_goods_refresh_cfg or {}) do
		cfg_ids[i] = {}
		for i2, v2 in pairs(v) do
			table.insert(cfg_ids[i], i2)
		end
	end
	local function sortFunc(a, b)
		return a < b
	end
	for i, v in pairs(cfg_ids) do
		table.sort(v, sortFunc)
	end
	self.m_shop_goods_refresh_cfg_ids = cfg_ids
end

function M:getCurTimes()
	local buy_times = 0
	if self.m_cache_data[self.m_shop_type] and self.m_cache_data[self.m_shop_type].data.rtimes then
		buy_times = self.m_cache_data[self.m_shop_type].data.rtimes
	end
	return buy_times
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self:getCurTimes()
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(446,0)
	return max_times
end

function M:initDataByType(data, shop_type)
	local goods = data.goods or {}
	local shop_goods = ConfigManager:getCfgByName("shop_goods")
	local cur_shop_goods = shop_goods[self.m_shop_type] or {}
	local stage_list = cur_shop_goods.stage_list or {}
	local text = cur_shop_goods.text or {}
	local cur_stage = UserDataManager:getCurStage()
	local tips_msg = ""
	if shop_type == 5 then
		tips_msg = Language:getTextByKey("new_str_0612")
	elseif shop_type == 34 then --巅峰帮会新增加 feats 功勋
		tips_msg = self:getGuildShopText(data)
		self.m_guild_feats = data.feats
	else
		for i,v in ipairs(stage_list) do
			tips_msg = Language:getTextByKey(tostring(text[i]))
			if cur_stage >= v then
				break
			end
		end
		if tips_msg == "" then
			local shop_type = ConfigManager:getCfgByName("shop_type")
			local cur_shop_type = shop_type[self.m_shop_type] or {}
			tips_msg = Language:getTextByKey(cur_shop_type.moneyGuide or "")
		end
	end
	local show_data = {}

	self:processData(show_data, goods, self.m_shop_type)
	local peddler_goods = data.peddler_goods or {} -- 狐仙商人
	local fix_data = {}
	local tab_btn = self:getTabBtnByShopType(self.m_shop_type)
	local fixed_shop_type = data.fixed_shop_type or (tab_btn and tab_btn.fixed_shop_type)
	self:processData(fix_data, peddler_goods, fixed_shop_type)
	if #fix_data > 0 then
		local new_show_data = {}
		table.insertto(new_show_data, fix_data)
		table.insertto(new_show_data, show_data)
		show_data = new_show_data
	end
	self.m_cache_data[shop_type] = {data = data, list_data = show_data, tips_msg = tips_msg, fix_data = {}, show_shop_tips = _G.next(peddler_goods) ~= nil}
end

function M:processData(show_data, goods, shop_type)
	for k,v in pairs(goods) do
		local id = tonumber(k)
		if shop_type ~= 7 or (shop_type == 7 and id <= self.m_show_index) then
			local item = v.item or {}
			local hero_ids = {}
			if #item > 2 then
				if item[1] == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
					hero_ids = self:getCanEquipHeroIds(item[2])
				end
			end
			local item_data = RewardUtil:getProcessRewardData(item)
			table.insert(show_data, {id = id, data = v, hero_ids = hero_ids, item_data = item_data, shop_type = shop_type})
		end
	end
	self:shopSort(show_data)
end

function M:shopSort(show_data)
	local shopType = self.m_shop_type
	-- shopType 1=普通商店 2=公会商店 4=闯王商店 5=迷宫旅行商人 6=演武+巅峰商店 8=论剑商店 10=盗帅商店 11=聚宝山积分商店
	if shopType == 1 or shopType == 2 or shopType == 4  or shopType == 5 or shopType == 6 or shopType == 11  then
		--商铺显示的商品排序规则如下：
		--0. 未出售在前，已出售在后
		--1. 按照折扣排序，折扣高的在前，折扣低的在后
		--2. 相同折扣下，物品品质高的在前，品质低的在后
		--3. 元宝商品在前，铜币商品在后
		--4. 贵的在前
		table.sort(show_data, function(data1, data2)
			local remain1 = data1.data.remain
			local remain2 = data2.data.remain
			if remain1 == remain2 then
				local ex1 = data1.data.ex or 0
				local ex2 = data2.data.ex or 0
				if ex1 == ex2 then
					local discount1 = data1.data.discount or 0
					local discount2 = data2.data.discount or 0
					if discount1 == discount2 then
						local quality1 = data1.item_data.quality or 0
						local quality2 = data2.item_data.quality or 0
						if quality1 == quality2 then
							local data_type1 = data1.data.sell[1] or 0
							local data_type2 = data2.data.sell[1] or 0
							if data_type1 == data_type2 then
								local cost1 = data1.data.sell[3] or 0
								local cose2 = data2.data.sell[3] or 0
								if cost1 == cose2 then
									return data1.id > data2.id
								else
									return cost1 > cose2
								end
							else
								return data_type1 > data_type2
							end
						else
							return quality1 > quality2
						end
					else
						return discount1 < discount2
					end
				else
					return ex1 > ex2
				end
			else
				return remain1 > remain2
			end
			
		end)
	elseif shopType == 8 then
		--天级赛限定物品在前
		table.sort(show_data, function(data1, data2)
			local show_type1 = self:isLimit(data1)
			local show_type2 = self:isLimit(data2)
			if show_type1 == show_type2 then
				return data1.id < data2.id
			else
				return show_type1 > show_type2
			end
		end)
	else
		table.sort(show_data, function(data1, data2)
			return data1.id < data2.id
		end)
	end
end

function M:cacheExist(shop_type)
	return self.m_cache_data[shop_type] ~= nil
end

function M:getShowData(fixed_value)
	local curPlayerVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
	fixed_value = fixed_value or 0
	local tab_index = self.m_sel_tab_index or self.m_open_tab_index
	local tab_item = __TAB_BTN_NODE[tab_index] or {}
	if fixed_value == 0 then
		fixed_value = tab_item.fixed_value or 0
	end
	local data = self.m_cache_data[self.m_shop_type].list_data or {}
	local show_data = {}
	if tab_item.show_select_race == true and self.m_select_race_index ~= 1 then -- 筛选卡牌
		local select_race = self.m_select_race_index - 1
		for k,v in ipairs(data) do
			local fixed = v.data.fixed or 0
			if fixed == fixed_value then -- 是否固定物品 1固定 0随机
				if v.item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
					if v.item_data.item_cfg.race == select_race then
						if self:isPassByVipLevel(v.data.goods_id, curPlayerVipLevel,shop_goods_info_cfg) then
							table.insert(show_data, v)
						end
					end
				elseif v.item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
					if v.item_data.item_cfg.sort == 2 then -- 碎片类型
						local effect = v.item_data.item_cfg.effect or {}
						if #effect > 0 then
							local item_data = RewardUtil:getProcessRewardData(effect[1])
							if item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS and item_data.item_cfg.race == select_race then
								if self:isPassByVipLevel(v.data.goods_id, curPlayerVipLevel, shop_goods_info_cfg) then
									table.insert(show_data, v)
								end
							end
						end
					end
				end
			end
		end
	else
		for k,v in ipairs(data) do
			local fixed = v.data.fixed or 0
			if fixed == fixed_value then -- 是否固定物品 1固定 0随机
				if self:isPassByVipLevel(v.data.goods_id, curPlayerVipLevel,shop_goods_info_cfg) then
					table.insert(show_data, v)
				end
			end
		end
	end
	--if #show_data == 0 then
	--	show_data = self.m_cache_data[self.m_shop_type].fix_data or {}
	--end
	--类型为20的自选卡，奖励内容和赛季相关
	for i, v in ipairs(show_data) do
		GameUtil:updateItemEffect(v.item_data)
	end
	if self:checkIsHunt(self.m_shop_type) == true then --苗疆商店排序
		show_data = data
		for i, v in pairs(show_data) do
			for sell_i, sell_v in ipairs(v.data.sell) do
				local data = RewardUtil:getProcessRewardData(sell_v)
				if data.user_num < data.data_num then
					v.is_exchage = 1  --不可兑换
					break
				end
				v.surplus = v.data.max_purchase_time - v.data.cur_purchased_time
			end
			
		end
		table.sort(show_data,function(data1,data2)
			local data1_num = self:soreMiningShop(data1)
			local data2_num = self:soreMiningShop(data2)
			if data1_num == data2_num then
				return data1.id < data2.id
			else
				return data1_num < data2_num
			end
		end)
	end
	--巅峰商店拦截
	if self.m_shop_type == 34 then
		local guild_data = show_data
		show_data = {}
		local season = UserDataManager:getCurSeason()
		local shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
		for k,v in ipairs(guild_data) do
			local shopSeason = shop_goods_info_cfg[v.data.goods_id] and shop_goods_info_cfg[v.data.goods_id].season or season
			if v.data.feats <= self.m_guild_feats and shopSeason <= season then 
				table.insert(show_data,v)
			end
		end
	end
	return show_data
end

--- 商城道具增加vip限制
function M:isPassByVipLevel(itemId, playerVipLevel,shop_goods_info_cfg)
	if not itemId or not shop_goods_info_cfg then
		return false
	end
	if not shop_goods_info_cfg[itemId] then
		return false
	end
	local curData = shop_goods_info_cfg[itemId]
	local needVipLevel = curData.vip
	if needVipLevel then
		return playerVipLevel >= needVipLevel
	end
	return true
end

function M:soreMiningShop(data)
	if data.is_exchage == 1 then
		return 2
	elseif data.surplus <= 0 then
		return 3
	else
		return 1
	end
end

function M:getDataCount()
	local data = self.m_cache_data[self.m_shop_type].list_data or {}
	return #data
end

function M:getRefreshRemainingTime()
	local data = self.m_cache_data[self.m_shop_type].data or {}
	local next_refresh = data.next_refresh or 0
	return next_refresh - UserDataManager:getServerTime()
end

function M:getPeddlerNextTime()
	local data = self.m_cache_data[self.m_shop_type].data or {}
	local peddler_next_refresh = data.peddler_next_refresh or 0
	return peddler_next_refresh - UserDataManager:getServerTime()
end

function M:getTipsMsg()
	return self.m_cache_data[self.m_shop_type].tips_msg or ""
end

function M:getCurShopData()
	return self.m_cache_data[self.m_shop_type] or {}
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

function M:getShopTypeByIndex(index)
	local item = __TAB_BTN_NODE[index] or {}
	return item.shop_type or -1
end

function M:getTabBtnByShopType(shop_type)
	for k,v in pairs(__TAB_BTN_NODE) do
		if v.shop_type == shop_type then
			return v
		end
	end
	return {}
end

function M:getRefreshCost()
	--local cost_item = ConfigManager:getCommonValueById(333)
	--if cost_item and #cost_item > 0 then
	--	local data = RewardUtil:getProcessRewardData(cost_item)
	--	if data.user_num >= data.data_num and data.data_num > 0 then -- 优先消耗道具
	--		return cost_item
	--	end
	--end
	local data = self.m_cache_data[self.m_shop_type].data or {}
	local refresh_count = data.refresh_count or 0
	local btn_node = self:getTabBtnByShopType(self.m_shop_type)
	local refresh_key = btn_node.refresh_key or self.m_shop_type
	return GameUtil:getRefreshCost(refresh_count,refresh_key)
end

function M:getFreeRefreshFlag()
	if self.m_shop_type ~= 1 then
		return false, 0
	end
	local data = self.m_cache_data[self.m_shop_type].data or {}
	local refresh_count = data.refresh_count or 0
	local vip_cfg = ConfigManager:getCfgByName("vip")
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local vip_cfg_item = vip_cfg[vip_lv] or {}
	local shop_refresh_limit = vip_cfg_item.shop_refresh_limit or 0
	local free_count = shop_refresh_limit - refresh_count
	if free_count > 0 then -- 有免费
		return true, free_count
	end
	return false, 0
end

function M:getOrdinaryShopRefreshCost()
	local cost_item = ConfigManager:getCommonValueById(333)
	if cost_item and #cost_item > 0 then
		return cost_item
	end
end

function M:getOrdinaryShopRefreshTips()
	local data = self.m_cache_data[self.m_shop_type].data or {}
	local refresh_count = data.refresh_count or 0
	local need_refresh_time = 0
	local show_item = nil
	local shop_goods_refresh_cfg = ConfigManager:getCfgByName("shop_goods_refresh")
	shop_goods_refresh_cfg = shop_goods_refresh_cfg or {}
	local shop_goods_refresh_cfg_item = shop_goods_refresh_cfg[1] or {}
	local cfg_ids = self.m_shop_goods_refresh_cfg_ids[1] or {}
	local cur_stage = UserDataManager:getCurStage()
	for i, v in ipairs(cfg_ids) do
		if cur_stage <= v then
			break
		end
		local cfg_item = shop_goods_refresh_cfg_item[v]
		local refresh_time = cfg_item.refresh_time or {}
		local show_info = cfg_item.show_info or {}
		for i2, v2 in ipairs(refresh_time) do
			if refresh_count < v2 then
				need_refresh_time = v2 - refresh_count
				show_item = show_info[i2]
				break
			end
		end
	end
	return need_refresh_time, show_item
end

function M:getCanEquipHeroIds(equip_c_id)
	return GameUtil:getCanEquipHeroIds(equip_c_id)
end

function M:isCaution(cell_data)
	local caution = 0
	local goods_id = 0
	if cell_data.data and cell_data.data.goods_id then
		goods_id = cell_data.data.goods_id
	end
	local shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
	if shop_goods_info_cfg and shop_goods_info_cfg[goods_id] and shop_goods_info_cfg[goods_id].caution then
		caution = shop_goods_info_cfg[goods_id].caution
	end
	return caution
end

function M:isLimit(cell_data,has_num)
	local show_type = 0
	local goods_id = 0
	if cell_data.data and cell_data.data.goods_id then
		goods_id = cell_data.data.goods_id
	end
	if self.m_shop_goods_info_cfg and self.m_shop_goods_info_cfg[goods_id] and self.m_shop_goods_info_cfg[goods_id].show_type then
		show_type = self.m_shop_goods_info_cfg[goods_id].show_type
	end
	--[[
	local shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
	if shop_goods_info_cfg and shop_goods_info_cfg[goods_id] and shop_goods_info_cfg[goods_id].show_type then
		show_type = shop_goods_info_cfg[goods_id].show_type
	end
	]]--

	return show_type
end

function M:getShopCellOpenFlag(cell_data)
	local open_flag = true
	local tips_str = nil
	if cell_data.shop_type == 7 then
		local id = cell_data.id
		local open_condition = ConfigManager:getCommonValueById(420,{})
		local open_stage = open_condition[id] or 9999999999
		local cur_stage = UserDataManager:getCurStage()
		open_flag = cur_stage >= open_stage
		if not open_flag then
			local stage = ConfigManager:getCfgByName("stage")
			local stage_item = stage[open_stage] or {}
			local name = Language:getTextByKey(tostring(stage_item.map_point_name))
			tips_str = Language:getTextByKey("new_str_0954", name)
		end

	elseif cell_data.shop_type == 37 then
		local show_type = 0
		local goods_id = 0
		if cell_data.data and cell_data.data.goods_id then
			goods_id = cell_data.data.goods_id
		end
		if self.m_shop_goods_info_cfg and self.m_shop_goods_info_cfg[goods_id] and self.m_shop_goods_info_cfg[goods_id].show_type then
			show_type = self.m_shop_goods_info_cfg[goods_id].show_type
		end
		open_flag=show_type<=self.rise_id
		local name=""
		if show_type>0 then
			name =ConfigManager:getCfgByName("rise_arena_base")[show_type].name
		end
		name=Language:getTextByKey(name)
		tips_str = Language:getTextByKey("new_str_1141", name)
	end
	return open_flag, tips_str
end

--返回苗疆商店是否强制弹出提示窗
function M:getIsCaution(goods_id)
	local shop_goods_info2 = ConfigManager:getCfgByName("shop_goods_info2")
	return shop_goods_info2[goods_id].caution or 0
end

--是否是横板的商店（苗疆商店/皮肤商店）
function M:checkIsHunt(type_id)
	for k,v in pairs(__TAB_TYPE_HUNT) do
		if type_id == v then
			return true
		end
	end
	return false
end

function M:getHeroSkins(id)
	local skins = UserDataManager:getHeroSkins()
	if skins[tostring(id)] then
		return true
	end
	return false
end

-- 巅峰商店 
function M:getGuildShopText(data)
	local text = Language:getTextByKey("guild_high_war_new_0044")
	local goods = data.goods	
	local feats = data.feats
	local shop_goods_info_cfg = ConfigManager:getCfgByName("shop_goods_info")
	local last_feats = 10000
	for k,v in pairs(goods) do
		local shop_data =shop_goods_info_cfg and shop_goods_info_cfg[v.goods_id] or nil
		if shop_data and feats < shop_data.feats and last_feats > shop_data.feats then
			last_feats = shop_data.feats
		end
	end
	if last_feats == 10000 then 
		return text
	else
		return string.format(Language:getTextByKey("guild_high_war_new_0043"),last_feats)
	end
end

function M:isOpenActiive(open_id) --判断活动是否开启 并控制入口的显示与消失
	local open_flag = false
	local cfg = ConfigManager:getCfgByName("active") or {}
	local activeData = UserDataManager:getActivesDataByOpenId(open_id) or {}
	if next(cfg) or not activeData then
		for k,v in pairs(cfg) do 
			if v.open_id == open_id and v.version == activeData.version then
				if v.show_time =="" then
					return true
				end
				local show_time =GameUtil:stringToTimesTamp(v.show_time)
				local endtime = show_time- UserDataManager:getServerTime()
				if endtime > 0 then
					open_flag = true
				else
					open_flag = false
				end
				return open_flag
			end
		end
	else 
		return open_flag
	end
	return open_flag
end

function M:getGuildHighShopTime(open_id)
	local cfg = ConfigManager:getCfgByName("active") or {}
	local activeData = UserDataManager:getActivesDataByOpenId(open_id) or {}
	if next(cfg) then
		for k,v in pairs(cfg) do
			if v.open_id == open_id and v.version == activeData.version then
					local show_time =GameUtil:stringToTimesTamp(v.show_time)
					local endtime = show_time- UserDataManager:getServerTime()
				return endtime
			end
		end
	else
		return 0
	end
end

return M
