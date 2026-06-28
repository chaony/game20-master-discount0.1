local M = class("CompareSwordFightReportPopView", LikeOO.OOPopBase)
--剑试天下 战报界面
M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordFightReportPop"	--CompareSwordWithWorld.CompareSwordFightReportPop
M.m_iphoneXAdapter = true
M.m_size_type = 2

local M_TabTag = {
	raceGroup = 1 , --回合
	raceItem = 2, 	--轮次
	promotion= 3 ,}

local _scroll_step = 10

function M:onEnter()
	self.m_tab_group_list = {}
	self.m_tab_item_list = {}
	self.m_tab_item_scroll_list ={}  --下拉菜单滑动列表
	self.m_tab_group_limit = 5 		--下拉菜单滑动列表展示item个数
	
	self.dropDownCurIndex = 1	--todo:获取当前回合的下标
	self.dropDownDataList = self:getDropDownDataList()
	
	self.dD_open = false 	--右侧下拉菜单显隐

	for i = 1, 16 do --self.cur_round do
		local langNumTxt =  GameUtil:numberToChineseString(i)
		local txtName =  Language:getTextByKey("compare_sword_race_text_015" , langNumTxt)
		table.insert(self.m_tab_group_list ,
				{idx = i, name = txtName ,tabTag = M_TabTag.raceGroup , scroll_open = i == self.m_model.sel_group})
	end
	--init tab item
	for i = 1, 10 do	--固定有10个轮次
		local langNumTxt =  GameUtil:numberToChineseString(i)
		local txtName =  Language:getTextByKey("compare_sword_race_text_014" , langNumTxt)
		table.insert(self.m_tab_item_list ,
				{idx = i, name = txtName ,tabTag = M_TabTag.raceItem })
	end
	self.select_obj = nil
	self:refreshUI()
	self:setListScrollSize()
end

function M:setListScrollSize()
	local listScroll_Go = self:findGameObject("list_scroll")
	local listScroll_rect = listScroll_Go:GetComponent("RectTransform")
	if self.m_model.open_type == 1 then
		listScroll_rect.sizeDelta = Vector2(listScroll_rect.rect.width , 473)
	elseif self.m_model.open_type == 2 then
		listScroll_rect.sizeDelta = Vector2(listScroll_rect.rect.width , 522)
	end
end

function M:updateTabScroll() --下拉菜单 滑动列表
	local all_cell_size ={}
	for i,v in ipairs(self.m_tab_group_list or {}) do
		if i == self.m_model.sel_group and v.scroll_open then
			local group_num = 10
			group_num = group_num <= self.m_tab_group_limit and group_num or self.m_tab_group_limit 
			all_cell_size[i] = Vector2(190, 65 * group_num + 65)
		else
			all_cell_size[i] = Vector2(190, 65)
		end
	end
	
	if self.m_tab_group_scroll == nil then
		local list_scroll = self:findGameObject("tab_scroll")
		local params = {
			show_data = self.m_tab_group_list,
			loop_scroll_object = list_scroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateTabGroupCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_model.sel_group == index then
					cell_data.scroll_open = not cell_data.scroll_open
					self:updateTabScroll()
				else
					self.m_tab_group_list[self.m_model.sel_group].scroll_open = false
					cell_data.scroll_open = true
					self:updateMsg("switchNode" , {groupId = index , round = self.m_model.sel_round ,day_idx = self.dropDownCurIndex})
				end
				
			end,
		}
		self.m_tab_group_scroll = LoopScrollViewUtil.new(params)

	else
		self.m_tab_group_scroll:reloadData(self.m_tab_group_list, true, all_cell_size)
		self.m_tab_group_scroll:moveToCellIndex(self.m_model.sel_group)
	end
	
end

function M:updateTabGroupCell(index , obj , data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local format = Language:getTextByKey(data.name)

	local expand_btn = luaBehaviour:FindGameObject("expand_btn")

	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "item_loopscroll", self.m_model.sel_group == index and data.scroll_open) 
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "group_checkmark" , not data.scroll_open)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "group_label" , data.name)
	local rect = obj:GetComponent("RectTransform")
	if index == self.m_model.sel_group and data.scroll_open then
		local group_num = 10
		group_num = group_num <= self.m_tab_group_limit and group_num or self.m_tab_group_limit 
		rect.sizeDelta = Vector2(190, 65 * group_num + 65)

		local type_detail_loopscroll = luaBehaviour:FindGameObject("item_loopscroll")
		local type_detail_loopscroll_rect = type_detail_loopscroll:GetComponent("RectTransform")
		type_detail_loopscroll_rect.sizeDelta = Vector2(type_detail_loopscroll_rect.rect.width, 65 * group_num)
		self.m_tab_item_scroll_list = nil
		self:updateTabItemScroll(index , luaBehaviour)

		if self.m_model.sel_group == index and self.m_model.sel_round >= 5 then
			self.m_tab_item_scroll_list:moveToCellIndex(self.m_model.sel_round)
		end

	else
		rect.sizeDelta = Vector2(190, 65)
	end
	

	
