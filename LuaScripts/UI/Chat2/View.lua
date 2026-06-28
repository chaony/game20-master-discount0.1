---@class ChatView:OOPopBase
local M = class("ChatView",LikeOO.OOPopBase)

local __CHAT_CHANNEL = {LOCAL = 1, WORLD = 2, GUILD = 3, PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6, GROUP = 7}
local __PRIVATE_LIST =
{
	{type = "friend", list_text = "type_des_text", text_key = "chat_friend_num_text"},
	{type = "others", list_text = "type_des_text", text_key = "chat_stranger_num_text"},
	{type = "black", list_text = "type_des_text", text_key = "chat_blacklist_num_text"},
}
local __PRIVATE_LIST2 = {"group"}

local __EMOJI_TAB_BTN_NODE =
{
	{btn_key = "emoji_togglebtn", btn_text = "emoji_togglebtn_text", text_key = "new_str_1019", open = true}, -- emoji
	{btn_key = "emoji_gif_togglebtn", btn_text = "emoji_gif_togglebtn_text", text_key = "new_str_1020", open = true,}, -- emoji_gif
}

local __CHAT_CHANNEL_MAIN_TOGGLE =
{
	{btn_text = "new_str_0475", btn_name = "channel_1", channel_id = __CHAT_CHANNEL.LOCAL},
	{btn_text = "new_str_0474", btn_name = "channel_2", channel_id = __CHAT_CHANNEL.WORLD},
	{btn_text = "new_str_0476", btn_name = "channel_3", channel_id = __CHAT_CHANNEL.GUILD},
	{btn_text = "new_str_0477", btn_name = "channel_4", channel_id = __CHAT_CHANNEL.PRIVATE},
	--{btn_text = "chat_new_text_008", btn_name = "channel_7", channel_id = __CHAT_CHANNEL.GROUP},
}

local __CHAT_CHANNEL_TOGGLE =
{
	{btn_text = "guild_high_war_text_0020", btn_name = "channel_3", channel_id = __CHAT_CHANNEL.GUILD},
	{btn_text = "guild_high_war_text_0019", btn_name = "channel_5", channel_id = __CHAT_CHANNEL.GUILDHIGHWAR},
	{btn_text = "guild_high_war_text_0021", btn_name = "channel_6", channel_id = __CHAT_CHANNEL.GUILDHIGHWARLOG},
}

M.m_uiName = "Chat/Chat2"
M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_friend_cell_limit = 5

