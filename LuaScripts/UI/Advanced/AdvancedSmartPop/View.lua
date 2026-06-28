local M = class("AdvancedSmartPopView",LikeOO.OOPopBase)

M.m_uiName = "Advanced/AdvancedSmartPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "advanced_str_0009")
	self:setTextByLanKey("tips_text", "advanced_str_0017")
	self:setTextByLanKey("yes_text", "new_str_0315")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
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
				self:refreshOneListCell(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "select_btn" then
					self.m_model:changeSelect(index)
					local image = click_object.transform:Find("select_image")
					image.gameObject:SetActive(self.m_model.m_list_data[index].selected)
				end
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:refreshOneListCell(obj, index)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local material_image = luaBehaviour:FindGameObject("material_image")
	local hero_panel = luaBehaviour:FindGameObject("hero_panel")
	local newhero_panel = luaBehaviour:FindGameObject("newhero_panel")
	

	UIUtil.destroyAllChild(material_image.transform)
	UIUtil.destroyAllChild(hero_panel.transform)
	UIUtil.destroyAllChild(newhero_panel.transform)

	local data = self.m_model.m_list_data[index]
	obj.transform:Find("select_btn/select_image").gameObject:SetActive(data.selected)
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(data[1])
	if cfg == nil and GameUtil then
		GameUtil:sendLuaError("advancedSmartPop", "UserDataManager.hero_data:getHeroDataById(data[1]) cfg = nil data[1] = " .. data[1])
	end
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cfg.id, 1, data[1]})
	local heroIcon = CommonUIUtil:createHeroElementByData(itemData)
	heroIcon.transform:SetParent(hero_panel.transform, false)
	UIUtil.setScale(heroIcon.transform, 0.7)

	itemData.quality = itemData.quality + 1
	heroIcon = CommonUIUtil:createHeroElementByData(itemData)
	local new_hero = table.copy(heroData)
	new_hero.evo = new_hero.evo + 1
	CommonUIUtil:updateHeroLvByData(heroIcon, new_hero)
	heroIcon.transform:SetParent(newhero_panel.transform, false)
	UIUtil.setScale(heroIcon.transform, 0.7)
	
	for i,v in ipairs(data[2]) do
		heroData, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if heroData and cfg then
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cfg.id, 1, v})
			heroIcon = CommonUIUtil:createHeroElementByData(itemData)
			heroIcon.transform:SetParent(material_image.transform,false)
			UIUtil.setScale(heroIcon.transform, 0.7)
		end
	end
end

return M