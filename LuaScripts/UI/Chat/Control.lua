--聊天
local M = class("ChatControl",LikeOO.OOControlBase)

local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}
function M:onEnter()
	self.emoji_text = {}
	self.m_model.uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_ADD_CHANNEL, {self, self.onAddChannel})
end


function M:onRefreshChatInfo()
	self.m_view:AddMsg()
end

function M:onAddChannel()
	self.m_model:initData()
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("common_refresh", { channel_id = G_CHAT_CHANEL }, "parent") 
		self.m_view:closeUIAnim()
	elseif msg == 'btn_send' then
		if G_CHAT_CHANEL == __CHAT_CHANNEL.GUILD then
			local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
			if guild_id == nil or guild_id  <= 0 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0043"), delay_close = 2})
				return
			end
		elseif G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
			local name = self.m_model.m_private_names[self.m_model.m_private_name]
			if name == nil then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0515"), delay_close = 2})
				return
			end
		end
		if self.m_view.emoji then
			self.m_view:ChangeEmoji()
		end
		local msg = self.m_view:getMsg()
		if msg == nil or msg == '' then
			--没有文字
			return
		end
		
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
    	-- Logger.log(text,"text ========")
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
		
	elseif msg == 'btn_emoji' then
		self.m_view:ChangeEmoji()
	elseif string.find(msg,'channel_') then
		self.m_view.input.text = ''
		local sp = string.split(msg,'_')
		local channel = tonumber(sp[2])
		G_CHAT_CHANEL = channel
		self.m_view:SetToggleChoose(channel)
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
	elseif msg == "click_private" then
		self.m_model.m_private_name = data
		self.m_view:setPrivateName()
		self.m_view:AddMsg()
		self.m_view:setPrivateVisible()
		self.m_view:updatePrivateList()
	elseif msg == "open_friend" then
		self.m_model:init(data)
		self.m_view:SetToggleChoose(G_CHAT_CHANEL)
	elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
		self:switchTabBtn(msg)
	elseif msg == "go_bottom_btn" then
		self.m_view:goToBottom()	
	elseif msg == 'emoji_gif_icon' then
		if G_CHAT_CHANEL == __CHAT_CHANNEL.GUILD then
			local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
			if guild_id == nil or guild_id  <= 0 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0043"), delay_close = 2})
				return
			end
		elseif G_CHAT_CHANEL == __CHAT_CHANNEL.PRIVATE then
			local name = self.m_model.m_private_names[self.m_model.m_private_name]
			if name == nil then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0515"), delay_close = 2})
				return
			end
		end
		if self.m_view.emoji then
			self.m_view:ChangeEmoji()
		end
		
		local text = "[" .. data.emoji .. "]"
		-- Logger.log(text,"text ========")
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
	elseif msg == "add_enjoySpring_task" then
		self:joinSpringTask(data)
	elseif msg == "join_fulwin_arena" then
		self:joinFulwinArena(data)
	elseif msg == "join_group" then
		self:joinGroup(data)
	elseif msg == "add_fourforce_task" then
		self:joinFourForceTask(data)
	end
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
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gift_group_text_0018"), delay_close = 2})
		self:closeView()
	end
	local params = { vsn = data.version, group_id = data.group_id }
	self.m_model:getNetData("gift_join_group", params, joinGroupCallback)
end

function M:joinFulwinArena(data)
	local flag, tips_str = BtnOpenUtil:isBtnOpen(312)
	if not flag then
		GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
		return
	end

	--if data.typ == 1 then
	--	local flag1, tips_str1 = BtnOpenUtil:isBtnOpen(334)
	--	if not flag1 then
	--		GameUtil:lookInfoTips(self, {msg = tips_str1, delay_close = 2})
	--		return
	--	end
	--else
	--	local flag2, tips_str2 = BtnOpenUtil:isBtnOpen(335)
	--	if not flag2 then
	--		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Fengyun_challenge_tips_no"), delay_close = 2})
	--		return
	--	end
	--end
	
	local time = ConfigManager:getCommonValueById(725, 30)
	local server_time = UserDataManager:getServerTime()
	local send_time = data.send_time or 0
	if server_time - send_time >= time then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0086"), delay_close = 2})
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

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_ADD_CHANNEL, {self, self.onAddChannel})
    M.super.destroy(self)
end


return M