function M:onEnter()
	self.emoji = false
	self.toggles = {}
	self.m_chat_cell_size = {}
	self.player_cell_objs = {}
	self.m_type_detail_scroll_tab = {}
	self.m_private_list = __PRIVATE_LIST
	self.m_private_list_active = false
	self.bg = self:findGameObject("bg")
	self.input = self:findInputField('input')
	self.m_gray_img = self:findImage("gray_img")
	self.private_bg = self:findGameObject("private_bg")
	self.anim =  self.m_luaBehaviour:GetComponent('Animator')
	self.private_list_bg = self:findGameObject("private_list_bg")
	self.choose_img = self:findGameObject('pool_xuanzhong'):GetComponent('Image').sprite
	self.un_choose_img = self:findGameObject('pool_weixuanzhong'):GetComponent('Image').sprite
	self.scroll_rect = self:findGameObject('msg_scroll_view'):GetComponent('LoopListView2')
	self.input.text = ChatUtil.cur_input_msg ~= nil and ChatUtil.cur_input_msg or ""
	
	self:InitMsg()
	self:updateSortBtnView()
	self:setTextByLanKey("member_btn_text", "chat_new_text_005")
	self:setTextByLanKey("disband_btn_text", "chat_new_text_007")
	self:setTextByLanKey("add_black_btn_text", "chat_new_text_004")
	self:setTextByLanKey("quit_group_btn_text", "chat_new_text_006")
	self:setTextByLanKey("recent_sort_btn_text", "chat_new_text_003")
	self:setTextByLanKey("friend_sort_btn_text", "chat_new_text_002")
	self:setTextByLanKey("create_group_btn_text", "chat_new_text_001")
	
	if self.m_model.m_open_type and self.m_model.m_open_type == "guild_high_war" then
		self:InitChannel2()
	else
		self:InitChannel()
	end
	
	self:updateEmojiScroll()
	self:setObjectVisible("Toggles_emoji", self.emoji)
	self:setObjectVisible("emoji_gif_bg", self.emoji)
	for k,v in pairs(__EMOJI_TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		if k == self.m_model.m_sel_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
	end
	UIUtil.addInputFieldListener(self.input.transform, handler(self,self.inputChanged))
end

--------------------------- 频道按钮 ---------------------------
-- 频道 toggles
function M:InitChannel()
	local pool_toggle = self:findGameObject('pool_channel_toggle')
	local chanel_content = self:findGameObject('channel_content')
	local toggle_data = nil
	if self.m_model.m_open_type and self.m_model.m_open_type == "guild_high_war" then
		toggle_data = __CHAT_CHANNEL_TOGGLE
	else
		toggle_data = __CHAT_CHANNEL_MAIN_TOGGLE
	end
	for i = 1, #toggle_data do
		local toggle = CS.UnityEngine.GameObject.Instantiate(pool_toggle)
		local chat_toggle_data = toggle_data[i]
		self.toggles[chat_toggle_data.channel_id] = toggle
		toggle.transform:SetParent(chanel_content.transform,false)
		toggle.name = chat_toggle_data.btn_name
		local ch_text = toggle.transform:GetChild(0):GetComponent('Text')
		ch_text.text = Language:getTextByKey(chat_toggle_data.btn_text)
		toggle:SetActive(true)
	end
	self:updateMsg("channel_" .. G_CHAT_CHANEL, {is_init = true})
end

-- 设置选中的频道 toggle
function M:SetToggleChoose(index, is_first)
	local toggle = self.toggles[index]
	if self.cur_choose_toggle then
		self.cur_choose_toggle:GetComponent('Image').overrideSprite = self.un_choose_img
	end
	toggle:GetComponent('Image').overrideSprite = self.choose_img
	self.cur_choose_toggle = toggle
	if not is_first then
		--local uid = ChatUtil.cur_private_uid
		--local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL, uid)
		self:updateChatLoopScroll()
		--self.scroll_rect:SetListItemCount(#msgs, false)
		--self.scroll_rect:MovePanelToItemIndex(#msgs, 0)
	end

	for k,v in pairs(self.toggles) do
		if k == index then
			UIUtil.setTextColor(v.transform, Color(241/255, 243/255, 255/255), "Text")
			--UIUtil.setTextColor(v.transform, GlobalConfig.COMMON_COLLOR.COMMON_1, "Text")
		else
			UIUtil.setTextColor(v.transform, Color(241/255, 226/255, 181/255), "Text")
			--UIUtil.setTextColor(v.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "Text")
		end
	end

	local flag = G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE or G_CHAT_CHANEL == __CHAT_CHANNEL.GROUP
	self:setObjectVisible("private_list_bg", flag)
	self:setObjectVisible("chat_bg2", flag)
	self:setObjectVisible("chat_bg", flag == false)

	local chat_main_node = self:findGameObject("chat_main_node")
	local input_pos_x = (G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE or G_CHAT_CHANEL == __CHAT_CHANNEL.GROUP) and 312 or 150
	UIUtil.setLocalPosition(chat_main_node.transform, input_pos_x)

	local msg_scroll_view = self:findGameObject("msg_scroll_view")
	local rt = msg_scroll_view:GetComponent("RectTransform")
	local scroll_view_pos_x = (G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE or G_CHAT_CHANEL == __CHAT_CHANNEL.GROUP) and 384 or 80
	rt.offsetMin = Vector2(scroll_view_pos_x, rt.offsetMin.y)
	rt.offsetMax = Vector2(-13, rt.offsetMax.y)
	
	if G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		if not is_first then
			self:updateTypeList()
		end
		self:refreshPrivateBtn()
		--self.anim:SetBool('private',true)
	elseif msg == __CHAT_CHANNEL.GROUP then
		self:updateTypeList()
		self:refreshPrivateBtn()
	else
		self.m_private_list_active = false
		local private_list_bg = self:findGameObject("private_list_bg")
		--UIUtil.setLocalScale(private_list_bg.transform, 1, 0, 1)
		--self.anim:SetBool('private',false)
	end
	if self.emoji then
		self:ChangeEmoji()
	end
	--self:setObjectVisible("go_bottom_btn",  true)
	self:setObjectVisible("input_bg",  G_CHAT_CHANEL ~= __CHAT_CHANNEL.GUILDHIGHWARLOG)
	self:updateGroupName()
end


--------------------------- 聊天窗口 ---------------------------
--初始化聊天窗口
function M:InitMsg()
	self:updateChatLoopScroll()
end

-- 聊天消息滑动窗口
function M:updateChatLoopScroll()
	local uid = ChatUtil.cur_private_uid
	local msgs = ChatUtil:getChannelMsg(G_CHAT_CHANEL, uid)
	for i = 1, #msgs do
		local msg = msgs[i].msg or ""
		msg = GameUtil:formatInputText(msg)
		if self.m_model:checkMsgIsEmojiGif(msg) and CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
			self.m_chat_cell_size[i] = Vector2(495.3, 200)
		else
			self.m_chat_cell_size[i] = self:getChatCellHeight(msgs[i], msg)
		end
	end
	if self.m_loop_scroll_view == nil then
		local scroll_obj = self:findGameObject("msg_scroll_view")
		local params = {
			show_data = msgs,
			loop_scroll_object = scroll_obj,
			all_cell_size = self.m_chat_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, index )
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		--self.m_loop_scroll_view:reloadData(msgs, true)
		self.m_loop_scroll_view:reloadData(msgs, true, self.m_chat_cell_size)
	end
	self.m_loop_scroll_view:moveToCellIndex(#msgs)
end

-- 聊天消息气泡
function M:updateScrollViewCell(index, cell_object, cell_data)
	if not self.m_model then
		return
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	local msg_data = cell_data
	local time = UserDataManager:getServerTime() - string.sub(msg_data.time, 1, 10)
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
	local is_other = msg_data.uid ~= UserDataManager.user_data:getUserStatusDataByKey("uid")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_context",  not is_other)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "other_context",  is_other)
	local item
	if not is_other then
		item = luaBehaviour:FindGameObject("self_context")
	else
		item = luaBehaviour:FindGameObject("other_context")
	end
	self:updateChatCell(item, time_str, msg_data, msg, is_other)
	local rect = cell_object:GetComponent("RectTransform")
	local item_size_rect = item:GetComponent("RectTransform")
	rect.sizeDelta = Vector2(rect.rect.width, item_size_rect.rect.height +20)
	if G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
		if not is_other then
			item_size_rect.offsetMin = Vector2(0, item_size_rect.offsetMin.y)
			item_size_rect.offsetMax = Vector2(500, item_size_rect.offsetMax.y)
		end
	else
		if not is_other then
			item_size_rect.offsetMin = Vector2(302.4, item_size_rect.offsetMin.y)
			item_size_rect.offsetMax = Vector2(797.7, item_size_rect.offsetMax.y)
		end
	end
end

function M:updateChatCell(item, time_str, msg_data, msg, is_other)
	local cur_rt = item:GetComponent('RectTransform')
	local cur_lb = UIUtil.findLuaBehaviour(cur_rt)
	LuaBehaviourUtil.setObjectVisible(cur_lb,"qipao", true)
	local time_text = cur_lb:FindText("time")
	time_text.text = time_str
	local head_node = cur_lb:FindGameObject(is_other and "orther_head_node" or "self_head_node")
	local self_text = cur_lb:FindText('text')
	self_text.text = msg
	local self_name = cur_lb:FindText('name')
	self_name.text = msg_data.name
	self:CreateEmojiGifByDate(cur_lb, msg)
	self_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	local text_size = self_text.transform:GetComponent('RectTransform').sizeDelta
	if self.m_model:checkMsgIsEmojiGif(msg) and CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
		text_size.y = text_size.y + 100
	end
	text_size.x = text_size.x + 24
	text_size.y = text_size.y*1.15 + 44
	self_text.transform.parent:GetComponent("RectTransform").sizeDelta = text_size
	cur_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), text_size.y+20)
	self:CreateEvent(cur_lb, msg_data, cur_rt)
	--local title_id = msg_data.title -- 称号和名字适配
	--if title_id and title_id ~= 0 then
	--	time_text.transform.anchoredPosition = Vector3.New(257, -12, 0)
	--else
	--	time_text.transform.anchoredPosition = Vector3.New(280, -12, 0)
	--end
	if is_other then
		local qipao = cur_lb:FindGameObject("qipao")
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
		local function clickCallback(_, uid)
			self:updateMsg("show_player", uid)
		end
		local orher_head = cur_lb:FindGameObject("orher_head")
		UIUtil.setButtonClick(orher_head.transform,clickCallback, msg_data.uid)
	end
	GameUtil:setUserAvatar(head_node, msg_data,nil, nil,{show_flag = true, scale = 0.75})
end

function M:getChatCellHeight(msg_data, msg)
	local item = self:findGameObject("self_context_height")
	local cur_rt = item:GetComponent('RectTransform')
	local cur_lb = UIUtil.findLuaBehaviour(cur_rt)
	LuaBehaviourUtil.setObjectVisible(cur_lb,"qipao", true)
	local time_text = cur_lb:FindText("time")
	time_text.text = "999"
	local self_text = cur_lb:FindText('text')
	self_text.text = msg
	local self_name = cur_lb:FindText('name')
	self_name.text = msg_data.name
	--self:CreateEmojiGifByDate(cur_lb, msg)
	self_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	local text_size = self_text.transform:GetComponent('RectTransform').sizeDelta
	if self.m_model:checkMsgIsEmojiGif(msg) and CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
		text_size.y = text_size.y + 100
	end
	text_size.x = text_size.x + 24
	text_size.y = text_size.y*1.15 + 44
	self_text.transform.parent:GetComponent("RectTransform").sizeDelta = text_size
	cur_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), text_size.y+20)
	self:CreateEvent(cur_lb, msg_data, cur_rt)
	local item_size_rect = item:GetComponent("RectTransform")
	local temp = Vector2(495.3, item_size_rect.rect.height + 20)
	return temp
