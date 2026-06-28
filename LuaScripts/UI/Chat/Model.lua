local M = class("ChatModel", LikeOO.OODataBase)

local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}
function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:setEmojiAsset(1) -- 初始化表情
	self:setEmojiGifAsset(2) -- 初始化动图配置
	self.m_private_name = 1
	self.m_sel_tab_index = 1 -- emoji toggle sel
	self.m_open_type = self.m_params.open_type or nil
	self:init(self.m_params)
	--if self.m_params.id then
	--	--从好友进来的
	--	local uid = self.m_params.id
	--	local name = self.m_params.name
	--	ChatUtil.channel_msgs[__CHAT_CHANNEL.PRIVATE] = ChatUtil.channel_msgs[__CHAT_CHANNEL.PRIVATE] or {}
	--	G_CHAT_CHANEL = __CHAT_CHANNEL.PRIVATE
	--	ChatUtil.player_names[name] = uid
	--else
	--	G_CHAT_CHANEL = __CHAT_CHANNEL.LOCAL
	--end
	--self:initData()
	--if self.m_params.name then
	--	for i,v in ipairs(self.m_private_names or {}) do
	--		if v == self.m_params.name then
	--			self.m_private_name = i
	--		end
	--	end
	--end
end

function M:init(data)
	if data.id then
		--从好友进来的
		local uid = data.id
		local name = data.name
		local avatar = data.avatar
		ChatUtil.channel_msgs[__CHAT_CHANNEL.PRIVATE] = ChatUtil.channel_msgs[__CHAT_CHANNEL.PRIVATE] or {}
		G_CHAT_CHANEL = __CHAT_CHANNEL.PRIVATE
		ChatUtil.player_names[name] = uid
		ChatUtil.private_player_avatar[name] = avatar
	elseif data.channel_id then
		local channel_id = self:isRightChannelId(data.channel_id )
		G_CHAT_CHANEL = channel_id
	else
		G_CHAT_CHANEL = __CHAT_CHANNEL.LOCAL
	end
	self:initData()
	if data.name then
		for i,v in ipairs(self.m_private_names or {}) do
			if v == data.name then
				self.m_private_name = i
			end
		end
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

--收到消息時
function M:onReceive()
	
end

--切换频道
function M:onChangeChannel(channel)
	
end

function M:initData(data)
	if data then 
		self.m_data = data
	end
	
	self.m_private_names = {}
	for k,v in pairs(ChatUtil.player_names or {}) do
		self.m_private_names[#self.m_private_names + 1] = k
	end
	local function sort(d1, d2)
		return d1 < d2
	end
	table.sort(self.m_private_names, sort)
end

function M:netData(data, tag)

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
		send_data.target_name = self.m_private_names[self.m_private_name]
		send_data.channel_id = tostring(ChatUtil.player_names[send_data.target_name])
	end
	return send_data
end

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

return M