end

function M:updateTabItemScroll(group_idx , g_luaBehaviour)
	local data = self.m_tab_item_list
	if self.m_tab_item_scroll_list == nil then
		local list_scroll = g_luaBehaviour:FindGameObject("item_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTabItemCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("switchNode" , {groupId = self.m_model.sel_group , round = index ,day_idx = self.dropDownCurIndex})


			end , 

		}
		self.m_tab_item_scroll_list = LoopScrollViewUtil.new(params)
	else
		self.m_tab_item_scroll_list:reloadData(data,true)
	end
end


function M:updateTabItemCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour , "item_label" , cell_data.name)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "item_checkmark" , self.m_model.sel_round == index)
	
end

-- 右侧下拉菜单
local __TAB_DROPDOWN_BTN = { "a_tsjfs_btn_jiantou01","a_tsjfs_btn_jiantou02", }
local __TAB_DROPDOWN_ITEM_BTN = {"a_tsjfs_btn_xuanzhong", "a_tsjfs_btn_weixuanzhong"}
local __TAB_IMAGE_BG = {"a_tsjfs_bg","a_tsjjs_bg"}
local __TAB_DROPDOWN_BTN_COLOR = { Color(119 / 255, 85 / 255, 35 / 255), Color(1, 1, 1) }

function M:refreshDropDown()
	local dDGO = self:findGameObject("dropDown_loopscroll")
	dDGO:SetActive(self.dD_open)
	
	if self.dD_open then --列表展开状态
		self:setImg(__TAB_DROPDOWN_BTN[1],"active_ui" , "btn_dropDown")
	else
		self:setImg(__TAB_DROPDOWN_BTN[2],"active_ui" , "btn_dropDown")
	end

	local textGroup = self:findText("text_curGroup")
	textGroup.text = Language:getTextByKey(self.dropDownDataList[self.dropDownCurIndex].name)
end

function M:getDropDownDataList()
	local result ={}
	for i = 1, 10 do	-- 每天10回合
		local lang_num = GameUtil:numberToChineseString(i)
		local lang_txt = Language:getTextByKey("compare_sword_race_text_030", lang_num)
		table.insert(result, i , {name = lang_txt , open = false})
	end
	result[self.dropDownCurIndex].open = true	--todo：设置为当前进行的组 开启
	return result
end

function M:updateDropDownLoopScroll()
	local data = self.dropDownDataList
	if self.m_dropDown_scroll_view == nil then
		local loopscroll = self:findGameObject("dropDown_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:UpdateDDItem(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.dD_open = false
				self.dropDownCurIndex = index
				for i, v in pairs(self.dropDownDataList) do
					v.open = i == self.dropDownCurIndex
				end
				self:updateDropDownLoopScroll()
				self:refreshDropDown()
				--todo:刷新战报滚动视图
				self:updateMsg("switchNode" , {groupId = self.m_model.sel_group , round = self.m_model.sel_round , day_idx = self.dropDownCurIndex})
			end
		}
		self.m_dropDown_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_dropDown_scroll_view:reloadData(data)
	end
end

function M:UpdateDDItem(obj , data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local itemName = luaBehaviour:FindText("text_itemName")

		itemName.text = Language:getTextByKey(data.name)
		LuaBehaviourUtil.setImg(luaBehaviour,"img_dDBtnBg" ,data.open and __TAB_DROPDOWN_ITEM_BTN[1] or __TAB_DROPDOWN_ITEM_BTN[2] , "active_ui")
		itemName.color = data.open and __TAB_DROPDOWN_BTN_COLOR[1] or __TAB_DROPDOWN_BTN_COLOR[2]
		--self:setTextColor("text_itemName" , )

	end
end



function M:refreshUI()
	self:setObjectVisible("tab_scroll",self.m_model.open_type==1)
	self:setObjectVisible("tab_scroll2",self.m_model.open_type==2 or self.m_model.open_type==3 or self.m_model.open_type==4)
	self:setObjectVisible("dropDown_node" , self.m_model.open_type == 1)
	if self.m_model.open_type == 1 then 
		self:updateTabScroll()
	elseif self.m_model.open_type == 2 or self.m_model.open_type == 4 or self.m_model.open_type == 3 then
		self:updateDayList()
	end
	self:updateLoopScroll()
	self:refreshDropDown()
	self:updateDropDownLoopScroll()
	
	self:setObjectVisible("CommonTipsNode",not next(self.m_model:getListData()) )
end

--战报 滑动列表
function M:updateLoopScroll()	
	self.m_click_cell_object = nil
	local data = self.m_model:getListData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")  --挂载LoopScroll名称
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data) --更新列表内容
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--点击事件 
				self:updateMsg("btn_fightData",cell_data)
			end,
			pull_refresh = function() -- 下拉刷新
				if self.m_model.open_type == 1 then
					self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
					self:updateMsg("load_rank")
				end
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
		if self.m_control.m_load_end == true and 
				self.m_model.open_type == 1 then 
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_load_end = false
end

