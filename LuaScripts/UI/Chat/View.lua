local M = class("ChatView",LikeOO.OOPopBase)
local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}

local __EMOJI_TAB_BTN_NODE = {
	{btn_key = "emoji_togglebtn", btn_text = "emoji_togglebtn_text", text_key = "new_str_1019", open = true}, -- emoji
	{btn_key = "emoji_gif_togglebtn", btn_text = "emoji_gif_togglebtn_text", text_key = "new_str_1020", open = true,}, -- emoji_gif
}

local __CHAT_CHANNEL_TOGGLE = 
{
	{btn_text = "guild_high_war_text_0020", btn_name = "channel_3", channel_id = __CHAT_CHANNEL.GUILD},
	{btn_text = "guild_high_war_text_0019", btn_name = "channel_5", channel_id = __CHAT_CHANNEL.GUILDHIGHWAR},
	{btn_text = "guild_high_war_text_0021", btn_name = "channel_6", channel_id = __CHAT_CHANNEL.GUILDHIGHWARLOG},
}

M.m_uiName = "Chat/Chat"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()	
	self.toggles = {}
	self.m_private_list_active = false
	self.scroll_rect = self:findGameObject('ScrollView'):GetComponent('LoopListView2')
	self.input = self:findInputField('input')
	UIUtil.addInputFieldListener(self.input.transform, handler(self,self.inputChanged))
	self.choose_img = self:findGameObject('pool_xuanzhong'):GetComponent('Image').sprite
	self.un_choose_img = self:findGameObject('pool_weixuanzhong'):GetComponent('Image').sprite
	self.private_list_bg = self:findGameObject("private_list_bg")
	self.private_bg = self:findGameObject("private_bg")
	self.anim =  self.m_luaBehaviour:GetComponent('Animator')
	self.m_gray_img = self:findImage("gray_img")
	self.bg = self:findGameObject("bg")
	if self.m_model.m_open_type and self.m_model.m_open_type == "guild_high_war" then
		self:InitChannel2()
	else
		self:InitChannel()
	end
	self:InitMsg()
	self.emoji = false
	self:updateEmojiScroll()
	self:setTextByLanKey("input_placeholder", "char_input_tex")
	self:setTextByLanKey("btn_send_text", "send_tex") 
	self:setTextByLanKey("private_text", "chat_private_tex") 
	
	self:setTextByLanKey("empty_text", "chat_ui_no_msg") 
	self:setTextByLanKey("chat_tips_text", "tid#SystemCaution_1") 
	
	self:setObjectVisible("Toggles_emoji", self.emoji)
	self:setObjectVisible("emoji_gif_bg", self.emoji)

	self.m_toggle_btns = {}
	for k,v in pairs(__EMOJI_TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_sel_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
	end
end

function M:InitChannel()
	local pool_toggle = self:findGameObject('pool_channel_toggle')
	local chanel_content = self:findGameObject('channel_content')
	for i = 1,5  do
		local toggle = CS.UnityEngine.GameObject.Instantiate(pool_toggle)
		self.toggles[i] = toggle
		toggle.transform:SetParent(chanel_content.transform,false)
		toggle.name = 'channel_'..i
		local ch_text = toggle.transform:GetChild(0):GetComponent('Text')
		if i == __CHAT_CHANNEL.LOCAL then
			ch_text.text = Language:getTextByKey('new_str_0475') 
		elseif i == __CHAT_CHANNEL.WORLD then
			ch_text.text = Language:getTextByKey('new_str_0474')
		elseif i == __CHAT_CHANNEL.GUILD then
			ch_text.text =  Language:getTextByKey('new_str_0476')
		else
			ch_text.text = Language:getTextByKey('chat_private_tex2')
			--if #v == 0 then
			--	ch_text.text = ChatUtil.player_names[k]
			--else
			--	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
			--	if v[1].uid == self_uid then
			--		ch_text.text = v[1].target_name
			--		ChatUtil.player_names[v[1].uid] =  v[1].target_name
			--	else
			--		ch_text.text = v[1].name
			--		ChatUtil.player_names[v[1].uid] =  v[1].name
			--	end
			--end
		end
		toggle:SetActive(true)
	end
	self:SetToggleChoose(G_CHAT_CHANEL,true)
end

function M:InitChannel2()
	local pool_toggle = self:findGameObject('pool_channel_toggle')
	local chanel_content = self:findGameObject('channel_content')
	for i = 1, #__CHAT_CHANNEL_TOGGLE do
		local toggle = CS.UnityEngine.GameObject.Instantiate(pool_toggle)
		local chat_toggle_data = __CHAT_CHANNEL_TOGGLE[i]
		self.toggles[chat_toggle_data.channel_id] = toggle
		toggle.transform:SetParent(chanel_content.transform,false)
		toggle.name = chat_toggle_data.btn_name
		local ch_text = toggle.transform:GetChild(0):GetComponent('Text')
		ch_text.text = Language:getTextByKey(chat_toggle_data.btn_text)
		toggle:SetActive(true)
	end
	
	self:SetToggleChoose(G_CHAT_CHANEL,true)
end

function M:SetToggleChoose(index,is_firset)
	local toggle = self.toggles[index]
	if self.cur_choose_toggle then
		self.cur_choose_toggle:GetComponent('Image').overrideSprite = self.un_choose_img
	end
	toggle:GetComponent('Image').overrideSprite = self.choose_img
	self.cur_choose_toggle = toggle
	if not is_firset then
		local name = self.m_model.m_private_names[self.m_model.m_private_name]
		local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL,name)
		self.scroll_rect:SetListItemCount(#msgs, false)
		self.scroll_rect:MovePanelToItemIndex(#msgs, 0)
	end

	for k,v in pairs(self.toggles) do
		if k == index then
			UIUtil.setTextColor(v.transform, GlobalConfig.COMMON_COLLOR.COMMON_1, "Text")
		else
			UIUtil.setTextColor(v.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "Text")
		end
	end
	
	self:setObjectVisible("private_bg", G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE)
	if G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		self:setPrivateName()
		self:updatePrivateList()
		self.anim:SetBool('private',true)
	else
		self.m_private_list_active = false
		local private_list_bg = self:findGameObject("private_list_bg")
		UIUtil.setLocalScale(private_list_bg.transform, 1, 0, 1)
		self.anim:SetBool('private',false)
	end
	if self.emoji then
		self:ChangeEmoji()
	end
	self:refreshRedPoint()
	self:setObjectVisible("go_bottom_btn",  G_CHAT_CHANEL ~= __CHAT_CHANNEL.PRIVATE)

	self:updateEmptyMsgText()

end

function M:setPrivateVisible()
	self.m_private_list_active = not self.m_private_list_active
	local scale = self.m_private_list_active and 1 or 0
	local private_list_bg = self:findGameObject("private_list_bg")
	UIUtil.setLocalScale(private_list_bg.transform, 1, scale, 1)
end

function M:setPrivateName()
	local name = self.m_model.m_private_names[self.m_model.m_private_name] or ""
	self:setText("private_select_name_text", name)
end

function M:inputChanged()
	-- local text = self.input.text
	-- local caret = self.input.caretPosition
	-- local old_len = #self.m_input_text
	-- local now_len = #text
	-- self.m_input_text = text
	-- if old_len > now_len then -- 删除操作
	-- 	for i=#self.m_control.emoji_text,1,-1 do
	-- 		v = self.m_control.emoji_text[i]
	-- 		if v.index > caret then
	-- 			v.index = v.index - (self.m_input_caret - caret)
	-- 			if v.index <= caret then
	-- 				table.remove(self.m_control.emoji_text, i)
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- self.m_input_caret = caret
end

--获得当前输入的文字
function M:getMsg()
	return self.input.text
end

function M:updateEmptyMsgText()
	
	local name = self.m_model.m_private_names[self.m_model.m_private_name]
	local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL, name)
	
	self:setObjectVisible("empty_text", #msgs == 0)
end

--初始化全部聊天信息
function M:InitMsg()
	local name = self.m_model.m_private_names[self.m_model.m_private_name]
	local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL, name)
	
	self:updateEmptyMsgText()

	self.scroll_rect:InitListView(#msgs,function(list, index)
		if not self.m_model then 
			return
		end
		local name = self.m_model.m_private_names[self.m_model.m_private_name]
		local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL, name)
		if index < 0 or index>#msgs then
			return nil
		end
		local msg_data = msgs[index+1]
		local item
		local head_node

		local time = UserDataManager:getServerTime() - msg_data.time
		local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
		local time_str = ""
		if day > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0002"),day)
		elseif hour > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0003"),hour)
		elseif min > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0004"),min)
		end
		local msg = msg_data.msg or ""
		msg = GameUtil:formatInputText(msg)
		if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
		--self 
			item = list:NewListViewItem('self_context')
			local self_rt = item:GetComponent('RectTransform')
			local self_lb = UIUtil.findLuaBehaviour(self_rt)
			LuaBehaviourUtil.setObjectVisible(self_lb,"qipao", true)
			local time_text = self_lb:FindText("time")
			time_text.text = time_str
			head_node = self_lb:FindGameObject("self_head_node")
			local self_text = self_lb:FindText('text')
			self_text.text = msg
			local self_name = self_lb:FindText('name')
			self_name.text = msg_data.name
			
			-- 动图 START
			self:CreateEmojiGifByDate(self_lb, msg)
			-- 动图 END
			self_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			local text_size = self_text.transform:GetComponent('RectTransform').sizeDelta
			if self.m_model:checkMsgIsEmojiGif(msg) and CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
				text_size.y = text_size.y + 100
			end
			text_size.x = text_size.x + 24
			text_size.y = text_size.y*1.15 + 44
			self_text.transform.parent:GetComponent("RectTransform").sizeDelta = text_size
			-- self_text.transform.parent:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			-- local text_size = self_text.transform.parent:GetComponent('RectTransform').sizeDelta

			-- local y = text_size.y + 40;
			self_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), text_size.y+20)
			if not item.IsInitHandlerCalled then   
				item.IsInitHandlerCalled = true
			end
			self:CreateEvent(self_lb, msg_data, self_rt)
			local title_id = msg_data.title -- 称号和名字适配
			if title_id and title_id ~= 0 then
				time_text.transform.anchoredPosition = Vector3.New(257, -12, 0)
			else
				time_text.transform.anchoredPosition = Vector3.New(280, -12, 0)
			end
		else
		--other
			item = list:NewListViewItem('other_context')
			local other_rt = item:GetComponent('RectTransform')
			local other_lb = UIUtil.findLuaBehaviour(other_rt)
			LuaBehaviourUtil.setObjectVisible(other_lb,"qipao", true)
			local time_text = other_lb:FindText("time")
			time_text.text = time_str
			head_node = other_lb:FindGameObject("orther_head_node")
			local other_text = other_lb:FindText('text')
			other_text.text = msg
			local other_name = other_lb:FindText('name')
			other_name.text = msg_data.name
			local qipao = other_lb:FindGameObject("qipao")
			-- 动图 START
			self:CreateEmojiGifByDate(other_lb, msg)
			-- 动图 END
			other_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			local text_size = other_text.transform:GetComponent('RectTransform').sizeDelta
			if self.m_model:checkMsgIsEmojiGif(msg) and CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
				text_size.y = text_size.y + 100
			end
			text_size.x = text_size.x + 24
			text_size.y = text_size.y*1.15 + 44
			other_text.transform.parent:GetComponent("RectTransform").sizeDelta = text_size
			-- other_text.transform.parent:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			-- local y = other_text.transform.parent:GetComponent('RectTransform').sizeDelta.y  + 40;
			other_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), text_size.y+20)
			
			local scrollRectClick = qipao:GetComponent("ScrollRectClick")
			if scrollRectClick then
				scrollRectClick.index = index
				scrollRectClick:RegistClickCallBack(
					function(click_type, index)
						if click_type == 2 then
							self.m_control:openView("Pops.ReportBtnPop", {uid = msg_data.uid, name = msg_data.name, chat = msg_data.msg, module_id = 3, obj = qipao})
						end
					end
				)
			end
			self:CreateEvent(other_lb, msg_data, other_rt)
			if not item.IsInitHandlerCalled then   
				item.IsInitHandlerCalled = true
			end
			local function clickCallback(_, uid)
				self:updateMsg("show_player", uid)
			end
			local orher_head = other_lb:FindGameObject("orher_head")
			UIUtil.setButtonClick(orher_head.transform,clickCallback, msg_data.uid)
			
			local title_id = msg_data.title -- 称号和名字适配
			if title_id and title_id ~= 0 then
				other_name.transform.anchoredPosition = Vector3.New(260, -12, 0)
			else
				other_name.transform.anchoredPosition = Vector3.New(215, -12, 0)
			end
		end
		GameUtil:setUserAvatar(head_node, msg_data,nil, nil,{show_flag = true, scale = 0.75})
		return item
	end)
	if ChatUtil.channel_msgs[G_CHAT_CHANEL] and #ChatUtil.channel_msgs[G_CHAT_CHANEL] > 0 then
		self.scroll_rect:MovePanelToItemIndex(#ChatUtil.channel_msgs[G_CHAT_CHANEL]-1, 0)
	end
end
-- 创建聊天动图
function M:CreateEmojiGifByDate(itemNode, msg)
	local qipao = itemNode:FindGameObject("qipao")
	local gif_node = itemNode:FindGameObject("gif_node")
	local gif_img = itemNode:FindGameObject("gif_img")
	local SpriteAnimation = gif_img:GetComponent("UGUISpriteAnimation")
	local gif_data = self.m_model:checkMsgIsEmojiGif(msg)
	if gif_data then
		UIUtil.setScale(gif_img.transform, 1.25)
		SpriteAnimation.FPS = gif_data.fps
		SpriteAnimation.AutoPlay = true
		SpriteAnimation.Loop = true
		SpriteAnimation:ClearSpriteFrames()
		local path_name = "Texture/chat_gif/"..gif_data.icon
		local ab_name = string.gsub(path_name, "/", "_")
		if (SpriteAnimation.SetSpriteByName) then
			SpriteAnimation:SetSpriteByName(path_name, string.lower(ab_name))
			qipao:SetActive(false)
			gif_node:SetActive(true)
		else
			qipao:SetActive(true)
			gif_node:SetActive(false)
			local self_text = itemNode:FindText('text')
			self_text.text = Language:getTextByKey(gif_data.text)
		end
	else
		qipao:SetActive(true)
		gif_node:SetActive(false)
		SpriteAnimation:ClearSpriteFrames()
	end
end

function M:ChangeEmoji()
	if self.emoji then
		self.emoji = false	
	else
		self.emoji = true
		self:updateEmojiScroll()
	end
	self:setObjectVisible("Toggles_emoji", self.emoji) -- 显示emoji和动图的切换按钮
	self:setObjectVisible("emoji_gif_bg", self.m_model.m_sel_tab_index == 2)
	self.anim:SetBool('emoji',self.emoji)
	local openLV = ConfigManager:getCommonValueById(545); -- 聊天动态表情开启等级
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	if not CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle or level < openLV then
		self:setObjectVisible("Toggles_emoji", false)
	end
end

local __EVENT_NODE_NAME = {"event_1", "event_2", "event_3", "event_4"}
function M:CreateEvent(luabehaviour, msg_data, cell_rt)
	if msg_data.event and msg_data.event > 0 then
		LuaBehaviourUtil.setObjectVisible(luabehaviour, "event_node", true)
		for i,v in pairs(__EVENT_NODE_NAME) do
			local event_node = nil
			if i == msg_data.event then
				event_node = LuaBehaviourUtil.setObjectVisible(luabehaviour, v, true)
			else
				LuaBehaviourUtil.setObjectVisible(luabehaviour, v, false)
			end
			if not IsNull(event_node) then
				if msg_data.event == 1 then -- 游园赏春活动分享任务
					self:updateEnjoySpringEvent(event_node, msg_data)
					LuaBehaviourUtil.setObjectVisible(luabehaviour, "qipao", false)
					cell_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 140)
				elseif msg_data.event == 2 then
					self:updateFulwinArenaEvent(event_node, msg_data)
					LuaBehaviourUtil.setObjectVisible(luabehaviour, "qipao", false)
					cell_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 140)
				elseif msg_data.event == 3 then
					self:updateGroupEvent(event_node, msg_data)
					LuaBehaviourUtil.setObjectVisible(luabehaviour, "qipao", false)
					cell_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 140)
				elseif msg_data.event == 4 then -- 四方争霸
					self:updateFourForceEvent(event_node, msg_data)
					LuaBehaviourUtil.setObjectVisible(luabehaviour, "qipao", false)
					cell_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 140)
				end
			end
		end
	else
		LuaBehaviourUtil.setObjectVisible(luabehaviour, "event_node", false)
	end
