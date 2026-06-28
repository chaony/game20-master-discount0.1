local M = class("ArenaHigherView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigher"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local rank = {
	{name = "arena_str_0002", color = GlobalConfig.COMMON_COLLOR.COMMON_2, img = "ui_one"},
	{name = "arena_str_0003", color = GlobalConfig.COMMON_COLLOR.COMMON_6, img = "ui_two"},
	{name = "arena_str_0004", color = GlobalConfig.COMMON_COLLOR.COMMON_15, img = "ui_three"},
	{name = "arena_str_0005", color = GlobalConfig.COMMON_COLLOR.COMMON_4},
	{name = "arena_str_0006", color = GlobalConfig.COMMON_COLLOR.COMMON_4},
}
function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1, item_id = 1005})
	self:setTextByLanKey("list_title_text", "new_str_1113")
	self:setTextByLanKey("mine_score_text", "arena_str_0010")
	self:setTextByLanKey("close_title_text", "new_str_0401")
	self:setTextByLanKey("record_btn_text", "new_str_0233")
	self:setTextByLanKey("def_btn_text", "new_str_0234")
	self:setTextByLanKey("rank_btn_text", "new_str_0235")
	self:setTextByLanKey("reward_btn_text", "new_str_0224")
	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self:setTextByLanKey("score_title_text", "new_str_0380")
	self:setTextByLanKey("rank_title_text", "new_str_0077")
	self:setTextByLanKey("time_titile_text", "new_str_1058")
	self:setTextByLanKey("challenge_btn_text", "new_str_0386")
	self:setTextByLanKey("free_challenge_title_text", "new_str_0565")
	self.m_refresh_btn = self:findButton("refresh_btn")
	self.m_refresh_btn_text = self:findText("refresh_btn_text")
	self.self_arena_node = self:findGameObject("self_arena_node")
	self.m_time_text = self:findText("time_text")
	self.m_list_title_time_text = self:findText("list_title_time_text")

	--排名1 2 3 的格子 
	self.m_frist_rank = self:findGameObject("frist_rank"):GetComponent("LuaBehaviour");
	self.m_second_rank = self:findGameObject("second_rank"):GetComponent("LuaBehaviour")
	self.m_third_rank = self:findGameObject("third_rank"):GetComponent("LuaBehaviour")
	self.m_rank_behaviour = {
		[1] = self.m_frist_rank,
		[2] = self.m_second_rank,
		[3] = self.m_third_rank,
	}
	self.m_good1 = self:findGameObject("good1")
	self.m_good2 = self:findGameObject("good2")
	self.m_good3 = self:findGameObject("good3")
	self.m_good_list = {
		[1] = self.m_good1,
		[2] = self.m_good2,
		[3] = self.m_good3,
	}
	local show_coin_tab = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0})
	self:setImg(show_coin_tab.icon_name, show_coin_tab.atlas_name, "high_arena_coin_img")
	self:refreshUI()
	for i = 1,3 do
		self:setObjectVisible("good_red_point_"..i, RedPointUtil:hasRedPointById(2404) == true)
	end
	UserDataManager:removeRedDotByKey("high_arena")
end

function M:refreshUI()
	-- self:updateListScroll()
	self:updateLikeUsers(self.m_model.m_data.like);
	self:updateTopData()
	self:updateSelfData()
	self:refreshRedPoint()

	local cd_time = self.m_model.m_data.cd or 0
	if cd_time > 0 then
		self:setRefreshBtnEnabled(false)
		GameUtil:remainingTimeUpdate(self.m_control, "refresh_btn_time_update", self.m_refresh_btn_text, cd_time, "refresh_btn_time_end", 1)
	else
		self:setRefreshBtnEnabled(true)
	end
	local free_time = self.m_model:getFreeTimes()
	local cur_times = self.m_model:getCurTimes()
	self:setObjectVisible("max_times_text", free_time <= 0)
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  cur_times .. "/" .. self.m_model:getMaxTimes())
	self:setObjectVisible("challenge_btn_anim", free_time > 0)
	self:setTextByLanKey("free_challenge_text", "new_str_0568", free_time)
	self:setTimeText()

	--快速导航
	self:setObjectVisible("guide_btn", true)
	
	local time = self.m_model:getRemainingTime()
	local function tick(event, dt, remaining_time)
		self:setTimeText()
		if remaining_time <= 0 then
			self:setTextByLanKey("time_text", "activities_str_0007")
		end
	end
	EventDispatcher:registerTimeEvent("ArenaHigherTime", tick, 1, time)
	self:setBigTimeText()
	local big_time = self.m_model:getBigRemainingTime()
	local function tick(event, dt, remaining_time)
		self:setBigTimeText()
		if remaining_time <= 0 then
			self:setTextByLanKey("list_title_time_text", "activities_str_0007")
		end
	end
	EventDispatcher:registerTimeEvent("ArenaHigherBigTime", tick, 1, big_time)
	self:refreshWeekendDoubleUI()
end

