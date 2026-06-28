--- 玩家属性
---@class CommonAttrNode:OOUIbase
local M = class("CommonAttrNode",LikeOO.OOUIbase)

M.m_uiName = "Common/CommonAttrNode"
M.m_iphoneXAdapter = true
local __ATTR_TAB = {
	[1] = {
		-- 金币 钻石
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[2] = {
		-- 公会点 钻石
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.GUILD_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[3] = {
		-- 英灵币 钻石
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.HERO_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[4] = {
		-- 迷宫币 钻石
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MAZE_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[5] = {
		-- 迷宫币 钻石
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_gacha_1", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1009, 0 } },
		{ key = "m_gacha_2", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1010, 0 } },
		{ key = "m_friend", data = { RewardUtil.REWARD_TYPE_KEYS.FRIEND_COIN, 0, 0 } },
	},
	[6] = {
		-- 竞技场币 钻石
		{ key = "m_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0 } },
		{ key = "m_top_arena", data = { RewardUtil.REWARD_TYPE_KEYS.TOP_ARENA_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[7] = {
		-- 竞技场币 钻石
		{ key = "m_tree_coin", data = { RewardUtil.REWARD_TYPE_KEYS.CRYSTAL, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[8] = {
		-- 金币 英雄经验 突破丹
		{ key = "m_hero_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_hero_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0 } },
		{ key = "m_hero_dust", data = { RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0 } },
	},
	[9] = {
		-- 金币 钻石 锦囊玉轴资源币
		{ key = "m_activ_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_activ_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_active_jn", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5050, 0 } },
	},
	[10] = {
		-- 金币 钻石 刷新券
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5055, 0 } },
	},
	[11] = {
		-- 钻石 前缘卷
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1011, 0 } },
	},
	[12] = {
		-- 金币 钻石 盗帅令
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_thief_coin", data = { RewardUtil.REWARD_TYPE_KEYS.THIEF_COIN, 0, 0 } },
	},
	[13] = {
		-- 钻石
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[14] = {
		-- 钻石 银司南 金司南
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_1", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1105, 0 } },
		{ key = "m_2", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1106, 0 } },
	},
	[15] = {
		-- 金币 钻石 争霸玉佩
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_race_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.RACE_ARENA_COIN, 0, 0 } },
		{ key = "m_top_race_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.TOP_RACE_ARENA_COIN, 0, 0 } },
	},
	[16] = {
		-- 金币 钻石 修为
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_dust", data = { RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0 } },
	},
	[17] = {
		-- 金币 钻石 巅峰币
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_top_arena", data = { RewardUtil.REWARD_TYPE_KEYS.TOP_ARENA_COIN, 0, 0 } },
	},
	[18] = {
		-- 金币 钻石 竞猜币
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_top_arena", data = { RewardUtil.REWARD_TYPE_KEYS.QUIZ_COIN, 0, 0 } },
	},
	[19] = {
		-- 金币 钻石 竞猜币
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_top_arena", data = { RewardUtil.REWARD_TYPE_KEYS.RICHMAN_POINT, 0, 0 } },
	},
	[20] = {
		-- 代金券 钻石
		{ key = "m_voucher", data = { RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[21] = {
		-- 竞技场币 钻石
		{ key = "m_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0 } },
		{ key = "m_top_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.TOP_RACE_ARENA_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[22] = {
		-- 森罗币 寒山币 万岛币  炎火币
		{ key = "m_mining_gold_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MINING_GOLD_COIN, 0, 0 } },
		{ key = "m_mining_wood_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MINING_WOOD_COIN, 0, 0 } },
		{ key = "m_mining_water_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MINING_WATER_COIN, 0, 0 } },
		{ key = "m_mining_fire_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MINING_FIRE_COIN, 0, 0 } },
	},
	[23] = {
		-- 陨星矿
		{ key = "m_mining_gold_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1418, 0 } },
		{ key = "m_mining_wood_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1103, 0 } },
		{ key = "m_mining_water_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1417, 0 } },
	},
	[24] = {
		-- 赛季成就积分
		{ key = "m_season_coin", data = { RewardUtil.REWARD_TYPE_KEYS.SEASON_COIN, 0, 0 } },
	},
	[25] = {
		-- 赛季成就积分
		{ key = "m_season_coin", data = { RewardUtil.REWARD_TYPE_KEYS.SEASON_COIN, 0, 0 } },
		{ key = "m_title_piece_coin", data = { RewardUtil.REWARD_TYPE_KEYS.TITLE_PIECE_COIN, 0, 0 } },
	},
	[26] = {
		-- 双旦灵鹿迎新--鹿铃
		{ key = "m_lingdang", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5341, 0 } },
	},
	[27] = {
		-- 天命化星--天命石
		{ key = "m_tianmingshi", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1431, 0 } },
	},
	[28] = {
		-- 铸剑龙渊
		{ key = "m_zhujianjingshi", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5357, 0 } },
	},
	[29] = {
		-- 新年活动
		{ key = "m_spring_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5365, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5366, 0 } },
	},
	[30] = {
		-- 竞技场币 钻石
		{ key = "m_arena_coin", data = { RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0 } },
		{ key = "m_huashan_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ARENA_MOUNTAIN_HUA_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[31] = {
		-- 苗疆银帕  苗疆绣饰 
		{ key = "m_act_mining_silver", data = { RewardUtil.REWARD_TYPE_KEYS.ACT_MINING_SILVER, 0, 0 } },
		{ key = "m_act_mining_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ACT_MINING_COIN, 0, 0 } },
	},
	[32] = {
		-- 钻石 秘境探宝资源币
		{ key = "m_activ_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_active_meihua", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5395, 0 } },
		{ key = "m_active_shanzi", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5396, 0 } },
	},
	[33] = {
		-- 館裡藏金
		{ key = "m_activ_chuizi", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5403, 0 } },
		{ key = "m_activ_guanzi", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5366, 0 } },
	},
	[34] = {
		-- 皮肤券
		{ key = "m_ship_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5146, 0 } },
	},
	[35] = {
		-- 武林通宝
		{ key = "m_myth_coin", data = { RewardUtil.REWARD_TYPE_KEYS.MYTH_COIN, 0, 0 } },
	},
	[36] = {
		-- 金币 钻石 锦囊玉轴资源币
		{ key = "m_activ_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_activ_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_active_jn", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5440, 0 } },
	},
	[37] = {
		-- 小浣熊砸罐子
		{ key = "m_spring_coin", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5412, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5413, 0 } },
		
	},
	[38] = {
		-- 金币 宠物经验丹
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_pet_exp", data = { RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0 } },
	},
	[39] = {
		-- 元宝 宠物经验丹
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_pet_exp", data = { RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0 } },
	},
	[40] = {
		-- 元宝 宠物币
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_pet_coin", data = { RewardUtil.REWARD_TYPE_KEYS.PET_COIN, 0, 0 } },
	},
	[41] = {
		-- 宠物币 心情道具
		{ key = "m_pet_coin", data = { RewardUtil.REWARD_TYPE_KEYS.PET_COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	
	},
	[42] = {
		--代金券 金币 钻石 锦囊玉轴资源币
		{ key = "m_voucher", data = { RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 0, 0 } },
		{ key = "m_activ_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_activ_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "m_active_jn", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5440, 0 } },
	},
	[43] = {
		--威望碎片
		{ key = "m_active_jn", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5563, 0 } },
		{ key = "m_active_jn", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5564, 0 } },
	},
	[44] = {
		--天赐祈福
		{ key = "m_heaven_stone", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5582, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[45] = { 
		{key = "ghw_coin", data = { RewardUtil.REWARD_TYPE_KEYS.GHW_COIN, 0, 0 }}
	},
	[46] = {
		{key = "full_service_coin", data = { RewardUtil.REWARD_TYPE_KEYS.FULL_SERVICE_COIN, 0, 0 }}
	},
	[47] = {
		--瑞兔小斋
		--{ key = "m_heaven_stone", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5412, 1 } },
		{ key = "m_activ_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
	},
	[48] = {
		{key = "guild_talent_coin", data = { RewardUtil.REWARD_TYPE_KEYS.GUILD_TALENT_COIN, 0, 0 }}
	},
	[49] = {
		{key = "talent_attr_coin", data = { RewardUtil.REWARD_TYPE_KEYS.TALENT_ATTR_COIN, 0, 0 }}
	},
	[50] = {
		{key = "talent_buff_coin", data = { RewardUtil.REWARD_TYPE_KEYS.TALENT_BUFF_COIN, 0, 0 }}
	},
	[51] = {
		-- 侠隐宝玉 唤神令
		--{ key = "m_hero_sp_coin", data = { RewardUtil.REWARD_TYPE_KEYS.HERO_SP_COIN, 0, 0 } },
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1434, 0 } },
	},
	[52] = {
		-- 神魂结晶
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 1435, 0 } },
	},
	[53] = {
		-- 侠隐宝玉
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.HERO_ISLE_COIN, 1435, 0 } },
	},
	[54] = {
		-- 通用秘籍残卷
		{ key = "m_item", data = { RewardUtil.REWARD_TYPE_KEYS.ITEM,200001, 0 } },
	},
	[55] = {
		-- 争锋商店
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "m_diamond", data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 } },
		{ key = "icon_daobi", data = { RewardUtil.REWARD_TYPE_KEYS.RISE_ARENA_COIN,200001, 0 } },
	},
	[56] = {
		-- 酒楼金券
		{ key = "a_icon_jiulouhuobi", data = { RewardUtil.REWARD_TYPE_KEYS.HOTEL_COIN, 0, 0 } },
	},
	[57] = {
		-- rta
		{ key = "m_coin", data = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } },
		{ key = "a_icon_rta2", data = { RewardUtil.REWARD_TYPE_KEYS.RTA_WD_COIN, 0, 0 } },
		{ key = "a_icon_rta1", data = { RewardUtil.REWARD_TYPE_KEYS.RTA_HM_COIN,0, 0 } },
	},
}

function M:onCreate()
	self.m_exp_slider = self:findSlider("exp_slider")
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onEnter()
	self:setObjectVisible("title_node", false)
	self.m_attr_nodes = {}
	for i=1,4 do
		local attr_node = self:findGameObject("attr_node_" .. i)
		local attr_icon = self:findGameObject("attr_icon_" .. i)
		local attr_text = self:findGameObject("attr_text_" .. i)
		self.m_attr_nodes[i] = {attr_node = attr_node, attr_icon = attr_icon, attr_text = attr_text}
	end
	local mode = self.m_params.mode or 1
	self.m_attr_tab_items = table.copy(__ATTR_TAB[mode] or {})
	local item_id = self.m_params.item_id
	if item_id and item_id > 0 then
		table.insert(self.m_attr_tab_items, {key = "m_item", data = {RewardUtil.REWARD_TYPE_KEYS.ITEM, item_id, 0}})
	end
	local item_ids = self.m_params.item_ids or {}
	for k,v in pairs(item_ids) do
		table.insert(self.m_attr_tab_items, {key = "m_item", data = {RewardUtil.REWARD_TYPE_KEYS.ITEM, v, 0}})
	end
    self:refreshUI()    
end

function M:onButtonClick(obj, name)
	local mode = self.m_params.mode or 1
	for k,v in pairs(self.m_attr_tab_items) do
		if v.icon_img == name then
			GameUtil:lookInfoTips(self.m_control, {click_transform = obj.transform, data = v.data})
			self:updateMsg(name, obj)
			local full_btn_name = self.m_uiName .. "/" .. name
			GameUtil:playBtnSound(full_btn_name)
		    break
		end
	end
end

function M:changeAttrsByMode(mode)
	self.m_params.mode = mode
	self.m_attr_tab_items =  __ATTR_TAB[mode] or {}
    self:refreshUI()   
end

function M:refreshUI()
	for i,nodes in pairs(self.m_attr_nodes) do
		local v = self.m_attr_tab_items[i]
		nodes.attr_node:SetActive(v ~= nil)
		if v then
			local item_data = RewardUtil:getProcessRewardData(v.data)
			local user_num = item_data.user_num
			if self[v.key] ~= user_num then
				UIUtil.setImg(nodes.attr_icon.transform, item_data.icon_name, "item_icon")
				user_num = GameUtil:formatValueToString(user_num)
				UIUtil.setText(nodes.attr_text.transform, tostring(user_num))
				self[v.key] = user_num
				v.icon_img = nodes.attr_icon.name
			end
		end
	end
end

--主动刷新
function M:initiativeRefresh(curr_data)
	for i,nodes in pairs(self.m_attr_nodes) do
		local v = self.m_attr_tab_items[i]
		nodes.attr_node:SetActive(v ~= nil)
		if v then
			local item_data = RewardUtil:getProcessRewardData(v.data)
			local user_num = curr_data[item_data.data_type] or item_data.user_num
			if self[v.key] ~= user_num then
				UIUtil.setImg(nodes.attr_icon.transform, item_data.icon_name, "item_icon")
				user_num = GameUtil:formatValueToString(user_num)
				UIUtil.setText(nodes.attr_text.transform, tostring(user_num))
				self[v.key] = user_num
				v.icon_img = nodes.attr_icon.name
			end
		end
	end
end


function M:setTitle(title_str)
	self:setObjectVisible("title_node", true)
	self:setText("title_text", tostring(title_str))
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "net_data_back" then
		self:refreshUI()
	end
end

function M:setBGVisible(visible)
	self:setObjectVisible("bg_img", visible)
end

function M:setVisible(visible)
	self:setObjectVisible("content_node", visible)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M