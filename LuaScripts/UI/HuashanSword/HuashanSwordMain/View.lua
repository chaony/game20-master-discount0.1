local M = class("HuashanSwordMainView",LikeOO.OOPopBase)

M.m_uiName = "HuashanSword/HuashanSwordMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 30})
	self:setTextByLanKey("list_title_text", "new_str_0690")
	self:setTextByLanKey("mine_score_text", "arena_str_0010")
	self:setTextByLanKey("close_title_text", "huashan_sword_text0001")
	self:setTextByLanKey("record_btn_text", "new_str_0233")
	self:setTextByLanKey("def_btn_text", "new_str_0234")
	self:setTextByLanKey("score_title_text", "new_str_0380")
	self:setTextByLanKey("rank_name_title_text", "world_boss_str_0027")
	self:setTextByLanKey("name_title_text", "new_str_0372")
	self:setTextByLanKey("rank_title_text", "new_str_0235")
	self:setTextByLanKey("reward_btn_text", "new_str_0224")
	self.m_challenge_btn_text = self:setTextByLanKey("challenge_btn_text", "new_str_0386")
	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self.m_refresh_btn = self:findButton("refresh_btn")
	self.m_refresh_btn_text = self:findText("refresh_btn_text")
	self.m_time_text = self:findText("time_text")
	self.m_list_title_time_text = self:findText("list_title_time_text")
	self.m_time_key = self.m_model:getActStatus() == 1 and "openServerRank_str_0007" or "huashan_sword_text0012"
	--排名1 2 3 的格子 

	local show_coin_tab = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0})
	self:setImg(show_coin_tab.icon_name, show_coin_tab.atlas_name, "high_arena_coin_img")
	self:refreshUI()

	--UserDataManager:removeRedDotByKey("high_arena")
end

function M:refreshUI()
	self:updateListScroll()
	self:refreshRacesIcon()
	self:updateSelfData()
	self:refreshRedPoint()
	local free_time = self.m_model:getFreeTimes()
	local cur_times = self.m_model:getCurTimes()
	self:setObjectVisible("max_times_text", free_time <= 0)
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  cur_times .. "/" .. self.m_model:getMaxTimes())
	self:setTextByLanKey("free_challenge_text", "new_str_0568", free_time)
	if free_time <= 0 then
		UIUtil.setLocalPosition(self.m_challenge_btn_text.transform, nil, -43)
	else
		UIUtil.setLocalPosition(self.m_challenge_btn_text.transform, nil, -59)
	end
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts, 999)
		self:setTextByLanKey("time_text",self.m_time_key, text)
	else
		local open_staus = self.m_model:getActStatus()
		if open_staus == 1 then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
		elseif open_staus == 2 then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		end
		self:updateMsg(99999)
	end
end

function M:refreshRedPoint()
	local record_flag0 = RedPointUtil:hasRedPointById(276)
	self:setObjectVisible("rank_btn_red_point", record_flag0)
    local record_flag1 = RedPointUtil:hasRedPointById(27604)
    self:setObjectVisible("record_btn_red_point", record_flag1)
	local record_flag2 = RedPointUtil:hasRedPointById(27602)
	self:setObjectVisible("reward_btn_red_point", record_flag2)
	local record_flag3 = RedPointUtil:hasRedPointById(27601)
	self:setObjectVisible("shop_btn_red_point", record_flag3)
end

function M:updateListScroll()
	local data = self.m_model:getListData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
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
				self.last_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_list_scroll.m_scroll_rect.content.rect.height
	self.m_list_scroll:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end

