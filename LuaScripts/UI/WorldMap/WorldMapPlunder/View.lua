local M = class("WorldMapPlunderView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapPlunder_station"
M.m_iphoneXAdapter = true
M.m_size_type = 2
M.cell_childList = nil
local __TAB_BTN_NODE = {
	{btn_key = "message_btn", lua_name = "", btn_text = "message_btn_text", text_key = "new_str_0492", open = true, red_point = "message_red_point_img", red_point_id = 1002}, -- 驻地信息
	{btn_key = "details_btn", lua_name = "", btn_text = "details_btn_text", text_key = "new_str_0493", open = true, red_point = "details_red_point_img" }, -- 驻地详情
}

function M:onEnter()
	M.super.onEnter(self)
	self.message_btn_loopscroll = self:findGameObject("message_btn_loopscroll")
	self.details_btn_loopscroll = self:findGameObject("details_btn_loopscroll")
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("tab_click", k)
			end
		end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		self:setObjectVisible(v.red_point, false)
	end
end



function M:changeImg(img)
	
end


--界面切换页签
function M:switchTabForPlunderNode(index)
	self.m_model:refreshPlunderListData(index)
		
	self:switchTabNode(index)
	
end


function M:btnSetActive(messageActive,detailsActive)
	self.message_btn_loopscroll:SetActive(messageActive)
	self.details_btn_loopscroll:SetActive(detailsActive)
end

function M:switchTabNode(index)
	self.m_model.m_open_tab_index = index
	for k,v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_7
		local outline_width = index == k and 2 or 0
		UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_7, outline_width)
		local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
		self:setObjectVisible(v.red_point, red_flag == true)
	end
	local loopscroll_obj = nil
	if index == 1 then
		loopscroll_obj = "message_btn_loopscroll"
		self:btnSetActive(true,false)
		
	elseif index == 2 then
		loopscroll_obj = "details_btn_loopscroll"
		self:btnSetActive(false,true)
	end
	self.m_loop_scroll_view = nil
	self:updateLoopScroll(loopscroll_obj)
end


--驻地详情设置UI
function M:set_messageUi(obj,data )
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"atk_btn", false)
	local map_event_cfg = ConfigManager:getCfgByName("fort_info")
	local event_name = nil
	local event_des = nil
	
	for k,v in pairs(map_event_cfg) do
		if data.cell_data.building_id == tonumber(k) then
			event_name = v.name 
			event_des = v.des
		end
	end
	local event_des_text = Language:getTextByKey(data.cfg.event_des)

	local des = string.split(event_des_text, "}")

	if #des > 1 then
		local des_1 = string.split(des[1], "{")
		if event_des ~= nil then
			local des_text = Language:getTextByKey(event_des)
			local des_Value = des_1[1]..des_text..des[2]
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_mesg_text", des_Value )
		end
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_mesg_text", tostring(data.cfg.event_des) )
	end


	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_name_text", tostring(data.cfg.event_name) )


	--土匪袭击事件 打开攻击按钮
	if data.cell_data.type == 10 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"atk_btn", true)
	end

end
--[[
	创建列表
]]
--初始化队伍界面
function M:initialHeroData(data)
    for k,v in pairs(self.m_model.m_data.station_list) do
    	if data.building_id == v.building_id then
    		self.m_model.m_curGarrison_team = {}
    		for k1,v1 in pairs(v.team) do
           		self:initialHeroView(k1,v1[1],v.building_id)
           		
        	end
    	end   
    end
end

function M:updateLoopScroll(loopscroll_obj)
	self.m_cell_tab = {}
	local data = self.m_model.m_show_data
	self.m_select_index = -1
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject(loopscroll_obj)
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				self.m_cell_tab[index] = cell_object
				local data = cell_data
				local is_new = nil
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if loopscroll_obj == "message_btn_loopscroll" then
					self:set_messageUi(cell_object,cell_data)
				else
					local cell = cell_object.transform:Find("cell_1/herobtn_details")
					if cell ~= nil then
						self.cell_childList = cell.transform:GetComponentsInChildren(typeof(U3DUtil:Get_Button()), true)
						-- if self.cell_childList ~= nil then
						-- 	for i = 0, self.cell_childList.Length - 1 do
						-- 		local ps = self.cell_childList[i]
						-- 		if ps ~= nil then
						-- 			UIUtil.setButtonClick(ps.transform, function(trans,params)
						-- 				self:updateMsg("cell_btn", {obj_trans = ps,params = params})
						-- 			end, nil, nil, self.m_uiName)

						-- 			--ps:Simulate(dt, false, false);
						-- 		end
						-- 	end
						-- end
					end
					self:initialHeroData(cell_data)
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
					local name = luaBehaviour:FindText("eventName_text")--驻地名字
					name.text = Language:getTextByKey(cell_data.cfg.name)

				end
				

				if cell_data.cell_data ~= nil then
					is_new = cell_data.cell_data.is_new
				else
					is_new = cell_data.data.is_new
				end
				--新
				if is_new ~= nil then
					if is_new == 1 then
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"xin_img", true)
					else
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"xin_img", false)
					end
				end

				if self.m_select_index == index then
					self.m_select_cell = cell_object
				end
				
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if loopscroll_obj == "details_btn_loopscroll" then
					if click_name == "event_evacuate_btn" then
						local params =
						{
							on_ok_call = function(msg)
								--点击确定的处理！！
								
								local function netCallback(response)

									for k,v in pairs(cell_data.data.team) do
										table.removebyvalue(self.m_model.all_one_key_Herodata,v[1])
									end
									self.m_control:closeView()
									
								end
								local params = {}
								params.building_id = cell_data.building_id
								self.m_model:getNetData("big_map_plunder_evacuate", params, netCallback, nil,nil,GlobalConfig.POST)
							end,
							no_close_btn = false,
							text =string.format(Language:getTextByKey("worldMapPlunder_hint"),Language:getTextByKey(cell_data.cfg.name))
						}
						static_rootControl:openView("Pops.CommonPop", params)
					elseif click_name == "event_dispatch_btn" then
						
						self:updateMsg("event_dispatch_btn",{cell_data = cell_data,cell_object = cell_object})
						

					elseif click_name == "event_confirm_btn" then
						
						self:updateMsg("event_confirm_btn",{cell_data = cell_data})
					else

						self:updateMsg("select_Item_click", {index = index, cell_data = cell_data})
					end
					
				elseif loopscroll_obj == "message_btn_loopscroll" then
					--掠夺按钮
					self:updateMsg("atk_btn",{item_cell_data = cell_data,index = index})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		--self:runCellAnim()
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:refreshRedPoint()

