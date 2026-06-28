local M = class("LiteratureRankTaskView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureRankTask"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE_1 = {
	{btn_key = "self_togglebtn", btn_text = "self_btn_text", red_point = "self_red_point_img",},
	{btn_key = "group_togglebtn", btn_text = "group_btn_text", red_point = "group_red_point_img",},
}

local __TAB_BTN_NODE_2 = {
	{btn_key = "my_task_togglebtn", btn_text = "my_task_btn_text", text_key = "enjoySpring_str_0003", red_point = "my_task_red_point_img",},
	{btn_key = "friend_task_togglebtn", btn_text = "friend_task_btn_text", text_key = "enjoySpring_str_0004", red_point = "friend_task_red_point_img",},
}

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	self.gray_img = self:findImage("gray_img")
	self:setTextByLanKey("close_title_text", "enjoySpring_str_0001")
	self:setTextByLanKey("tips_text_1", "enjoySpring_str_0005")
	self:setTextByLanKey("tips_text_6", "enjoySpring_str_0007")
	self:setTextByLanKey("remove_task_btn_text", "enjoySpring_str_0008")
	self:setTextByLanKey("remove_task_btn_text2", "enjoySpring_str_0008")
	self:setTextByLanKey("refresh_task_btn_text", "enjoySpring_str_0009")
	self:setTextByLanKey("Invite_btn_text", "enjoySpring_str_0010")
	self:setTextByLanKey("remove_friend_btn_text", "enjoySpring_str_0011")
	self:setTextByLanKey("share_task_value_text2", "enjoySpring_str_0012")
	self:setTextByLanKey("tips_text_8", "enjoySpring_str_0013")
	self:setTextByLanKey("show_rank_list_btn_text", "enjoySpring_str_0014")
	self.task_reward_item = self:findGameObject("task_reward_item")
	self:setObjectVisible("task_reward_item", false)
	local force_cfg = self.m_model:getEnjoySpringForceCfg()
	for k,v in pairs(__TAB_BTN_NODE_1) do
		if k == 1 then
			self:setText(v.btn_text, string.cutTextForString(Language:getTextByKey(force_cfg.name)))
		else
			self:setText(v.btn_text, string.cutTextForString(Language:getTextByKey("enjoySpring_str_0001")))
		end
		
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_rank_tab then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("rank_tab", k)
			end
		end, nil, self.m_uiName)
		self:setObjectVisible(v.red_point, false)
	end

	for k,v in pairs(__TAB_BTN_NODE_2) do
		self:setText(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))

		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_task_tab then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("task_tab", k)
			end
		end, nil, self.m_uiName)
		--self:setObjectVisible(v.red_point, false)
	end
	
	self:refreshUI()
end

function M:refreshUI()
	for k,v in pairs(__TAB_BTN_NODE_1) do
		if k == self.m_model.m_rank_tab then
			self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
	end

	for k,v in pairs(__TAB_BTN_NODE_2) do
		if k == self.m_model.m_task_tab then
			self:setTextColor(v.btn_text, Color( 0.4196078, 0.4392157, 0.6392157))
		else
			self:setTextColor(v.btn_text,  Color( 0.3137255, 0.3294118, 0.4941176))
		end
	end
	self:refreshRank()
	self:refreshTask()
	self:refreshWarrior()
	self:refreshRedpoint()
end

function M:refreshRank()
	for i=1,4 do
		local rank_list = self:findGameObject("rank_list_" .. i)
		local luaBehaviour = rank_list:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rank_group_icon", self.m_model.m_rank_tab == 2)
		local rank_user = self.m_model:getRankUser(i)
		if rank_user and rank_user.user then
			local user = rank_user.user
			self:setObjectVisible("rank_list_" .. i, true)
			if user.name == nil or user.name == "" then
				local text = LuaBehaviourUtil.setText(luaBehaviour, "rank_palyer_name_text", tostring(user.uid))
				text.fontSize = self.m_model.m_rank_tab == 1 and 24 or 20
			else
				local text = LuaBehaviourUtil.setText(luaBehaviour, "rank_palyer_name_text", tostring(user.name))
				text.fontSize = self.m_model.m_rank_tab == 1 and 24 or 20
			end
			local server_name = ""
			if tonumber(user.server) == 0 then
				server_name = UserDataManager.server_data:getServerName()
			else
				server_name = UserDataManager.server_data:getServerNameById(user.server)
			end
			LuaBehaviourUtil.setText(luaBehaviour, "rank_server_text", server_name)
			if self.m_model.m_rank_tab == 2 then
				local force_cfg = self.m_model:getEnjoySpringForceCfg(rank_user.force)
				local word = string.cutText(Language:getTextByKey(force_cfg.name))
				for k=1, 4 do
					LuaBehaviourUtil.setText(luaBehaviour,"name_" .. k, word[k] or "")
				end
				local icon = luaBehaviour:FindGameObject("rank_group_icon")
				GameUtil:updateResourcesImg(icon,"Texture/EnjoySpring/" .. force_cfg.icon)
			end
		else
			self:setObjectVisible("rank_list_" .. i, false)
		end
	end
	local head_node = self:findGameObject("rank_one_head")
	local one_user = self.m_model:getRankUser(1)
	if one_user and one_user.user then
		self:setObjectVisible("rank_one_head", true)
		GameUtil:setUserAvatar(head_node, one_user.user, nil, nil, {show_flag = true, scale = 1})
		self:setObjectVisible("no_rank_text", false)
		self:setObjectVisible("show_rank_list_btn", true)
	else
		self:setObjectVisible("rank_one_head", false)
		self:setObjectVisible("no_rank_text", true)
		self:setObjectVisible("show_rank_list_btn", false)
	end
	