end

-- 移动到聊天窗口底部
function M:goToBottom()
	local last_cell_index = self.m_loop_scroll_view:getCellsCount()
	self.m_loop_scroll_view:moveToCellIndex(last_cell_index)
end


--------------------------- 私聊频道 ---------------------------
-- 页签滑动窗口
function M:updateTypeList()
	if G_CHAT_CHANEL ~= __CHAT_CHANNEL.PRIVATE then
		return
	end
	
	local all_cell_size = {}
	for i,v in ipairs(self.m_private_list or {}) do
		if i == ChatUtil.type_select_index then
			local detail_num = self.m_model:getTypeListDetailNum(i)
			detail_num = detail_num <= self.m_friend_cell_limit and detail_num or self.m_friend_cell_limit + 0.1  -- offset to indicate hidden friend
			all_cell_size[i] = Vector2(282, 85 * detail_num + 34)
		else
			all_cell_size[i] = Vector2(282, 34)
		end
	end
	if self.m_type_scroll == nil then
		local list_scroll = self:findGameObject("type_scroll")
		local params = {
			show_data = self.m_private_list,
			loop_scroll_object = list_scroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateTypeCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_type_btn", {index = index, cell_data = cell_data})
			end
		}
		self.m_type_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_type_scroll:reloadData(self.m_private_list, nil, all_cell_size)
	end
