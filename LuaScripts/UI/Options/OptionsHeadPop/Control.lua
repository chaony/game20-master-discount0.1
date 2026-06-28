local M = class("OptionsHeadPopControl",LikeOO.OOControlBase)

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		self:updateMsg("refresh_ui", nil, "Options")
        self:closeView()
    elseif msg == "tab_btn" then
    	self.m_model:setTab(data)
    	self.m_view:setTab()
    elseif msg == "ok_btn" then
    	if self.m_model.m_tab == 1 then
    		self:requestHead()
    	elseif self.m_model.m_tab == 2 then
			self:userSetFrame()
		elseif self.m_model.m_tab == 3 then
			self:useTitle()
    	end
	elseif msg == "upgrade_btn" then	--称号升级
		if self.m_model.m_tab == 3 then
			if self.m_model.m_upgrade_btn_status == 1 then
				self:upgradeTitle()
			elseif self.m_model.m_upgrade_btn_status == 2 then
				self:titleExchange()
			end
		end
	elseif msg == "title_preview_btn" then	--称号预览
		self.m_view:createTitlePreviewNode()
	elseif msg == "title_preview_close_btn" then	--关闭称号预览
		self.m_view:closeTitlePreviewNode()
	elseif msg == "cancel_btn" then
		self:closeView()
	elseif msg == "click_head" then
		self.m_model:setHeadSelect(data)
		self.m_view:refreshUI()
	elseif msg == "click_border" then
		self.m_model:setBorderSelect(data.index)
		self.m_view:refreshUI()
	elseif msg == "click_title" then
		self.m_model:setTitleSelectId(data.cell_data.id)
		self.m_view:refreshUI(false)
	elseif msg == "btn_attribute" then
		local tempData = {}
		local allTitleData = self.m_model:getTitleData()
		for _, itemData in pairs(allTitleData) do
			if itemData.owner ~= 0 then
				table.insert(tempData, itemData)
			end
		end
		self:openView("Pops.TitleAttributePop", {titleData = tempData})
    end
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "titles_update" then
		local titles = data.data or {}
		local old_title_data = titles.remove or {}
		local new_title_data = titles.update or {}
		local old_title_ID = old_title_data[1]
		local new_title_ID
		for _, title_item in pairs(new_title_data) do
			new_title_ID = tonumber(title_item.id)
		end
		--local old_title_cfg = self.m_model:getTitleCfgById(old_title_ID)
		--local new_title_cfg = self.m_model:getTitleCfgById(new_title_ID)
		self:openView("Options.OptionsTitleUpgrade", {old_title_ID = old_title_ID, new_title_ID = new_title_ID})
	elseif curEvent == "title_packages_update" then --titles, title_packages都更新完成再进行此界面的数据刷新
		
	end
end

function M:requestHead()
	local id = self.m_model.m_head[self.m_model.m_head_index]
	if id == nil then
		Logger.logWarningAlways(self.m_model.m_head_index, "self.m_model.m_head_index not found : ")
		return
	end
	local activation_state, lock_type = self.m_model:playerPictureIsActivationState(id)
	if activation_state == false then
		local cfg = ConfigManager:getPlayerPictureCfg(id)
		if cfg.unlock == 1 then
			if lock_type == 2 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0035"), delay_close = 2})
			else
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0021"), delay_close = 2})
			end
		elseif cfg.unlock == 2 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0028"), delay_close = 2})
		elseif cfg.unlock == 3 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0031"), delay_close = 2})
		end
		return
	end
	local function headCallback(response)
		self:updateMsg("refresh_ui", nil, "Options")
        self:closeView()
    end
    local params = {}
    params.avatar = self.m_model.m_head[self.m_model.m_head_index]
    self.m_model:getNetData("user_set_avatar", params, headCallback)
end

function M:userSetFrame()
	local border_data = self.m_model.m_border[self.m_model.m_border_index]
	if border_data then
		local activation_state = self.m_model:playerFrameIsActivationState(border_data.id)
		if activation_state == false then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0034"), delay_close = 2})
			return
		end
		local function headCallback(response)
			self:updateMsg("refresh_ui", nil, "Options")
			self:closeView()
		end
		local params = {}
		params.frame = border_data.id
		self.m_model:getNetData("user_set_frame", params, headCallback)
	end
end
-- 佩戴称号
function M:useTitle()
	local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	if self.m_model.m_sel_title_id == title_id then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0003"), delay_close = 2})
		return 
	end
	local titleIds = UserDataManager.title_data:getTitlesId()
	local owner_flag = table.indexof(titleIds, tostring(self.m_model.m_sel_title_id))
	if owner_flag == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0004"), delay_close = 2})
		return
	end
	local function headCallback(response)
		self:updateMsg("refresh_ui", nil, "Options")
		self:closeView()
	end
	local params = {}
	params.title_id = self.m_model.m_sel_title_id
	self.m_model:getNetData("user_set_title", params, headCallback)
end

-- 升级称号
function M:upgradeTitle()
	local titleIds = UserDataManager.title_data:getTitlesId()
	local owner_flag = table.indexof(titleIds, tostring(self.m_model.m_sel_title_id))
	if owner_flag == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0004"), delay_close = 2})
		return
	end

	local title_cfg = self.m_model:getTitleCfgById(self.m_model.m_sel_title_id)
	local up_top_flag = title_cfg.next_id and title_cfg.next_id == 0 -- 满级
	if up_top_flag == true then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0009"), delay_close = 2})
		return
	end
	
	local up_flag, material_data = self.m_model:canTitleUpgrade(title_cfg)
	if up_flag == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0007"), delay_close = 2})
		return
	end
	
	local function headCallback(response)
		self.m_model:updateAllTitleData()
		self.m_view:setTab()
		RewardUtil:rewardTipsByData(response.reward) --展示升级结果的界面在self:dataUpdateEvent()
	end
	local params = {}
	params.title_id = self.m_model.m_sel_title_id
	params.material_title_id = material_data.ID
	self.m_model:getNetData("title_title_upgrade", params, headCallback)
end

--兑换元宝
function M:titleExchange()
	local titleIds = UserDataManager.title_data:getTitlesId()
	local owner_flag = table.indexof(titleIds, tostring(self.m_model.m_sel_title_id))
	if owner_flag == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0004"), delay_close = 2})
		return
	end

	local title_cfg = self.m_model:getTitleCfgById(self.m_model.m_sel_title_id)
	local up_flag = self.m_model:canTitleUpgrade(title_cfg)
	if up_flag == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0008"), delay_close = 2})
		return
	end

	local function headCallback(response)
		self.m_model:updateAllTitleData()
		self.m_view:setTab()
		RewardUtil:rewardTipsByData(response.reward)
	end
	local params = {}
	params.title_data = {}
	local material_data = self.m_model:getTitleMaterialData(title_cfg.group)
	for _, material_item in pairs(material_data) do
		params.title_data[tostring(material_item.ID)] = material_item.count
	end
	self.m_model:getNetData("title_sell_title", params, headCallback)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M;