end

function M:updateEnjoySpringEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text","enjoySpring_str_0015")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","enjoySpring_str_0016")
		local star = event_data.star or 1
		for i=1, 3 do
			if star >= i then
				LuaBehaviourUtil.setImg(event_luabe, "star_img_" .. i, "a_wqb_nandu1", "mystic_ui")
			else
				LuaBehaviourUtil.setImg(event_luabe, "star_img_" .. i, "a_wqb_nandu2", "mystic_ui")
			end
		end
		UIUtil.setButtonClick(event_node.transform, function(trans, data)
			if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
				GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("enjoySpring_str_0017"), delay_close = 2})
			else
				self:updateMsg("add_enjoySpring_task", data)
			end
		end, event_data,"event_btn", self.m_uiName)
	end
end

function M:updateFulwinArenaEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text","fylt_str_0083")
		local typ = event_data.typ or 1
		if typ == 1 then
			LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","fylt_str_0084")
		else
			LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","fylt_str_0085")
		end
		local time = ConfigManager:getCommonValueById(725, 30)
		local server_time = UserDataManager:getServerTime()
		local send_time = event_data.send_time or 0
		if server_time - send_time >= time then
			LuaBehaviourUtil.setObjectVisible(event_luabe, "event_status_text", true)
			LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_status_text","fylt_str_0087")
		else
			LuaBehaviourUtil.setObjectVisible(event_luabe, "event_status_text", false)
		end
		
		UIUtil.setButtonClick(event_node.transform, function()
			if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
				GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("fylt_str_0090"), delay_close = 2})
			else
				self:updateMsg("join_fulwin_arena", event_data)
			end
		end, nil,"event_btn", self.m_uiName)
	end
