local M = class("RankListView",LikeOO.OOPopBase)

M.m_uiName = "Rank/RankList"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "RankListNode", text_key = "tog_1_text", show_text = "new_str_0235" , red_point_img = "race_red_point_img"}, -- 排行榜
	{btn_key = "tog_2", lua_name = "RewardNode", text_key = "tog_2_text", show_text = "new_str_0373" , red_point_img = "reward_red_point_img"}, -- 奖励
}

function M:onEnter()
    self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		if k == 1 then
			local name = "new_str_0235"
			if self.m_model.m_btn_cfg.rece_type then
				local race_cfg = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_btn_cfg.rece_type]
				name = Language:getTextByKey(race_cfg.name)..Language:getTextByKey(self.m_model.m_btn_cfg.name)
			end
			self:setTextByLanKey(v.text_key, name)
		else
			self:setTextByLanKey(v.text_key, v.show_text)
		end
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
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "new_str_0375")
	self:setTextByLanKey("own_score_title_text", "new_str_0380")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("player_label_text2", "new_str_0372")
	self:setTextByLanKey("reward_label_text", "new_str_0373")
	
    self.m_own_info_node = self:findGameObject("own_info_node")
	if self.m_model.m_id == 2 then
		self.m_own_info_prefab = GameUtil:createPrefab("Rank/RankListItem1",self.m_own_info_node.transform)
	else
		self.m_own_info_prefab = GameUtil:createPrefab("Rank/RankListItem",self.m_own_info_node.transform)
	end
    local btn = UIUtil.findButton(self.m_own_info_prefab.transform)
    btn.enabled = false
	local btn2 = UIUtil.findButton(self.m_own_info_prefab.transform, "handle_point_btn")
	if btn2 then
		btn2.enabled = true
		local function clickCallback(_, cell_data)
			self:updateMsg("click_self_info")
		end
		UIUtil.setButtonClick(btn2.transform,clickCallback)
	end
    self:setTextByLanKey("common_title_text", "new_str_0114")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
    self:setTextByLanKey("reward_btn_text", "new_str_0110")
    self.m_reward_red_point_img = self:findGameObject("tog_2_red_point_img")
	self:refreshUI()
    UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
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
    self:setObjectVisible("RankListNode", index == 1)
    self:setObjectVisible("RewardNode", index == 2)
    if index == 1 then
        
		if self.m_model.m_rank_cfg then
		    if self.m_model.m_rank_cfg.rece_type then
		        local race_icon = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_rank_cfg.rece_type].race_icon
		        self:setImg(race_icon,  ResourceUtil:getLanAtlas(), "rank_title_img")
		        self:setObjectVisible("rank_title_img", true)
		    else
		        self:setObjectVisible("rank_title_img", false)
		    end
		    self:setTextByLanKey("rank_title_text", self.m_model.m_rank_cfg.name)
			self:setTextByLanKey("common_title_text", self.m_model.m_rank_cfg.name)
		else
			self:setTextByLanKey("common_title_text", "new_str_0114")
		end
    else
        self:setTextByLanKey("common_title_text", "new_str_0531")    
    end
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model:getOwnRankData()
    self:updateItemInfo(self.m_own_info_prefab, data)
	if self.m_model.m_sel_tab_index and self.m_model.m_sel_tab_index == 2 then
		self:updateRewardLoopScroll()
	elseif self.m_model.m_id == 2 then
		self:updateLoopScroll1()
	else
		self:updateLoopScroll()
	end
	self:setObjectVisible("loopscroll1", self.m_model.m_id == 2)
	self:setObjectVisible("loopscroll", self.m_model.m_id ~= 2)
    self:refreshRedPoint()
    self:setOwnInfo()
end

function M:refreshOwnPrebPosition()
	local content = self:findGameObject("Content")
	local loopscroll1 = self:findGameObject("loopscroll1")
	local rect = content:GetComponent("RectTransform")
	local rect2 = loopscroll1:GetComponent("RectTransform")
		
	if self.m_model.m_click_self then
		rect.sizeDelta = Vector2(rect.rect.width, 210)
		rect2.sizeDelta = Vector2(rect.rect.width, 274.24)
	else
		rect.sizeDelta = Vector2(rect.rect.width, 137)
		rect2.sizeDelta = Vector2(rect.rect.width, 347.24)
	end