end

function M:refreshRedpoint()
	local self_status, friend_status = self.m_model:getAllTaskStatus()
	if self_status[2] == 1 and friend_status[2] > 0 then
		self:setObjectVisible("friend_task_red_point_img", true)
	else
		self:setObjectVisible("friend_task_red_point_img", false)
	end

	local friend_user = self.m_model.m_data.my_task.receive
	if friend_user and next(friend_user) and self_status[1] == 1 and friend_status[1] > 0 then
		self:setObjectVisible("my_task_red_point_img", true)
	else
		self:setObjectVisible("my_task_red_point_img", false)
	end
end

function M:refreshTask()
	local task_cfg = self.m_model:getTask()
	local received_count, max_count = self.m_model:getTaskReceivedCount()
	--Logger.log(task_cfg,"task_cfg ===")
	if task_cfg then
		self:setObjectVisible("task_node", true)
		self:setObjectVisible("no_task_node", false)
		self:setTextByLanKey("tips_text_3", task_cfg.name)
		for i=1,3 do
			if task_cfg.star >= i then
				self:setImg("a_wqb_nandu1", "mystic_ui", "star_img_" .. i)
			else
				self:setImg("a_wqb_nandu2", "mystic_ui", "star_img_" .. i)
			end
		end
		local task_reward_content = self:findGameObject("task_reward_content")
		UIUtil.destroyAllChild(task_reward_content.transform)
		for i,v in ipairs(task_cfg.reward or {}) do
			local reward_item = GameUtil:instanceObject(self.task_reward_item, task_reward_content)
			reward_item:SetActive(true)
			local ItemNode = UIUtil.findTrans(reward_item.transform, "ItemNode")
			GameUtil:updateItemElement(ItemNode, v, true, true)
		end
		self:setTextByLanKey("tips_text_7", "enjoySpring_str_0029", received_count, max_count)
		
		self:setObjectVisible("remove_task_btn", self.m_task_tab == 2)
		
		local self_user = UserDataManager.user_data.user_status
		local self_head = self:findGameObject("self_head")
		GameUtil:setUserAvatar(self_head, self_user, nil, nil)
		local self_value, friend_value = self.m_model:getTaskValue()
		local self_value_2 = self_value < task_cfg.target_value and self_value or task_cfg.target_value
		local friend_value_2 = friend_value < task_cfg.target_value and friend_value or task_cfg.target_value
		self:setTextByLanKey("tips_text_4", "enjoySpring_str_0031",self_value_2,task_cfg.target_value)
		if self.m_model.m_task_tab == 1 then
			local friend_user = self.m_model.m_data.my_task.receive
			local other_head = self:findGameObject("other_head")
			
			if next(friend_user) == nil then
				other_head:SetActive(false)
				self:setObjectVisible("no_other_head", true)
				self:setObjectVisible("refresh_task_btn", true)
				self:setObjectVisible("Invite_btn", true)
				self:setObjectVisible("remove_friend_btn", false)
				self:setObjectVisible("receive_task_reward_btn", false)
				self:setTextByLanKey("tips_text_5", "enjoySpring_str_0030")
				
			else
				other_head:SetActive(true)
				GameUtil:setUserAvatar(other_head, friend_user, nil, nil)
				self:setObjectVisible("no_other_head", false)
				self:setObjectVisible("refresh_task_btn", false)
				self:setObjectVisible("Invite_btn", false)
				self:setObjectVisible("remove_friend_btn", true)
				self:setObjectVisible("receive_task_reward_btn", true)
				local receive_task_reward_btn = self:findButton("receive_task_reward_btn")
				local receive_task_reward_btn_img = self:findImage("receive_task_reward_btn")
				local self_status, friend_status = self.m_model:getTaskStatus()
				if self_status == 1 and friend_status > 0 then
					receive_task_reward_btn.interactable = true
					receive_task_reward_btn_img.material = nil
				else
					receive_task_reward_btn.interactable = false
					receive_task_reward_btn_img.material = self.gray_img.material
				end
				
				self:setTextByLanKey("tips_text_5", "enjoySpring_str_0032",friend_value_2,task_cfg.target_value)
			end
			self:setObjectVisible("remove_task_btn", false)
			self:setObjectVisible("receive_friend_task_reward_btn", false)
		else
			self:setObjectVisible("Invite_btn", false)
			self:setObjectVisible("refresh_task_btn", false)
			self:setObjectVisible("remove_friend_btn", false)
			self:setObjectVisible("receive_task_reward_btn", false)
			self:setObjectVisible("no_other_head", false)
			local friend_user = self.m_model.m_data.friend_task.invite
			local other_head = self:findGameObject("other_head")
			other_head:SetActive(true)
			GameUtil:setUserAvatar(other_head, friend_user, nil, nil)
			self:setTextByLanKey("tips_text_5", "enjoySpring_str_0032",friend_value_2,task_cfg.target_value)
			local self_status, friend_status = self.m_model:getTaskStatus()
			if self_status == 1 and friend_status > 0 then
				self:setObjectVisible("remove_task_btn", false)
				self:setObjectVisible("receive_friend_task_reward_btn", true)
			else
				self:setObjectVisible("remove_task_btn", true)
				self:setObjectVisible("receive_friend_task_reward_btn", false)
			end
		end
		self:setObjectVisible("time_text", true)
		self:createTaskDownTime()
	else
		self:setObjectVisible("time_text", false)
		self:setObjectVisible("task_node", false)
		self:setObjectVisible("no_task_node", true)
		self:setObjectVisible("refresh_task_btn2", self.m_model.m_task_tab == 1)
		self:setTextByLanKey("tips_text_2", "enjoySpring_str_0038", received_count, max_count)
	end
