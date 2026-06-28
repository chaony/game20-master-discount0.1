local M = class("GuildHighWarRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarRewardPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1",  text_key = "tog_1_text", show_text = "guild_high_war_text_0039" , red_point_img = "race_red_point_img"}, -- 排行榜
	{btn_key = "tog_2",  text_key = "tog_2_text", show_text = "UnionWar_str_085" , red_point_img = "reward_red_point_img"}, -- 奖励
	{btn_key = "tog_3",  text_key = "tog_3_text", show_text = "guild_high_war_text_0025" , red_point_img = "reward_red_point_img"}, -- 奖励
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
		local have_reward = next(self.m_model.m_daily_gift_num) and true or false
		if not have_reward and k == 1 then
			tog_btn.interactable = false
		else
			tog_btn.interactable = true
		end
		self:setObjectVisible(v.red_point_img, false)
	end
	self:setTextByLanKey("common_title_text", "new_str_0110")
	self:setObjectVisible("tog_1",false) -- 保持之前逻辑不变 干掉每日
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
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("DailyNode",  self.m_model.m_sel_tab_index == 1)
	self:setObjectVisible("RecordNode",  self.m_model.m_sel_tab_index ~= 1)
	if self.m_model.m_sel_tab_index == 1 then
		self:updateLoopDailyScroll()
		self:updateNumsText()
		self:refreshDailyNode()
	else
		self:setObjectVisible("guild_name_empty_text",false)
		self:setObjectVisible("guild_img",self.m_model.m_sel_tab_index == 2 )
		self:setObjectVisible("team_head_bg",self.m_model.m_sel_tab_index == 3 )
		self:setObjectVisible("team_head_bg_mask",self.m_model.m_sel_tab_index == 3 )
		self:setTextByLanKey("reward_des_text", "guild_high_war_text_0040")
		local guild_name = self.m_model.m_guild_data.name or ""
		local player_name = UserDataManager.user_data:getUserStatusDataByKey("name")
		self:setTextByLanKey("guild_name_text", self.m_model.m_sel_tab_index == 3 and player_name or guild_name)
		self:setTextByLanKey("record_text", self.m_model.m_sel_tab_index == 3 and "guild_high_war_text_0025" or "UnionWar_str_085")
		self:setTextByLanKey("rank_text", "new_str_0374")
		self:setTextByLanKey("record_num_text", self.m_model.m_sel_tab_index == 2 and tostring(self.m_model.m_g_score) or tostring(self.m_model.m_score))
		self:setTextByLanKey("rank_num_text", self.m_model.m_sel_tab_index == 2 and tostring(self.m_model.m_g_rank) or tostring(self.m_model.m_rank))
		local gender = self.m_model.m_guild_data.flag or 0
		local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
		if flag_cfg then
			local union_icon_img = self:findImage("guild_img")
			GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
		end
		if self.m_model.is_watch == 1 then
			self:setObjectVisible("img_panel",false)
			self:setObjectVisible("text_panel",false)
			self:setObjectVisible("guild_name_empty_text",true)
			self:setTextByLanKey("guild_name_empty_text", "guild_high_war_text_0089")
		end
			--self:updateLoopRewardScroll()
		end
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

function M:refreshDailyNode()
	for i = 1, 9 do
		local show_data = self.m_model:getDailyNodeData(i)
		self:setObjectVisible("opne_name_text" .. i, show_data ~= nil)
		self:setObjectVisible("name_img" .. i, show_data ~= nil)
		local reward_node = self:setObjectVisible("ItemNode" .. i, show_data ~= nil)
		self:setObjectVisible("light_img" .. i, show_data ~= nil)
		self:setObjectVisible("reward_btn" .. i, show_data ~= nil)
		local reward_btn_img = self:findImage("reward_btn" .. i)
		local alpha_value = (show_data and show_data.is_self) and 255 or 0
		self:setColorA(reward_btn_img, alpha_value)
		if show_data then
			self:setTextByLanKey("opne_name_text" .. i, show_data.name)
			if show_data.is_self then
				self:setObjectVisible("reward_btn" .. i, true)
			else
				self:setObjectVisible("reward_btn" .. i, false)
			end
			--local box_id = show_data.box_id or {}
			--local box_reward = box_id.box_reward or {}
			--local reward = box_reward[1] or {}
			local reward = self.m_model:getRewardDataByBoxId(show_data.box_id)
			if reward and reward[1] then
				local reward_data = RewardUtil:getProcessRewardData(reward)
				local luaBehaviour = UIUtil.findLuaBehaviour(reward_node)
				GameUtil:updateItemElementByData(reward_node, reward_data, false, true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_img", false)
			end
		else
			self:setObjectVisible("reward_btn" .. i, true)
		end
	end
end

--[[
	创建列表
]]
function M:updateLoopDailyScroll()
    local data = self.m_model:getTagName() -- { {id = 1, name = "1", rewards = {{103, 1011, 21}, {107, 0, 3280}, {103, 99003, 11}}},
				   --{id = 1, name = "2", rewards = {{103, 1011, 22}, {107, 0, 3280}, {103, 99003, 12}}},
				   --{id = 1, name = "3", rewards = {{103, 1011, 23}, {107, 0, 3280}, {103, 99003, 13}}},}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateItemInfo(cell_object, cell_data, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "cell" then
                    self:updateMsg("select_daily_index",{index = index})
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

function M:updateItemInfo(obj, data, id)
    local user = data.user or {}
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local name_text = nil
	name_text = UIUtil.setTextByLanKey(transform,"name_text", data)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", self.m_model.m_cur_daily_index == id)
end

function M:updateLoopRewardScroll()
	local cfg_type = self.m_model.m_sel_tab_index == 2 and 2 or 1
	self.m_cfg_type = cfg_type
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
end

function M:updateRewardItemInfo(cell_object, cfg_key, index, cfg_type)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local cfg_data = self.m_model:getCfgDataByTypeAndIndex(self.m_cfg_type, index) or {}
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_des_text", self.m_model.m_sel_tab_index == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_value_text", self.m_model.m_sel_tab_index == 2)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_range_text", self.m_model.m_sel_tab_index == 3)
	local reward = cfg_data.reward or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "record_des_text", "UnionWar_str_085" )
	if cfg_data.rank then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "record_value_text","guild_high_war_text_0099", cfg_data.rank[1] .. (cfg_data.rank[2] and "-" .. cfg_data.rank[2] or "")  )
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_range_text","guild_high_war_text_0099", cfg_data.rank[1] .. (cfg_data.rank[2] and "-" .. cfg_data.rank[2] or "") )

	end
end

function M:refreshRedPoint()
    local red_point = self.m_model:getRankRedPointById(self.m_model.m_id)
    self.m_reward_red_point_img:SetActive(red_point)
end

return M