local M = class("MailPopView",LikeOO.OOPopBase)

M.m_uiName = "Mail/MailPop"
M.m_size_type = 2

function M:onEnter()
	self.rewards_image = self:findGameObject("rewards_image")
	self.get_btn = self:findGameObject("get_btn")
	self.get_img = self:findGameObject("get_img")
	self.no_text = self:findGameObject("no_text")
	self.detail_panel = self:findGameObject("detail_panel")
	self:setTextByLanKey("get_btn_text", "new_str_0056")
	self:setTextByLanKey("no_text", "mail_str_0014")
	self:setTextByLanKey("common_title_text", "mail_str_0015")
	self.detail_title_text = self:findGameObject("detail_title_text")
	self.text_scroll = self:findGameObject("text_scroll")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
	self:findButton("fast_remove_btn").interactable = #self.m_model.m_list_data > 0
	self:findButton("fast_get_btn").interactable = #self.m_model.m_list_data > 0
	self:refreshDetailUI()
end

function M:updateListScroll()
	local data = self.m_model.m_list_data
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("open", index)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj,id)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local title_text = luaBehaviour:FindText("title_text")
	local reward_img = luaBehaviour:FindGameObject("reward_img")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local read_img = luaBehaviour:FindGameObject("read_img")
	-- local read_text = luaBehaviour:FindText("read_text")
	
	-- read_text.text = Language:getTextByKey("mail_str_0013")
	select_img:SetActive(id == self.m_model.m_select_index)
	local data = self.m_model:getMailByIndex(id)
	local key, content
	for k,v in pairs(data.content) do
		key = k
		content = v
	end
	if key == "text_content" then
		title_text.text = content.mail_title
	elseif key == "language_content" then
		title_text.text = Language:getTextByKey(content.mail_title)
	elseif key == "format_content" then
		local mail_cfg = ConfigManager:getCfgByName("mail")
		local cfg = mail_cfg[content.config_id]
		if cfg then
			title_text.text = Language:getTextByKey(cfg.title)
		end
	end
	local time = UserDataManager:getServerTime() - data.create_ts
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	if day > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0002"),day), "time_text")
	elseif hour > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0003"),hour), "time_text")
	elseif min > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0004"),min), "time_text")
	else
		UIUtil.setText(obj.transform, Language:getTextByKey("mail_str_0005"), "time_text")
	end

	time = data.expire_ts - UserDataManager:getServerTime()
	day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	if day > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0009"),day), "rem_time_text")
	elseif hour > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0010"),hour), "rem_time_text")
	elseif min > 0 then
		UIUtil.setText(obj.transform, string.format(Language:getTextByKey("mail_str_0011"),min), "rem_time_text")
	else
		UIUtil.setText(obj.transform, Language:getTextByKey("mail_str_0012"), "rem_time_text")
	end

	if data.status == 0 then
		-- UIUtil.setImg(obj.transform, "yx_ui_liebiao_m", "mail_ui", "Image")
		UIUtil.setImg(obj.transform, "a_yj_xinfeng_red", "mail_ui", "icon_image")
		UIUtil.setTextColor(obj.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "title_text")
		UIUtil.setTextColor(obj.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "time_text")
		read_img:SetActive(false)
	else
		-- UIUtil.setImg(obj.transform, "yx_ui_liebiao_m", "mail_ui", "Image")
		UIUtil.setImg(obj.transform, "a_yj_xinfeng_bu", "mail_ui", "icon_image")
		UIUtil.setTextColor(obj.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "title_text")
		UIUtil.setTextColor(obj.transform, GlobalConfig.COMMON_COLLOR.COMMON_5, "time_text")
		read_img:SetActive(true)
	end

	local reward_content = luaBehaviour:FindGameObject("reward_content")
	UIUtil.destroyAllChild(reward_content.transform)
	-- local red_point_img = luaBehaviour:FindGameObject("red_point_img")
	-- if #data.gift > 0 and data.is_received == false then	
	-- 	red_point_img:SetActive(true)
		-- for i,v in ipairs(data.gift) do
		-- 	if v[4] then
		-- 		v.quality = v[4]
		-- 		v[4] = nil
		-- 	end
		-- end
	-- 	reward_img:SetActive(true)
	-- 	GameUtil:createRewards(reward_content.transform, data.gift, true, true)
	-- else
	-- 	red_point_img:SetActive(data.status == 0)
	-- 	reward_img:SetActive(false)
	-- end
	local mask_image = luaBehaviour:FindGameObject("mask_image")
	mask_image:SetActive(data.is_received == false and data.status == 0)
end

------------------邮件内容--------------------------------------------------------------------------------------------

function M:refreshDetailUI()
	local mail = self.m_model:getMailByIndex(self.m_model.m_select_index)
	if mail == nil then
		self.detail_panel:SetActive(false)
		self.no_text:SetActive(true)
		return
	else
		self.detail_panel:SetActive(true)
		self.no_text:SetActive(false)
	end
	self:updateRewardsScroll(mail.gift)
	if next(mail.gift) == nil then
		self.rewards_image:SetActive(false)
		local rect = self.text_scroll:GetComponent("RectTransform")
		rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("bottom"), 10, 390)
		-- UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0006")
	else
		local rect = self.text_scroll:GetComponent("RectTransform")
		rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("bottom"), 194, 206)
		self.rewards_image:SetActive(true)
		if mail.is_received then
			self.get_btn:SetActive(false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          )
			self.get_img:SetActive(true)
			-- UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0006")
		else
			self.get_btn:SetActive(true)
			self.get_img:SetActive(false)
			-- UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0056")
		end
	end

	local key, content = self.m_model:getContent()
	if key == "text_content" then
		self:setText("detail_title_text", content.mail_title or "")
		self:setText("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
		else
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. content.mail_from)
		end
	elseif key == "language_content" then
		self:setTextByLanKey("detail_title_text", content.mail_title or "")
		self:setTextByLanKey("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
		else
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(content.mail_from))
		end
	elseif key == "format_content" then
		local mail_cfg = ConfigManager:getCfgByName("mail")
		local cfg = mail_cfg[content.config_id]
		if cfg then
			self:setText("detail_title_text", Language:getTextByKey(cfg.title))
			if cfg.sender == nil or cfg.sender == "" then
				self:setText("send_text", "")
			else
				self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(cfg.sender))
			end
			
			local newText = GameUtil:formatTextString(Language:getTextByKey(cfg.content), content.params)
			self:setText("des_text", newText)
		end
	end
	self.detail_title_text.transform:GetComponent('ContentSizeFitter'):SetLayoutHorizontal();
end

function M:updateRewardsScroll(rewards)
    local data = rewards
    if self.m_rewards_scroll == nil then
        local list_scroll = self:findGameObject("rewards_scroll")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listRewardHandle(cell_object, index, data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_rewards_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_rewards_scroll:reloadData(data,true)
    end
end

function M:listRewardHandle(obj, id, data)
	-- local data = self.m_model.m_rewards[id]
	-- UIUtil.setScale(obj.transform, 0.8)
	GameUtil:updateItemElement(obj, data, true, true)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local tips_img = luaBehaviour:FindGameObject("tips_img")
	local tips_text = luaBehaviour:FindText("tips_text")
	-- Logger.log(self.m_model.m_params.is_received,"is_received ===")

	tips_img:SetActive(self.m_model.m_params.is_received)
	tips_text.text = ""
end

return M