end

function M:createTaskDownTime()
	if self.m_task_timer then
		self.m_control:removeTimer(self.m_task_timer)
		self.m_task_timer = nil
	end
	local end_time = self.m_model:getTaskEndTime()
	if end_time then
		local function tick()
			local server_time = UserDataManager:getServerTime()
			local down_time = math.max(end_time - server_time, 0)
			local time_format = GameUtil:formatTimeBySecond(down_time)
			self:setTextByLanKey("time_text", "enjoySpring_str_0033", time_format)
		end
		self.m_task_timer = self.m_control:setTimer(1,tick)
		tick()
	else
		self:setText("time_text", "")
	end
end

local slider_value = {0.05, 0.20, 0.35, 0.505, 0.66, 0.81, 1}
function M:refreshWarrior()
	local war_order, cfg = self.m_model:getWarriorCfg()
	local pay_status = self.m_model:getwrriorPayStatus()
	if pay_status == 0 then
		local show_price = GameUtil:getMoneyTypeNum(war_order.price).. Language:getTextByKey("new_str_0037")
		self:setText("buy_btn_text", show_price)
	else
		self:setTextByLanKey("buy_btn_text", "petard_text_0018")
	end
	
	if cfg then
		local max_value = 0
		for i,v in pairs(cfg) do
			local reward_node = self:findGameObject("reward_node_" .. i)
			local luaBehaviour = reward_node:GetComponent("LuaBehaviour")
			LuaBehaviourUtil.setText(luaBehaviour,"reward_num_text", v.condition)
			local item = luaBehaviour:FindGameObject("ItemNode")
			local item_luaBehaviour = item:GetComponent("LuaBehaviour")
			local receive_status = self.m_model:getWrriorRewardStatus(i)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "can_get_img", receive_status == 1)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "receive_reward_btn", receive_status == 1)
			if v.free_reward and next(v.free_reward) then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_bg_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_top_img", false)
				GameUtil:updateItemElement(item,v.free_reward[1], true,true)
				LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "lock_image", false)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_bg_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_top_img", true)
				GameUtil:updateItemElement(item,v.fee_incentives[1], true,true)
				LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "lock_image", pay_status == 0)
			end
			LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", receive_status == 2)
			if max_value < v.condition then
				max_value = v.condition
			end
			local receive_reward_btn = luaBehaviour:FindGameObject("receive_reward_btn")
			UIUtil.setButtonClick(receive_reward_btn.transform, function(obj, data)
				audio:SendEvtUI("UI_Pay")
				self:updateMsg("receive_warrior_reward", data)
			end, i, nil, self.m_uiName)
		end
		local value = self.m_model:getWrriorValue()
		local warrior_slider = self:findSlider("warrior_slider")
		value = math.min(value, max_value)
		local index = math.min(value, #slider_value)
		warrior_slider.value = slider_value[index] or 0
		self:setText("share_task_value_text", tostring(value) .. "/" .. max_value)
	end
end

function M:everyDayRefreshEvent()
	self:updateMsg("refres_index")
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end

return M