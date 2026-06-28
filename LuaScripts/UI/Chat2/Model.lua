---@class ChatModel:OODataBase
local M = class("ChatModel", LikeOO.OODataBase)

-- 聊天频道
local __CHAT_CHANNEL = {LOCAL = 1, WORLD = 2, GUILD = 3, PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6, GROUP = 7}
local __PRIVATE_LIST = {FRIEND = 1, STRANGER = 2, BLACKLIST = 3}

function M:onCreate()
	M.super.onCreate(self)
	self:getData("red_envelope_recv_ids")
end

function M:onEnter()
	self:setEmojiAsset(1)
	self:setEmojiGifAsset(2)
	self.m_sel_tab_index = 1
	self.m_open_type = self.m_params.open_type or nil
	self:init(self.m_params)
end

function M:init(data)
	if data.id then
		--从好友进来的
		local uid = data.id
		local name = data.name
		local avatar = data.avatar
		G_CHAT_CHANEL = __CHAT_CHANNEL.PRIVATE
		ChatUtil.cur_private_uid = uid
		ChatUtil.private_uids[uid] = name
		ChatUtil.player_names[name] = uid
		ChatUtil.private_player_avatar[name] = avatar
		if not self:isAllTypeListDataReady() then
			ChatUtil.type_select_index = 1
			return
		end
		if self:isFriend(uid) then
			ChatUtil.type_select_index = 1
		elseif self:isStranger(uid) then
			ChatUtil.type_select_index = 2
		elseif self:isBlackListPlayer(uid) then
			ChatUtil.type_select_index = 3
		end
	elseif data.channel_id then
		local channel_id = self:isRightChannelId(data.channel_id )
		G_CHAT_CHANEL = channel_id
	else
		G_CHAT_CHANEL = __CHAT_CHANNEL.LOCAL
	end
end

-- 好友数据
function M:setFriendData(data)
	self:updateFriendData(data)
	self:sortTypeListData(__PRIVATE_LIST.FRIEND)
end

function M:updateFriendData(data)
	self.m_friend_data = {}
	if data ~= nil then
		self.m_friend_data = data.friends_info
	end
	self.m_friend_uids = {}
	self.m_friend_num = 0
	self.m_online_friend_num = 0
	for k,v in ipairs(self.m_friend_data) do
		self.m_friend_uids[v.uid] = 1
		self.m_friend_num = self.m_friend_num + 1
		if v.is_online == 1 then
			self.m_online_friend_num = self.m_online_friend_num + 1
		end
	end
	self.friend_data_ready = true
end

-- 黑名单数据
function M:setBlacklistData(data)
	self:updateBlacklistData(data)
	self:sortTypeListData(__PRIVATE_LIST.BLACKLIST)
end 

function M:updateBlacklistData(data)
	self.m_blacklist_data = {}
	if data ~= nil then
		self.m_blacklist_data = data.blacklist_infos
	end
	self.m_blacklist_uids = {}
	self.m_blacklist_num = 0
	self.m_online_blacklist_num = 0
	for k,v in pairs(self.m_blacklist_data) do
		self.m_blacklist_uids[v.uid] = 1
		self.m_blacklist_num = self.m_blacklist_num + 1
		if v.is_online == 1 then
			self.m_online_blacklist_num = self.m_online_blacklist_num + 1
		end
	end
	self.blacklist_data_ready = true
end

-- 陌生人数据
function M:canUpdateStrangerData()
	return self.friend_data_ready and self.blacklist_data_ready
end

function M:getStrangerUIDs()
	self.m_stranger_uids = {}
	for uid,_ in pairs(ChatUtil.private_uids) do
		if not self.m_friend_uids[uid] and not self.m_blacklist_uids[uid] then
			table.insert(self.m_stranger_uids, uid)
		end
	end
	return self.m_stranger_uids
end

