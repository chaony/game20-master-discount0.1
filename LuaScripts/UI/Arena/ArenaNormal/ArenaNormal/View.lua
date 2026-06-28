---@class ArenaNormalView:OOPopBase
---@field m_model ArenaNormalModel
local M = class("ArenaNormalView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaNormalRank/ArenaPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1, item_id = 1004})
	--self.m_attr_node:setTitle(Language:getTextByKey("tid#arena_explain2"))
	self:setTextByLanKey("list_title_text", "arena_str_0008")
	self:setTextByLanKey("record_btn_text", "new_str_0233")
	self:setTextByLanKey("def_btn_text", "new_str_0234")
	self:setTextByLanKey("rank_btn_text", "new_str_0235")
	self:setTextByLanKey("reward_btn_text", "new_str_0224")
	self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("refresh_btn_text", "union_str_1035")
	self:setTextByLanKey("close_title_text", "tid#arena_explain1")
	self:setTextByLanKey("rank_first_score_title_text", "new_str_0375")
	self:setTextByLanKey("own_power_title_text", "friend_str_0041")
	self:setTextByLanKey("score_title_text", "new_str_0566")
	self:setTextByLanKey("rank_title_text", "new_str_0567")
	self:setTextByLanKey("free_challenge_title_text", "new_str_0565")
	self:setTextByLanKey("room_title_text", "new_str_0688")
	self:setTextByLanKey("time_titile_text", "new_str_1058")
	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self:setTextByLanKey("challenge_btn_text", "new_str_0386")

	self.self_arena_node = self:findGameObject("self_arena_node")
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
	self.m_gray_img = self:findImage("gray_img")
	self.m_time_text = self:findText("time_text")
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
	for i = 1,3 do
		self:setObjectVisible("good_red_point_"..i, RedPointUtil:hasRedPointById(1102) == true)
	end
	UserDataManager:removeRedDotByKey("arena")
	self:refreshUI()
end

function M:refreshUI()
	--self:updateListScroll()
	self:updateLikeUsers(self.m_model.m_data.like);
	self:updateTopData()
	self:updateSelfData()
	self:refreshRedPoint()
	local free_time = self.m_model:getFreeTimes()
	self:setObjectVisible("max_times_text", free_time <= 0)
	local cur_times = self.m_model:getCurTimes()
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  cur_times .. "/" .. self.m_model:getMaxTimes())
	self:setObjectVisible("challenge_btn_anim", free_time > 0)
	self:setTextByLanKey("free_challenge_text", "new_str_0568", free_time)
	self:setTextByLanKey("room_num_text", tostring(self.m_model.m_data.room_id))
	self:updateArenaRewardWeek()
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
	EventDispatcher:registerTimeEvent("ArenaNormalTime", tick, 1, time)
end

function M:setTimeText()
	local time = self.m_model:getRemainingTime()
	local ft = GameUtil:formatTimeBySecond(time)
	self.m_time_text.text = ft
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

function M:updateListScroll()
	--local data = self.m_model:getListData()
	local data = self.m_model:getTopData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end,
			ui_name = self.m_uiName
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
		--加载spine动画
		--local hero = cur_LuaBehaviour:FindGameObject("hero")
		--local cfg = ConfigManager:getPlayerPictureCfg(rank_data.user.avatar);
		--local spine_name = cfg.hero_spine;
		--GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
		local HeadNode = cur_LuaBehaviour:FindGameObject("HeadNode")
		GameUtil:setUserAvatar(HeadNode, rank_data.user, nil, nil, {show_flag = true, scale = 0.75})
		local info_node = cur_LuaBehaviour:FindGameObject("info_node")
		local title_id = rank_data.user.title
		if info_node then
			if title_id and title_id ~= 0 then
				info_node.transform.anchoredPosition = Vector3.New(0, -20, 0)
			else
				info_node.transform.anchoredPosition = Vector3.New(0, 0, 0)
			end
		end
		--点赞次数
		local good_num_txt = cur_LuaBehaviour:FindText("good_num_txt");
		good_num_txt.text = rank_data.like;
	end
end

function M:updateLikeUsers( like )
	like = like or {}
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

	GameUtil:setUserAvatar(HeadNode, data.user, nil, nil, {show_flag = true, scale = 1.05})
	local room_id = self.m_model:getRoomId()
	if room_id == 0 then -- 定级中
		grading_text.gameObject:SetActive(true)
		rank_text.gameObject:SetActive(false)
		rank_img.gameObject:SetActive(false)
		score_text.transform.parent.gameObject:SetActive(false)
	else
		grading_text.gameObject:SetActive(false)
		if data.rank >= 1 and data.rank <= 3 then
			rank_text.gameObject:SetActive(false)
			rank_img.gameObject:SetActive(true)
			local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[data.rank]
			LuaBehaviourUtil.setImg(luaBehaviour,"rank_img", top_three_item.rank, top_three_item.atlas)
		else
			rank_text.gameObject:SetActive(true)
			rank_img.gameObject:SetActive(false)
			rank_text.text = data.rank
		end
		score_text.transform.parent.gameObject:SetActive(true)
	end
	name_text.text = Language:getTextByKey(data.user.name)
	score_text.text = data.score
	power_text.text = data.user.full_combat
	--local free_time = self.m_model:getFreeTimes()
	--local free_flag = free_time > 0
	--local attack_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attack_btn_text", free_flag and "new_str_0231" or "new_str_0219")
	--UIUtil.setLocalPosition(attack_btn_text.transform, free_flag and 0 or 15)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", not free_flag)
	--attack_btn_text.gameObject:SetActive(free_flag)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")
