local M = class("GuildHighWarRankListView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarCityRankList"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1",  text_key = "tog_1_text", show_text = "guild_high_war_new_0031" , red_point_img = "race_red_point_img"}, -- 战绩
	{btn_key = "tog_2",  text_key = "tog_2_text", show_text = "guild_high_war_new_0032" , red_point_img = "reward_red_point_img"}, -- 战绩奖励
	{btn_key = "tog_3",  text_key = "tog_3_text", show_text = "guild_high_war_new_0033" , red_point_img = "reward_red_point_img"}, -- 武勋
	{btn_key = "tog_4",  text_key = "tog_4_text", show_text = "guild_high_war_new_0034" , red_point_img = "reward_red_point_img"}, -- 武勋奖励
}

function M:onEnter()
    self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
		self:setObjectVisible(v.red_point_img, false)
	end

	self:setTextByLanKey("rank_label_text", "new_str_0374")
	
	self:setTextByLanKey("score_label_text", "new_str_0375")
	self:setTextByLanKey("own_score_title_text", "new_str_0380")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("player_label_text2", "new_str_0372")
	self:setTextByLanKey("reward_label_text", "new_str_0373")
	
    self.m_own_info_node = self:findGameObject("own_info_node")
	self.m_own_info_prefab2 = GameUtil:createPrefab("Rank/RankListItem",self.m_own_info_node.transform)
	self.m_own_info_prefab = GameUtil:createPrefab("GuildHighWar/GuildHighWarRankListItem",self.m_own_info_node.transform)
    self:setTextByLanKey("common_title_text", "new_str_0114")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
    self:setTextByLanKey("reward_btn_text", "new_str_0110")
    self.m_reward_red_point_img = self:findGameObject("tog_2_red_point_img")
	self:switchNode(1)
end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:switchNode(index)
	self:setObjectVisible("loopscroll1", index == 3)
	self:setObjectVisible("loopscroll", index == 1)
	self:setObjectVisible("RecordNode", index == 2 or index == 4)
	self:setObjectVisible("RankListNode", index == 1 or index == 3)
	self:setObjectVisible("own_info_node", index == 1 or index == 3)
	self.m_own_info_prefab2:SetActive( index == 3)
	self.m_own_info_prefab:SetActive( index == 1)
	if index == 1 then
		self:setTextByLanKey("player_label_text", "new_str_0444")
		self:setTextByLanKey("lv_label_text", "guild_high_war_text_0028")
		self:setTextByLanKey("score_label_text", "UnionWar_str_085")
		self:setObjectVisible("lv_label_text",false)
		self:setTextByLanKey("gang_label_text", "guild_high_war_text_0028")
	
		--
		self:setObjectVisible("score_label_text",true)
		self:setObjectVisible("power_label_text",false)
		self:setObjectVisible("gang_label_text",true)
		self:setObjectVisible("player_label_text",true)
		self:setObjectVisible("gang_label_text2",false)
		self:setObjectVisible("score_label_text2",false)
		self:setTextByLanKey("gang_label_text2", "new_str_0444")
		self:setTextByLanKey("score_label_text2", "UnionWar_str_085")
	elseif index == 3 then
		self:setTextByLanKey("player_label_text", "new_str_0372")
		self:setTextByLanKey("lv_label_text", "new_str_0436")
		self:setTextByLanKey("score_label_text", "guild_high_war_text_0025")
		self:setObjectVisible("lv_label_text",false)
		self:setObjectVisible("gang_label_text",true)
		self:setTextByLanKey("power_label_text", "new_str_0490")
		self:setTextByLanKey("gang_label_text", "guild_high_war_text_0028")
		--
		self:setObjectVisible("score_label_text",true)
		self:setObjectVisible("power_label_text",false)
		self:setObjectVisible("gang_label_text",true)
		self:setObjectVisible("player_label_text",true)
		self:setObjectVisible("gang_label_text2",false)
		self:setObjectVisible("score_label_text2",false)
	end
	self:setObjectVisible("gang_label_text3",true)
	
    self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_sel_tab_index == 1 then
		--local data = self.m_model:getOwnFightRankData()
		--self:updateItemInfo(self.m_own_info_prefab, data,nil,true)
		self:updateLoopScroll()
	elseif self.m_model.m_sel_tab_index == 3 then
		local data = self.m_model:getOwnRankData()
		self:updateItemInfo1(self.m_own_info_prefab2, data)
		self:updateLoopScroll1()
	elseif self.m_model.m_sel_tab_index == 2 or self.m_model.m_sel_tab_index == 4 then
		self:refreshRewardUI()
	end
    self:refreshRedPoint()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "race_img" then
                    self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
                else
                    self:updateMsg("item_click", {id = index})
                end
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:updateLoopScroll1()
	local data = self.m_model:getRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view1 == nil then
		local loopscroll = self:findGameObject("loopscroll1")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "race_img" then
					self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
				else
					self:updateMsg("item_click", {id = index})
				end
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety1 = self.m_loop_scroll_view1.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view1.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view1 = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view1:reloadData(data)
		if self.m_control.m_mail_load1 == true then
			self:pullRefreshListOffset1()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end