function M:setTimeText()
	local time = self.m_model:getRemainingTime()
	local ft = GameUtil:formatTimeBySecond(time)
	self.m_time_text.text = ft
end

function M:setBigTimeText()
	local time = self.m_model:getBigRemainingTime()
	local ft = GameUtil:formatTimeBySecond(time)
	self.m_list_title_time_text.text = ft
end

function M:setRefreshBtnEnabled(enabled)
	self.m_refresh_btn.enabled = enabled
	self.m_refresh_btn_text.gameObject:SetActive(not enabled)
end

function M:updateTopData()
	local top_data = self.m_model:getTopData()
	local rank_data = {}
	for i, v in ipairs(top_data) do
		rank_data[v.rank] = v;
	end
	for i = 1, 3 do
		if rank_data[i] ~= nil then
			self:updateRank(self.m_rank_behaviour[i], rank_data[i]);
		else
			self:hideRank(self.m_rank_behaviour[i], i)
		end
	end
end

function M:refreshRedPoint()
    local record_flag1 = RedPointUtil:hasRedPointById(2401)
    self:setObjectVisible("record_btn_red_point", record_flag1)
	local record_flag2 = RedPointUtil:hasRedPointById(2402)
	record_flag2 = record_flag2 or RedPointUtil:hasRedPointById(2403)
	self:setObjectVisible("reward_btn_red_point", record_flag2)
end

function M:updateListScroll()
	local data = self.m_model:getListData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

--更新点赞的文本
function M:updateGoodNumTxt( rank, like )
	local good_num_txt = self.m_rank_behaviour[rank]:FindText("good_num_txt");
	good_num_txt.text = like;
end

function M:hideRank( cur_LuaBehaviour, rank )
	local hero = cur_LuaBehaviour:FindGameObject("hero");
	hero:SetActive(false);
	local good = cur_LuaBehaviour:FindGameObject("good"..rank);
	good:SetActive(false);
	local good_num_bg = cur_LuaBehaviour:FindGameObject("good_num_bg");
	good_num_bg:SetActive(false);
	local good_num_txt = cur_LuaBehaviour:FindGameObject("good_num_txt");
	good_num_txt:SetActive(false);

	local player_name_txt = cur_LuaBehaviour:FindText("player_name");
	player_name_txt.text = Language:getTextByKey("new_str_0079");
end

function M:updateRank( cur_LuaBehaviour, rank_data )
	if cur_LuaBehaviour ~= nil then
		--玩家名字
		local player_name_txt = cur_LuaBehaviour:FindText("player_name");
		player_name_txt.text = rank_data.user.name;
		----加载spine动画
		--local hero = cur_LuaBehaviour:FindGameObject("hero")
		--local cfg = ConfigManager:getPlayerPictureCfg(rank_data.user.avatar);
		--local spine_name = cfg.hero_spine;
		--GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
		local head_node = cur_LuaBehaviour:FindGameObject("head_node")
		GameUtil:setUserAvatar(head_node,rank_data.user, nil, nil,{show_flag = true, scale = 1.05})
		--点赞次数
		local good_num_txt = cur_LuaBehaviour:FindText("good_num_txt");
		good_num_txt.text = rank_data.like;
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "server_name", "s" .. tostring(rank_data.user.server))
	end                 
end

function M:updateLikeUsers( like )
	for i = 1, 3 do
		local rank_data = self.m_model:getTopDataByIndex(i);
		if rank_data ~= nil then
			if rank_data.user.is_robot == true then
				self:setObjectVisible("good"..i.."_bg", false)
				self:setObjectVisible("good"..i, false)
				LuaBehaviourUtil.setObjectVisible(self.m_rank_behaviour[i],"good_num_bg", false)
			end
		end
	end
	like = like or {}
	for i, v in ipairs(like) do
		local rank_data = self.m_model:getRankDataByUid(v);
		if rank_data ~= nil then
			local good = self.m_good_list[rank_data.rank]
			if not IsNull(good) then
				good:SetActive(false);
			end
		end
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local rank_text = luaBehaviour:FindText("rank_text")
	local rank_img = luaBehaviour:FindImage("rank_img")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local score_text = luaBehaviour:FindText("score_text")
	local power_text = luaBehaviour:FindText("power_text")
	local grading_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "grading_text", "new_str_0262")

	GameUtil:setUserAvatar(HeadNode,data.user,nil,nil,{show_flag = true, scale = 1.05})
	local room_id = self.m_model:getRoomId()
	rank_img.gameObject:SetActive(false)
	local cfg = ConfigManager:getHighArenaCfgByRank(data.rank)
	if room_id == 0 then -- 定级中
		grading_text.gameObject:SetActive(true)
		rank_text.gameObject:SetActive(false)
		score_text.transform.parent.gameObject:SetActive(false)
	else
		grading_text.gameObject:SetActive(false)
		rank_text.gameObject:SetActive(true)
		rank_text.text = Language:getTextByKey(tostring(cfg.division_name or "new_str_0076"))
		score_text.transform.parent.gameObject:SetActive(true)
	end
	name_text.text = Language:getTextByKey(data.user.name)
	local own_cfg = ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.rank)
	local own_high_coin = own_cfg.high_coin or 0
	local high_coin = cfg.high_coin or 0
	local diff_value = high_coin - own_high_coin
	score_text.text = (diff_value >= 0 and "+" or "") .. Language:getTextByKey("new_str_0294", diff_value)
	power_text.text = data.user.full_combat
	local free_time = self.m_model:getFreeTimes()
	local free_flag = free_time > 0
	local attack_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attack_btn_text", free_flag and "new_str_0231" or "new_str_0219")
	UIUtil.setLocalPosition(attack_btn_text.transform, free_flag and 0 or 15)
	LuaBehaviourUtil.setImg(luaBehaviour, "attack_btn", free_flag and "ui_chenganniu_xiao" or "ui_lvanniu_xiao", "common_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_img", not free_flag)
