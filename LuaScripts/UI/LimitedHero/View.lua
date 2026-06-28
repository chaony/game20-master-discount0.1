local M = class("LimitedHeroView", LikeOO.OOPopBase)

M.m_uiName = "LimitedHero/LimitedHero"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("hint_text", "limited_hero_007")
    self.m_gray_image = self:findImage("gary_img")
    self.reward_grid = self:findGameObject("reward_node")
	for i = 1, 3 do
		self:setTextByLanKey("day_text_" .. i, "day_str_" .. i)
	end
	local main_data = self.m_model:getMainData()
	for i = 1, 4 do
		self:setObjectVisible("charge_btn"..i, false)
		self:setTextByLanKey("charge_des_text_"..i, "limited_hero_002")
		if main_data and main_data[i] then
			self:setTextByLanKey("charge_text_" .. i, "limited_hero_001", GameUtil:switchMoneyType(main_data[i].cfg.price))
		end
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateTagInfo()
end

function M:updateTagInfo()
	local selected_tag_index = self.m_model:getSelectedTagIndex()
	for tag_index = 1, 4 do
		local main_data_tag = self.m_model:getMainData(tag_index)
		if main_data_tag then
			self:setObjectVisible("charge_btn" .. tag_index, true)
			if tag_index == selected_tag_index then
				self:setImg("sjsc_xz", "active_ui","charge_btn"..tag_index)
				self:setTextColor("charge_text_"..tag_index, Color( 168/255, 88/255, 36/255))
				self:setTextColor("charge_des_text_"..tag_index, Color( 168/255, 88/255, 36/255))
			else
				self:setImg("sjsc_wxz", "active_ui","charge_btn"..tag_index)
				self:setTextColor("charge_text_"..tag_index, GlobalConfig.COMMON_COLLOR.COMMON_1)
				self:setTextColor("charge_des_text_"..tag_index, GlobalConfig.COMMON_COLLOR.COMMON_1)
			end
			self:findImage("charge_btn"..tag_index):SetNativeSize()
			local red_point_flag = false
			if main_data_tag.status_data.is_buy == 1 then
				for k, v in pairs(main_data_tag.status_data.can_receive) do
					if v == 1 then
						red_point_flag = true
						break
					end
				end
			end
			self:setObjectVisible("tag_red_point_"..tag_index, red_point_flag)
		else
			self:setObjectVisible("charge_btn" .. tag_index, false)	
		end
	end
	local main_data_tag = self.m_model:getMainData(selected_tag_index)
	if main_data_tag then
		if main_data_tag.cfg.spine then
			self:setSpine(main_data_tag.cfg.spine[1])
		end
		self:setTextByLanKey("des_text", main_data_tag.cfg.name2)
		self:setTextByLanKey("des_hero_text", main_data_tag.cfg.name3)
		self:setObjectVisible("buy_btn", main_data_tag.status_data.is_buy == 0 and self.m_model:isInShowTime() == false)
		self:setTextByLanKey("buy_btn_text", "limited_hero_001", GameUtil:switchMoneyType(main_data_tag.cfg.price))
	end
	self:updateDayInfo()
end

function M:updateDayInfo()
	local selected_tag_index = self.m_model:getSelectedTagIndex()
	local selected_day_index = self.m_model:getSelectedDayIndex()
	local main_data_tag = self.m_model:getMainData(selected_tag_index)
	for i = 1, 3 do
		if i == selected_day_index then
			self:setTextColor("day_text_" .. i, Color( 168/255, 88/255, 36/255))
			self:setObjectVisible("day_img_"..i, true)
			self:setObjectVisible("day_red_point_"..i, false)
		else
			self:setTextColor("day_text_" .. i, Color( 244/255, 222/255, 156/255))
			self:setObjectVisible("day_img_"..i, false)
			self:setObjectVisible("day_red_point_"..i, main_data_tag.status_data.can_receive["day_" .. i] == 1)
		end
	end
	self:updateDayInfoReward()
	self:setObjectVisible("get_reward_btn", main_data_tag.status_data.is_buy == 1 or self.m_model:isInShowTime() == true)
	self:setTextByLanKey("get_reward_btn_text", "limited_hero_00" .. (main_data_tag.status_data.can_receive["day_" .. selected_day_index] + 3))
end

function M:updateDayInfoReward()
	local selected_tag_index = self.m_model:getSelectedTagIndex()
	local selected_day_index = self.m_model:getSelectedDayIndex()
	local main_data_tag = self.m_model:getMainData(selected_tag_index)
	local reward_data = main_data_tag.cfg["day_" .. selected_day_index]
	local receive_flag = main_data_tag.status_data.can_receive["day_" .. selected_day_index] == 1
	
	UIUtil.destroyAllChild(self.reward_grid.transform)
	for k, v in pairs(reward_data) do
		local item = GameUtil:createItemElement(v, true, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		UIUtil.setObjectVisible(item.transform, receive_flag, "duigoudi_img")
	end
end

function M:setSpine(hero_reward)
	if hero_reward then
		local cfg = ConfigManager:getHeroSkinCfg(hero_reward)
		if cfg then
			local icon = cfg.hero_spine
			if self.cacheSpineName == icon then
				return
			else
				self.cacheSpineName = icon
			end
			local play_img = self:findGameObject("hero_sk")
			GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
			return
		end
	end
	local hero_sk = self:findGameObject("hero_sk")
	GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/hero_0105_SkeletonData", "idle", 0, true)
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts, 999)
		self:setTextByLanKey("time_down_text", text)
	else
		self:updateMsg(99999)
	end
end

return M