function M:pullRefreshListOffset1()
	self.now_offsety1 = self.m_loop_scroll_view1.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view1.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety1 - self.now_offsety1) / self.m_loop_scroll_view1.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view1:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load1 = false
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
	if self.m_model.m_sel_tab_index == 1 then
		self:updateItemInfo(cell_object, data, index)
	else
		self:updateItemInfo1(cell_object, data, index)
	end
end

function M:updateRankIcon(id, transform, rank, luaBehaviour)
	if id then
		local top_three_flag = id < 4
		UIUtil.setObjectVisible(transform, top_three_flag, "top_three_rank_img")
		UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
		local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[id]
		if top_three_item then
			LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
		end
		for i = 1,3 do
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Ui_Rank_Bang_00"..i, i==id)
		end
		UIUtil.setText(transform, tostring(rank), "rank_text")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
	else
		UIUtil.setObjectVisible(transform, false, "top_three_rank_img")
		UIUtil.setObjectVisible(transform, true, "rank_text")
		if rank < 1 then
			UIUtil.setTextByLanKey(transform, "none_rank_text", "new_str_0076")
			UIUtil.setTextByLanKey(transform, "rank_text", "")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
		else
			UIUtil.setTextByLanKey(transform, "none_rank_text", "")
			UIUtil.setText(transform, tostring(rank), "rank_text")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
		end
	end
end

function M:updateItemInfo(obj, data, id,flag)
    local user = data.user or {}
    local rank = data.rank or 0
    local score = data.score or 0
	local citys = data.citys or {}
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	self:updateRankIcon(id, transform, rank, luaBehaviour)
	--LuaBehaviourUtil.setImg(luaBehaviour,"race_icon", race.race_icon, ResourceUtil:getLanAtlas())
	--UIUtil.setText(transform, tostring(score), "race_score_text")
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", true)
	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
    end
	UIUtil.setText(transform, tostring(citys["3"] or 0), "city_text1")
	UIUtil.setText(transform, tostring(citys["2"] or 0), "city_text2")
	UIUtil.setText(transform, tostring(citys["1"] or 0), "city_text3")
	UIUtil.setText(transform, tostring(score), "score_text")
	UIUtil.setText(transform, GameUtil:formatValueToString(data.combat), "xuanzhanscore")
	--for i = 1,3 do
	--	UIUtil.setObjectVisible(transform, false, "city_img"..i)
	--	UIUtil.setObjectVisible(transform, false, "city_text"..i)
	--end
    local gender = user.flag or 0
	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
	if flag_cfg then
		local union_icon_img = luaBehaviour:FindImage("gender_img")
		GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
	end
	UIUtil.setObjectVisible(transform, gender > 0 and flag_cfg, "gender_img")
    --特殊处理设置位置
	if flag then
		local imgObj = UIUtil.findImage(transform,"gender_img")
		local textObj = UIUtil.findText(transform,"name_text")
		local raceObj = UIUtil.findImage(transform,"race_icon")
		local scoreTextObj = UIUtil.findText(transform,"score_text")
		--373 -198 349
		UIUtil.setLocalPosition(imgObj.transform, -87,0, 0)
		UIUtil.setLocalPosition(textObj.transform, 67, 0, 0)
		UIUtil.setLocalPosition(raceObj.transform, 270, 0, 0)
		UIUtil.setLocalPosition(scoreTextObj.transform, 349, 0, 0)
	end
end

function M:updateItemInfo1(obj, data, id)
	local user = data.user or {}
	local rank = data.rank or 0
	local score = data.score or 0
	local transform = obj.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	self:updateRankIcon(id, transform, rank, luaBehaviour)
	local name_text = nil
	if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
	else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
	end
--	UIUtil.setText(transform, tostring(user.level), "level_text")
	
	UIUtil.setText(transform, GameUtil:formatValueToString(score), "race_score_text")
	UIUtil.setObjectVisible(transform,false,"power_text")
	UIUtil.setObjectVisible(transform,true,"gang_text")
	UIUtil.setObjectVisible(transform,false,"level_text")
	UIUtil.setText(transform, tostring(GameUtil:formatValueToString(user.full_combat or 0)), "power_text")
	UIUtil.setText(transform, tostring(user.guild_name or ""), "gang_text")
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-90, -15, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-90, 0, 0)
	end
end