end
--[[
	创建列表
]]
function M:updateRewardLoopScroll()
    local data = self.m_model:getQuestsData()
    if data == nil then
        return
    end
	if self.m_reward_loop_view == nil then
		local loopscroll = self:findGameObject("reward_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRewardCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "look_btn" then
					self:updateMsg("look_top_player", {index = index})
				elseif click_name == "receive_btn" then
					self:updateMsg("receive_awards", {index = index})
				elseif click_name == "head_node" then
					self:updateMsg("look_player", {index = index})
				end
			end
		}
		self.m_reward_loop_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_view:reloadData(data, true)
	end
end

--奖励Scroll内cell的回调
function M:updateRewardCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	UIUtil.setTextByLanKey(transform, "first_title_text", "new_str_0078")
	UIUtil.setTextByLanKey(transform, "first_none_node/none_text", "new_str_0079")
	UIUtil.setTextByLanKey(transform, "name_text", data.cfg.name, data.cfg.target_value)
	local user = data.data.user or {}
	local value = data.data.value or 0 -- 是否完成 0 未完成 1 已完成
	local recv = data.data.recv or 0  -- 是否领奖 0 未领奖 1 已领奖
	local first_flag = _G.next(user)
	UIUtil.setObjectVisible(transform, not first_flag, "first_none_node")
	UIUtil.setObjectVisible(transform, first_flag, "first_player_node")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "had_img", value == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_text", value == 0)
	if first_flag then
		local time = data.data.time or 0
		local tm = TimeUtil.gmTime(time)
		local time_str = string.format("%d-%02d-%02d %02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", "new_str_0654", tostring(user.name), time_str)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text", "new_str_0080")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text_red", "new_str_0080")
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local finish = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", false)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", false)
	local can_click = false
	local show_reward = true
	if value == 0 then
		--未完成
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", true)
		can_click = true
	else
		if recv == 0 then
			--可领取
			can_click = false
		else
			--已完成
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", true)
			can_click = true
			show_reward = false
		end
	end
	local finish_eff = luaBehaviour:FindGameObject("UI_RankReward_LingQu_01")
	-- 奖励
	local drop = data.cfg.drop or {}
	local reward_node = UIUtil.findRectTransform(transform, "reward_node")
	UIUtil.destroyAllChild(reward_node)
	if show_reward == true then
		GameUtil:createRewards(reward_node, drop, true, can_click, function ()
			if value ~= 0 and recv == 0 then
				self:lockTouch()
				finish:SetActive(true)
				finish_eff:SetActive(true)
				finish.transform.localScale = Vector3(2,2,2)
				local sequence = Tweening.DOTween.Sequence()
				sequence:Append(finish.transform:DOScale(1, 0.25):SetEase(Tweening.Ease.Linear))
				sequence:OnComplete(function ()
					finish_eff:SetActive(false)
					self.m_control:setOnceTimer(0.15, function ()
						self:updateMsg("receive_awards", {index = index})
						self:unlockTouch()
					end)
				end)
				sequence:SetAutoKill(true)
			end
		end)
		if value ~= 0 and recv == 0 then
			GameUtil:creatCommonItemEffect(reward_node, 7, 0.95)
		end
	end
end