end

-- 页签 cell
function M:updateTypeCell(index, cell_object, cell_data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	local format = Language:getTextByKey(cell_data.text_key)
	local online_num = self.m_model:getTypeListOnlineDetailNum(index)
	local total_num = self.m_model:getTypeListDetailNum(index)
	local num_str = string.format(format, online_num, total_num)
	LuaBehaviourUtil.setText(luaBehaviour, cell_data.list_text, num_str)
	local expand_btn = luaBehaviour:FindGameObject("expand_btn")
	UIUtil.setLocalScale(expand_btn.transform, 1, index == ChatUtil.type_select_index and -1 or 1, 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_detail_loopscroll", ChatUtil.type_select_index == index)
	local rect = cell_object:GetComponent("RectTransform")
	if index == ChatUtil.type_select_index then
		local detail_num = self.m_model:getTypeListDetailNum(index)
		detail_num = detail_num <= self.m_friend_cell_limit and detail_num or self.m_friend_cell_limit + 0.1  -- offset to indicate hidden friend
		rect.sizeDelta = Vector2(282,85 * detail_num + 34)
		local type_detail_loopscroll = luaBehaviour:FindGameObject("type_detail_loopscroll")
		local type_detail_loopscroll_rect = type_detail_loopscroll:GetComponent("RectTransform")
		type_detail_loopscroll_rect.sizeDelta = Vector2(type_detail_loopscroll_rect.rect.width, 85 * detail_num)
		self:updateTypeDetailList(index, luaBehaviour)
	else
		rect.sizeDelta = Vector2(282, 34)
	end
end

-- 玩家列表滑动窗口
function M:updateTypeDetailList(type_index, p_luaBehaviour)
	local data = self.m_model:getTypeListData(type_index)
	if self.m_type_detail_scroll_tab[type_index] == nil then
		local list_scroll = p_luaBehaviour:FindGameObject("type_detail_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self.player_cell_objs[cell_data.uid] = cell_object
				self:updatePlayerCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_detail_cell", cell_data)
			end
		}
		self.m_type_detail_scroll_tab[type_index] = LoopScrollViewUtil.new(params)
	else
		self.m_type_detail_scroll_tab[type_index]:reloadData(data, true)
	end
end

-- 玩家列表 cell
function M:updatePlayerCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local has_red_point = ChatUtil:hasPlayerRedPoint(cell_data.uid)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_img", has_red_point)
	
	local head_node = luaBehaviour:FindGameObject("head_node")
	local player_head = luaBehaviour:FindGameObject("player_head")
	GameUtil:setUserAvatar(player_head, cell_data, nil, nil, {show_flag = true, scale = 0.6})
	UIUtil.setText(cell_object.transform, Language:getTextByKey(cell_data.name), "name_text")
	self:setPlayerCellChosenView(cell_data.uid)
	local time_text = luaBehaviour:FindText("time_text")
	local time_str = ""
	if cell_data.is_online == 0 then
		local time = UserDataManager:getServerTime() - cell_data.last_active_time
		local day, hour, min = GameUtil:getTimeLayoutBySecond(time)
		if day > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0002"),day)
		elseif hour > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0003"),hour)
		elseif min > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0004"),min)
		else
			time_str = Language:getTextByKey("mail_str_0005")
		end
		time_text.color = Color( 183/255, 65/255, 65/255)
	else
		time_str = Language:getTextByKey("mail_str_0006")
		time_text.color = Color( 64/255, 118/255, 17/255)
	end
	time_text.text = time_str

	local function clickCallback(_, uid)
		self:updateMsg("show_player", uid)
	end
	UIUtil.setButtonClick(head_node.transform, clickCallback, cell_data.uid)
end

function M:setPlayerCellChosenView(uid)
	local player_cell_obj = self.player_cell_objs[uid] 
	if player_cell_obj then
		local luaBehaviour = UIUtil.findLuaBehaviour(player_cell_obj)
		if ChatUtil.cur_private_uid == uid then
			LuaBehaviourUtil.setImg(luaBehaviour, "detail_cell", "a_lt_tabrenwu", "mystic_ui")
		else
			LuaBehaviourUtil.setImg(luaBehaviour, "detail_cell", "a_lt_untabrenwu", "mystic_ui")
		end
	end
end

-- 移动滑动列表至玩家 cell
function M:moveToCurrentPrivateCell(name)
	local scroll_tab = self.m_type_detail_scroll_tab[ChatUtil.type_select_index]
	local index = scroll_tab:getCellIndexByCellName(name)
	scroll_tab:moveToCellIndex(index)
end

function M:setPrivateVisible()
	self.m_private_list_active = not self.m_private_list_active
	local scale = self.m_private_list_active and 1 or 0
	local private_list_bg = self:findGameObject("private_list_bg")
	UIUtil.setLocalScale(private_list_bg.transform, 1, scale, 1)
end

function M:refreshPrivateBtn()
	self:setObjectVisible("recent_sort_btn", true)
	self:setObjectVisible("friend_sort_btn", true)
	self:setObjectVisible("create_group_btn", false)  -- not yet
	self:setObjectVisible("add_black_btn", true)
	self:setObjectVisible("member_btn", false)
	self:setObjectVisible("quit_group_btn", false)
	self:setObjectVisible("disband_btn", false)
end

function M:updateSortBtnView()
	if ChatUtil.type_detail_sort == 1 then
		self:setImg("a_ui_currency_yeqian_h_n", "common_ui", "friend_sort_btn")
		self:setImg("a_ui_currency_yeqian_h_s", "common_ui", "recent_sort_btn")
		local text = self:findText("friend_sort_btn_text")
		text.color = Color( 99/255, 60/255, 16/255)
		text = self:findText("recent_sort_btn_text")
		text.color = Color( 162/255, 113/255, 58/255)
	else
		self:setImg("a_ui_currency_yeqian_h_s", "common_ui", "friend_sort_btn")
		self:setImg("a_ui_currency_yeqian_h_n", "common_ui", "recent_sort_btn")
		local text = self:findText("friend_sort_btn_text")
		text.color = Color( 162/255, 113/255, 58/255)
		text = self:findText("recent_sort_btn_text")
		text.color = Color( 99/255, 60/255, 16/255)
	end
end


--------------------------- 聊天表情 ---------------------------
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
	self:setObjectVisible("emoji_node", self.emoji) -- 显示emoji和动图的切换按钮
	self:setObjectVisible("Toggles_emoji", self.emoji) -- 显示emoji和动图的切换按钮
	self:setObjectVisible("emoji_gif_bg", self.m_model.m_sel_tab_index == 2 and self.emoji)
	--self.anim:SetBool('emoji',self.emoji)
	local openLV = ConfigManager:getCommonValueById(545); -- 聊天动态表情开启等级
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	if not CS.wt.framework.SpriteAtlasHelper.LoadMultipleSpriteUseBundle or level < openLV then
		self:setObjectVisible("Toggles_emoji", false)
	end
end

function M:updateEmojiScroll()
	local data = self.m_model.m_emoji_data
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

-- 筛选标签点击事件
function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index, keep_offset)
	for k,v in pairs(__EMOJI_TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 241/255, 226/255, 181/255)
		--cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
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

-- 创建 gif 动图列表
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


--------------------------- 活动事件 ---------------------------
local __EVENT_NODE_NAME = {"event_1", "event_2", "event_3", "event_4","event_5","event_6"}
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
				elseif msg_data.event == 5 then -- 登仙楼邀请好友助威
					self:updateAwakeSystemEvent(event_node, msg_data)
					LuaBehaviourUtil.setObjectVisible(luabehaviour, "qipao", false)
					cell_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 140)
				elseif msg_data.event == 6 then -- 红包
					self:updateRedPacketEvent(event_node, msg_data)
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
				self.m_control:showLookInfoTips(Language:getTextByKey("enjoySpring_str_0017"), 2)
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
				self.m_control:showLookInfoTips(Language:getTextByKey("fylt_str_0090"), 2)
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
				self.m_control:showLookInfoTips(Language:getTextByKey("gift_group_text_0030"), 2)
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
				self.m_control:showLookInfoTips(Language:getTextByKey("enjoySpring_str_0017"), 2)
			else
				self:updateMsg("add_fourforce_task", data)
			end
		end, event_data,"event_btn", self.m_uiName)
	end