end

function M:updateGroupEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text","gift_group_text_0028")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","gift_group_text_0029")
		local time_day_end = TimeUtil.getIntTimestamp(event_data.create_time) + 3600 * 24
		local time_now = UserDataManager:getServerTime()
		--当天拼团
		if time_now > time_day_end then
			LuaBehaviourUtil.setObjectVisible(event_luabe, "event_status_text", true)
			LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_status_text","fylt_str_0087")
		else
			LuaBehaviourUtil.setObjectVisible(event_luabe, "event_status_text", false)
		end
		UIUtil.setButtonClick(event_node.transform, function(trans, data)
			if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
				GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gift_group_text_0030"), delay_close = 2})
			else
				self:updateMsg("join_group", data)
			end
		end, event_data,"event_btn", self.m_uiName)
	end
end

function M:updateFourForceEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text","four_force_war_0001")
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","enjoySpring_str_0016")
		local star = event_data.star or 1
		for i=1, 3 do
			if star >= i then
				LuaBehaviourUtil.setImg(event_luabe, "star_img_" .. i, "a_wqb_nandu1", "mystic_ui")
			else
				LuaBehaviourUtil.setImg(event_luabe, "star_img_" .. i, "a_wqb_nandu2", "mystic_ui")
			end
		end
		UIUtil.setButtonClick(event_node.transform, function(trans, data)
			if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
				GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("enjoySpring_str_0017"), delay_close = 2})
			else
				self:updateMsg("add_fourforce_task", data)
			end
		end, event_data,"event_btn", self.m_uiName)
	end