function M:updateStrangerData(data)
	self.m_stranger_data = {}
	if data ~= nil then
		self.m_stranger_data = data.users_info
	end
	self.m_stranger_num = 0
	self.m_online_stranger_num = 0
	for _,v in pairs(self.m_stranger_data) do
		self.m_stranger_num = self.m_stranger_num + 1
		if v.is_online == 1 then
			self.m_online_stranger_num = self.m_online_stranger_num + 1
		end
	end
	self.stranger_data_ready = true
end

-- 玩家数据排序
function M:sortAllTypeListData()
	self:sortTypeListData(__PRIVATE_LIST.FRIEND)
	self:sortTypeListData(__PRIVATE_LIST.STRANGER)
	self:sortTypeListData(__PRIVATE_LIST.BLACKLIST)
end

function M:sortTypeListData(index)
	local type_list_data
	if index == __PRIVATE_LIST.FRIEND then
		type_list_data = self.m_friend_data
	elseif index == __PRIVATE_LIST.STRANGER then
		type_list_data = self.m_stranger_data
	elseif index == __PRIVATE_LIST.BLACKLIST then
		type_list_data = self.m_blacklist_data
	end

	if not type_list_data or #type_list_data < 2 then
		return
	end
	
	if ChatUtil.type_detail_sort == 1 then  -- 按红点与最近登录时间排序
		local function timeSort(data1, data2)
			if ChatUtil.player_red_points[data1.uid] and ChatUtil.player_red_points[data2.uid] then
				return data1.last_active_time > data2.last_active_time
			elseif ChatUtil.player_red_points[data1.uid] then
				return true
			elseif ChatUtil.player_red_points[data2.uid] then
				return false
			else
				return data1.last_active_time > data2.last_active_time
			end
		end
		table.sort(type_list_data, timeSort)
	elseif ChatUtil.type_detail_sort == 2 then  -- 按最近聊天时间排序
		local function nameSort(data1, data2)
			local msgs1 = ChatUtil:getChannelMsg(__CHAT_CHANNEL.PRIVATE, data1.uid)
			local msgs2 = ChatUtil:getChannelMsg(__CHAT_CHANNEL.PRIVATE, data2.uid)
			local latest_msg1 = msgs1[#msgs1]
			local latest_msg2 = msgs2[#msgs2]
			if not latest_msg1 then
				return false
			elseif not latest_msg2 then
				return true
			end
			local latest_time1 = latest_msg1.time
			local latest_time2 = latest_msg2.time
			return latest_time1 > latest_time2
		end
		table.sort(type_list_data, nameSort)
	end
end

-- 玩家数据获取
function M:isAllTypeListDataReady()
	return self.friend_data_ready and self.stranger_data_ready and self.blacklist_data_ready
end

function M:getTypeListData(index)
	if index == __PRIVATE_LIST.FRIEND then
		return self.m_friend_data
	elseif index == __PRIVATE_LIST.STRANGER then
		return self.m_stranger_data
	elseif index == __PRIVATE_LIST.BLACKLIST then
		return self.m_blacklist_data
	end
end

function M:getTypeListDetailNum(index)
	if index == __PRIVATE_LIST.FRIEND then
		return self.m_friend_num or 0
	elseif index == __PRIVATE_LIST.STRANGER then
		return self.m_stranger_num or 0
	elseif index == __PRIVATE_LIST.BLACKLIST then
		return self.m_blacklist_num or 0
	end
end

function M:getTypeListOnlineDetailNum(index)
	if index == __PRIVATE_LIST.FRIEND then
		return self.m_online_friend_num or 0
	elseif index == __PRIVATE_LIST.STRANGER then
		return self.m_online_stranger_num or 0
	elseif index == __PRIVATE_LIST.BLACKLIST then
		return self.m_online_blacklist_num or 0
	end
end

function M:isRightChannelId(channel_id)
	if self.m_open_type and self.m_open_type == "guild_high_war" then
		if channel_id == __CHAT_CHANNEL.LOCAL or channel_id == __CHAT_CHANNEL.WORLD or channel_id == __CHAT_CHANNEL.PRIVATE then
			channel_id = __CHAT_CHANNEL.GUILDHIGHWAR
		end
	else
		if channel_id == __CHAT_CHANNEL.GUILDHIGHWAR or channel_id == __CHAT_CHANNEL.GUILDHIGHWARLOG then
			channel_id = __CHAT_CHANNEL.WORLD
		end
	end
	return channel_id
end

function M:getMsgData(msg)
	local send_data = {
		uid = UserDataManager.user_data:getUserStatusDataByKey("uid"),
		name = UserDataManager.user_data:getUserStatusDataByKey("name"), 
		avatar = tostring(UserDataManager.user_data:getUserStatusDataByKey("avatar")),
		frame = tostring(UserDataManager.user_data:getUserStatusDataByKey("frame")),
		msg = msg,
		channel_type = tostring(G_CHAT_CHANEL),
		title = UserDataManager.user_data:getUserStatusDataByKey("title"),
	}
	if G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		send_data.target_name = ChatUtil.private_uids[ChatUtil.cur_private_uid]
		send_data.channel_id = tostring(ChatUtil.cur_private_uid)
	end
	return send_data
end

function M:isFriend(uid)
	return self.m_friend_uids[uid] ~= nil
end

function M:isStranger(uid)
	return not self.m_friend_uids[uid] and not self.m_blacklist_uids[uid]
end

function M:isBlackListPlayer(uid)
	return self.m_blacklist_uids[uid] ~= nil
end

-- 聊天表情
function M:setEmojiAsset(id)
	self.m_emoji_asset_id = id
	self:updateEmojiListData()
	self:initEmojiText()
end

function M:updateEmojiListData()
	local emoji = ConfigManager:getCfgByName("emoji")
	self.m_emoji_data = emoji[self.m_emoji_asset_id] or {}
end

function M:initEmojiText()
	local emoji = ConfigManager:getCfgByName("emoji")
	local emoji_to_text = {}
	local text_to_emoji = {}
	for i,v in ipairs(emoji) do
		for i,v in ipairs(v) do
			local str = Language:getTextByKey(v.text)
			emoji_to_text[v.emoji] = str
			text_to_emoji[str] = v.emoji
		end
	end
	self.m_emoji_to_text = emoji_to_text
	self.m_text_to_emoji = text_to_emoji
end

function M:getTextByEmoji(str)
	return self.m_emoji_to_text[str]
end

function M:getEmojiByText(str)
	return self.m_text_to_emoji[str]
end

function M:setEmojiGifAsset(id)
	self.m_emoji_gif_asset_id = id
	self:updateEmojiGifListData()
end

function M:updateEmojiGifListData()
	local emoji = ConfigManager:getCfgByName("emoji")
	local emoji_gif_data = emoji[self.m_emoji_gif_asset_id] or {}
	self.m_emoji_gif_data = {}
	for i, v in pairs(emoji_gif_data) do
		if v.unlock_item ~= 0 then
			local flag =UserDataManager:checkEmojiCanUse(v.emoji)
			if flag then
				v.id = i
				table.insert(self.m_emoji_gif_data,v)
			end
		else
			v.id = i
			table.insert(self.m_emoji_gif_data,v)
		end
	end
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	local function sortFun(data1, data2)
		if data1.unlock_level == data2.unlock_level then
			return data1.id < data2.id
		else
			return data1.unlock_level < data2.unlock_level
		end
	end
	table.sort(self.m_emoji_gif_data,sortFun)
end

-- 检查发的消息是否是动图
function M:checkMsgIsEmojiGif(msg)
	local emoji = ConfigManager:getCfgByName("emoji")
	local emoji_gif_data = emoji[self.m_emoji_gif_asset_id] or {}
	for i, v in pairs(emoji_gif_data) do
		local str = "["..v.emoji .."]"
		if str == msg then
			return v
		end
	end
	return nil
end

function M:updateData(callback)
	local function netCallback(response)
		if response then
			self.m_data = response
			callback()
		end
	end
	self:getNetData("red_envelope_recv_ids",nil,netCallback)
end

return M
