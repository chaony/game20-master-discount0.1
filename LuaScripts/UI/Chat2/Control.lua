--聊天
---@class ChatControl:OOControlBase
---@field m_model ChatModel
---@field m_view ChatView
local M = class("ChatControl",LikeOO.OOControlBase)

local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6, GROUP = 7,}
local __PRIVATE_LIST = {FRIEND = 1, STRANGER = 2, BLACKLIST = 3}

function M:onEnter()
	self.emoji_text = {}
	self.m_model.uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	self:updatePrivatePlayerData()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_ADD_CHANNEL, {self, self.onAddChannel})
end

function M:onHandle(msg, data)
	if msg == 99999 then    -- 返回
		self:updateMsg("common_refresh", { channel_id = G_CHAT_CHANEL }, "parent")
		self.m_view:closeUIAnim()
	elseif msg == 'btn_send' then
		self:sendChatText()
	elseif msg == 'btn_emoji' then
		self.m_view:ChangeEmoji()
	elseif string.find(msg,'channel_') then
		self.m_view.input.text = ''
		local sp = string.split(msg,'_')
		local channel = tonumber(sp[2])
		G_CHAT_CHANEL = channel
		--if ChatUtil:hasChannelRedPoint(channel) then
		ChatUtil:updateReadTs(channel)
		ChatUtil:updateRedPointData()
		self.m_view:updateChannelRedPoint()
		--end
		self.m_view:SetToggleChoose(channel, data.is_init)
		local full_btn_name = self.m_view.m_uiName .. "/pool_channel_toggle"
		GameUtil:playBtnSound(full_btn_name)
	elseif msg == "emoji_icon" then
		local emoji_text = "[" .. self.m_model:getTextByEmoji(data.emoji) .. "]"
		local text = self.m_view:getMsg() .. emoji_text
		self.m_view.input.text = text
		self.m_view.input:MoveTextEnd()
	elseif msg == "show_player" then
		self:openView("Pops.PlayerInfo", {uid = data})
	elseif msg == "private_list_btn" then
		self.m_view:setPrivateVisible()
	elseif msg == "open_friend" then
		self.m_model:init(data)
		self.m_view:SetToggleChoose(__CHAT_CHANNEL.PRIVATE)
		if self.m_model:isStranger(data.id) then
			self:requestStrangerData()
		end
	elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
		self:switchTabBtn(msg)
	elseif msg == "go_bottom_btn" then
		self.m_view:goToBottom()
	elseif msg == 'emoji_gif_icon' then
		self:sendChatGif(data)
	elseif msg == "add_enjoySpring_task" then
		self:joinSpringTask(data)
	elseif msg == "join_fulwin_arena" then
		self:joinFulwinArena(data)
	elseif msg == "add_fourforce_task" then
		self:joinFourForceTask(data)
	elseif msg == "click_type_btn" then
		if data and data.index ~= ChatUtil.type_select_index then
			ChatUtil.type_select_index = data.index
		else
			ChatUtil.type_select_index = nil
		end
		self.m_view:updateTypeList()
		self.m_view:updateChannelRedPoint()
	elseif msg == "click_detail_cell" then
		ChatUtil.private_uids[data.uid] = data.name
		ChatUtil.player_names[data.name] = data.uid
		if ChatUtil.cur_private_uid ~= data.uid then
			ChatUtil.cur_private_uid = data.uid
			--if ChatUtil:hasPlayerRedPoint(data.uid) then
			ChatUtil:updateReadTs(__CHAT_CHANNEL.PRIVATE, data.uid)
			ChatUtil:updateRedPointData()
			--end
			self.m_view:updateChatLoopScroll()
			self.m_view:updateTypeList()
			self.m_view:updateChannelRedPoint()
		end
	elseif msg == "friend_sort_btn" then
		if ChatUtil.type_detail_sort == 1 then
			return
		end
		ChatUtil.type_detail_sort = 1
		self.m_model:sortAllTypeListData()
		self.m_view:updateSortBtnView()
		self.m_view:updateTypeList()
	elseif msg == "recent_sort_btn" then
		if ChatUtil.type_detail_sort == 2 then
			return
		end
		ChatUtil.type_detail_sort = 2
		self.m_model:sortAllTypeListData()
		self.m_view:updateSortBtnView()
		self.m_view:updateTypeList()
	elseif msg == "add_black_btn" then
		self:addToBlacklist()
	elseif msg == "refresh_data" then
		self:updatePrivatePlayerData()
		if ChatUtil.cur_private_uid == data then
			ChatUtil.cur_private_uid = nil
			self.m_view:updateChatLoopScroll()
		end
	elseif msg == "awaken_system_invite" then
		self:awakenSystemInvite(data)
	elseif msg == "receive_red_packet" then
		self:openRedPacketPop(data)
	elseif msg == "refreshRedPacketState" then
		self.m_model:updateData(handler(self,self.onRefreshChatView))
	end
end

