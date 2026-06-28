---@class SelectSupportHeroView:OOPopBase
---@field m_model SelectSupportHeroModel
local M = class("SelectSupportHeroView",LikeOO.OOPopBase)

M.m_uiName = "AdditionSupportSystem/SelecHeroPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn = "martial_0_toggle", name = "martial_0_text", lan_text = "new_str_0144",race = 0},
	{btn = "martial_1_toggle", name = "martial_1_text", lan_text = "new_str_0144",race = 1},
	{btn = "martial_2_toggle", name = "martial_2_text", lan_text = "new_str_0145",race = 3},
	{btn = "martial_3_toggle", name = "martial_3_text", lan_text = "new_str_0143",race = 4},
	{btn = "martial_4_toggle", name = "martial_4_text", lan_text = "new_str_0142",race = 2},
	{btn = "martial_5_toggle", name = "martial_5_text", lan_text = "new_str_0237",race = 6},
	{btn = "martial_6_toggle", name = "martial_6_text", lan_text = "new_str_0238",race = 5},
	{btn = "martial_7_toggle", name = "martial_7_text", lan_text = "new_str_0238",race = 7},
}

function M:onEnter()
	self.hui = self:findImage("hui");
	self.m_scroll_view_update_move_flag = true

	self.m_model.selectType_index = 1;
	--for i,v in ipairs(__TAB_BTN_NODE) do
	--	local tog_btn = self:findToggle(v.btn)
	--	local item = self:findGameObject(v.btn)
	--	local lan_text = "new_str_0065"
	--	if self.m_model.selectType_index == i then
	--		UIUtil.setToggleIsOn(item.transform, true)
	--		UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
	--	end
	--	UIUtil.addToggleListener(tog_btn, function(is_on, data)
	--		if is_on then
	--			self:updateMsg("tab_btn",{index = data,value = __TAB_BTN_NODE[data]})
	--			UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
	--		else
	--			UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
	--		end
	--	end, i, self.m_uiName)
	--end

	self.race_hero = self.m_model:switchHeroList(self.m_model.m_cur_race_id)
	self:setTextByLanKey("tip_text","supportSys_str_0002")
	self:refreshUI()
end

--function M:initHeroCell( cell_name )
--	local cell_object = self:findGameObject(cell_name);
--	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
--	local have_panel = luaBehaviour:FindGameObject("have_panel")
--	local no_panel = luaBehaviour:FindGameObject("no_panel")
--	local stars = luaBehaviour:FindGameObject("stars")
--	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
--	have_panel:SetActive(false);
--	stars:SetActive(false);
--	no_panel:SetActive(true);
--end


function M:refreshUI()
	self:createLoopScroll();
end

--英雄列表
function M:createLoopScroll(data_value)
	local data = self.race_hero
	if data_value then
		data = data_value
	end
	local spacing = 0
	if self.m_model.m_type ~= 1 then
		spacing = 40
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 7,
			--spacing = spacing,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

				local canClick=false
				local islocked=table.indexof(self.m_model.m_all_ids,cell_data.id)
				if islocked==false then
					canClick=true
					self:updateMsg("select_hero", cell_data.oid)
				else
					if self.m_model.m_selected_support_oid~=nil then
						if self.m_model.m_selected_support_oid==cell_data.oid then
							canClick=true
							self:updateMsg("select_hero", cell_data.oid)
						end
					end
				end
				if canClick==false then
					return
				end
				
				local luaBehaviour = nil
				if self.select_cell_object then
					luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_object)
					if self.m_model.m_selected_support_oid==cell_data.oid then
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", not self.select_cell_object.gameObject.activeSelf)
					else
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
						luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
						self.select_cell_object = cell_object;
					end
				end
				
				--if self.m_model.m_selected_support_oid==nil then
				--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
				--else
				--	if self.m_model.m_selected_support_oid~=cell_data.oid then
				--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
				--	end
				--end
				--
				--if self.m_model.m_selected_support_oid~=cell_data.oid then
				--	if islocked==false  then
				--		--已经选择的同名侠客不让他选
				--		luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
				--	end
				--else
				--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
				--end
				--self.select_cell_object = cell_object;
				
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, self.m_scroll_view_update_move_flag)
	end
end

function M:selectHero(selected)
	if self.select_cell_object then
		luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_object)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", selected)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, cell_data)
	if obj == nil then
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return
	end
	local hero_id = cell_data.id
	self:setTextByLanKey("common_title_text", "advanced_str_0012")
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	--local finish = self.m_model:isFinishHero(heroOid)
	--if finish == 1 then
	--	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", true)
	--else
	--	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
	--end


	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", cell_data.oid==self.m_model.m_cur_support_oid)
	local hero_cfg = self.m_model:getHero(hero_id)
	if hero_cfg then
		local itemData = self.m_model:getHeroData(cell_data)
		GameUtil:updateItemElementByData(obj, itemData)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
	end

	if cell_data.oid==self.m_model.m_selected_support_oid then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
		local islocked=table.indexof(self.m_model.m_all_ids,hero_id)
		if islocked then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text","new_str_1150")
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_image", islocked)
	end

end


--刷新槽位
function M:updateSendList()
	--槽位上的英雄
	local solt_players = self.m_model:getSendSlot()
	for i, v in pairs(solt_players) do
		--槽位数据
		if v.hero_id > 0 then
			local playerid = v.hero_id;
			local cell_veiw = self.cellView[i].obj;
			--找到槽位
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_veiw.transform)
			local function btns()
				self:updateMsg("check_send_btn", v.hero_id)
				if v.hero_id > 0 then
					audio:SendEvtUI("Play_UI_HeroSelected")
				end
			end
			luaBehaviour:RegistButtonClick(btns)
			local have_panel = luaBehaviour:FindGameObject("have_panel")
			have_panel:SetActive(true);
			--获取道具人物头像数据
			local itemData = self.m_model:getHeroData(playerid)
			--设置头像到槽位上
			GameUtil:updateItemElementByData(cell_veiw, itemData)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
			--如果已经完成
			local finish = self.m_model:isFinishHero(v.hero_id)
			if finish == 1 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", true)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
			end
		else
			local cell_name = self.cellView[i].name;
			self:initHeroCell(cell_name)
		end
	end
end


function M:alterData(obj, data )
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local item = luaBehaviour:FindGameObject("item_img")--任务名字
	local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
	item:SetActive(true)
	local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
	local frame = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality]
	LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.hero_item_frame, "hero_head_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_img", true)
	local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
	local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
	if race_data then
		LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
	end
	local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
	quality_up_img:SetActive(frame.is_add == true)
	if frame.is_add == true then
		LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
	end
end



function M:destroy()
	EventDispatcher:unRegisterEvent("wish_time_update")
	M.super.destroy(self)
end

return M