local M = class("CombatSuppressSystemView",LikeOO.OOPopBase)

M.m_uiName = "CombatSuppressSystem/CombatSuppressSystem"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local _compare_score = {0.08,0.15}
local _line_StateImg = {{img = "a_dfbhz_dfyzxt_dfdj__qizi_hong",text = "combat_suppress_system_text_009"},
						{img = "a_dfbhz_dfyzxt_dfdj__qizi_huang",text = "combat_suppress_system_text_008"},
						{img = "a_dfbhz_dfyzxt_dfdj__qizi_lv",text = "combat_suppress_system_text_007"}}
local _all_StateImg = {"a_dfbhz_dfyzxt_dfdj_jubuweijian_txt",
					   "a_dfbhz_dfyzxt_dfdj_shengquanzaiwo_txt",
					   "a_dfbhz_dfyzxt_dfdj_shengrenyichou_txt",
					   "a_dfbhz_dfyzxt_dfdj_shijunlidi_txt",
					   "a_dfbhz_dfyzxt_dfdj_xiongduojishao_txt",}

function M:onEnter()
	self:setTextByLanKey("left_name_text","combat_suppress_system_text_001")
	self:setTextByLanKey("right_name_text","combat_suppress_system_text_001")
	self:updateLeftListScroll()
	self:updateRightListScroll()
	self:refreshState()
	self:setTextByLanKey("left_nums_text",self.m_model.m_level)
	self:setTextByLanKey("right_nums_text",self.m_model.m_enemy_level)
end

function M:refreshState()
	local gap = self.m_model.m_level - self.m_model.m_enemy_level
	local config_desc = ConfigManager:getCfgByName("combat_repress_level_skill")
	local desc = 3
	--for i = gap,0,-1 do
	--	if config_desc[i] then
	--		desc = config_desc[i].des		
	--		break
	--	end
	--end
	
	local state_img = self:findImage("state_img")
	local now_state_img = _all_StateImg[4]
	if gap == 1 then
		now_state_img = _all_StateImg[3]
		desc = 2
	elseif gap > 1 then
		now_state_img = _all_StateImg[2]
		desc = 1
	elseif gap == -1 then
		now_state_img = _all_StateImg[1]
		desc = 4
	elseif gap < -1 then
		now_state_img = _all_StateImg[5]
		desc = 5
	end
	self:setTextByLanKey("desc_text","tid#combat_repress_level_diff" .. desc)
	GameUtil:updateResourcesImg(state_img,"Texture/zh_cn/" .. now_state_img)
end

function M:updateLeftListScroll()
	local data = self.m_model.m_locate_type_data
	if self.m_left_list_scroll == nil then
		local list_scroll = self:findGameObject("left_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
			self:updateLeftCell(index,cell_object,cell_data)		
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

function M:updateLeftCell(index,cell_object,cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		--标记
		local gap = 0
		local select_mark = 0
		local self_score = self.m_model.m_type_value[index]
		local enemy_score = self.m_model.m_enemy_type_value[index]
		if self_score == 0 or enemy_score == 0 then  --有一个为0
			if self_score > enemy_score then
				select_mark = 3
			elseif self_score < enemy_score then
				select_mark = 1
			end
		else
			gap = self_score > enemy_score and self_score/enemy_score or enemy_score/self_score
			gap = gap - 1
			if self_score > enemy_score and gap > _compare_score[1] then
				select_mark = 3
			elseif self_score < enemy_score then
				if _compare_score[1] < gap and gap < _compare_score[2] then
					select_mark = 2
				elseif _compare_score[2] <gap then
					select_mark = 1
				end
			end
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "state_bg", select_mark ~= 0)
		if select_mark ~= 0 then
			LuaBehaviourUtil.setImg(luaBehaviour,"state",_line_StateImg[select_mark].img,"main_ui2")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"state_text",_line_StateImg[select_mark].text)
		end
		
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"type_text",cell_data)
		local _fillAmount = 0
		local level_img = luaBehaviour:FindImage("exp_Fill")
		if index == 1 then  --等级的特殊处理
			local level = GameUtil:getCombatSupressLevel(self_score) + 1
			local target_level = 0
			for i = level,1,-1 do
				local level_cfg = self.m_model.combat_repress_level_data[level]
				if level_cfg then
					target_level = level_cfg.min_level		
				end
			end
			_fillAmount = self_score/target_level
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"nums_text",self_score .. "/" ..target_level)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "state_bg", false)
			level_img.color = Color.New(69/255,135/255,49/255,1)
		else
			_fillAmount = self_score/self.m_model.m_target_table[index]
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"nums_text",self_score .. "/" ..self.m_model.m_target_table[index])
			level_img.color = Color.New(1,1,1,1)
		end
		
		if self_score == 0 then
			level_img.fillAmount = 0
		elseif self_score > 0 then
			level_img.fillAmount = _fillAmount
		end
	end
end

function M:updateRightListScroll()
	local data = self.m_model.m_locate_type_data
	if self.m_right_list_scroll == nil then
		local list_scroll = self:findGameObject("right_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRightCell(index,cell_object,cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end,
			ui_name = self.m_uiName
		}
		self.m_right_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_right_list_scroll:reloadData(data)
	end
end

function M:updateRightCell(index,cell_object,cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"state",false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"state_text",false)
		local _fillAmount = 0
		local level_img = luaBehaviour:FindImage("exp_Fill")
		if index == 1 then  --等级的特殊处理
			local level = GameUtil:getCombatSupressLevel(self.m_model.m_enemy_type_value[index]) + 1
			local target_level = 0
			for i = level,1,-1 do
				local level_cfg = self.m_model.combat_repress_level_data[level]
				if level_cfg then
					target_level = level_cfg.min_level
				end
			end
			_fillAmount = self.m_model.m_enemy_type_value[index]/target_level
			level_img.color = Color.New(69/255,135/255,49/255,1)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"nums_text",self.m_model.m_enemy_type_value[index] .. "/" ..target_level)
		else
			_fillAmount = self.m_model.m_enemy_type_value[index]/self.m_model.m_target_table[index]
			level_img.color = Color.New(1,1,1,1)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"nums_text",self.m_model.m_enemy_type_value[index] .. "/" ..self.m_model.m_target_table[index])
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"type_text",cell_data)
		if self.m_model.m_enemy_type_value[index] == 0 then
			level_img.fillAmount = 0
		elseif self.m_model.m_enemy_type_value[index] > 0 then
			level_img.fillAmount = _fillAmount
		end
	end
end

function M:runBackAnim(func)
	local obj = self:findGameObject("content_node")
	if not IsNull(obj) then
		local luaBehaviour = obj:GetComponent("LuaBehaviour")
		luaBehaviour:RunAnim("CombatSuppressSystem_content_node_takeback",func)
	end
end

function M:refreshUI()
	
end

return M

