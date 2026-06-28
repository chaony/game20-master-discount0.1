local M = class("WorldMiniMapView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMiniMap"
M.m_size_type = 2

function M:onEnter()
	self.map_area_table = self.m_model:getMapAreaCfg()

	self.m_cur_head_node = self:findGameObject("hero_head")
	self.m_cur_head_node_rect = self.m_cur_head_node:GetComponent("RectTransform")
	self.regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	--local bg_img = self:findGameObject("bg_img")
	--local bg_scale = self.m_control.m_view.m_bg_scale_w
	--UIUtil.setLocalScale(bg_img.transform, bg_scale, bg_scale)
	--local map_scroll_view = self:findGameObject("map_scroll_view")
	--local scroll_rect = UIUtil.findScrollRect(map_scroll_view)
	--local view_rt = scroll_rect.content.rect
	--local height = view_rt.height*bg_scale
	--local size_delta = scroll_rect.content.sizeDelta
	--scroll_rect.content.sizeDelta = Vector2.New(size_delta.x, height)
	self:refreshUI()
end

function M:refreshText()
	if self.cur_map == nil then
		self:setTextByLanKey("title_left_text", "new_str_0521")
		self:setTextByLanKey("title_right_text", "new_str_0521")
		self:setTextByLanKey("map_btn_text", self.map_area_table[self.m_model.map_id].name)
	else
		self:setTextByLanKey("title_left_text", self.cur_map.name)
		self:setTextByLanKey("title_right_text", self.cur_map.name)
		self:setTextByLanKey("map_btn_text", "new_str_0596")
	end
end

function M:refreshHead()
	local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(avatar))
	if cfg then
		self:setImg(cfg.icon, "hero_head_ui", "head_icon_img")
	else
		self:setImg("item_icon_wenhao", "item_icon", "head_icon_img")
	end
end

