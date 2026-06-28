local M = class("WorldMapCompleteView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapComplete"
M.m_size_type = 2

function M:onEnter()
	self.map_area_table = self.m_model.map_area_cfg
	self.eventInfoData = ConfigManager:getCfgByName("worldsceneevent_info")
	self.regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	self.mapBrands = {}
	self:setTextByLanKey("common_title_text", "worldMap_str_006")
	self:refreshUI()
end

function M:refreshUI()
	self:updateEventLoopScroll()
	local imgPath = self.map_area_table[self.m_model.select_id].complete_resources
	local bg_img = self:findImage("bg_img")
	--self:setTexture("bg_img", "Texture/"..imgPath, "texture_"..imgPath)
	GameUtil:updateResourcesImg(bg_img, "Texture/"..imgPath)
	if self.mapBrands[self.m_model.select_id] == nil then
		for k,v in pairs(self.mapBrands) do
			v:SetActive(false)
		end
		self.mapBrand = ResourceUtil:GetUIItem("WorldMap/WorldMapComplete/worldMapComplete"..self.m_model.select_id, self.content_node, "ui_prefabs")
		self.mapBrands[self.m_model.select_id] = self.mapBrand
		if self.mapBrand ~= nil then
			local rect = self.mapBrand:GetComponent("RectTransform")
			rect.anchoredPosition3D = Vector3.New(0,0,0)
		end
	else
		self.mapBrand = self.mapBrands[self.m_model.select_id]
		for k,v in pairs(self.mapBrands) do
			v:SetActive(k == self.m_model.select_id)
		end	
	end

	if self.mapBrand ~= nil then
		for k,v in pairs(self.eventInfoData) do
			if v.sceneName == self.m_model.select_id and (v.type == 1 or v.type == 0) then
				local brand = self.mapBrand.transform:Find(tostring(k))
				if brand ~= nil then
					local open_flag, pre_task_end, tips_str = SceneManager.curScene:checkMapOpen(k)

					if open_flag == true then
						brand.gameObject:SetActive(true)
						local luaBehaviour = UIUtil.findLuaBehaviour(brand)
						if luaBehaviour ~= nil then
							local cpd, status = self.m_model:getMapCpd(self.m_model.select_id, k)
							local totalMapCount = self.regional_map_cfg[k].scene
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_btn", false)
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "area_img", true)
							--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", self.regional_map_cfg[k].name)

							UIUtil.setButtonClick(brand, function(trans, data)
								if pre_task_end == true then
									--local status = data.status
									--if status == 1 then
									--	local function netCallback(response)
									--		self:refreshUI()
									--		self.m_control:updateMsg("refreshUI", {}, "WorldMap.WorldMapComplete")
									--		RewardUtil:rewardTipsByData(response.reward)
									--	end
									--	local params = {area_id = self.m_model.select_id, scene_id = k}
									--	self.m_model:getNetData("big_map_receice_scene_cpd", params, netCallback)
									--else
										self:updateMsg("openWorldTaskReward", {area_id = self.m_model.select_id, scene_id = data.id})
									--end
								else
									audio:SendEvtUI("Play_UI_Notice")
									GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
								end
							end, {id = k, status = status, cell_data = {cfg = self.regional_map_cfg[k]}}, "click_btn")

							LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "complete_text", "new_str_0606")
							LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cpd_text", cpd.."/"..totalMapCount)
							if cpd >= totalMapCount then
								LuaBehaviourUtil.setTextColor(luaBehaviour, "cpd_text", Color( 0/255, 255/255, 0/255))
							else
								LuaBehaviourUtil.setTextColor(luaBehaviour, "cpd_text", Color( 255/255, 255/255, 0/255))
							end
						end
					else
						brand.gameObject:SetActive(false)
					end
				end
			end
		end
	end
end



function M:updateEventLoopScroll()
	local data = self.m_model:getAreaData()

	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_map", {id = cell_data.mapId})
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "area_text", cell_data.mapName)
	if self.m_model:checkAreaOpen(cell_data.mapId) then
		if self.m_model.select_id == cell_data.mapId then
			LuaBehaviourUtil.setTextColor(luaBehaviour, "area_text", GlobalConfig.COMMON_COLLOR.COMMON_6)
			LuaBehaviourUtil.setImg(luaBehaviour, "area_img", "a_ui_currency_yeqian_h_s", "common_ui")
		else
			LuaBehaviourUtil.setTextColor(luaBehaviour, "area_text", GlobalConfig.COMMON_COLLOR.COMMON_7)
			LuaBehaviourUtil.setImg(luaBehaviour, "area_img", "a_ui_currency_yeqian_h_n", "common_ui")
		end
	else
		LuaBehaviourUtil.setImg(luaBehaviour, "area_img", "a_ui_currency_yeqian_h_n", "common_ui")
		LuaBehaviourUtil.setTextColor(luaBehaviour, "area_text", GlobalConfig.COMMON_COLLOR.COMMON_7)
	end
	--是否是当前场景
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cur_area", cell_data.mapId == SceneManager.curScene.sceneId)
end

function M:destroy()
	for k,v in pairs(self.mapBrands) do
		ResourceUtil:ReturnItem(v)
	end
	self.mapBrands = {}
	M.super.destroy(self)
end

return M