function M:updateMoreRankInfo(luaBehaviour, data, id)
	for i = 1, 5 do
		local num = 0
		local icon_name = GlobalConfig.TYPE_HERO_RACE[i-1] and GlobalConfig.TYPE_HERO_RACE[i-1].race_icon or "a_tjbbd_tian"
		if not(id) then
			num = self.m_model:getFloorByRace(i-1)
		else
			if  data.tower_floor and data.tower_floor[tostring( i-1)] then
				num = data.tower_floor[tostring( i-1)]
			end
		end
		
		LuaBehaviourUtil.setText(luaBehaviour, "rank_num_" .. i, num)
		LuaBehaviourUtil.setImg(luaBehaviour,"rank_icon" .. i, icon_name, ResourceUtil:getLanAtlas())
	end
end

function M:refreshRedPoint()
    local red_point = self.m_model:getRankRedPointById(self.m_model.m_id)
    self.m_reward_red_point_img:SetActive(red_point)
end


-----------------------------------奖励 
function M:refreshRewardUI()
		self:setObjectVisible("guild_name_empty_text",false)
		self:setObjectVisible("guild_img",self.m_model.m_sel_tab_index == 2 )
		self:setObjectVisible("team_head_bg",self.m_model.m_sel_tab_index == 4 )
		self:setObjectVisible("team_head_bg_mask",self.m_model.m_sel_tab_index == 4 )
	    self:setObjectVisible("record_star",self.m_model.m_sel_tab_index == 2)
	    self:setObjectVisible("record_star2",self.m_model.m_sel_tab_index == 4)
		self:setTextByLanKey("reward_des_text", "guild_high_war_text_0040")
		local guild_name = self.m_model.m_guild_name or self.m_model.m_guild_data.name  
		local player_name = UserDataManager.user_data:getUserStatusDataByKey("name")
		self:setTextByLanKey("guild_name_text", self.m_model.m_sel_tab_index == 4 and player_name or guild_name)
		self:setTextByLanKey("record_text", self.m_model.m_sel_tab_index == 4 and "guild_high_war_text_0025" or "UnionWar_str_085")
		self:setTextByLanKey("rank_text", "new_str_0374")
		self:setTextByLanKey("record_num_text", self.m_model.m_sel_tab_index == 2 and tostring(self.m_model.m_g_score) or tostring(self.m_model.m_r_score))
		self:setTextByLanKey("rank_num_text", self.m_model.m_sel_tab_index == 2 and tostring(self.m_model.m_g_rank) or tostring(self.m_model.m_r_rank))
	    local user = self.m_model:getOwnFightRankData().user
		local gender = user.flag or 0
		--local gender = self.m_model.m_guild_data.flag or 0
		local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
		if flag_cfg then
			local union_icon_img = self:findImage("guild_img")
			GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
		end
		
		local head_node = self:findGameObject("team_head_node")
		GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
		self:updateLoopRewardScroll()
	--self:refreshRedPoint()
end

function M:updateNumsText()
	self:setTextByLanKey("open_times_text", "guild_high_war_text_0034", 1 )
	for i = 1, 4 do
		self:setTextByLanKey("num_text" .. i, "guild_high_war_text_003" .. (4+i), 1 .. "/" .. 2)
	end
end

function M:setColorA( img, a )
	local color = img.color
	color.a = a
	img.color = color
end

local PLAYOFF_TYPE = {
	[1] = {3,4}, --天
	[2] = {5,6}, --地
	[3] = {7,8}, --玄
	[4] = {9,10}, --人
}
function M:updateLoopRewardScroll()
	self:setObjectVisible("common_tips_node",false)
	local cfg_type = self.m_model.m_sel_tab_index == 2 and 2 or 1
	local data = self.m_model:getRankShowDataByType(cfg_type)
	if self.m_reward_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRewardItemInfo(cell_object, cell_data, index, cfg_type)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--if click_name == "cell" then
				--	self:updateMsg("select_daily_index",{index = index})
				--else
				--	self:updateMsg("item_click", {id = index})
				--end
			end,
			ui_name = self.m_uiName
		}
		self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_scroll_view:reloadData(data)
	end
	--后备赛特殊处理
	if self.m_model.playoff_type == 5 then
		self:setTextByLanKey("reward_des_text", "guild_high_war_new_0047")
	end
	
end

function M:updateRewardItemInfo(cell_object, cell_data, index, cfg_type)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	--local cfg_data = self.m_model:getCfgDataByTypeAndIndex(self.m_cfg_type, index) or {}
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_des_text", self.m_model.m_sel_tab_index == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_value_text", self.m_model.m_sel_tab_index == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_range_text", self.m_model.m_sel_tab_index == 4)
	local reward = cell_data.reward or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "record_des_text", "UnionWar_str_085" )
	if cell_data.rank then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "record_value_text","guild_high_war_text_0099", cell_data.rank[1] .. (cell_data.rank[2] and "-" .. cell_data.rank[2] or "")  )
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_range_text","guild_high_war_text_0099", cell_data.rank[1] .. (cell_data.rank[2] and "-" .. cell_data.rank[2] or "") )

	end
end

function M:refreshRedPoint()
	local red_point = self.m_model:getRankRedPointById(self.m_model.m_id)
	self.m_reward_red_point_img:SetActive(red_point)
end

return M