end

function M:AddChannel(channel)
	local pool_toggle = self:findGameObject('pool_channel_toggle')
	local chanel_content = self:findGameObject('channel_content')
	local toggle = CS.UnityEngine.GameObject.Instantiate(pool_toggle)
	self.toggles[channel] = toggle
	toggle.transform:SetParent(chanel_content.transform,false)
	toggle.name = 'channel_'..channel
	local ch_text = toggle.transform:GetChild(0):GetComponent('Text')
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local v = ChatUtil.channel_msgs[channel]
	if v[1].uid == self_uid then
		ch_text.text = v[1].target_name
		ChatUtil.player_names[v[1].uid] =  v[1].target_name
	else
		ch_text.text = v[1].name
		ChatUtil.player_names[v[1].uid] =  v[1].name
	end
	toggle:SetActive(true)
end

--刷新消息
function M:AddMsg()
	local name = self.m_model.m_private_names[self.m_model.m_private_name]
	local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL,name)
	self:updateEmptyMsgText()

	local last_msg_uid = 0
	if msgs and #msgs > 0 then
		last_msg_uid = msgs[#msgs].uid
	end

	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	--获取收到消息之前的最后一条消息的item是否显示，如果存在代表显示，则代表聊天框在最底下，需要自动刷新位置
	local last_chat_item = self.scroll_rect:GetShownItemByItemIndex(#msgs - 2)
	self.scroll_rect:SetListItemCount(#msgs, false)
	if last_chat_item or self_uid == last_msg_uid then
		self.scroll_rect:MovePanelToItemIndex(#msgs, 0)
	end
	self:refreshRedPoint()
end

function M:goToBottom()
	if self.scroll_rect and self.scroll_rect.ItemTotalCount and self.scroll_rect.ItemTotalCount > 0 then
		local msg_count = self.scroll_rect.ItemTotalCount
		self.scroll_rect:MovePanelToItemIndex(msg_count, 0)
	end
end

function M:refreshRedPoint()
	if G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		ChatUtil.channel_red_points[4] = false
	end
	for k,v in pairs(self.toggles) do
		if k == G_CHAT_CHANEL then
			ChatUtil.red_points[k] = false
			UIUtil.setObjectVisible(v.transform, false, "red_point_img")
		else
			local flag = ChatUtil.red_points[k] == true
			if k == __CHAT_CHANNEL.PRIVATE then
				flag = ChatUtil.channel_red_points[4]
			end
			UIUtil.setObjectVisible(v.transform, flag, "red_point_img")
		end
	end
end

function M:updatePrivateRedPoint()
	ChatUtil.red_points[__CHAT_CHANNEL.PRIVATE] = false
	for k,v in pairs(ChatUtil.player_red_points) do
		if v > 0 then
			ChatUtil.red_points[__CHAT_CHANNEL.PRIVATE] = true
			break
		end
	end
end

function M:updatePrivateList()
	local data = self.m_model.m_private_names
	if self.m_private_scroll == nil then
		local list_scroll = self:findGameObject("private_scroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
                local avatar = ChatUtil.private_player_avatar[data] or "181"
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				local private_player_name_text = luaBehaviour:FindText("private_player_name_text")
				LuaBehaviourUtil.setText(luaBehaviour, "private_player_name_text", cell_data)
				local HeadNode = luaBehaviour:FindGameObject("HeadNode")
				GameUtil:setUserAvatar(HeadNode,{avatar = avatar})
				if self.m_model.m_private_name == index then
					--LuaBehaviourUtil.setImg(luaBehaviour,"private_palyer_sign_img", "a_lt_siliao_zhuangshi1", "main_ui")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "private_palyer_sign_img", true)
					--private_player_name_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
					ChatUtil.player_red_points[cell_data] = 0
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "privae_player_red_point_img", false)
				else
					--LuaBehaviourUtil.setImg(luaBehaviour,"private_palyer_sign_img", "a_lt_siliao_zhuangshi2", "main_ui")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "private_palyer_sign_img", false)
					--private_player_name_text.color = GlobalConfig.COMMON_COLLOR.COMMON_8
					local red = ChatUtil.player_red_points[cell_data] and ChatUtil.player_red_points[cell_data] > 0 or false
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "privae_player_red_point_img", red)
					if red then
						LuaBehaviourUtil.setText(luaBehaviour, "red_num_text", ChatUtil.player_red_points[cell_data])
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				ChatUtil.player_red_points[cell_data] = 0
				self:updateMsg("click_private", index)
			end
		}
		self.m_private_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_private_scroll:reloadData(data,true)
	end