end

function M:updateSelfData()
	local luaBehaviour = self.self_arena_node:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")
	local rank_text = luaBehaviour:FindText("rank_text")
	local rank_img = luaBehaviour:FindImage("rank_img")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local score_text = luaBehaviour:FindText("score_text")
	local power_text = luaBehaviour:FindText("power_text")
	local ItemNode = luaBehaviour:FindGameObject("ItemNode")
	local grading_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "grading_text", "new_str_0262")

	local user_data = UserDataManager.user_data.user_status
	GameUtil:setUserAvatar(HeadNode, user_data, nil, nil, {show_flag = true, scale = 1.05})
	local title_id = user_data.title
	if title_id and title_id ~= 0 then
		HeadNode.transform.anchoredPosition = Vector3.New(-14, 200, 0)
	else
		HeadNode.transform.anchoredPosition = Vector3.New(-14, 174, 0)
	end
	local room_id = self.m_model:getRoomId()
	--self:setObjectVisible("reward_btn", room_id ~= 0)
	if room_id == 0 then -- 定级中
		grading_text.gameObject:SetActive(true)
		rank_text.gameObject:SetActive(false)
		rank_img.gameObject:SetActive(false)
		score_text.text = Language:getTextByKey("new_str_0263")
	else
		grading_text.gameObject:SetActive(false)
		if self.m_model.m_data.rank <= 0 then
			rank_img.gameObject:SetActive(false)
			rank_text.text = Language:getTextByKey("new_str_0076")
		elseif self.m_model.m_data.rank <= 3 then
			rank_text.gameObject:SetActive(false)
			rank_img.gameObject:SetActive(true)
			local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[self.m_model.m_data.rank]
			LuaBehaviourUtil.setImg(luaBehaviour,"rank_img", top_three_item.rank, top_three_item.atlas)
		else
			rank_text.gameObject:SetActive(true)
			rank_img.gameObject:SetActive(false)
			rank_text.text = self.m_model.m_data.rank
		end
		score_text.text = self.m_model.m_data.score
	end
	local name_key = user_data.name
	if name_key == nil or name_key == "" then
		name_key = "new_str_0141"
	end
	name_text.text = Language:getTextByKey(name_key)
	local user = UserDataManager.user_data.user_status
	local combat = user.full_combat or 0
	power_text.text = tostring(combat)
	local arena_reward = ConfigManager:getCfgByName("arena_reward")
	local reward = arena_reward[self.m_model.m_data.rank]
	if reward == nil then
		local index = 0
		for k,v in pairs(arena_reward) do
			if k <= self.m_model.m_data.rank and k > index then
				index = k
			end
		end
		reward = arena_reward[index]
	end
	-- if reward then
	-- 	GameUtil:updateItemElement(ItemNode, reward.daily_rewards[1], true, true)
	-- 	ItemNode.gameObject:SetActive(true)
	-- else
	-- 	ItemNode.gameObject:SetActive(false)
	-- end
end

function M:refreshRedPoint()
    local record_flag1 = RedPointUtil:hasRedPointById(1101)
    self:setObjectVisible("record_btn_red_point", record_flag1)
	UserDataManager:removeRedDotByKey("arena_beat")
	UserDataManager:removeRedDotByKey("arena_can_chanllenge")
end

function M:updateArenaRewardWeek()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getArenaRewardWeekData()
	local width = self.m_box_node_rt.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].cfg.num
	end
	max_num = max_num > 0 and max_num or 100
	self:setTextByLanKey("week_reward_box_text", "new_str_0689", cur_num, max_num)
	self.m_week_box_reward_slider.value = cur_num/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("Arena/ArenaNormal/ArenaRewardWeekBox", box_trans)
		local transform = task_box.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.num/max_num - width*0.5, 0)
		local function btns(trans,params)
			if data.status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(cfg.num), "score_text")
		local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		local box_img = luaBehaviour:FindImage("box_img")
		if data.status == 0 then
			box_img.material = nil
		elseif data.status == 2 then
			box_img.material = nil
		elseif data.status == -1 then
			--box_img.material = self.m_gray_img.material
			LuaBehaviourUtil.setImg(luaBehaviour,"box_img","a_wxlj_box_open",  "arena_ui")
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
		if data.status == 2 then
			--self.m_control:setOnceTimer(0.1, function()
			--	if not IsNull(task_box) then
			--		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
			--	end
			--end)
			if box_effect ~= nil then
				box_effect.gameObject:SetActive(true)
			end
			if box_effect2 ~= nil then
				box_effect2.gameObject:SetActive(true)
			end
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("ArenaNormalTime")
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M