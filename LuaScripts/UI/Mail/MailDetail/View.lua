local M = class("MailDetailPopView",LikeOO.OOPopBase)

M.m_uiName = "Mail/MailDetailsPop"
M.m_size_type = 2

function M:onEnter()
	self.text_scroll = self:findGameObject("text_scroll")
	self.rewards_scroll = self:findGameObject("rewards_scroll")
	self.rewards_image = self:findGameObject("rewards_image")
	self:setText("des_text", "")
	self:refreshUI()
end

function M:refreshUI()
	self:updateRewardsScroll()
	if next(self.m_model.m_rewards) == nil then
		self.rewards_image:SetActive(false)
		local rect = self.text_scroll:GetComponent("RectTransform")
		rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("bottom"), 72,rect.rect.height + 120)
		UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0006")
	else
		if self.m_model.m_params.is_received then
			UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0006")
		else
			UIUtil.setTextByLanKey(self:findGameObject("yes_btn").transform, "Text", "new_str_0056")
		end
	end

	local key, content = self.m_model:getContent()
	if key == "text_content" then
		self:setText("common_title_text", content.mail_title or "")
		self:setText("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
			self:setObjectVisible("send_text", false)
		else
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. content.mail_from)
		end
	elseif key == "language_content" then
		self:setTextByLanKey("common_title_text", content.mail_title or "")
		self:setTextByLanKey("des_text", content.mail_content or "")
		if content.mail_from == nil or content.mail_from == "" then
			self:setText("send_text", "")
			self:setObjectVisible("send_text", false)
		else
			self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(content.mail_from))
		end
	elseif key == "format_content" then
		local mail_cfg = ConfigManager:getCfgByName("mail")
		local cfg = mail_cfg[content.config_id]
		if cfg then
			self:setText("common_title_text", Language:getTextByKey(cfg.title))
			if cfg.sender == nil or cfg.sender == "" then
				self:setText("send_text", "")
				self:setObjectVisible("send_text", false)
			else
				self:setText("send_text", Language:getTextByKey("mail_str_0001") .. Language:getTextByKey(cfg.sender))
			end
			
			local newText = GameUtil:formatTextString(Language:getTextByKey(cfg.content), content.params)
			self:setText("des_text", newText)
		end
	end
	local des_text = self:findText("des_text")
	des_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
end

function M:updateRewardsScroll()
    local data = self.m_model.m_rewards
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("rewards_scroll")
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

            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:listHandle(obj, id)
	local data = self.m_model.m_rewards[id]
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