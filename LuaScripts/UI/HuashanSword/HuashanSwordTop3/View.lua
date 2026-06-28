local M = class("HuashanSwordTop3View",LikeOO.OOPopBase)

M.m_uiName = "HuashanSword/HuashanSwordTop3"
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
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 30})
	self:setTextByLanKey("list_title_text", "new_str_0690")
	self:setTextByLanKey("close_title_text", "huashan_sword_text0001")
	self:setTextByLanKey("title_text1", "huashan_sword_text0002")
	self:setTextByLanKey("title_text2", "huashan_sword_text0003")
	self:setTextByLanKey("add_btn_text", "huashan_sword_text0004")
	self:setTextByLanKey("challenge_btn_text", "huashan_sword_text0005")
	self:setTextByLanKey("reward_btn_text", "new_str_0224")
	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self:setTextByLanKey("time_titile_text", "new_str_1058")
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
	--local show_coin_tab = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0})
	--self:setImg(show_coin_tab.icon_name, show_coin_tab.atlas_name, "high_arena_coin_img")
	self:refreshUI()
	for i = 1,3 do
		self:setObjectVisible("good_red_point_"..i, RedPointUtil:hasRedPointById(276) == true and self.m_model:isCurDay() )
	end
	--UserDataManager:removeRedDotByKey("high_arena")
end

function M:updateTimeStr()
	local ts = self.m_model:getCurStartTs()
	if ts then
		local time_str = os.date("%Y年%m月%d日", ts)
		self:setText("time_text", time_str)
	end
end

function M:refreshUI(change_day)
	self:updateListTopScroll()
	self:updateListBottomScroll()
	if change_day then
		self.m_top_list_scroll:moveToCellIndex(1)
		self.m_bottom_list_scroll:moveToCellIndex(1)
	end
	self:updateLikeUsers(self.m_model.m_data.like);
	self:updateTopData()
	self:refreshRedPoint()

	local free_time = self.m_model:getFreeTimes()
	local cur_times = self.m_model:getCurTimes()
	self:setObjectVisible("max_times_text", free_time <= 0)
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  cur_times .. "/" .. self.m_model:getMaxTimes())
	self:setObjectVisible("challenge_btn_anim", free_time > 0)
	self:setTextByLanKey("free_challenge_text", "new_str_0568", free_time)
	self:updateTimeStr()
	self:refreshJiantou()
end

function M:refreshJiantou()
	self:setObjectVisible("jiantou_left_btn", self.m_model.m_cur_day ~= 1)
	self:setObjectVisible("jiantou_right_btn", self.m_model.m_cur_day ~= self.m_model.m_total_day)
end


function M:setRefreshBtnEnabled(enabled)
	--self.m_refresh_btn.enabled = enabled
	--self.m_refresh_btn_text.gameObject:SetActive(not enabled)
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

function M:updateListTopScroll()
	local data = self.m_model:getListData(4, 10)
	if self.m_top_list_scroll == nil then
		local list_scroll = self:findGameObject("top_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_top_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_top_list_scroll:reloadData(data)
	end
end

function M:updateListBottomScroll()
	local data = self.m_model:getListData(11, 50)
	if self.m_bottom_list_scroll == nil then
		local list_scroll = self:findGameObject("bottom_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_bottom_list_scroll.m_scroll_rect.viewport.rect.height - self.m_bottom_list_scroll.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_bottom_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_bottom_list_scroll:reloadData(data)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_bottom_list_scroll.m_scroll_rect.viewport.rect.height - self.m_bottom_list_scroll.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_bottom_list_scroll.m_scroll_rect.content.rect.height
	self.m_bottom_list_scroll:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end

--更新点赞的文本
function M:updateGoodNumTxt( rank, like )
	local good_num_txt = self.m_rank_behaviour[rank]:FindText("good_num_txt");
	good_num_txt.text = like;
end

function M:hideRank( cur_LuaBehaviour, rank )
	--local hero = cur_LuaBehaviour:FindGameObject("hero");
	--hero:SetActive(false);
	local good = cur_LuaBehaviour:FindGameObject("good"..rank);
	good:SetActive(false);
	local good_num_bg = cur_LuaBehaviour:FindGameObject("good" .. rank .. "_bg");
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
		local hero = cur_LuaBehaviour:FindGameObject("rank_spine_1")
		local cfg = ConfigManager:getPlayerPictureCfg(rank_data.user.avatar);
		local spine_name = cfg.hero_spine;
		GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
		local head_node = cur_LuaBehaviour:FindGameObject("HeadNode")
		GameUtil:setUserAvatar(head_node,rank_data.user, nil, nil,{show_flag = true, scale = 1.05})
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "tx_mask", false)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "border_img", false)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "lv_bg", false)
		head_node:GetComponent("Image").enabled = false
		--点赞次数
		local good_num_txt = cur_LuaBehaviour:FindText("good_num_txt");
		good_num_txt.text = rank_data.like;
		local server_name = ""
		if tonumber(rank_data.user.server) == 0 then
			server_name = UserDataManager.server_data:getServerName()
		else
			server_name = UserDataManager.server_data:getServerNameById(rank_data.user.server)
		end
		server_name = "[" .. server_name .. "]"
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "server_name", server_name)
	end                 
