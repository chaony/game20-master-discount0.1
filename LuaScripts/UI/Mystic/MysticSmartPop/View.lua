local M = class("MysticSmartPopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticSmartPop"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_evolution_type == 1 then
		self:setTextByLanKey("common_title_text", "mystic_str_0004")
	else
		self:setTextByLanKey("common_title_text", "mystic_str_0014")
	end
	
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
				self:refreshOneListCell(cell_object, data, index)
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

function M:refreshOneListCell(obj, data, index)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")

	for i,v in ipairs(data) do
		local one_data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, one_data.id, one_data.evo, oid = v})
		local icon = luaBehaviour:FindGameObject("solt_" .. i)
		GameUtil:updateItemElementByData(icon, itemData, false, false)
	end

	local one_data, cfg = UserDataManager.mystic_data:getMysticDataById(data[1])
	
	local icon = luaBehaviour:FindGameObject("new_icon")
	local suiji_img = luaBehaviour:FindGameObject("suiji_img")
	if self.m_model.m_evolution_type == 1 then
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, one_data.id, one_data.evo + 1})
		GameUtil:updateItemElementByData(icon, itemData, false, false)
		suiji_img:SetActive(false)
	else
		 GameUtil:updateItemElementNoData(icon, RewardUtil.REWARD_TYPE_KEYS.MYSTIC)
        local luaBehaviour = icon:GetComponent("LuaBehaviour")
        local quality_item = GlobalConfig.QUALITY_MYSTIC_SETTING[one_data.evo + 1] or GlobalConfig.QUALITY_MYSTIC_SETTING[1]
        LuaBehaviourUtil.setImg(luaBehaviour,"no_quality_img", quality_item.frame_name, "equip_icon")
        --local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
        suiji_img:SetActive(true)
        local add_img = luaBehaviour:FindGameObject('add_img')
        add_img:SetActive(false)
	end
end

return M