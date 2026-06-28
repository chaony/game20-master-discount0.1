--- 
local M = class("RedPacketDetailNode",LikeOO.OOUIbase)

M.m_uiName = "Item/RedPacketDetailNode"

local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6, GROUP = 7,}
local newLine = "\n"

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self.ext_params = {}
	self.m_gray_image = self:findImage("gray_image")
	self.m_icon_node = self:findGameObject("icon_node")
	self:setTextByLanKey("max_btn_text", "new_str_0643")
	self:setObjectVisible("add_node", false)
	self.find_input = self:findInputField("user_input_field")
	UIUtil.addInputFieldListener(self:findGameObject("user_input_field").transform, handler(self,self.inputChanged))
end

function M:updateUseNum()
	self:setObjectVisible("use_red_point_img", false)
	self:setObjectVisible("user_num_slider", false)
	local use_max = self:getMaxNum()
	local use_num = self:getUseNum()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local cfg_use_num = item_cfg.use_num
	self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
	self:setSearchText(use_num)
end

function M:onButtonClick(obj, name)
	if name == "minus_ten_btn" then
		self:addUseNum(-10)
		self:updateUseNum()
	elseif name == "minus_one_btn" then
		self:addUseNum(-1)
		self:updateUseNum()
	elseif name == "add_one_btn" then
		self:addUseNum(1)
		self:updateUseNum()
	elseif name == "max_btn" then
		self:addUseNum(self:getMaxNum())
		self:updateUseNum()
	elseif name == "use_btn" then
		self:useItem()
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	local show_data = self.m_show_data 
	local item_cfg = show_data.item_cfg
	self.m_use_num = math.min(self:getMaxNum(),1)
	self:setTextByLanKey("common_title_text", show_data.name)
	local moneyGuide_cfg = ConfigManager:getCfgByName("money_guide")
	local cur_money_guide = moneyGuide_cfg[item_cfg.money_guide]
	local money_guide_name = Language:getTextByKey(cur_money_guide.name) 
	local desc = item_cfg.des or ""
	local nums = Language:getTextByKey("red_packet_text_001",item_cfg.quantity)
	local money = Language:getTextByKey("red_packet_text_002",item_cfg.lower_limit,item_cfg.upper_limit)
	local time_str = Language:getTextByKey("red_packet_text_003")
	
	local final_str = desc .. newLine .. nums .. newLine.. money .. money_guide_name .. newLine
	self:setTextByLanKey("item_des_text", final_str)
	
	local text_scroll = self:findImage("item_des_scroll")
	local strCount = string.utf8len(final_str)
	text_scroll.raycastTarget = strCount > 300
	
	self:setTextByLanKey("use_btn_text", item_cfg.sort == 2 and "new_str_0049" or "new_str_0048")
	self:setTextByLanKey("grey_use_btn_text", item_cfg.sort == 2 and "new_str_0049" or "new_str_0048")
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self:updateUseNum()
end

function M:updateView(data)
	self.m_show_data = data
	self.red_packet_id = data.data_id
	self:refreshUI()
end

function M:addUseNum(value)
	local new_count = self.m_use_num + value
	self.m_use_num = math.min(math.max(1,new_count),self:getMaxNum())
end

function M:getMaxNum()
	local max_num = self.m_show_data.user_num or 0
	return max_num
end

function M:getUseNum()
	return self.m_use_num
end

function M:checkInTab(id, tab)
	for i,v in pairs(tab) do
		if v == id then
			return true
		end
	end
	return false
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "items_update" then
		self:refreshUI()
	end
end

function M:useItem()		
	if self:idCdBytype()  then
		local tips_str = Language:getTextByKey("red_packet_text_006")
		GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
		return
	end
	local id = self.red_packet_id
	local nums = self.m_use_num
	local params = {envelope_id = id,send_num = nums}
	local function Callback(response)
		if response.incr_id then
			for k,v in pairs(response.incr_id) do
				self:sendMsg(v,__CHAT_CHANNEL.WORLD)
				local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
				if guild_id and guild_id > 0 then
					self:sendMsg(v,__CHAT_CHANNEL.GUILD)
				end
				self.ext_params.auto = true
				static_rootControl:openView("Main.RedPacketPop",self.ext_params)
			end
		end
	end
	self.m_model:getNetData("red_envelope_send_envelope", params, Callback)
end


function M:idCdBytype()		
	return ChatUtil:isCdByType(__CHAT_CHANNEL.GUILD) or ChatUtil:isCdByType(__CHAT_CHANNEL.LOCAL) 
end

function M:sendMsg(id,channel_id)
	local send_data = self:getChatData(id)
	send_data.channel_type = tostring(channel_id)--
	ChatUtil:sendMsg(send_data,2)
end

function M:getSearchText()
	return self.find_input.text
end

function M:setSearchText(num)
	self.find_input.text = num
end

function M:inputChanged()
	local num = self:getSearchText()
	if self.m_use_max and tonumber(num) >= self.m_use_max then
		num = self.m_use_max
		self.find_input.text =  self.m_use_max
	end
	self.m_use_num = tonumber(num)
end

function M:getChatData(id)
	local name =  self.m_show_data.name
	self.ext_params.invite_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	self.ext_params.send_time = UserDataManager:getServerTime()
	self.ext_params.red_packet_id = self.red_packet_id
	self.ext_params.red_id = id
	local send_data = {
		uid = UserDataManager.user_data:getUserStatusDataByKey("uid"),
		name = UserDataManager.user_data:getUserStatusDataByKey("name"),
		avatar = tostring(UserDataManager.user_data:getUserStatusDataByKey("avatar")),
		frame = tostring(UserDataManager.user_data:getUserStatusDataByKey("frame")),
		title = UserDataManager.user_data:getUserStatusDataByKey("title"),
		msg = tostring(self.red_packet_id),
		event = 6,
		event_ext = Json.encode(self.ext_params),
	}
	return send_data
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M