function M:updateScrollViewCell(idx , cell_object , data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	local head_node_left = luaBehaviour:FindGameObject("HeadNodeLeft")
	GameUtil:setUserAvatar(head_node_left, data.atk_user_info, false, false, {show_flag = true, scale = 1})
	local head_node_right = luaBehaviour:FindGameObject("HeadNodeRight")
	GameUtil:setUserAvatar(head_node_right, data.def_user_info, false, false, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", data.atk_user_info.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", data.def_user_info.name)

	local imagePath = data.win == 1 and "a_sjjs_shengli" or "a_sjjs_shibai"
	local imagePathR = data.win == 1 and "a_sjjs_shibai" or "a_sjjs_shengli"
	LuaBehaviourUtil.setImg(luaBehaviour, "left_img_result", imagePath, ResourceUtil:getLanAtlas())
	LuaBehaviourUtil.setImg(luaBehaviour, "right_img_result", imagePathR, ResourceUtil:getLanAtlas())
	--LuaBehaviourUtil.setImg(luaBehaviour, "right_img_result", imagePathR, ResourceUtil:getLanAtlas())
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_pointValue_text",  data.win == 1)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_pointValue_text", data.win ~= 1)

	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_pointValue_text",  false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_pointValue_text", false)
	local commonCfg = ConfigManager:getCfgByName("common")
	--local value = commonCfg[794].value or {10,15}
	--local score = 0
	--if data.atk_round_win_times <=2 then
	--	score = value[1] or 10
	--elseif data.atk_round_win_times >=3 then
	--	score = value[2] or 15
	--end
	if data.atk_score then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_pointValue_text", true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_pointValue_text","compare_sword_race_text_032", data.atk_score)
	end
	if data.def_score then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_pointValue_text", true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_pointValue_text", "compare_sword_race_text_032",data.def_score)
	end
	
end




-- 个人战报
-- 个人战报 页签滑动窗口
function M:updateDayList()
	local data = self.m_model.open_type == 2 and self.m_model.day_data or self.m_model.round_data
	if self.m_type_scroll == nil then
		local list_scroll = self:findGameObject("tab_scroll2")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateDayCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_model.current_day ~= cell_data then
					self.m_model.current_day = cell_data
					local luaBehaviour = self.select_obj:GetComponent("LuaBehaviour")
					local hero_img = luaBehaviour:FindImage("day_button")
					hero_img.color = Color.New(255 / 255, 255 / 255, 255 / 255)
					self:updateDayCell(index, cell_object, cell_data)
					self:updateMsg("click_type_btn",  cell_data)
				end
			end
		}
		self.m_type_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_type_scroll:reloadData(data, nil, all_cell_size)
	end
end

local ROUND_TXT = {
	[1] = "compare_sword_guess_title_001",
	[2] = "compare_sword_guess_title_002",
	[3] = "compare_sword_guess_title_003",
	[4] = "compare_sword_guess_title_004",
	[5] = "compare_sword_guess_title_005",
	[6] = "compare_sword_guess_title_006",
}
-- 个人战报 页签 cell
function M:updateDayCell(index, cell_object, cell_data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	if self.m_model.open_type == 2 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_button_text","compare_sword_race_text_030", cell_data)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_button_text",ROUND_TXT[cell_data])
	end
	if cell_data == self.m_model.current_day then
		self.select_obj = cell_object
		local hero_img = luaBehaviour:FindImage("day_button")
		hero_img.color = Color.New(199 / 255, 199 / 255, 199 / 255)
	else
		local hero_img = luaBehaviour:FindImage("day_button")
		hero_img.color = Color.New(255 / 255, 255 / 255, 255 / 255)
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M