end

function M:updateAwakeSystemEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		local hero_id = event_data.hero_id or ""
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
		local name = ""
		if hero_cfg then
			name = hero_cfg.name or ""
		end
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text","awake_system_text_0067")
		local finale_name = Language:getTextByKey(name)
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","tid#AwakenDes_001",finale_name)
		UIUtil.setButtonClick(event_node.transform, function(trans, data)
			if msg_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
				self.m_control:showLookInfoTips(Language:getTextByKey("awake_system_text_0046"), 2)
			else
				self:updateMsg("awaken_system_invite", data)
			end
		end, event_data,"event_btn", self.m_uiName)
	end
end

function M:updateRedPacketEvent(event_node, msg_data)
	local event_data = Json.decode(msg_data.event_ext)
	if event_data then
		local event_luabe = event_node:GetComponent("LuaBehaviour")
		local cfg = ConfigManager:getCfgByName("red_envelope")
		local cur_cfg = cfg[event_data.red_packet_id]
		local data = self.m_model.m_data or{}
		local ids = data.recv_ids or {}
		local flag = false
		local redid = event_data.red_id or "" 
		for k,v in pairs(ids) do
			if v == redid then
				flag = true
				break
			end
		end
		LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_name_text",cur_cfg.name)
		if flag == true then
			LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","red_packet_text_005")
		else
			if data.day_recv_num <= 0 then
				LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","red_packet_text_009")
			else
				LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","red_packet_text_008",data.day_recv_num)
			end
		end
		--LuaBehaviourUtil.setTextByLanKey(event_luabe, "event_msg_text","red_packet_text_005")
		--LuaBehaviourUtil.setObjectVisible(event_luabe, "event_msg_text",flag)
		LuaBehaviourUtil.setObjectVisible(event_luabe, "add_btn",false)
		UIUtil.setButtonClick(event_node.transform, function(trans, data)
			self:updateMsg("receive_red_packet", data)
		end, event_data,"event_btn", self.m_uiName)
	end