function M:setOwnInfo()
    local data = self.m_model:getOwnRankData()
    local rank = data.rank or 0
    if rank < 1 then
        self:setTextByLanKey("own_rank_text", "new_str_0076")
    else
        self:setTextByLanKey("own_rank_text", "new_str_0381", rank)
    end
    local score = data.score or 0
    if self.m_model.m_id == 1 then--"完成章节"
        self:setTextByLanKey("score_label_text", "new_str_0133")
        self:setTextByLanKey("own_score_title_text", "new_str_0382")
        local chapter_id, stage_id, stage_item = GameUtil:getChapterIdByStageId(score)
        self:setTextByLanKey("own_score_text", tostring(stage_item.map_point_name))
    elseif self.m_model.m_id == 2 then----"爬塔进度"
        self:setTextByLanKey("score_label_text", "new_str_0384")
        self:setTextByLanKey("own_score_title_text", "new_str_0383")
        self:setTextByLanKey("own_score_text", "new_str_0951", score)
	elseif  self.m_model.m_id == 4 then
		self:setTextByLanKey("score_label_text", "new_str_0701")
		self:setTextByLanKey("own_score_title_text", "new_str_0380")
		self:setTextByLanKey("own_score_text", tostring(score))
    else
        self:setTextByLanKey("score_label_text", "new_str_0375")
        self:setTextByLanKey("own_score_title_text", "new_str_0380")
        self:setTextByLanKey("own_score_text", tostring(score))
    end
    local user = data.user or {}
    local own_head_node = self:findGameObject("own_head_node")
    GameUtil:setUserAvatar(own_head_node, user,false,false,{show_flag = true, scale = 1})
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
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
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end
--天机楼列表单独创建
function M:updateLoopScroll1()
	local data = self.m_model:getRankData()
	local all_cell_size = {}
	for i,v in ipairs(data or {}) do
		if v.user.uid == self.m_model.m_cur_select_id then
			all_cell_size[i] = Vector2(945, 174.5)
		else
			all_cell_size[i] = Vector2(945, 83.52)
		end
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll1")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "race_img" then
					self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
				elseif click_name == "handle_point_btn" then
					self:updateMsg("handle_point_btn", {index = index, uid = cell_data.user.uid})
				else
					self:updateMsg("item_click", {id = index})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true, all_cell_size)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateItemInfo(obj, data, id)
    local user = data.user or {}
    local rank = data.rank or 0
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_rank_cfg.rece_type]
    if race then
       LuaBehaviourUtil.setImg(luaBehaviour,"race_icon", race.race_icon, ResourceUtil:getLanAtlas())
    else
    	LuaBehaviourUtil.setImg(luaBehaviour,"race_icon", "a_phb_icon_jifen",  "common_ui")
    end

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
	local rank_bg = luaBehaviour:FindGameObject("rank_bg")
	if not IsNull(rank_bg) then
		if rank >= 100 then
			UIUtil:setLocalDelta(rank_bg.transform, 64,32)
		elseif	rank >= 1000 then
			UIUtil:setLocalDelta(rank_bg.transform, 84,32)
		else
			UIUtil:setLocalDelta(rank_bg.transform, 32,32)	
		end
	end
    local score = data.score or 0
    if self.m_model.m_id == 1 then--"完成章节"
        local chapter_id, stage_id, stage_item = GameUtil:getChapterIdByStageId(score)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", false)
        -- UIUtil.setText(transform, string.format("%d-%d", chapter_id, stage_id), "race_score_text")
        UIUtil.setTextByLanKey(transform, "race_score_text", stage_item.map_point_name)
    elseif self.m_model.m_id == 2 then----"爬塔进度"
        UIUtil.setTextByLanKey(transform, "race_score_text", "new_str_0951", score)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", false)
	elseif self.m_model.m_id == 4 then
		UIUtil.setText(transform, tostring(score), "race_score_text")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", false)
    else
        UIUtil.setText(transform, tostring(score), "race_score_text")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", true)
    end
	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
    end
    UIUtil.setTextByLanKey(transform, "level_text", "new_str_0075", user.level or 1)
    local gender = user.gender or 0
    UIUtil.setObjectVisible(transform, gender > 0, "gender_img")
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		if self.m_model.m_id == 2 then
			name_text.transform.anchoredPosition = Vector3.New(-90, -57, 0)
		else
			name_text.transform.anchoredPosition = Vector3.New(-90, -15, 0)
		end
	else
		if self.m_model.m_id == 2 then
			name_text.transform.anchoredPosition = Vector3.New(-90, -42, 0)
		else
			name_text.transform.anchoredPosition = Vector3.New(-90, 0, 0)
		end
	end
	local handle_point_btn = luaBehaviour:FindGameObject("handle_point_btn")
	local jiantou_img = luaBehaviour:FindGameObject("jiantou_img")
	if self.m_model.m_id == 2 then
		local rect = obj:GetComponent("RectTransform")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_point_btn", true)
		if (id and data.user.uid == self.m_model.m_cur_select_id) or (not(id) and self.m_model.m_click_self) then
			rect.sizeDelta = Vector2(rect.rect.width, 174.5)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", true)
			self:updateMoreRankInfo(luaBehaviour, data, id)
			if handle_point_btn then
				handle_point_btn.transform.localScale = Vector3(1, -1, 1)
			end
		else
			rect.sizeDelta = Vector2(rect.rect.width, 83.52)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", false)
			if handle_point_btn then
				handle_point_btn.transform.localScale = Vector3(1, 1, 1)
			end
		end
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

function M:fingerSliding(locat)
    if locat then
        self:updateMsg("sliding_right")
    else
        self:updateMsg("sliding_left")
    end
end

return M