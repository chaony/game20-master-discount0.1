local M = class("WorldMapPlunderEnemyView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapPlunder_enemy"
M.m_iphoneXAdapter = true
M.m_size_type = 2


M.m_curGarrison_data = {}
M.last_obj = nil
M.cell_childList =nil


function M:onEnter()
	M.super.onEnter(self)

	self.hero_loopscroll = self:findGameObject("hero_loopscroll")
	self.enemy_loopscroll = self:findGameObject("enemy_loopscroll")


	self.overallAtk = self:findGameObject("overallAtk")
	--撤离按钮
	self.evacuate_btn = self:findGameObject("evacuate_btn")
	--惩戒按钮
	self.punishment_btn = self:findGameObject("punishment_btn")
	--一键派遣按钮
	self.dispatch_btn = self:findGameObject("dispatch_btn")

	--完成按钮
	self.accomplish_btn = self:findGameObject("accomplish_btn")

	self.evacuate_btn:SetActive(false)
	self.dispatch_btn:SetActive(false)
	self.accomplish_btn:SetActive(false)
	self.hero_loopscroll:SetActive(false)
	self.hero_loopscroll_active = false
	self.enemy_loopscroll:SetActive(true)
	self.enemy_loopscroll_active = true

	self.outputNode = self:findGameObject("outputNode")
	
end

function M:battle_end_initialUI()

	self.punishment_btn:SetActive(false)
	self.evacuate_btn:SetActive(true)
	self.dispatch_btn:SetActive(true)
	self.accomplish_btn:SetActive(true)
	self:setTextByLanKey("common_title_text", "驻守阵容")
	self.overallAtk:SetActive(true)
	local rect = self.outputNode:GetComponent("RectTransform")
	local pos = rect.anchoredPosition
	pos.y = -26
	rect.anchoredPosition = pos
	self.hero_loopscroll:SetActive(true)
	self.hero_loopscroll_active = true
	self.enemy_loopscroll:SetActive(false)
	self.enemy_loopscroll_active = false
	self:initialHeroData()
end




function M:refreshUI()
	local data = self.m_model:refreshPlunderListData()
	if self.hero_loopscroll_active then
		self:updatehero_LoopScroll()
	elseif self.enemy_loopscroll_active then
		self:updateLoopScroll(data)
	end

	
end

function M:updatehero_LoopScroll()

	local cell1 = self:findGameObject("cell1")

	self.cell_childList = cell1.transform:GetComponentsInChildren(typeof(U3DUtil:Get_Button()), true)
	if self.cell_childList ~= nil then
			for i = 0, self.cell_childList.Length - 1 do
				local ps = self.cell_childList[i]
				if ps ~= nil then
					UIUtil.setButtonClick(ps.transform, function(trans,params)
						self:updateMsg("cell_btn", {obj_trans = ps,params = params})
					end, nil, nil, self.m_uiName)

					--ps:Simulate(dt, false, false);
				end
			end
	end
end
function M:updateLoopScroll(show_data)
	self.m_cell_tab = {}
	local data = show_data
	if self.m_loop_scroll_view == nil then
		
		local loopscroll = self:findGameObject("enemy_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				self.m_cell_tab[index] = cell_object
				local data = cell_data

				local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cell_data.id, 1})
				-- CommonUIUtil:updateHeroLvByData(item_node, data.hero_data, true)
				local ui_element = CommonUIUtil:updateHeroElementByData(cell_object, itemData, nil , true)
			end,
			 ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		--self:runCellAnim()
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--一键派遣
function M:dispathHeroData(data)
	self.m_curGarrison_data = {}
    local atk_value = 0 
    local cur_Heros = {}

    local cur_Heros = self.m_model.cur_Garrison[self.m_model.cur_building_id]

    local heroIds = table.copy(UserDataManager.hero_data:getHerosId())

    heroIds = self.m_model:getAllHero(heroIds)
    for k,v in pairs(cur_Heros) do
		table.insert(heroIds,v)
	end
    local heroIds_atk = self.m_model:getAllHero_atk(heroIds) 
    self.m_model.m_curGarrison_team = {}

    
  
    local all_atk_heroTeam = 0
    	local all_atk_curTeam = 0
    	for k,v in pairs(cur_Heros) do
    		local hero_select_Data = UserDataManager.hero_data:getHeroDataById(v)
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
				
				local ps = self.cell_childList[i-1]
				if ps ~= nil then
					self.m_curGarrison_data[ps] = hero_Data
					atk_value = atk_value + hero_Data.attrs.atk
					 CommonUIUtil:updateHeroElementByData(ps.transform:Find("HeroNode"), itemData, nil , true,true)
				end
			 end
			  self:setTextByLanKey("atk_text", math.floor(atk_value))
		end
   
    
	