local icon_bg_name = {"a_bangdan_yi", "a_bangdan_er", "a_bangdan_san", "a_bangdan_qita"}
function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("head_node")
	local server_name_text = luaBehaviour:FindText("server_name_text")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text",  (tostring(data.rank < 4 and "" or data.rank)))
	local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", Language:getTextByKey(data.user.name))
	local power_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text",  Language:getTextByKey("openServerRank_str_0008", GameUtil:formatValueToString(data.user.full_combat)))
	GameUtil:setUserAvatar(HeadNode,data.user,nil,nil,{show_flag = true, scale = 1.05})
	local title_id = data.user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-69, -3, 0)
		server_name_text.transform.anchoredPosition = Vector3.New(56.722, -3, 0)
		power_text.transform.anchoredPosition = Vector3.New(-69, -28, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-69, 12, 0)
		server_name_text.transform.anchoredPosition = Vector3.New(56.722, 12, 0)
		power_text.transform.anchoredPosition = Vector3.New(-69, -12.28143, 0)
	end
	local rank_bg_name = ""
	if data.rank > 3 or data.rank == 0 then
		rank_bg_name = icon_bg_name[4]
	else
		rank_bg_name = icon_bg_name[data.rank]
	end
	LuaBehaviourUtil.setImg(luaBehaviour, "rank_bg_img", rank_bg_name, "mystic_ui")
	local server_name = ""
	if tonumber(data.user.server) == 0 then
		server_name = UserDataManager.server_data:getServerName()
	else
		server_name = UserDataManager.server_data:getServerNameById(data.user.server)
	end
	server_name_text.text = "[" .. server_name .. "]"
	local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(data.rank, self.m_model.m_version)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "own_segment_text", cfg.division_name or "new_str_0076")
	local segment_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "own_segment_node", true)
	CommonUIUtil:setSegmentInfo(segment_node, cfg, nil, "pub_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_rank_text", false)
end

function M:updateSelfData()
	local user_data = UserDataManager.user_data.user_status
	--加载spine动画
	local hero = self:findGameObject("hero_spine")
	local ply_cfg = ConfigManager:getPlayerPictureCfg(user_data.avatar)
	GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(ply_cfg.hero_spine), "idle", 0, true)
	local rank = self.m_model.m_data.rank or 0
	local cfg = ConfigManager:getHuaShanCfgByRankAndVsn(rank, self.m_model.m_version)
	self:setTextByLanKey("own_segment_rank_text", cfg.division_name or "new_str_0076")
	local dw_name = Language:getTextByKey(cfg.division_name or "new_str_0076")
	self:setTextByLanKey("rank_level_text", "dragonsword_text_0011", "   " .. dw_name)
	self:setTextByLanKey("my_rank_text", "dragonsword_text_0011", "   " .. rank)
	self:setTextByLanKey("my_combat_text", "new_str_0930", "   " .. GameUtil:formatValueToString(user_data.full_combat))
	if rank <= 0 then
		--rank_text.text = Language:getTextByKey("new_str_0076")
		self:setObjectVisible("own_segment_node", false)
		self:setTextByLanKey("own_segment_rank_text", "new_str_0076")
	else
		self:setTextByLanKey("own_segment_rank_text", cfg.division_name or "new_str_0076")
		local segment_node = self:setObjectVisible("own_segment_node", true)
		CommonUIUtil:setSegmentInfo(segment_node, cfg, nil, "pub_ui")
		self:setObjectVisible( "segment_rank_text", false)
	end

	local day_reward_text = self:findText("day_reward_text")
	day_reward_text.text = Language:getTextByKey("new_str_0294", cfg.high_coin or 0)
	local arena_coin_store = self.m_model.m_data.arena_coin_store or 0
	local com_value = ConfigManager:getCommonValueById(659, 99999999)
	self:setTextByLanKey("reward_coin_text", "new_str_0053", arena_coin_store, com_value)
	self:setObjectVisible("box_reward_btn_anim", arena_coin_store > 0)

end
function M:refreshRacesIcon()
	self:setObjectVisible("shili_root", true)
	self:setObjectVisible("shili1", false);
	self:setObjectVisible("shili2", false);
	self:setObjectVisible("shili3", false);
	self:setTextByLanKey("shili_name","huashan_sword_text0014")
	for i, v in ipairs(self.m_model:getCurVsnRaces()) do
		if v ~= 7 then
			self:setObjectVisible("shili"..i, true);
			local race_img_info = GlobalConfig.TYPE_HERO_RACE[v];
			LuaBehaviourUtil.setImg(self.m_luaBehaviour, "shili"..i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
		end
	end
end
function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M