end

function M:updateLikeUsers( like )
	for i = 1, 3 do
		local rank_data = self.m_model:getTopDataByIndex(i);
		if rank_data ~= nil then
			if rank_data.user.is_robot == true or not(self.m_model:isCurDay()) then
				self:setObjectVisible("good"..i.."_bg", false)
				self:setObjectVisible("good"..i, false)
				LuaBehaviourUtil.setObjectVisible(self.m_rank_behaviour[i],"good_num_bg", false)
			else
				self:setObjectVisible("good"..i.."_bg", true)
				self:setObjectVisible("good"..i, true)
				LuaBehaviourUtil.setObjectVisible(self.m_rank_behaviour[i],"good_num_bg", true)
			end
		end
	end
	like = like or {}
	for i, v in ipairs(like) do
		local rank_data = self.m_model:getRankDataByUid(v);
		if rank_data ~= nil then
			local good = self.m_good_list[rank_data.rank]
			if not IsNull(good)  then
				good:SetActive(false);
			end
		end
	end
end
local icon_bg_name = {"a_bangdan_yi", "a_bangdan_er", "a_bangdan_san", "a_bangdan_qita"}

function M:listHandle(obj, id, data, is_top)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local rank_text = luaBehaviour:FindText("rank_text")
	local HeadNode = luaBehaviour:FindGameObject("head_node")
	local name_text = luaBehaviour:FindText("name_text")
	local server_name_text = luaBehaviour:FindText("server_name_text")
	--local power_text = luaBehaviour:FindText("combat_text")
	if HeadNode then
		GameUtil:setUserAvatar(HeadNode,data.user,nil,nil,{show_flag = true, scale = 1.05})
	end
	local title_id = data.user.title
	if is_top then
		if title_id and title_id ~= 0 then
			name_text.transform.anchoredPosition = Vector3.New(35.43, -13.1, 0)
			server_name_text.transform.anchoredPosition = Vector3.New(113.4989, -14.1, 0)
		else
			name_text.transform.anchoredPosition = Vector3.New(35.43, 1, 0)
			server_name_text.transform.anchoredPosition = Vector3.New(113.4989, 0, 0)
		end
	end
	local rank_bg_name = ""
	if data.rank > 3 or data.rank == 0 then
		rank_bg_name = icon_bg_name[4]
	else
		rank_bg_name = icon_bg_name[data.rank]
	end
	LuaBehaviourUtil.setImg(luaBehaviour, "rank_bg_img", rank_bg_name, "mystic_ui")
	local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(data.rank, self.m_model.m_version)
	local server_name = ""
	if tonumber(data.user.server) == 0 then
		server_name = UserDataManager.server_data:getServerName()
	else
		server_name = UserDataManager.server_data:getServerNameById(data.user.server)
	end
	server_name_text.text = "[" .. server_name .. "]"
	rank_text.text = (tostring(data.rank))
	name_text.text = Language:getTextByKey(data.user.name)
	--power_text.text = data.user.full_combat
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M