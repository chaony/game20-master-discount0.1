local M = class("HeroBossView",LikeOO.OOPopBase)

M.m_uiName = "Activities/HeroBoss/HeroBoss"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "hero_boss_text_001")
	self:setTextByLanKey("challenge_btn_text", "hero_boss_text_002")
	self:setTextByLanKey("intercept_btn_text", "hero_boss_text_003")
	self:setTextByLanKey("tog_1_text", "hero_boss_text_005")
	self:setTextByLanKey("tog_2_text", "hero_boss_text_006")
	self:setTextByLanKey("rank_label_text", "hero_boss_text_007")
	self:setTextByLanKey("score_label_text", "hero_boss_text_010")
	self:setTextByLanKey("reward_btn_text", "hero_boss_text_011")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	for i = 1, 2 do
		local tog_btn = self:findToggle("tog_" .. i)
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, i) end, nil, self.m_uiName)
	end
	self:refreshUI()
end

function M:refreshUI()
	local cfg = self.m_model.m_cfg
	local challenge_max_times = cfg.challenge_max_times
	local loot_max_times = cfg.loot_max_times
	local hero_id = cfg.hero_id
	self:setTextByLanKey("challenge_times_text", "hero_boss_text_004", challenge_max_times - self.m_model.m_data.challenge_times)
	self:setTextByLanKey("intercept_times_text", "hero_boss_text_004", loot_max_times - self.m_model.m_data.loot_times)
	self:refreshHero(hero_id)
	self:switchTabUpdate(true, 2)
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self.m_toggle = update_key
		self:updateMsg("tog_" .. update_key)
		for i = 1, 2 do
			local tab_text = self:findText("tog_" .. i .. "_text")
			tab_text.color = update_key == i and Color(208/255,193/255,243/255,1) or Color(101/255,82/255,148/255,1)
		end
		self:setTextByLanKey("player_label_text", update_key == 2 and "hero_boss_text_008" or "hero_boss_text_009")
	end
end

function M:refreshRank(ranks, myRank)
	self:updateLoopScroll(ranks)
	self:updateRankCell(0, self:findGameObject("own_info"), myRank)
end

function M:updateLoopScroll(ranks)
	local data = ranks
	self:setObjectVisible("common_tips_node", #data <= 0)
	if self.m_loop_scroll_view == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRankCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_toggle == 2 then
					self:updateMsg(click_name, {id = index , cell_data = cell_data})
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateRankCell(index, cell_object, cell_data)
	local rank = cell_data.rank or 0
	local user = cell_data.user or {}
	local top_three_flag = rank >= 1 and rank <= 3
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_top_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
	if top_three_flag == true then
		local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
		if top_three_item then
			LuaBehaviourUtil.setImg(luaBehaviour,"rank_top_img", top_three_item.rank2, top_three_item.atlas2)
			local class_name_img = UIUtil.findImage(cell_object.transform,"rank_top_img")
			class_name_img:SetNativeSize()
		end
	end
	if rank < 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
	end
	--local score = GameUtil:formatValueToString(cell_data.score or 0)
	local score = cell_data.score or 0
	LuaBehaviourUtil.setText(luaBehaviour, "score_text",  score)
	if self.m_toggle == 1 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false)
		if user.name == nil or user.name == "" then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "union_str_0047")
			LuaBehaviourUtil.setText(luaBehaviour, "rank_text", "")
			LuaBehaviourUtil.setText(luaBehaviour, "score_text",  "")
		else
			LuaBehaviourUtil.setText(luaBehaviour, "name_text", "<color=#c58461>" .. user.name .. "</color>")
		end
	else
		if user.guild_name == nil or user.guild_name == "" then
			LuaBehaviourUtil.setText(luaBehaviour, "name_text", user.name)
		else
			LuaBehaviourUtil.setText(luaBehaviour, "name_text", user.name .. "\n<size=20><color=#c58461>" .. user.guild_name .. "</color></size>")
		end
		local HeadNode = luaBehaviour:FindGameObject("head_node")
		HeadNode:SetActive(true)
		GameUtil:setUserAvatar(HeadNode, user, nil, nil,{show_flag = true, scale = 1})
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img", false)
	end
end

function M:refreshHero(hero_id)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = cfg.skin[1]}, cfg)
	local spine_name = skin_cfg.hero_spine or "hero_0001_SkeletonData"
	self:setObjectVisible("hero_spine", true)
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
	--[[
	--evo
	self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui","hero_evo")
	--name
	local class_str = Language:getTextByKey(cfg.class)
	local name_str = Language:getTextByKey(skin_cfg.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	--race
	local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	]]--
end

return M