end

--一键派遣
function M:dispathHeroData(data)
    local atk_value = 0 
    local m_curGarrison_team = {}
    local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
    local heroIds = table.copy(UserDataManager.hero_data:getHerosId())

    local cur_Heros = data.cell_data.data.team

    local luaBehaviour = UIUtil.findLuaBehaviour(data.cell_object)
	self.m_model.cur_building_id = data.cell_data.data.building_id
	



    heroIds = self.m_model:getAllHero(heroIds)

	for k,v in pairs(cur_Heros) do
		table.insert(heroIds,v[1])
	end
    local heroIds_atk = self.m_model:getAllHero_atk(heroIds) 
    self.m_model.m_curGarrison_team = {}
	-- self.m_model.cur_building_id = data.cell_data.building_id 
	local cell_childList = nil
	local cell = data.cell_object.transform:Find("cell_1/herobtn_details")
	if cell ~= nil then
		cell_childList = cell.transform:GetComponentsInChildren(typeof(U3DUtil:Get_Button()), true)
	end


	
	local all_atk_heroTeam = 0
	local all_atk_curTeam = 0
	for k,v in pairs(cur_Heros) do
		local hero_select_Data = UserDataManager.hero_data:getHeroDataById(v[1])
		all_atk_heroTeam = all_atk_heroTeam + hero_select_Data.attrs.atk

	end

	for i=1,5 do
		local cur_select_Data = UserDataManager.hero_data:getHeroDataById(heroIds_atk[i])
		all_atk_curTeam = all_atk_curTeam + cur_select_Data.attrs.atk
	end

	if all_atk_heroTeam >= all_atk_curTeam then
		local params =
		{
			on_ok_call = function(msg)
					--点击确定的处理！！
			end,
			no_close_btn = false,
			text =Language:getTextByKey("worldMapPlunder_one_key")
		}
		static_rootControl:openView("Pops.CommonPop", params)
	else
		for i=1,5 do
			local hero_Data = UserDataManager.hero_data:getHeroDataById(heroIds_atk[i])
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_Data.id, 1})
						    	
			table.insert(self.m_model.m_curGarrison_team,hero_Data.oid )
			table.insert(self.m_model.all_one_key_Herodata,hero_Data.oid )
			self.m_model.cur_Garrison[self.m_model.cur_building_id] = self.m_model.m_curGarrison_team
			local ps = cell_childList[i-1]
			if ps ~= nil then
				 CommonUIUtil:updateHeroElementByData(ps.transform:Find("HeroNode"), itemData, nil , true,true)
			end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"event_dispatch_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"event_confirm_btn", true)
		end
	end
end
--初始化派遣队伍界面
function M:initialHeroView(i,data,building_id)
	if self.cell_childList ~= nil then
		
		local hero_Data = UserDataManager.hero_data:getHeroDataById(data)
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_Data.id, 1})

		local ps = self.cell_childList[i-1]
		if ps ~= nil then
					-- atk_value = atk_value + hero_Data.attrs.atk
			CommonUIUtil:updateHeroElementByData(ps.transform:Find("HeroNode"), itemData, nil , true,true)
		end
		table.insert(self.m_model.m_curGarrison_team,data )
		table.insert(self.m_model.all_one_key_Herodata,data )
		self.m_model.cur_building_id = building_id
		self.m_model.cur_Garrison[self.m_model.cur_building_id] = self.m_model.m_curGarrison_team
	end
	
end

function M:setGarrisonUI( response,data )
	local hero_Data = UserDataManager.hero_data:getHeroDataById(response.oid)
	local atk_value = hero_Data.attrs.atk
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_Data.id, 1})
	
 --   for k1,v1 in pairs(self.m_curGarrison_data) do

 --   		if k1 == data.obj_trans then
	-- 		table.removebyvalue(self.m_model.m_curGarrison_team,v1.oid)
	-- 	end

	-- 	atk_value = atk_value + v1.attrs.atk
	-- 	if v1.oid == response.oid then

	-- 		self.m_curGarrison_data[k1] = nil

			
	-- 		CommonUIUtil:updateHeroElementAdd(k1,nil,true,true)
	-- 	end

	-- end
	
	
    CommonUIUtil:updateHeroElementByData(data.obj_trans, itemData, nil , true,true)
    
    -- self.m_curGarrison_data[data.obj_trans] = hero_Data

    -- --设置总战力
	--self:setTextByLanKey("atk_text", math.floor(atk_value))

	

	
	local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
    

        if table.nums(self.m_model.m_curGarrison_team) > 0 then
        	for k,v in pairs(self.m_model.m_curGarrison_team) do

	        	if v == response.oid then
	        		table.removebyvalue(self.m_model.m_curGarrison_team,v)
	        	end
        	end
        end
		table.insert(self.m_model.m_curGarrison_team,response.oid )
		
end


function M:destroy()

    M.super.destroy(self)
end


return M