end



--------------------------- 其他 ---------------------------
--刷新消息
function M:addMsg()
	self:updateTypeList()
	self:updateChatLoopScroll()
	self:updateChannelRedPoint()
end

-- 关闭动画
function M:closeUIAnim(callback)
	self.anim:CrossFade("Chat_end",0)
	local function endChat(msg)
		if msg == "end_chat" then
			self.m_control:closeView()
		end
	end
	self:runAnim("Chat_end",endChat)
end

function M:updateGroupName()
	self:setObjectVisible("group_name_bg",  G_CHAT_CHANEL == __CHAT_CHANNEL.GROUP)
end

-- 获得当前输入的文字
function M:getMsg()
	return self.input.text
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

-- 更新频道红点显示
function M:updateChannelRedPoint()
	for k,v in pairs(self.toggles) do
		local has_red_point = ChatUtil:hasChannelRedPoint(k)
		UIUtil.setObjectVisible(v.transform, has_red_point, "red_point_img")
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
		ChatUtil.private_uids[v[1].uid] = v[1].target_name
		ChatUtil.player_names[v[1].target_name] = v[1].uid
	else
		ch_text.text = v[1].name
		ChatUtil.private_uids[v[1].uid] = v[1].name
		ChatUtil.player_names[v[1].name] =  v[1].uid
	end
	toggle:SetActive(true)
end

return M