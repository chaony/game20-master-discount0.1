local M = class("CompareSwordResultRankListView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/CompareSwordResult/CompareSwordResultRankList"
M.m_iphoneXAdapter = true
M.m_size_type = 2

--积分赛  晋级赛
local __TAB_BTN_NODE1 = {
	{ btn_key = "tog_1", btn_text = "tog_1_text", text_key = "game_of_heaven_and_earth_reward_text_002", type = 1 },
	{ btn_key = "tog_2", btn_text = "tog_2_text", text_key = "game_of_heaven_and_earth_reward_text_003", type = 2 },
}
--天赛 地赛
local __TAB_BTN_NODE2 = {
	{ btn_key = "tog_3", btn_text = "tog_3_text", text_key = "game_of_heaven_and_earth_reward_text_004", type = 1 },
	{ btn_key = "tog_4", btn_text = "tog_4_text", text_key = "game_of_heaven_and_earth_reward_text_005", type = 2 },
}
-- 1 积分赛 天 2 晋级赛 天  3 积分赛 地  4 晋级赛 地
local __TAB_BTN_NODE2_COLOR = { Color(86 / 255, 52 / 255, 42 / 255), Color(58 / 255, 72 / 255, 94 / 255) }

function M:onEnter()
	self.m_race_type = 1
	self.m_type_type = 1
	self:setTextByLanKey("common_title_text", "compare_sword_race_text_048")
	for k, v in pairs(__TAB_BTN_NODE1) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_race_type then
			--选中的那个
			tog_btn.isOn = true
			self.m_model.m_race_type = v.type
		end
		self:setTextColor(v.btn_text,k == self.m_model.m_race_type and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE)
		UIUtil.addToggleListener(tog_btn, function(is_on)
			self:switchTabUpdate1(is_on, k, v)
		end, nil, self.m_uiName)
	end

	for k, v in pairs(__TAB_BTN_NODE2) do
		self:setTextByLanKey(v.btn_text, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		if k == 1 then
			--选中的那个
			tog_btn.isOn = true
			self.m_model.m_type_type = v.type
		end
		self:setTextColor(v.btn_text,k == self.m_model.m_open_tab_index and  __TAB_BTN_NODE2_COLOR[1] or __TAB_BTN_NODE2_COLOR[2])
		UIUtil.addToggleListener(tog_btn, function(is_on)
			self:switchTabUpdate2(is_on, k, v)
		end, nil, self.m_uiName)
	end
	--根据比赛类型区分比赛排行榜按钮
	self:setObjectVisible("tog_2",self.m_model.raceType >=3)
	self:refreshUI()
end

function M:switchTabUpdate1(is_on, update_key, data)
	if is_on then
		self.m_model.m_race_type = update_key
		self:updateMsg("race", { key = update_key, value = data })
	end
	self:setTextColor(data.btn_text,is_on and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE)
end

function M:switchTabUpdate2(is_on, update_key, data)
	if is_on then
		self.m_model.m_type_type = update_key
		self:updateMsg("type", { key = update_key, value = data })
	end
	self:setTextColor(data.btn_text,is_on and __TAB_BTN_NODE2_COLOR[1] or __TAB_BTN_NODE2_COLOR[2])
end

function M:refreshUI()
	self:updateLoopScroll()
	self:updateSelfRank()
	local text = self.m_model.m_race_type == 1 and "compare_sword_rise_title_007" or "compare_sword_rise_title_007"
    self:setTextByLanKey("damage_text_",text)
	self:setObjectVisible("CommonTipsNode" , false)
	if not next(self.m_model:getRankList()) then
		self:setObjectVisible("CommonTipsNode" , true)
	end
end


--[[
	创建列表
]]
function M:updateLoopScroll()
	--local type = self.m_model.m_race_type + self.m_model.m_type_type
	local data = self.m_model:getRankList() --todo： 获取服务器的列表数据
	self:setObjectVisible("CommonTipsNode" , #data<=0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateItemInfo(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", { id = index ,data =cell_data})
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

local RANK_TXT ={
	[1] = "compare_sword_rank_title_001",
	[2] = "compare_sword_rank_title_002",
	[3] = "compare_sword_rank_title_003",
	[4] = "compare_sword_rank_title_004",
	[8] = "compare_sword_rank_title_005",
	[16] = "compare_sword_rank_title_006",
	[32] = "compare_sword_rank_title_007",
}
function M:updateItemInfo(cell_object, celldata)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	if luaBehaviour then
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
		--if #celldata.rank == 1 then
		--	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank[1])
		--elseif #celldata.rank >= 2 then
		--	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank[1] .. " - " .. celldata.rank[2])
		--else
		--	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank)
		--end
		if celldata.rank <= 3 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
			LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..celldata.rank, "common_ui")
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank)
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text",  celldata.user.server_name or UserDataManager.server_data:getServerNameById(celldata.user.server))
		luaBehaviour:FindGameObject("btn_showReport"):SetActive(false)
		local head_node = luaBehaviour:FindGameObject("head_node")
		GameUtil:setUserAvatar(head_node, celldata.user, false, false, {show_flag = true, scale = 1})
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",celldata.user.name)
		--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text",server_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "damage_text", GameUtil:formatValueToString(celldata.score))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "damage_text2", RANK_TXT[celldata.best_stage])
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "damage_text2", self.m_model.m_race_type == 2)
		--local reward_node = luaBehaviour:FindGameObject("reward_node")
		--GameUtil:createRewards(reward_node.transform, celldata.reward, true, true)
	end
end

function M:updateSelfRank()
	local ownInfoItemGO = self:findGameObject("own_info_Item")
	local luaBehaviour = ownInfoItemGO:GetComponent("LuaBehaviour")
	
	local rank_bgGO = luaBehaviour:FindGameObject("rank_bg")
	local rank_text = luaBehaviour:FindText("rank_text")
	local top_three_rank_img = luaBehaviour:FindImage("top_three_rank_img")
	local none_rank_text = luaBehaviour:FindText("none_rank_text")
	none_rank_text.gameObject:SetActive(false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text","qi_men_dun_jia_str_021")
	if self.m_model.self_rank==0 then --todo:
		top_three_rank_img.gameObject:SetActive(false)
		rank_bgGO.gameObject:SetActive(false)
		none_rank_text.gameObject:SetActive(true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
	elseif self.m_model.self_rank > 3 then
		rank_bgGO.gameObject:SetActive(false)
		top_three_rank_img.gameObject:SetActive(false)
		none_rank_text.gameObject:SetActive(false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text",true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", self.m_model.self_rank)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
		top_three_rank_img.gameObject:SetActive(true)
		if not self.m_model.self_rank then 
			top_three_rank_img.gameObject:SetActive(false)
		end
		local rankNum = self.m_model.self_rank
		self:setImg("a_phb_icon_" .. rankNum , "common_ui" , "top_three_rank_img")
	end
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_rank, score = self.m_score })
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, userData.user, false, false, {show_flag = true, scale = 1})
	local server_name = UserDataManager.server_data:getServerName()
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",userData.user.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text",server_name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text",GameUtil:formatValueToString(self.m_model.self_score))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text2",RANK_TXT[self.m_model.self_best_stage] or "")
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end


function M:destroy()

	M.super.destroy(self)
end

return M