end

function M:updateSelfData()
	local luaBehaviour = self.self_arena_node:GetComponent("LuaBehaviour")
	local rank_text = luaBehaviour:FindText("rank_text")
	local rank_img = luaBehaviour:FindImage("rank_img")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local score_text = luaBehaviour:FindText("score_text")
	local power_text = luaBehaviour:FindText("power_text")
	local day_reward_text = luaBehaviour:FindText("day_reward_text")
	local double_day_reward_text = luaBehaviour:FindText("double_day_reward_text")
	local grading_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "grading_text", "new_str_0262")

	local user_data = UserDataManager.user_data.user_status
	GameUtil:setUserAvatar(HeadNode,user_data,nil,nil,{show_flag = true, scale = 1.05})
	local room_id = self.m_model:getRoomId()
	self:setObjectVisible("reward_btn", room_id ~= 0)
	rank_img.gameObject:SetActive(false)
	local cfg = ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.rank)
	if room_id == 0 then -- 定级中
		grading_text.gameObject:SetActive(true)
		rank_text.gameObject:SetActive(false)
		score_text.text = Language:getTextByKey("new_str_0263")
	else
		grading_text.gameObject:SetActive(false)
		local rank = self.m_model.m_data.rank or 0
		if rank <= 0 then
			rank_text.text = Language:getTextByKey("new_str_0076")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "own_segment_node", false)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "own_segment_rank_text", "new_str_0076")
		else
			if rank >= 1 and rank <= 3 then
				rank_text.gameObject:SetActive(false)
				rank_img.gameObject:SetActive(true)
				local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
				LuaBehaviourUtil.setImg(luaBehaviour,"rank_img", top_three_item.rank, top_three_item.atlas)
			else
				rank_text.gameObject:SetActive(true)
				rank_img.gameObject:SetActive(false)
				rank_text.text = tostring(rank)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "own_segment_rank_text", cfg.division_name or "new_str_0076")
			local cfg = ConfigManager:getHighArenaCfgByRank(rank)
			local segment_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "own_segment_node", true)
			CommonUIUtil:setSegmentInfo(segment_node, cfg)
		end
		score_text.text = tostring(self.m_model.m_data.score or 0)
	end
	
	local name_key = user_data.name
	if name_key == nil or name_key == "" then
		name_key = "new_str_0141"
	end
	local high_coin_num =  cfg.high_coin or 0
	local buff_num = self.m_model:checkTeams()
	if buff_num > 0 then
		high_coin_num = high_coin_num * ((100+buff_num)/100)
	end
	day_reward_text.text = Language:getTextByKey("new_str_0294", math.ceil(high_coin_num))
	double_day_reward_text.text = "+"..Language:getTextByKey("new_str_0294", math.ceil(high_coin_num) )
	name_text.text = Language:getTextByKey(name_key)
	power_text.text = tostring(self.m_model.m_data.top_15_combat or 0)
	local arena_coin_store = self.m_model.m_data.arena_coin_store or 0
	local com_value = ConfigManager:getCommonValueById(86, 99999999)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_coin_text", "new_str_0053", arena_coin_store, com_value)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_rank_text", "new_str_0305", self.m_model.m_data.score_rank or 0)
	self:setObjectVisible("box_reward_btn_anim", arena_coin_store > 0)
	--加载spine动画
	local hero = luaBehaviour:FindGameObject("own_hero_spine")
	local cfg = ConfigManager:getPlayerPictureCfg(user_data.avatar)
	GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
end

--更新周末双倍显示
function M:refreshWeekendDoubleUI()
	local bl = self.m_model:checkWeekendDouble()
	self:setObjectVisible("double_img", bl)
	self:setObjectVisible("double_day_reward_text", bl)
	self:setObjectVisible("weekend_double_text", bl)
	self:setTextByLanKey("weekend_double_text", "arena_str_0035")
end



function M:destroy()
	EventDispatcher:unRegisterEvent("ArenaHigherBigTime")
	EventDispatcher:unRegisterEvent("ArenaHigherTime")
	EventDispatcher:unRegisterEvent("refresh_btn_time_update")
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M