end

function M:updateEmojiScroll()
	local data = self.m_model.m_emoji_data
	-- Logger.log(data,"emoji data ======")
	if self.m_emoji_scroll == nil then
		local list_scroll = self:findGameObject("emoji_scroll")
		local params = {
			show_data = data,
			one_line_count = 8,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:emojiListHandle(cell_object, index, data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("emoji_icon", cell_data)
			end
		}
		self.m_emoji_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_emoji_scroll:reloadData(data,true)
	end
end

function M:emojiListHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setText(luaBehaviour, "emoji_text", "[" .. data.emoji .. "]")
	
end

function M:closeUIAnim(callback)
	self.anim:CrossFade("Chat_end",0)
	local function endChat(msg)
		if msg == "end_chat" then
			self.m_control:closeView()
		end
	end

	self:runAnim("Chat_end",endChat)
	
end

-- 筛选标签点击事件
function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index, keep_offset)
	for k,v in pairs(__EMOJI_TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
	end
	self:ChangeEmojiAndGif()
end

function M:ChangeEmojiAndGif()
	self:setObjectVisible("emoji_scroll", self.m_model.m_sel_tab_index == 1)
	self:setObjectVisible("emoji_gif_bg", self.m_model.m_sel_tab_index == 2)
	if self.m_model.m_sel_tab_index == 1 then
		self:updateEmojiScroll()
	else
		self:updateEmojiGifScroll()
	end
end

-- 创建gif 动图列表
function M:updateEmojiGifScroll()
	local data = self.m_model.m_emoji_gif_data or {}
	-- Logger.log(data,"emoji data ======")
	if self.m_emoji_gif_scroll == nil then
		local list_scroll = self:findGameObject("emoji_gif_scroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:emojiGiftListHandle(cell_object, index, data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("emoji_gif_icon", cell_data)
			end
		}
		self.m_emoji_gif_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_emoji_gif_scroll:reloadData(data,true)
	end
end

function M:emojiGiftListHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local item = luaBehaviour:FindGameObject("ChatGif")
	local title_text = luaBehaviour:FindText("title_text")
	local lock_img = luaBehaviour:FindGameObject("lock_img")
	local lock_text = luaBehaviour:FindText("lock_text")
	if item then
		local img = item:GetComponent("Image")
		UIUtil.setScale(item.transform, 0.8)
		local SpriteAnimation = item:GetComponent("UGUISpriteAnimation")
		SpriteAnimation:ClearSpriteFrames()
		local path_name = "Texture/chat_gif/"..data.icon
		local ab_name = string.gsub(path_name, "/", "_")
		if (SpriteAnimation.SetSpriteByName) then
			SpriteAnimation:SetSpriteByName(path_name, string.lower(ab_name))
			SpriteAnimation:Pause()
			SpriteAnimation:SetSprite(0)
		end
		if title_text then
			title_text.text = Language:getTextByKey(data.text)
		end
		local level = UserDataManager.user_data:getUserStatusDataByKey("level")
		if data.unlock_level > level then
			lock_img:SetActive(true)
			lock_text.text = Language:getTextByKey(data.unlock_des)
			--img.material = self.m_gray_img.material
		else
			img.material = nil
			lock_img:SetActive(false)
		end
	end
end

return M