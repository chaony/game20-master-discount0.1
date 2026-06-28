
local M = class("GuildHighWarMainView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __CHAT_CHANNEL = {LOCAL = 1, WORLD = 2, GUILD = 3, PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}
local __TAB_CHAT_BTN_NODE = {
	{btn_key = "chat_channel_1", show_text = "new_str_0475", text_key = "chat_channel_text1", channel_tag = __CHAT_CHANNEL.LOCAL}, -- 本地
	{btn_key = "chat_channel_2", show_text = "new_str_0474", text_key = "chat_channel_text2", channel_tag = __CHAT_CHANNEL.WORLD}, -- 世界
	{btn_key = "chat_channel_3", show_text = "new_str_0476", text_key = "chat_channel_text3", channel_tag = __CHAT_CHANNEL.GUILD}, -- 公会
	{btn_key = "chat_channel_4", show_text = "new_str_0477", text_key = "chat_channel_text4", channel_tag = __CHAT_CHANNEL.PRIVATE}, -- 私聊
}
local PLAYOFF_TYPE = {
	[1] = {name = "guild_high_war_new_007"},
	[2] = {name = "guild_high_war_new_008"},
	[3] = {name = "guild_high_war_new_009"},
	[4] = {name = "guild_high_war_new_0010"},
	[5] = {name = "guild_high_war_new_0016"},
}
local GHW_STAGW = {
	[1] = {name = "guild_high_war_new_0022"},
	[2] = {name = "guild_high_war_new_0023"},
	[3] = {name = "guild_high_war_new_0024"},
	[4] = {name = "guild_high_war_new_0025"},
	[5] = {name = "guild_high_war_new_0026"},
	[6] = {name = "guild_high_war_new_0024"},
	[7] = {name = "guild_high_war_new_0027"},
	[8] = {name = "guild_high_war_new_0022"},
	[9] = {name = "guild_high_war_new_0023"},
}
local __Watch_Map_Pos = Vector3(548,307,10100)
local __Battle_Map_Pos = Vector3(249,307,10100)

function M:onEnter()
	self:setTextByLanKey("close_title_text", "guild_high_war_text_0001")
	self:setTextByLanKey("chakan_btn_text", "moon_shadow_str_006")
	self:setTextByLanKey("battle_team_btn_text", "guild_high_war_text_0041")
	self:setTextByLanKey("log_btn_text", "UnionWar_str_006")
	self:setTextByLanKey("edit_team_btn_text", "guild_high_war_new_0035")
	self:setTextByLanKey("reward_btn_text", "guild_high_war_new_0037") -- 巅峰商店
	self:setTextByLanKey("rank_btn_text", "guild_high_war_text_00107")
	self:setTextByLanKey("map_txt", "guild_high_war_text_0079")
	self:setTextByLanKey("double_btn_txt", "guild_high_war_new_0042")
	self:setTextByLanKey("threeword_btn_txt", "guild_high_war_new_0051")
	self:initChatToggleNode()
	self:showChatDetailNode()
	self:refreshUI()
	--self:updateMsg("pop_log")
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent})
	if self.m_model.m_pop_log and next(self.m_model.m_pop_log) and self.m_model.round_id ~=1 then
		self:updateMsg("pop_log")
	end
	self:setObjectVisible("chat_node",false)
	self:setObjectVisible("down_time_des_text",false)
	self:setObjectVisible("guild_node",false)
	self:setObjectVisible("guild_node2",false)
	self:setObjectVisible("guild_show_btn",false)
end

function M:initChatToggleNode()
	for i,v in ipairs(__TAB_CHAT_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn_key)
		local item = self:findGameObject(v.btn_key)
		self:setTextByLanKey(v.text_key, v.show_text)
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("chat_tab_btn",v.channel_tag)
				self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_12)
			else
				self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_2)
			end
		end, i, self.m_uiName)
	end
end

function M:showChatDetailNode()
	self:setObjectVisible("chat_node", self.m_model.m_chat_show)
	self:setObjectVisible("chat_btn2", not(self.m_model.m_chat_show))
	self:refreshPrivateChatRedPoint()

	if self.m_model.m_chat_show then
		--ChatUtil:setPrivateRedStatus(false)
		self:updateMsg("chat_tab_btn",self.m_model.m_cur_channel_id)
	end