function M:onRefreshChatView()
	self.m_view:updateChatLoopScroll()
end

function M:onRefreshChatInfo()
	self:requestFriendData()
	self.m_view:addMsg()
end

function M:onAddChannel()
	self.m_model:initData()
end

-- 请求玩家数据
function M:updatePrivatePlayerData()
	self:requestFriendData()
	self:requestBlacklistData()
end

-- 请求好友数据
function M:requestFriendData()
	self.m_model.friend_data_ready = false
	local function callback(response)
		self.m_model:setFriendData(response)
		self:requestStrangerData()
		if self.m_model:isAllTypeListDataReady() then
			self.m_view:updateTypeList()
			self.m_view:updateChannelRedPoint()
		end
	end
	self.m_model:getNetData("friend_friends_basic_info", nil, callback)
end

-- 请求黑名单数据
function M:requestBlacklistData()
	self.m_model.blacklist_data_ready = false
	local function callback(response)
		self.m_model:setBlacklistData(response)
		self:requestStrangerData()
		if self.m_model:isAllTypeListDataReady() then
			self.m_view:updateTypeList()
			self.m_view:updateChannelRedPoint()
		end
	end
	self.m_model:getNetData("friend_blacklist_index", nil, callback)
end

-- 请求陌生人数据
function M:requestStrangerData()
	if self.m_model:canUpdateStrangerData() then
		local stranger_uids = self.m_model:getStrangerUIDs()
		local function callback(response)
			self.m_model:updateStrangerData(response)
			self.m_model:sortTypeListData(__PRIVATE_LIST.STRANGER)
			if self.m_model:isAllTypeListDataReady() then
				self.m_view:updateTypeList()
				self.m_view:updateChannelRedPoint()
			end
		end
		self.m_model:getNetData("user_get_users_info", {uids = stranger_uids}, callback)
	end
end

-- 发送聊天消息
function M:sendChatText()
	if G_CHAT_CHANEL == __CHAT_CHANNEL.GUILD then
		local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
		if guild_id == nil or guild_id  <= 0 then
			self:showLookInfoTips(Language:getTextByKey("union_str_0043"), 2)
			return
		end
	elseif G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		if ChatUtil.cur_private_uid == nil then
			self:showLookInfoTips(Language:getTextByKey("new_str_0515"), 2)
			return
		end
	end
	if self.m_view.emoji then
		self.m_view:ChangeEmoji()
	end
	local msg = self.m_view:getMsg()
	if msg == nil or msg == '' then
		return
	end
	ChatUtil.cur_input_msg = nil
	local function getString(s)
		local key = string.sub(s,2,-2)
		local emoji = self.m_model:getEmojiByText(key)
		if emoji then
			return "[" .. emoji .. "]"
		else
			return s
		end
	end
	local text = string.gsub(msg, "%b[]", getString)
	local data = self.m_model:getMsgData(text)
	local is_max_times, need_stage, tips_id = ChatUtil:isTimesByType(G_CHAT_CHANEL)
	local is_cd = ChatUtil:isCdByType(G_CHAT_CHANEL)
	if is_max_times then
		tips_id = tips_id ~= "" and tips_id or "new_str_0961"
		if need_stage ~= 0 then
			local stage_cfg = ConfigManager:getCfgByName("stage")
			local stage_name = stage_cfg[need_stage] and stage_cfg[need_stage].map_point_name or ""
			stage_name = Language:getTextByKey(stage_name)
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_id, stage_name), delay_close = 2})
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_id, tostring(need_stage)), delay_close = 2})
		end
	elseif is_cd then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0960"), delay_close = 2})
	else
		ChatUtil:sendMsg(data,2)
		self.m_view.input.text = ''
	end
end

-- 发送动图
function M:sendChatGif(data)
	if G_CHAT_CHANEL == __CHAT_CHANNEL.GUILD then
		local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
		if guild_id == nil or guild_id  <= 0 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0043"), delay_close = 2})
			return
		end
	elseif G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		if ChatUtil.cur_private_uid == nil then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0515"), delay_close = 2})
			return
		end
	end
	if self.m_view.emoji then
		self.m_view:ChangeEmoji()
	end
	local text = "[" .. data.emoji .. "]"
	local data = self.m_model:getMsgData(text)
	local is_max_times, need_stage, tips_id = ChatUtil:isTimesByType(G_CHAT_CHANEL)
	local is_cd = ChatUtil:isCdByType(G_CHAT_CHANEL)
	if is_max_times then
		tips_id = tips_id ~= "" and tips_id or "new_str_0961"
		if need_stage ~= 0 then
			local stage_cfg = ConfigManager:getCfgByName("stage")
			local stage_name = stage_cfg[need_stage] and stage_cfg[need_stage].map_point_name or ""
			stage_name = Language:getTextByKey(stage_name)
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_id, stage_name), delay_close = 2})
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_id, tostring(need_stage)), delay_close = 2})
		end
	elseif is_cd then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0960"), delay_close = 2})
	else
		ChatUtil:sendMsg(data,2)
		self.m_view.input.text = ''
	end
