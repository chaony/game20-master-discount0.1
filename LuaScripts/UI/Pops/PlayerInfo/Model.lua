---@class PlayerInfoModel:OODataBase
local M = class("PlayerInfoModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{title_key = "new_str_0118", btn_key = "formation_togglebtn", lua_name = "UI.Pops.PlayerInfo.PlayerThreeFormationNode", btn_text = "formation_btn_text", text_key = "new_str_0118", url_key = "user_user_detail_info", open = true, team_sort = "high_arena_defense" }, -- 多阵型
	{title_key = "new_str_0118", btn_key = "formation_togglebtn2", lua_name = "UI.Pops.PlayerInfo.PlayerFormationNode", btn_text = "formation_btn_text2", text_key = "new_str_0118", url_key = "user_user_detail_info", open = true, team_sort = "local_arena_defense" }, -- 阵型
	{title_key = "new_str_0084", btn_key = "info_togglebtn", lua_name = "UI.Pops.PlayerInfo.PlayerInfoNode", btn_text = "info_btn_text", text_key = "new_str_0117", url_key = "user_user_detail_info", open = true, team_sort = nil }, -- 个人信息
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_look_model = self.m_params.look_model or 0
	self.show_battle_array = true
	local btn_tab = nil
	if self.m_look_model == 1 then -- 爬塔查看玩家
		self.m_open_tab_index = self.m_params.open_tab_index or 2
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 1
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
	elseif self.m_look_model == 2 then -- 高阶竞技场查看玩家
		--self.show_battle_array = self.m_params.show_battle_array --是否显示编队阵容
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
	elseif self.m_look_model == 3 then -- 联盟查看玩家
		self.m_open_tab_index = self.m_params.open_tab_index or 3
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = false
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		self.m_guild_data = self.m_params.guild or {}
	elseif self.m_look_model == 4 then -- 查看师傅/徒弟
		self.m_open_tab_index = self.m_params.open_tab_index or 3
		self.m_etime = self.m_params.etime
		self.m_status = self.m_params.status
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = false
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
	elseif self.m_look_model == 5 then -- 巅峰论剑查看玩家
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "top_arena"
	elseif self.m_look_model == 6 then -- 天级赛
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "top_race_arena_defense"
	elseif self.m_look_model == 7 then -- 五行联赛
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "season_race_arena_defense"
	elseif self.m_look_model == 8 then -- 华山论剑
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "arena_mountain_hua_defense"
	elseif self.m_look_model == 9 then	-- 风云擂台
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= (self.m_open_tab_index == 1 and 2 or 1)
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = self.m_params.open_tab_index == 1 and "friend_arena_defense3" or "friend_arena_defense1"
	elseif self.m_look_model == 10 then -- 天级赛
		self.m_open_tab_index = self.m_params.open_tab_index or 1
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 2
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "myth_arena_defense"
	elseif self.m_look_model == 11 then  --剑试天下 boss战排行
		self.m_open_tab_index = self.m_params.open_tab_index or 2
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = k ~= 1
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
		btn_tab.team_sort = "full_service_boss"
	else
		self.m_open_tab_index = self.m_params.open_tab_index or 3
		for k,v in pairs(__TAB_BTN_NODE) do
			v.open = false
		end
		btn_tab = __TAB_BTN_NODE[self.m_open_tab_index]
	end
	if self.m_look_model == 5 then 
		self:getData("user_user_detail_info", {target_uid = self.m_params.uid, team_sort = btn_tab.team_sort, default_team_sort = "high_arena_defense"})
	elseif self.m_look_model == 9 then
		self:getData("friend_arena_select_defend_teams", {defend_uid = self.m_params.uid, team_type = self.m_params.team_type, fair = self.m_params.fair})
	else
		self:getData("user_user_detail_info", {target_uid = self.m_params.uid, team_sort = btn_tab.team_sort})	
	end
	
end

function M:onEnter()
	self.m_uid = self.m_params.uid
	self.m_version = self.m_params.vsn or 0
	self.m_rank = self.m_params.rank
	self.m_score = self.m_params.score
	self.m_parent_view = self.m_params.parent_view
	self.m_sel_tab_index = nil
	self.m_cache_data = {}
	self:initData(self.m_data)
end

function M:initData(data, index)
	-- self.m_cache_data[index or self.m_open_tab_index] = data
	self.m_data = data or self.m_data
end

function M:getDataByIndex(index)
	-- return self.m_cache_data[index or self.m_open_tab_index]
	return self.m_data
end

function M:getShowHeros(data)
	local show_data = {}
	local team = data.view_team or {}
	local heros = data.view_heros or {}
	for k,v in pairs(team) do
		local hero = heros[v]
		if hero then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 0})
			data.quality = hero.evo
			data.card_id = v
			data.hero_data = hero
			table.insert(show_data, data)
		end
	end
	return show_data
end

function M:getAtkHeros(data)
	local total_combat = 0
	local show_data = {}
	local atk_team = data.team or {}
	local atk_heros = data.heros or {}
	for k,v in pairs(atk_team) do
		local hero = atk_heros[v]
		if hero then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 0})
			data.quality = hero.evo
			data.card_id = v
			data.hero_data = hero
			table.insert(show_data, data)
			total_combat = total_combat + (hero.combat or 0)
		end
	end
	return show_data, total_combat
end

-- 以前的逻辑没用了，直接返回
function M:getLookHerosData(data)
	return data
end

function M:getMultTeamShowData()
	local show_data = {}
	local high_arena_defense = self.m_data.teams or {}
	local heros = self.m_data.heros or {}
	local team_nums = 3
	if self.m_look_model == 6 then
		team_nums  = 2
	end
	for i = 1,team_nums do
		local team = high_arena_defense[i] or {}
		local team_heros_data = {}
		local total_combat = 0
		for index = 1,5 do
			local hero_id = team[index] or ""
			local hero_data = heros[hero_id]
			local data = nil
			if hero_data then
				data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = hero_id
				data.hero_data = hero_data
				total_combat = total_combat + (hero_data.combat or 0)
			end
			team_heros_data[index] = data or {}
		end
		show_data[i] = {team_heros_data = team_heros_data, total_combat = total_combat}
	end
	return show_data
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

function M:unionHandleBtnIsShow()
	if self.m_look_model == 3 then
		local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
		if self.m_guild_data.guild.president == self_uid then
			return true
		else
			for i,v in ipairs(self.m_guild_data.guild.elders) do
				if v == self_uid then
					return true
				end
			end
		end
	end
	return false
end

function M:getCountDownTime()
	if self.m_look_model == 4 and self.m_etime then
		local sep_tim = self.m_etime + 86400 
		local tim = sep_tim - UserDataManager:getServerTime() 
		return GameUtil:formatTimeBySecond(tim)
	end
end

return M
