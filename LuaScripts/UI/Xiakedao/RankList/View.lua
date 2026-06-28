---@class RankListView:OOPopBase
---@field m_model RankListModel
local M = class("RankListView",LikeOO.OOPopBase)

M.m_uiName = "Achievement/AchievementRankList"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "RankListNode", text_key = "tog_1_text", show_text = "new_str_0235" , red_point_img = "race_red_point_img"}, -- 排行榜
	{btn_key = "tog_2", lua_name = "RewardNode", text_key = "tog_2_text", show_text = "new_str_0373" , red_point_img = "reward_red_point_img"}, -- 奖励
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
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "world_boss_str_0033")
	self:setTextByLanKey("own_score_title_text", "new_str_0380")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("player_label_text2", "new_str_0372")
	self:setTextByLanKey("reward_label_text", "new_str_0373")
	self:setTextByLanKey("lv_label_text", "new_str_0701")
    self.m_own_info_node = self:findGameObject("own_info_node")
	self.m_own_info_prefab = GameUtil:createPrefab("Achievement/AchievementRankListItem",self.m_own_info_node.transform)
    local btn = UIUtil.findButton(self.m_own_info_prefab.transform)
    btn.enabled = false
    self:setTextByLanKey("common_title_text", "new_str_0114")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
    self:setTextByLanKey("reward_btn_text", "new_str_0110")
	self:refreshUI()
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
		self:setTextByLanKey("common_title_text", "new_str_0114")
    else
        self:setTextByLanKey("common_title_text", "new_str_0918")    
    end
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model:getOwnRankData()
    self:updateItemInfo(self.m_own_info_prefab, data)
	if self.m_model.m_sel_tab_index and self.m_model.m_sel_tab_index == 2 then
		self:updateRewardLoopScroll()
	else
		self:updateLoopScroll()
	end
end

function M:refreshOwnPrebPosition()
	local content = self:findGameObject("Content")
	local rect = content:GetComponent("RectTransform")
		
	if self.m_model.m_click_self then
		rect.sizeDelta = Vector2(rect.rect.width, 210)
	else
		rect.sizeDelta = Vector2(rect.rect.width, 137)
	end
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

	--local starT = TimeUtil.gmTime(data.time or 0)
	--local timerFormat = Language:getTextByKey("achievement_text5", starT.year, starT.month, starT.day, starT.hour, starT.min)
	--UIUtil.setText(transform, tostring(timerFormat), "race_score_text")

	UIUtil.setTextByLanKey(transform, "race_score_text", "achievement_text26",data.lose_num)
	
	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
    end
	--local numStr = GameUtil:numberToChineseString(data.chapter or 1) or ""
    UIUtil.setTextByLanKey(transform, "level_text", "achievement_text27",  data.score)
    local gender = user.gender or 0
    UIUtil.setObjectVisible(transform, gender > 0, "gender_img")
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-90, -15, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-90, 0, 0)
	end
	if data.chapter == 0 then
		UIUtil.setTextByLanKey(transform, "level_text", "new_str_0092")
		UIUtil.setTextByLanKey(transform, "race_score_text", "new_str_0092")
	end
end


--[[
	创建奖励
]]
function M:updateRewardLoopScroll()
	local data = self.m_model:getRankReward()
	local max_index = #data
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRewardScrollViewCell(index, cell_object, cell_data, max_index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rank_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateRewardScrollViewCell(index, cell_object, cell_data, max_index)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local reward = cell_data.reward or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
	local rank = cell_data.rank or {}
	local first_rank = rank[1] or 0
	local second_rank = rank[2] or 0

	local top_three_flag = first_rank > 0 and first_rank < 2
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[first_rank]
	if top_three_item and top_three_flag then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
	else
		--if index == max_index then
		--	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0894", first_rank)
		--else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", first_rank .. "-" .. second_rank)
		--end
	end
end

return M