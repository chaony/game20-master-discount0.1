local M = class("WorldMapRewardNewView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapReward/WorldMapReward"
M.m_iphoneXAdapter = true
M.m_size_type = 2
M.cell_childList = nil
local __TAB_BTN_NODE = {
	{btn_key = "person_btn", lua_name = "", btn_text = "person_btn_text", text_key = "new_str_0495", open = true, red_point = "message_red_point_img", red_point_id = 1002}, -- 驻地信息
	{btn_key = "underworld_btn", lua_name = "", btn_text = "underworld_btn_text", text_key = "new_str_0494", open = true, red_point = "details_red_point_img" }, -- 驻地详情
}
local TEST_TASK_LIST ={}

function M:onEnter()
	M.super.onEnter(self)
	-- self.message_btn_loopscroll = self:findGameObject("message_btn_loopscroll")
	-- self.details_btn_loopscroll = self:findGameObject("details_btn_loopscroll")
	--  self.m_toggle_btns = {}
	-- for k,v in pairs(__TAB_BTN_NODE) do
	-- 	self:setTextByLanKey(v.btn_text, v.text_key)
	-- 	local tog_btn = self:findToggle(v.btn_key)
	-- 	tog_btn.gameObject:SetActive(v.open)
	-- 	self.m_toggle_btns[k] = tog_btn
	-- 	UIUtil.addToggleListener(tog_btn, function(is_on)
	-- 		if is_on then
	-- 			self:updateMsg("tab_click", k)
	-- 		end
	-- 	end,nil,self.m_uiName)
	-- 	if k == self.m_model.m_open_tab_index then
	-- 		tog_btn.isOn = true
	-- 	end
	-- 	self:setObjectVisible(v.red_point, false)
	-- end

	
	self.opensend_btn = self:findGameObject("opensend_btn")
	self.m_loopScroll = LoopScrollUtil.new()
	local tiwn_tog_btn = self:findToggle("person_btn")
    local team_tog_btn = self:findToggle("underworld_btn")
	UIUtil.addToggleListener(tiwn_tog_btn, function(is_on) self:switchTabUpdate(is_on, "tiwn_tog") end, nil, self.m_uiName)
	UIUtil.addToggleListener(team_tog_btn, function(is_on) self:switchTabUpdate(is_on, "team_tog") end, nil, self.m_uiName)
	tiwn_tog_btn.isOn = true


	self:refreshUI()	
end

function M:refreshUI()
	self:setText("reset_btn_text","刷新")
	self:setText("aid_btn_text","我的外援")
	self:setText("tog_1_text","个人悬赏")
	--self:setText("tog_2_text","师徒悬赏")
	self:setTextByLanKey("common_title_text","new_str_0399")
	self:setTextByLanKey("offer_lv_text", "new_str_0075", self.m_model.bounty_lv)--当前等级
	self:setObjectVisible("tog1_hint",false)	
	self:setObjectVisible("tog2_hint",false)	
end

function M:setLoopScrollOffset(ismove)
	if self.m_loop_scroll_view ~= nil then
		local get_value = self.m_loop_scroll_view:getContentOffset()
		local v = get_value
		if ismove == true then
			v.x = get_value.x - 20
		elseif ismove == false then
			v.x = get_value.x + 20
		end
		v.y = 0
		self.m_loop_scroll_view:setContentOffset(v)
	end
	
end


function M:refreshTask(data)
	local pos = self.m_loop_scroll_view:getContentOffset()
	self:refreshUI()
	self:updateLoopScroll(data)
	if data then
		self.m_loop_scroll_view:setContentOffset(pos)
	end
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

--切换页签
function M:seleteTag(index)
	self:setResetTim()
	self:updateLoopScroll()
	local tog_1_text = self:findText("person_btn_text")
	local tog_2_text = self:findText("underworld_btn_text")

	
	tog_1_text.color = index == 1 and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_7
	tog_2_text.color = index == 2 and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_7

	if index == 1 then
		self:setObjectVisible("reset_btn",true)	
	elseif index == 2 then
		self:setObjectVisible("reset_btn",false)	
	end
end

function M:updateLoopScroll(cell_send_data)
	local data = self.m_model:getTaskList()

	TEST_TASK_LIST = {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:setTaskCell(cell_data,cell_object)
				table.insert(TEST_TASK_LIST, {data = cell_data, obj = cell_object})
				if index == 1 then
					self.m_guide_cell = cell_object
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "opensend_btn" then
					self:updateMsg("open_send", {reward = cell_data.data.reward , id = cell_data.id,cell_data = cell_data,lifetime = self.lifetime_text } )
				end
				if click_name == "reward_btn" then
					self:updateMsg("get_reward", cell_data.id)
				end
				if click_name == "chakan_btn" then
					self:updateMsg("chakan_btn", {cell_data = cell_data} )
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		
		self.m_loop_scroll_view:reloadData(data,true)
	end
	if #data > 0 then
		self:setObjectVisible("nil_caneqp",false)
	else
		self:setObjectVisible("nil_caneqp",true)
	end
end
M.lifetime_text = nil
function M:setTaskCell(task,obj,cell_send_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local name = luaBehaviour:FindText("offer_name_text")--任务名字
	name.text = Language:getTextByKey(task.cfg.name)
	local data = GlobalConfig.BOUNTY_RANK[task.cfg.rank]
	--name.color = data.RGBA
	--任务奖励
	local drop = task.data.reward or {}
	local reward_node = luaBehaviour:FindGameObject("reward_obj") 
	UIUtil.destroyAllChild(reward_node.transform)
	local rewadd_item = GameUtil:createItemElement(drop[1], true, true, nil)
	rewadd_item.transform:SetParent(reward_node.transform, false)
	local item_luaBehaviour = UIUtil.findLuaBehaviour(rewadd_item)
	if UserDataManager.active_double_id ~= 0 and item_luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour,"double_earn", true)
	end 
	--local count_text = luaBehaviour:FindText("count_text")
	local tim_text = luaBehaviour:FindText("time_text")
	--local slider = luaBehaviour:FindGameObject("slider")
	--local doing_img = luaBehaviour:FindGameObject("doing_img")
	local fill = luaBehaviour:FindImage("Fill")
	local reward_btn = luaBehaviour:FindGameObject("reward_btn")
	local opensend_btn = luaBehaviour:FindGameObject("opensend_btn")
	--local send_btn = luaBehaviour:FindGameObject("send_btn")
	local life_time_text = luaBehaviour:FindText("life_time_text") 
	local finish_bg = luaBehaviour:FindGameObject("finish_bg")

	local des_text = luaBehaviour:FindText("des_text")
	des_text.gameObject:SetActive(true)
	--count_text.gameObject:SetActive(false)
	tim_text.gameObject:SetActive(false)
	life_time_text.gameObject:SetActive(false)
	--slider:SetActive(false)
	reward_btn:SetActive(false)
	--send_btn:SetActive(false)
	--doing_img:SetActive(false)

	
	local finish_bg = luaBehaviour:FindGameObject("finish_bg")
			
	finish_bg:SetActive(false)

	des_text.text = Language:getTextByKey(task.cfg.text)

	--任务状态
	if task.data.quest_status == 0 then --未派遣
		opensend_btn:SetActive(true)
		local tim = GameUtil:formatTimeBySecond(task.cfg.duration_time*60)
		--count_text.text = Language:getTextByKey("new_str_0123")..tim
		life_time_text.text = self.m_model:checkDeadTime(task.data.expire_ts) 
		life_time_text.gameObject:SetActive(true)
		--count_text.gameObject:SetActive(true)
		if self.m_model.cur_type == 2 then
			--send_btn:SetActive(not self.m_model:chechMasterStatue())
		else
			--send_btn:SetActive(true)
		end
	elseif task.data.quest_status == 1 then --派遣中
		opensend_btn:SetActive(false)
		if task.count_down then
			if task.count_down <= 0 then
				tim_text.text = Language:getTextByKey("new_str_0063")
				tim_text.gameObject:SetActive(true)
				--doing_img:SetActive(false)
				reward_btn:SetActive(true)
				des_text.gameObject:SetActive(false)

				--slider:SetActive(true)
				fill.fillAmount = 1
				task.data.quest_status = 2
			else
				local ratio = task.count_down/(task.cfg.duration_time*60)
				fill.fillAmount = 1- ratio
				tim_text.text = GameUtil:formatTimeBySecond(task.count_down)
				tim_text.gameObject:SetActive(true)
				--slider:SetActive(true)
				--doing_img:SetActive(true)
				if self.m_model.cur_type == 2 and  self.m_model:chechMasterStatue() == true then
					life_time_text.text = task.data.name 
					life_time_text.gameObject:SetActive(true)
				end
			end
		end
	elseif task.data.quest_status == 2 then --待领取 
		opensend_btn:SetActive(false)	
		tim_text.text =  Language:getTextByKey("new_str_0063")
		tim_text.gameObject:SetActive(true)
		if self.m_model.cur_type == 2 then
			reward_btn:SetActive(not self.m_model:chechMasterStatue())
		else
			des_text.gameObject:SetActive(false)
			reward_btn:SetActive(true)
		end
		--slider:SetActive(true)
		fill.fillAmount = 1
	
	end

	local star_tab = {}
	local st = luaBehaviour:FindGameObject("star_1")
	st:SetActive(false)
	for i = 1, 6 do
		local st = luaBehaviour:FindGameObject("star_"..i)
		st:SetActive(false)
		table.insert(star_tab, i, st)
	end
	for k,v in pairs(star_tab) do
		if task.cfg.rank >= k then
			local st = luaBehaviour:FindGameObject("str_obj")
			st:SetActive(true)
			v:SetActive(true)
		end
	end
	self.lifetime_text = life_time_text.text
end

-- function M:openSelectHero( ... )
-- 	local tab_cls = CustomRequire("UI.WorldMap.WorldMapReward.WorldMapHeroSelectNode")
--     self.m_cur_tab_node = tab_cls.new(self.m_control)
-- end


function M:changeImg(img)
	
end


-- --界面切换页签
-- function M:switchTabForPlunderNode(index)
-- 	self.m_model:refreshPlunderListData(index)
		
-- 	self:switchTabNode(index)
	
-- end
--更新刷新时间
function M:setResetTim()
	local tim = GameUtil:formatTimeBySecond(self.m_model.dataTime)
	if self.m_model.cur_type == 1 then
		local time_show = " "..tim
		self:setText("reset_time_text",time_show)
	elseif self.m_model.cur_type == 2 then
		local time_show = " "..tim
		self:setText("reset_time_text",time_show)
	end
	self:updateItemTime()
end
function M:updateItemTime()
	for k, v in pairs(TEST_TASK_LIST) do
		if v.data.data.quest_status == 1 then --派遣中
			if IsNull(v.obj) then
				return
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
			v.data.count_down = v.data.count_down - 1
			local fill = luaBehaviour:FindImage("Fill")
			local tim_text = luaBehaviour:FindText("time_text")
			if v.data.count_down <= 0 then
				fill.fillAmount = 1
				UIUtil.setTextByLanKey(v.obj.transform, "time_text", "new_str_0063") 
				UIUtil.setObjectVisible(v.obj.transform,true,"time_text")
				UIUtil.setObjectVisible(v.obj.transform,true,"reward_btn")
				UIUtil.setObjectVisible(v.obj.transform,true,"slider")
				v.data.data.quest_status = 2
				break
			end
			local ratio = v.data.count_down / (v.data.cfg.duration_time * 60)
			fill.fillAmount = 1 - ratio
			tim_text.text = GameUtil:formatTimeBySecond(v.data.count_down)
			UIUtil.setObjectVisible(v.obj.transform,true,"time_text")
			UIUtil.setObjectVisible(v.obj.transform,true,"slider")
		end
	end
end

-- function M:switchTabNode(index)
-- 	self.m_model.m_open_tab_index = index
-- 	-- for k,v in pairs(__TAB_BTN_NODE) do
-- 	-- 	local cur_tab_text = self:findText(v.btn_text)
-- 	-- 	cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_3
-- 	-- 	local outline_width = index == k and 2 or 0
-- 	-- 	UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3, outline_width)
-- 	-- 	local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
-- 	-- 	self:setObjectVisible(v.red_point, red_flag == true)
-- 	-- end
	
	
-- 	self:updateLoopScroll()
-- end
-- --[[
-- 	创建列表
-- ]]
-- --初始化队伍界面
-- function M:initialHeroData(data)
--     for k,v in pairs(self.m_model.m_data.station_list) do
--     	if data.building_id == v.building_id then
--     		for k1,v1 in pairs(v.team) do
--            		self:initialHeroView(k1,v1[1])
--         	end
--     	end
       
--     end
-- end

-- function M:updateLoopScroll()
-- 	self.m_cell_tab = {}
-- 	local data = self.m_model.m_show_data
-- 	self.m_select_index = -1
-- 	TEST_TASK_LIST = {}
-- 	if self.m_loop_scroll_view == nil then
-- 		local loopscroll = self:findGameObject("loopscroll")
-- 		local params = {
-- 			show_data = data,
-- 			one_line_count = 1,
-- 			loop_scroll_object = loopscroll,
-- 			update_cell = function(index, cell_object, cell_data)
-- 			table.insert(TEST_TASK_LIST, {data = cell_data, obj = cell_object})
-- 				local transform = cell_object.transform
-- 				self.m_cell_tab[index] = cell_object
-- 				local data = cell_data
-- 				local is_new = nil
-- 				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)

-- 			end,
-- 			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
-- 					if click_name == "dispatch_btn" then
-- 						self:updateMsg("dispatch_btn",{reward = cell_data.cell_data.reward , id = cell_data.id})
						
-- 					elseif click_name == "chakan_btn" then
						
-- 						self:updateMsg("chakan_btn",{cell_data = cell_data})
-- 					else

-- 						self:updateMsg("select_Item_click", {index = index, cell_data = cell_data})
-- 					end
					
				
-- 			end,
-- 			ui_name = self.m_uiName
-- 		}
-- 		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
-- 		--self:runCellAnim()
-- 	else
-- 		self.m_loop_scroll_view:reloadData(data)
-- 	end
-- end

-- 

function M:destroy()

    M.super.destroy(self)
end


return M