end

-- 添加好友到黑名单
function M:addToBlacklist()
	if ChatUtil.cur_private_uid == nil then
		return
	end
	local friend_uid = ChatUtil.cur_private_uid
	local function netCallback(response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0115"), delay_close = 2})
		self:updatePrivatePlayerData()
		ChatUtil.cur_private_uid = nil
		self.m_view:updateChatLoopScroll()
	end
	local params =
	{
		no_close_btn = false,
		text = Language:getTextByKey("friend_str_0021"),
		on_ok_call = function(msg)
			local uid = friend_uid
			self.m_model:getNetData("friend_add_to_blacklist", {f_uid = uid}, netCallback)
		end
	}
	static_rootControl:openView("Pops.CommonPop", params)
end

-- 按钮切换
function M:switchTabBtn(index)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_model.m_sel_tab_index = index
		self.m_view:switchTabNode(index)
	end
end

function M:joinSpringTask(data)
	local function joinSpringTaskCallback(response)
		if response then
			self:openView("Activities.EnjoySpring.LiteratureRankTask", {task_tab = 2})
			self:closeView()
		end
	end
	self.m_model:getNetData("enjoy_spring_receive_invite", data, joinSpringTaskCallback)
end

function M:joinFourForceTask(data)
	local function joinFourForceTaskCallback(response)
		if response then
			self:openView("Activities.FourForceWar.FourForceWarTask", {task_tab = 2})
			self:closeView()
		end
	end
	self.m_model:getNetData("enjoy_spring_receive_invite", data, joinFourForceTaskCallback)
end

function M:openRedPacketPop(data)
	local m_data = self.m_model.m_data or{}
	local ids = m_data.recv_ids or {}
	local flag = false
	local redid = data.red_id or ""
	for k,v in pairs(ids) do
		if v == redid then
			flag = true
			break
		end
	end
	local params =table.copy(data)
	params.open = flag
	self:openView("Main.RedPacketPop",params)
end

function M:awakenSystemInvite(data)
	local function awakenSystemInviteCallBack(response)
		if response then
			self:showLookInfoTips(Language:getTextByKey("awake_system_text_0060"),2)
		end
	end
	local params = {target_uid = data.invite_uid}
	self.m_model:getNetData("awaken_friend_help", params, awakenSystemInviteCallBack)
end

function M:joinGroup(data)
	local function joinGroupCallback(response)
		if response then
			self:openView("HalfAnniversary.HalfAnniversaryGrouping", { index = 2})
			self:closeView()
		end
	end
	local time_day_end = TimeUtil.getIntTimestamp(data.create_time) + 3600 * 24
	local time_now = UserDataManager:getServerTime()
	--当天拼团
	if time_now > time_day_end then
		self:showLookInfoTips(Language:getTextByKey("gift_group_text_0018"), 2)
		self:closeView()
	end
	local params = { vsn = data.version, group_id = data.group_id }
	self.m_model:getNetData("gift_join_group", params, joinGroupCallback)
end

function M:joinFulwinArena(data)
	local flag, tips_str = BtnOpenUtil:isBtnOpen(312)
	if not flag then
		self:showLookInfoTips(tips_str, 2)
		return
	end

	--if data.typ == 1 then
	--	local flag1, tips_str1 = BtnOpenUtil:isBtnOpen(334)
	--	if not flag1 then
	--		self:showLookInfoTips(tips_str1, 2)
	--		return
	--	end
	--else
	--	local flag2, tips_str2 = BtnOpenUtil:isBtnOpen(335)
	--	if not flag2 then
	--		self:showLookInfoTips(Language:getTextByKey("Fengyun_challenge_tips_no"), 2)
	--		return
	--	end
	--end

	local time = ConfigManager:getCommonValueById(725, 30)
	local server_time = UserDataManager:getServerTime()
	local send_time = data.send_time or 0
	if server_time - send_time >= time then
		self:showLookInfoTips(Language:getTextByKey("fylt_str_0086"), 2)
		return
	end

	local function joinFulwinArenaCallback(response)
		if response then
			self:openView("FulwinArena.FulwinArenaMain")
			QuickOpenFuncUtil:openFunc(90)
			self:closeView()
		end
	end
	local params = {}
	params.ring_id = data.ring_id
	params.from = "chat"
	self.m_model:getNetData("friend_arena_join_ring", params, joinFulwinArenaCallback)
end

function M:showLookInfoTips(msg, delay_close)
	local pos_offset = G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE and Vector2.zero or Vector2(-160, 0)
	GameUtil:lookInfoTips(self, {msg = msg, delay_close = delay_close, pos_offset = pos_offset})
end

function M:destroy()
	ChatUtil.cur_input_msg = self.m_view:getMsg()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_ADD_CHANNEL, {self, self.onAddChannel})
	M.super.destroy(self)
end

return M
