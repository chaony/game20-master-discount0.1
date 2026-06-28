local M = class("BudoServerSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "BudoServer/BudoServerSelectPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self.progress_slider = self:findSlider("progress_slider")
	self.receive_btn_img = self:findImage("receive_btn")
	self.receive_btn = self:findButton("receive_btn")
	self.receive_hui = self:findImage("receive_hui")
	self.name_text = self:findGameObject("name_text")
	self.progress_slider_text = self:findGameObject("progress_slider_text")
	self.receive_text = self:findGameObject("receive_text")
	self.reward_node = self:findGameObject("reward_node")
	self:setTextByLanKey("name_hou","world_str_009")
	self:refreshUI()

end
M.N_COLOR = Color( 112/255,112/255, 110/255)
M.S_COLOR = Color( 81/255, 99/255, 145/255)



function M:refreshUI()
	self:refreshQuestMain()
	self:setTextByLanKey("btn_text_0","world_str_009")
	self:setTextByLanKey("close_title_text","world_str_010")
	self.m_gray_image = self:findImage("gray_image")
	local tower_floor = UserDataManager.tower_floor or 0
	self:setTextByLanKey("main_floor", "budo_str_001", tower_floor)
	local c_race_data1 = GlobalConfig.TYPE_HERO_RACE[1]
	local c_race_data2 = GlobalConfig.TYPE_HERO_RACE[2]
	local c_race_data3 = GlobalConfig.TYPE_HERO_RACE[3]
	local c_race_data4 = GlobalConfig.TYPE_HERO_RACE[4]
	self:setTextByLanKey("btn_text_1",c_race_data1.name)
	self:setTextByLanKey("btn_text_2",c_race_data2.name)
	self:setTextByLanKey("btn_text_3",c_race_data3.name)
	self:setTextByLanKey("btn_text_4",c_race_data4.name)
	self:setTextByLanKey("title_text","world_str_010")
	local tab_tower = ConfigManager:getCfgByName("tower_race")
	for i = 1, 4 do
		local race_data = GlobalConfig.TYPE_HERO_RACE[i]
		local race_name = self:findText("rank_name_text_"..i)
		local open_time = self:findText("show_time_"..i)
		local floor_num = self:findText("floor_num_"..i)
		local item_node = self:findImage( "item_node_"..i)
		local item_img = self:findImage( "item_img_"..i)
		--local rank = self:findImage( "rank_"..i)
		self:setImg(race_data.race_icon, ResourceUtil:getLanAtlas(), "race_"..i)
		race_name.text = Language:getTextByKey(tab_tower[i].name)
		open_time.text = self.m_model:getOpenTimeByIndex(i)
		floor_num.text = self.m_model:getFloorByIndex(i)
		local open_bl = self.m_model:checkIsOpen(i)
        open_time.color = self.S_COLOR
		--rank.material = nil
		item_node.material = nil
		item_img.material = nil
		--self:setObjectVisible("open_time_"..i, open_bl == false)
		if open_bl == false then
			if open_time then
                open_time.color = self.N_COLOR
            end
			--rank.material = self.m_gray_image.material  
			item_node.material = self.m_gray_image.material  
			item_img.material = self.m_gray_image.material 
		end
		local race_red_point = RedPointUtil:race_tower_reward(i)
		local once_red_point = RedPointUtil:checkTowerOnceOpen(i)
		if open_bl == true then
			self:setObjectVisible("race_red_point_"..i, race_red_point == true or once_red_point == true )
		else
			self:setObjectVisible("race_red_point_"..i, false )
		end
	end
	local tower_red_point = RedPointUtil:isFuncRedPointById(164)
	self:setObjectVisible("tower_red_point", tower_red_point == true)

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:setHeigth()

end

--刷新主线任务
function M:refreshQuestMain()
	local main_quest = self.m_model:getMainQuests()
	self.progress_slider.gameObject:SetActive(true)
	self.receive_btn_img.gameObject:SetActive(true)
	self.name_text:SetActive(true)
	self.progress_slider_text:SetActive(true)
	self.receive_text:SetActive(true)
	self.reward_node:SetActive(true)
	if #main_quest > 0 then
		for i, v in ipairs(main_quest) do
			if v.status ~= nil and v.status.status ~= nil and v.data ~= nil and v.status.status < 2 then
				self:setTextByLanKey("name_text",v.data.name2)--"后可领取"
				local num = 0
				for i = 1, 4 do
					local floor_num =  UserDataManager:getRaceFloorByRace(i or 0)
					if floor_num >= v.data.target_value then
						num = num + 1
					end
				end
				local slider_text= Language:getTextByKey("new_str_0471",num,4)
				self:setTextByLanKey("progress_slider_text",slider_text)
				local slider_value = num/4
				self.progress_slider.value = slider_value
				local reward_node = self:findGameObject("reward_node")
				GameUtil:createRewards(reward_node.transform,v.data.drop,true,true,nil,1)
				self.m_model.main_quest_id = v.id
				if slider_value < 1 then --未完成
					self.receive_btn.interactable = false
					self.receive_btn_img.material = self.receive_hui.material
				elseif slider_value == 1 then --已完成未领取
					self.receive_btn.interactable = true
					self.receive_btn_img.material = nil
				end
				return
			end
		end
	else
		self.progress_slider.gameObject:SetActive(false)
		self.receive_btn_img.gameObject:SetActive(false)
		self.name_text:SetActive(false)
		self.progress_slider_text:SetActive(false)
		self.receive_text:SetActive(false)
		self.reward_node:SetActive(false)
	end
	
end

return M