end

function M:initialHeroData()
	self.m_curGarrison_data = {}
	
	local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
	local function receivetCallback(response)
	    local atk_value = 0 
	    self.m_model.cur_buildingTeam_data = response
	    for k,v in pairs(response.station_list) do
	    	local cur_team = {}
	    	for kk,vv in pairs(v.team) do
	    		table.insert(cur_team,vv[1] )
	    	end
	    	self.m_model.cur_Garrison[v.building_id] = cur_team
			if v.building_id == self.m_model.m_params.cell_data.obj_id then

				for k1,v1 in pairs(v.team) do
					if self.m_model.m_curGarrison_team[k1] ~= v1 then
	        			table.insert(self.m_model.m_curGarrison_team,v1[1] )
	        		end
					local hero_Data = UserDataManager.hero_data:getHeroDataById(v1[1])
					local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_Data.id, 1})
					local ps = self.cell_childList[k1-1]
					if ps ~= nil then
						self.m_curGarrison_data[ps] = hero_Data
						atk_value = atk_value + hero_Data.attrs.atk
						CommonUIUtil:updateHeroElementByData(ps, itemData, nil , true,true)
					end
				end
			end
			self:setTextByLanKey("atk_text", math.floor(atk_value))
	    end
	end
	self.m_model:getNetData("big_map_plunder_station", nil, receivetCallback)
end


function M:setGarrisonUI( response,data )
	local hero_Data = UserDataManager.hero_data:getHeroDataById(response.oid)
	local atk_value = hero_Data.attrs.atk
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_Data.id, 1})
	local oid_new = string.split( response.oid,"-")
   for k1,v1 in pairs(self.m_curGarrison_data) do

   		local v1_oid_new = string.split( v1.oid,"-")
   		
   		

		atk_value = atk_value + v1.attrs.atk
   
		if k1 == data.obj_trans then
			atk_value = atk_value - v1.attrs.atk
   			--atk_value = atk_value + hero_Data.attrs.atk

			table.removebyvalue(self.m_model.m_curGarrison_team,v1.oid)
			
		end
		
		-- if v1_oid_new[1] == oid_new[1] then

		-- 	self.m_curGarrison_data[k1] = nil
		-- 	table.removebyvalue(self.m_model.m_curGarrison_team,v1.oid)
			
		-- 	CommonUIUtil:updateHeroElementAdd(k1,nil,true,nil)
		-- end

	end
	
	
    CommonUIUtil:updateHeroElementByData(data.obj_trans, itemData, nil , true,true)
    
    self.m_curGarrison_data[data.obj_trans] = hero_Data

    -- --设置总战力
	self:setTextByLanKey("atk_text", math.floor(atk_value))

	

	
	-- local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
    

        if table.nums(self.m_model.m_curGarrison_team) > 0 then
        	for k,v in pairs(self.m_model.m_curGarrison_team) do

	        	if v == response.oid then
	        		table.removebyvalue(self.m_model.m_curGarrison_team,v)
	        	end
        	end
        end

        table.insert(self.m_model.m_curGarrison_team,response.oid )
        self.m_model.cur_Garrison[self.m_model.cur_building_id] = self.m_model.m_curGarrison_team
		
		
		
end
function M:destroy()
	
    M.super.destroy(self)
end


return M