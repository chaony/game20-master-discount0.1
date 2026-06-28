local M = class("WorldMapTaskRewardView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapTaskReward/WorldMapTaskRewardPop"
M.m_size_type = 2

M.COMMON_COLLOR_1 =  Color( 117/255, 123/255, 202/255, 1)
M.COMMON_COLLOR_2 =  Color( 96/255, 105/255, 138/255, 1)

local __TAB_BTN_NODE = { 
	--{btn_key = "tog_1", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardMainNode", text_key = "tog_1_text", show_text = "主线: " , red_point_img = "battle_red_point_img"}, -- 收益
	--{btn_key = "tog_2", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardBranchNode", text_key = "tog_2_text", show_text = "支线: " , red_point_img = "battle_red_point_img"}, -- 快速
	--{btn_key = "tog_3", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardAreaNode", text_key = "tog_3_text", show_text = "区域: " , red_point_img = "battle_red_point_img"}, -- 事件

	{btn_key = "tog_1", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardBranchNode", text_key = "tog_1_text", show_text = "world_map_tex_001" , red_point_img = "battle_red_point_img"}, -- 事件
	{btn_key = "tog_2", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardAreaNode", text_key = "tog_2_text", show_text = "world_map_tex_002" , red_point_img = "battle_red_point_img"}, -- 区域
	{btn_key = "tog_3", lua_name = "UI.WorldMap.WorldMapTaskReward.TaskRewardMissionNode", text_key = "tog_3_text", show_text = "world_map_tex_003" , red_point_img = "battle_red_point_img"}, -- 委托
}

function M:onEnter()
	self.m_toggle_btns = {}
	self.m_content_panel = self:findGameObject("content_panel")
	self.content_area_panel = self:findGameObject("content_area_panel")
	self.panel = self:findGameObject("cell_Content")
	local rewardOpened = false
	self:setTextByLanKey("btn_text", "new_str_0970")
	self:setTextByLanKey("box_text", "world_map_tex_004")
	for k,v in pairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn_key)

		if k == 1 then
			local num = self.m_model:getBanchTaskNum()
			self:setTextByLanKey(v.text_key, Language:getTextByKey(v.show_text)..num)
		elseif k == 2 then
			local num = self.m_model:getOpenSceneNums()
			self:setTextByLanKey(v.text_key, Language:getTextByKey(v.show_text)..num)
		elseif k == 3 then
			local num = self.m_model:getMissionNums()
			if num ~= nil then
				tog_btn.gameObject:SetActive(true)
				self:setTextByLanKey(v.text_key, Language:getTextByKey(v.show_text)..num)
			else
				tog_btn.gameObject:SetActive(false)
			end
		end
		
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		if k == 2 then
			tog_btn.gameObject:SetActive(true)
		elseif k == 1 then
			local data = self.m_model:getCurBanchTask()
			tog_btn.gameObject:SetActive(false)
			if rewardOpened == false then
				rewardOpened = table.nums(data) > 0
			end
		elseif k == 3 then
			
		end 
		self:setObjectVisible(v.red_point_img, false)
	end
	--self.canReward = self.m_model.m_open_tab_index ~= 3

	--if self.canReward == false then
	--	self:setObjectVisible("box_btn", false)
	--	self:setObjectVisible("tx_box", false)
	--end

	self:setObjectVisible("click_btn", self.m_model.m_open_tab_index == 2)
	
	local regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	local r_m_cfg = regional_map_cfg[self.m_model.m_scene_id]
	self:setTextByLanKey("title_text", r_m_cfg.name)
	self:setTextByLanKey("common_title_text", r_m_cfg.name)
	self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg("check_tag", update_key)
	end
end

function M:switchTabNode(index)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	--self:setTextByLanKey("title_text", __TAB_BTN_NODE[index].show_text)
	for k,v in pairs(__TAB_BTN_NODE) do
		if k == self.m_model.m_sel_tab_index then
			self:setTextColor(v.text_key, M.COMMON_COLLOR_1)
		else
			self:setTextColor(v.text_key, M.COMMON_COLLOR_2)
		end
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    local parent = self.m_content_panel
	    self.m_content_panel:SetActive(true)
	    if index ~= 1 then
	    	parent = self.content_area_panel
	    	self.m_content_panel:SetActive(false)
	    end
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = parent})
	end
end

function M:refreshUI()
	if self.m_cur_tab_node ~= nil then
		self.m_cur_tab_node:refreshBox()
	end
	--if self.canReward == true then
	--	local cpd, status = self.m_model:getMapCpd()
	--	self:setTextByLanKey("cpd_text", cpd)
	--	if status == 2 then
	--		self:setImg("a_ck_linshixiangzi_open", "common_ui", "box_btn")
	--	else
	--		self:setImg("a_ck_linshixiangzi", "common_ui", "box_btn")
	--	end
	--	self:setObjectVisible("box_text", status ~= 2)
	--	self:setObjectVisible("tx_box", status == 1)
	--end
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end

return M