function M:refreshUI()
	self.cur_map = self.map_area_table[self.m_model.map_id]
	
	self:refreshText()
	self:refreshHead()

	if self.cur_map == nil then
		--if self.mapItems ~= nil then
		--	for k,v in pairs(self.mapItems) do
		--		v:SetActive(false)
		--	end
		--end
		if self.mapBrand ~= nil then
			self.mapBrand:SetActive(false)
		end
		--self:setTexture("bg_img", "Texture/a_ui_jianghu_shijieditu", "texture_a_ui_jianghu_shijieditu")
		local bg_img = self:findImage("bg_img")
		GameUtil:updateResourcesImg(bg_img, "Texture/a_ui_jianghu_shijieditu")
		local enter_map = UserDataManager.local_data:getUserDataByKey("enter_map_list", {})
		for k,v in pairs(self.map_area_table) do
			local map_area_item = self:findGameObject("map_area_" .. k)
			local encounter = self.m_model:getEncounterMapEventData(k)
			if map_area_item then
				map_area_item:SetActive(true)

				local unlock = v.unlock
				local open_flag, tips_str = GameUtil:getStageUnlock(unlock)
				local luaBehaviour = UIUtil.findLuaBehaviour(map_area_item)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(v.name))
				LuaBehaviourUtil.setText(luaBehaviour, "complete_text", "0".."%")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "qiyu_img", #encounter > 0)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "complete_bg", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sect_btn_point_img", false)

				if open_flag then
					LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", GlobalConfig.COMMON_COLLOR.COMMON_4)
					LuaBehaviourUtil.setImg(luaBehaviour,"a_ui_currency_jianghu_ditudiming", "area_bg_img", "main_ui")

					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "isNew_img", enter_map[k] ~= 1)

					self.m_cur_head_node:SetActive(true)

					if k == self.m_model.map_id then
						local localPosition = map_area_item.transform.localPosition
						UIUtil.setLocalPosition(self.m_cur_head_node.transform, localPosition.x - 55, localPosition.y, localPosition.z)
					end
				else
					LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", GlobalConfig.COMMON_COLLOR.COMMON_8)
					LuaBehaviourUtil.setImg(luaBehaviour,"a_ui_currency_jianghu_ditudimingsuo", "area_bg_img", "main_ui", "area_bg_img")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "isNew_img", false)
					UIUtil.setButtonClick(map_area_item.transform, function(trans, data)
						GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
					end, {}, "click_btn")
				end
			end
		end
	else		
		local imgPath = self.map_area_table[self.m_model.map_id].map_resources
		--self:setTexture("bg_img", "Texture/"..imgPath, "texture_"..imgPath)
		local bg_img = self:findImage("bg_img")
		GameUtil:updateResourcesImg(bg_img, "Texture/"..imgPath)
		self.area = self:findGameObject("Area"..self.m_model.map_id)
		for k,v in pairs(self.map_area_table) do
			self:setObjectVisible("map_area_" .. k, false)
		end
		self.map_area = CS.WorldCamera.Inst.Area_check
		--self.ui_area = self.area:GetComponent("AreaCheck")
		local left_top = self.area.transform:Find("Left_Top")
		self.left_top = left_top:GetComponent("RectTransform").anchoredPosition3D
		local right_bottom = self.area.transform:Find("Right_Bottom")
		self.right_bottom = right_bottom:GetComponent("RectTransform").anchoredPosition3D

		local x = GlobalTools:ToFloat(SceneManager.curScene.playerHelperArr[1])
		local y = GlobalTools:ToFloat(SceneManager.curScene.playerHelperArr[2])
		local z = GlobalTools:ToFloat(SceneManager.curScene.playerHelperArr[3])
		self:refreshHeroPos({x = x, y = y, z = z})

		if self.mapBrand == nil then
			local eventInfoData = ConfigManager:getCfgByName("worldsceneevent_info")

			self.mapBrand = ResourceUtil:GetUIItem("WorldMap/WorldMiniMap/worldMapBrand"..self.m_model.map_id, self.content_node, "ui_prefabs")
			self.m_cur_head_node_rect:SetAsLastSibling()
			local rect = self.mapBrand:GetComponent("RectTransform")
			rect.anchoredPosition3D = Vector3.New(0,0,0)
			for k,v in pairs(eventInfoData) do
				if v.sceneName == self.m_model.map_id and (v.type == 1 or v.type == 0) then
					local brand = self.mapBrand.transform:Find(tostring(k))
					local open, condition = self.m_model:checkMapOpen(k)
					if open == true then
						brand.gameObject:SetActive(true)
						local luaBehaviour = brand:GetComponent("LuaBehaviour")
						if luaBehaviour ~= nil then
							LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", self.regional_map_cfg[k].name)
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "complete_bg", false)
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sect_btn_point_img", false)

							if open then
								LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", GlobalConfig.COMMON_COLLOR.COMMON_4)
								LuaBehaviourUtil.setImg(luaBehaviour,"a_ui_currency_jianghu_ditudiming", "area_bg_img", "main_ui")
							else
								LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", GlobalConfig.COMMON_COLLOR.COMMON_8)
								LuaBehaviourUtil.setImg(luaBehaviour,"a_ui_currency_jianghu_ditudimingsuo", "area_bg_img", "main_ui", "area_bg_img")
							end

							UIUtil.setButtonClick(brand, function(trans, data)
								if open then
									SceneManager.curScene:transPointPoint(data.id)
									self.m_control:closeView()
								else
									local open, tips_str = GameUtil:getStageUnlock(condition)
									GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
								end

							end, {id = k}, "click_btn")
						end
					else
						brand.gameObject:SetActive(false)
					end
				end
			end
			--self.mapItems = {}
			--for k,v in pairs(eventInfoData) do
			--	if v.type == 1 or v.type == 0 then
			--		local mapItem = ResourceUtil:GetUIItem("WorldMap/worldMiniMapItem", self.content_node, "ui_prefabs")
			--		table.insert(self.mapItems, mapItem)
			--
			--		mapItem.name = v.name
			--		local luaBehaviour = mapItem:GetComponent("LuaBehaviour")
			--		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", v.languageKey)
			--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "complete_bg", false)
			--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "isNew_img", false)
			--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "qiyu_img", false)
			--
			--		local building = SceneManager.curScene.buildings[k]
			--		if building ~= nil then
			--			local rect = mapItem:GetComponent("RectTransform")
			--			rect.anchoredPosition3D = self:calculatePos(building.position)
			--		end
			--	end
			--end
		else
			--for k,v in pairs(self.mapItems) do
			--	v:SetActive(true)
			--end
			if self.mapBrand ~= nil then
				self.mapBrand:SetActive(true)
			end
		end
	end
end

function M:refreshHeroPos(data)
	local pos = self:calculatePos(Vector3.New(data.x, data.y, data.z))
	if pos.y < -302 then
		pos.y = -302
	end
	if pos.y > 241 then
		pos.y = 241
	end
	if pos.x < -514 then
		pos.x = -514
	end

	if pos.x > 500 then
		pos.x = 500
	end
	self.m_cur_head_node_rect.anchoredPosition3D = pos
end

function M:calculatePos(pos)
	local ui_pos = Vector3.New(0,0, 0)
	ui_pos.y = (pos.z - self.map_area.bottom)/(self.map_area.top - self.map_area.bottom) * (self.left_top.y - self.right_bottom.y) + self.right_bottom.y
	ui_pos.x = (pos.x - self.map_area.right)/(self.map_area.left - self.map_area.right) * (self.left_top.x - self.right_bottom.x) + self.right_bottom.x
	return ui_pos
end

function M:destroy()
	M.super.destroy(self)
	--if self.mapItems ~= nil then
	--	for k,v in pairs(self.mapItems) do
	--		ResourceUtil:ReturnItem(v)
	--	end
	--	self.mapItems = {}
	--end
	if self.mapBrand ~= nil then
		ResourceUtil:ReturnItem(self.mapBrand)
		self.mapBrand = nil
	end
end

return M