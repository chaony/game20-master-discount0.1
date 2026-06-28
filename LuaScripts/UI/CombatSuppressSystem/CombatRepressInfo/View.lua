local M = class("CombatRepressInfoView",LikeOO.OOPopBase)

M.m_uiName = "CombatSuppressSystem/CombatRepressInfo"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local _line_StateImg = {"a_dfyz_tc_jinque","a_dfyz_tc_luohou","a_dfyz_tc_lianghao","a_dfyz_tc_jizhi","a_dfyz_tc_manji"}
local _stars_nums = 5

function M:onEnter()
	self.m_loop_scroll_view = {}
	self:setTextByLanKey("common_title_text","combat_suppress_system_text_002")
	self:setTextByLanKey("repress_nums_text","combat_suppress_system_text_0010",self.m_model.m_hero_nums+self.m_model.m_global_nums)
	self:setSpine()
	self:updateTabName()
	self:updateStarListScroll()
	self:refreshUI()
end

function M:updateTabName()
	self.m_toggle_btns = {}
	for k,v in ipairs(self.m_model.m_tab_btn_node) do
		self:setTextByLanKey(v.text_name,v.text_key)			
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_select_id then
			tog_btn.isOn = true
			self:setTextColor(v.text_name, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_name, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
	end
end

function M:setSpine()
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.m_model.m_hero_spine, "", 0, false)
end

function M:refreshUI()
	self:updateLeftListScroll()
end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = self.m_model.m_tab_btn_node[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_name, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_name, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:updateLeftListScroll()
	local data = self.m_model:getLocateType()
	if self.m_left_list_scroll == nil then
		local list_scroll = self:findGameObject("type_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
			self:updateLeftCell(cell_object,cell_data)		
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end,
			ui_name = self.m_uiName
		}
		self.m_left_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_left_list_scroll:reloadData(data)
	end
end

function M:updateLeftCell(cell_object,cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		local nums = 0
		local key = ""
		if cell_data.add_type == 1 then
			local hero_data = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero_id)
			if hero_data then
				for k,v in pairs(self.m_model.combat_repress_data) do
					if v.id == cell_data.id then
						key = k
						break
					end
				end
			end
			nums = hero_data.combat_repress[key] or 0
		elseif cell_data.add_type == 2 then
			local global_data = UserDataManager:getGlobalCombatRepressData()
			if global_data then
				for k,v in pairs(self.m_model.combat_repress_data) do
					if v.id == cell_data.id then
						key = k
						break
					end
				end
			end
			nums = global_data[key] or 0
		end
		local img_value = 1
		--local score = nums/cell_data.max_combat_num * self.m_model.cfg_max_nums /(self.m_model.m_hero_nums + self.m_model.m_global_nums)
		local score = nums/cell_data.max_combat_num
		local state_nums = cell_data.tab_num
		if nums == cell_data.max_combat_num then
			img_value = 5
		else
			for k,v in ipairs(state_nums) do
				if score > v then
					img_value = k
				end
			end
		end
		LuaBehaviourUtil.setImg(luaBehaviour,"title_img",_line_StateImg[img_value],"language_zh_cn")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"title_img",cell_data.tab_show == 1)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"nums_text","combat_suppress_system_text_004",nums)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"type_text",cell_data.locate2_type_des)
		local obj = LuaBehaviourUtil.findGameObject(luaBehaviour,"list_scroll")
			if cell_data.link and next(cell_data.link) then
				obj:SetActive(true)
				self:updateGetList(obj,cell_data)
			else
				obj:SetActive(false)
			end
		
	end
end

function M:updateGetList(obj,cfg_data)
	if self.m_loop_scroll_view[obj] == nil then
		local loopscroll = obj
		local params = {
			show_data = cfg_data.link,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local jump = ConfigManager:getCfgByName("jump")
				local jump_item = jump[cell_data]
				if jump_item then
					local open_condition_id = jump_item.open_condition_id or 0
					local open_condition = ConfigManager:getCfgByName("open_condition")
					local open_condition_cfg = open_condition[open_condition_id]
					if open_condition_cfg then
						LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", open_condition_cfg.name)
						local str = Language:getTextByKey(open_condition_cfg.name)
						local line_img = luaBehaviour:FindGameObject("line_img")
						local item_bg_rt = UIUtil.findRectTransform(line_img.gameObject)
						if #str == 6 then
							item_bg_rt.sizeDelta = Vector2(40, 2)
						elseif #str == 9 then
							item_bg_rt.sizeDelta = Vector2(60, 2)
						elseif #str == 12 then
							item_bg_rt.sizeDelta = Vector2(80, 2)
						end
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(99999)
				local  data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero_id)
				QuickOpenFuncUtil:openFunc(cell_data,{hero_id = data.id})
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view[obj] = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view[obj]:reloadData(cfg_data.link,true)
	end
end

function M:updateStarListScroll()
	local data = self.m_model.m_tab_btn_node
	if self.m_star_list_scroll == nil then
		local list_scroll = self:findGameObject("star_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateStarCell(index,cell_object,cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end,
			ui_name = self.m_uiName
		}
		self.m_star_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_star_list_scroll:reloadData(data)
	end
end

function M:updateStarCell(index,cell_object,cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local hero_table = self.m_model.m_hero_table
	local global_table = self.m_model.m_global_table
	table.merge(hero_table,global_table)
	if luaBehaviour then
		local name_table = self.m_model.m_tab_btn_node[index]
		local max_nums = self.m_model.combat_repress_max_nums_list[index] or _stars_nums
		local one_stars_value = max_nums/_stars_nums
		local now_max_nums = hero_table[index] or 5
		local value = now_max_nums/one_stars_value
		local nums = math.floor(value)
		local hui_id = math.ceil(value)
		local text = Language:getTextByKey(name_table.text_key) or ""
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"type_text",text .. ":")
		for i = 1, _stars_nums do
			if i <= nums then
				LuaBehaviourUtil.setImg(luaBehaviour,"star_" .. i,"a_dfyz_tc_xingxingliang","main_ui2")
			elseif i > hui_id then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"star_" .. i,false)		
			end
		end
	end
end

return M