end
function M:updateGuildView()
	if self.m_model.m_is_watch == 1 or self.m_model.m_ghw_stage == 3 then --观战模式  --准备阶段
		self:setObjectVisible("guild_show_btn",false)
		self:setObjectVisible("guild_node",false)
		self:setObjectVisible("guild_node2",false)
		return
	end
	--self:setObjectVisible("guild_node", self.m_model.m_guild_show and self.m_model.m_ghw_stage == 6)
	--self:setObjectVisible("guild_node2", self.m_model.m_guild_show and (self.m_model.m_ghw_stage == 4 or self.m_model.m_ghw_stage == 5))
	self:setObjectVisible("guild_node", false)
	self:setObjectVisible("guild_node2", false)
	if self.m_model.m_ghw_stage == 6 then		self:updateGuildDeclareDetailView()
	elseif self.m_model.m_ghw_stage == 4 or self.m_model.m_ghw_stage == 5 then 
		self:updateGuildArrayDetailView()
	end
end

-- 右上界面 --宣战
function M:updateGuildDeclareDetailView()
	if self.m_model.m_guild_show == false then return end
	local data = self.m_model.m_line_data or {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("guild_detail_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			--one_line_count = 1,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local data = cell_data
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guild_name_text",data.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"gulid_context_text","guild_high_war_text_0073",data.level)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fight_Image",data.status == 1)
end

-- 右上界面 --布阵
function M:updateGuildArrayDetailView()
	if self.m_model.m_guild_show == false then return end
	self:setTextByLanKey("to2_atk_times_text","guild_high_war_text_0074")
	self:setTextByLanKey("to2_atk_times_text2","guild_high_war_text_0075")
	self:setTextByLanKey("to2_atk_times_text_empty","guild_high_war_text_0091")
	--防守
	local array_data = self.m_model.m_array_data or {}
	if self.m_loop_scroll_array_view == nil then
		local loopscroll = self:findGameObject("guild2_detail_scroll")
		local params = {
			show_data = array_data,
			loop_scroll_object = loopscroll,
			--one_line_count = 1,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollArrayViewCell1(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end
		}
		self.m_loop_scroll_array_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_array_view:reloadData(array_data)
	end
    -- 进攻
	local fight_data = self.m_model.m_fight_data or {}
	self:setObjectVisible("to2_atk_times_text_empty",#fight_data<=0)
	if self.m_loop_scroll_fight_view == nil then
		local loopscroll = self:findGameObject("guild2_detail_scroll2")
		local params = {
			show_data = fight_data,
			loop_scroll_object = loopscroll,
			--one_line_count = 1,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollArrayViewCell2(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end
		}
		self.m_loop_scroll_fight_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_fight_view:reloadData(fight_data)
	end
end

function M:updateScrollArrayViewCell1(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local data = cell_data
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guild_name_text",data.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"gulid_context_text","guild_high_war_text_0076",data.guild_name)
	local falg = Language:getTextByKey("new_str_0092")~= data.guild_name
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fight_Image",falg)
end

function M:updateScrollArrayViewCell2(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local data = cell_data
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guild_name_text",data.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"gulid_context_text","guild_high_war_text_0077",data.guild_name)

end

local chat_cell_offsetY = 22
local chat_content_default_height = 110
function M:updateChatScroll(msgs)
	local data = msgs
	local content_height = 0
	local cell_height_tab = {}
	for i = 1, 5 do
		local chat_cell = self:findGameObject("chat_cell" .. i)
		local cell_data = data[i]
		chat_cell:SetActive(cell_data ~= nil )
		if cell_data then
			local chat_context = cell_data.msg
			local emoji_data = self.m_model:checkMsgIsEmojiGif(cell_data.msg)
			if emoji_data then
				chat_context = Language:getTextByKey(emoji_data.text)
			end
			--"cell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msg"--cell_data.msg
			local sender_name = cell_data.name
			if tonumber(cell_data.channel_type)  == __CHAT_CHANNEL.PRIVATE then
				sender_name = cell_data.name
				if cell_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
					sender_name = cell_data.target_name
					sender_name = Language:getTextByKey("new_str_0956", sender_name)
				else
					sender_name = sender_name .. Language:getTextByKey("new_str_1048")
				end
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(chat_cell)
			local cell_rect = chat_cell:GetComponent("RectTransform")
			local chat_name_text = LuaBehaviourUtil.setText(luaBehaviour, "chat_name_text", sender_name .. ": ")
			chat_name_text.transform:GetComponent('ContentSizeFitter'):SetLayoutHorizontal();
			local name_size = chat_name_text.transform:GetComponent('RectTransform').sizeDelta
			local new_content_width = cell_rect.rect.width - name_size.x
			local chat_context_text = luaBehaviour:FindGameObject("chat_context_text")
			local context_rectform = chat_context_text.transform:GetComponent('RectTransform')
			context_rectform.sizeDelta = Vector2(new_content_width, context_rectform.sizeDelta.y)
			LuaBehaviourUtil.setText(luaBehaviour, "chat_context_text", chat_context)
			chat_context_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			local text_size = chat_context_text.transform:GetComponent('RectTransform').sizeDelta
			cell_rect.sizeDelta = Vector2(cell_rect.rect.width, text_size.y)
			content_height = content_height + text_size.y
			UIUtil.setLocalPosition( chat_context_text.transform, name_size.x + 3)
			cell_height_tab[i] = math.max(text_size.y, chat_cell_offsetY)
		end
	end
	self:updateChatCellPos(content_height <= 90, cell_height_tab)
end

function M:updateChatCellPos(is_default_pos, cell_height_tab)
	if is_default_pos then
		local start_pos = chat_content_default_height
		for i = 1, 5 do
			local chat_cell = self:findGameObject("chat_cell" .. i)
			local offsetY = 0
			if i > 1 and cell_height_tab[i - 1] then
				offsetY = cell_height_tab[i - 1]
			end
			local pos_y = start_pos - offsetY
			chat_cell.transform.localPosition = Vector3(chat_cell.transform.localPosition.x, pos_y,0)
			start_pos = pos_y
		end
	else
		local start_pos = -91 + cell_height_tab[#cell_height_tab] - chat_cell_offsetY
		for i =#cell_height_tab, 1, -1 do
			local chat_cell = self:findGameObject("chat_cell" .. i)
			local offsetY = cell_height_tab[i] and cell_height_tab[i] or 0
			offsetY = i == #cell_height_tab and 0 or offsetY
			local pos_y = start_pos + offsetY + chat_content_default_height
			chat_cell.transform.localPosition = Vector3(chat_cell.transform.localPosition.x, pos_y,0)
			start_pos = start_pos +  offsetY
		end
	end
end

function M:refreshPrivateChatRedPoint()
	--local is_red = ChatUtil:getPrivateRedStatus()
	--self:setObjectVisible("chat_btn_point_img", is_red)
end

function M:refreshUI()
	self:updateBtnStatus()
	self:updateAtkTimes()
	self:updateGuildView()
	self:UpdataRedPoint()
	--后期修改隐藏
	self:setObjectVisible("rank_btn", true)
	self:setObjectVisible("reward_btn", false)
	self:setObjectVisible("log_btn", false)
	--self:setObjectVisible("change_btn", false)
	
	
	--local map_go = self:findGameObject("map_btn")
	--map_go.transform.position = self.m_model.m_is_watch == 1 and __Watch_Map_Pos or __Battle_Map_Pos 
	--self:refreshLines()
	self:refreshSpine() --刷新特效
end

function M:refreshSpine()
	self:setObjectVisible("UI_GuildHighWar_Fire_001",self.m_model.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.BATTLE)	 --战斗阶段
end

function M:updateAtkTimes()
	local times = self.m_model.m_declare_times
	local _, city_level = self.m_model:getOwenerCityId()
	local des = ""
	for i = 1, city_level do
		local temp = Language:getTextByKey("guild_high_war_text_006" .. 9 - i ) .. (i<city_level and "/" or "")
		des = des .. temp
	end
	self:setTextByLanKey("to_atk_times_text","guild_high_war_text_0064", times)
	self:setTextByLanKey("to_atk_city_text","guild_high_war_text_0065", des)
end

function M:updateBtnStatus()
	self:setObjectVisible("rank_btn", self.m_model.m_show_staus)
	self:setObjectVisible("battle_team_btn", self.m_model.m_show_staus)
	self:setObjectVisible("log_btn", self.m_model.m_show_staus)
	self:setObjectVisible("reward_btn",  self.m_model.m_show_staus)
	--self:setObjectVisible("edit_team_btn",  self.m_model.m_show_staus)
	if self.m_model.m_is_watch == 1 then
		self:setObjectVisible("reward_btn", false)
		--self:setObjectVisible("edit_team_btn", false)
		self:setObjectVisible("battle_team_btn", false)
	end
	--self:setObjectVisible("edit_team_btn", false)
end

function M:updateActivityTimer()
	--local end_ts = self.m_model:getEndTs()
	--if end_ts >= 0 then
	--	local text = GameUtil:formatTimeBySecond(end_ts, 999)
	--	local stage_name = self.m_model:getStageName()
	--	if self.m_model.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.PREPARE then
	--		self:setTextByLanKey("down_time_des_text",stage_name, text)
	--	else
	--		self:setTextByLanKey("down_time_des_text",stage_name,tostring(self.m_model.m_round_id), text)
	--	end
	--else
	--	GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
	--	self:updateMsg(99999)
	--end
	local end_ts = self.m_model:getEndTs()
	local end_C_ts = self.m_model:getEndCycleTs()
	if end_ts<=0 or end_C_ts <=0 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
		self:updateMsg(99999)
		self:updateMsg("new_close_btn",nil,"UnionWar")
		return
	end
	if self.m_model.big_stage == 1 then
		self:setTextByLanKey("down_time_des_text1","guild_high_war_new_0011")
		self:setObjectVisible("Image2",false)
	elseif self.m_model.big_stage == 2 then
		local end_ts = self.m_model:getEndTs()
		self:setTextByLanKey("down_time_des_text1","guild_high_war_new_0012",self.m_model.cycle)
		self:setTextByLanKey("down_time_des_text2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
		self:setTextByLanKey("down_time_des_text3",GHW_STAGW[self.m_model.m_ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
	elseif self.m_model.big_stage == 3 then
		local end_ts = self.m_model:getEndTs()
		self:setTextByLanKey("down_time_des_text1",Language:getTextByKey(PLAYOFF_TYPE[self.m_model.playoff_type].name)..string.format(Language:getTextByKey("guild_high_war_new_0015"),self.m_model.cycle))
		self:setTextByLanKey("down_time_des_text2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
		self:setTextByLanKey("down_time_des_text3",GHW_STAGW[self.m_model.m_ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
	end
	--是否有双倍收益
	self:setObjectVisible("double_btn",false)
	if self.m_model.big_stage == 2 or self.m_model.big_stage == 3 then 
		local cfg = ConfigManager:getCfgByName("guild_high_war_base")
		if cfg then
			for m,n in ipairs(cfg) do 
				if n.type == self.m_model.big_stage and n.cycle == self.m_model.cycle then
					local double_time = n.double_time or nil
					if double_time then
						for k,v in pairs(double_time) do
							if v== self.m_model.m_round_id then
								self:setObjectVisible("double_btn",true)
								break
							end
						end
					else
						self:setObjectVisible("double_btn",false)
					end
				end
			end

		end
	else
		self:setObjectVisible("double_btn",false)
	end
end

function M:UpdataRedPoint()
	 -- 战报红点
	local red_flag = RedPointUtil:localRedPointJudge("guild_zhan_bao")
	self:setObjectVisible("log_btn_red_point_img",red_flag)
	if self.m_model.m_round_id == 1 then --特殊处理第一阶段红点
		self:setObjectVisible("log_btn_red_point_img",false)
	end
	--参与队
	local team_flag = RedPointUtil:hasRedPointById(295)
	self:setObjectVisible("battle_team_btn_red_point_img",team_flag)
	
	--任务红点
	--local task_red  = RedPointUtil:localRedPointJudge("guild_high_war_task")
	local flag_ = UserDataManager:getRedDotByKey("guild_high_war_task")
	self:setObjectVisible("edit_team_btn_red_point_img",flag_==1)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent})
	M.super.destroy(self)
end

return M




