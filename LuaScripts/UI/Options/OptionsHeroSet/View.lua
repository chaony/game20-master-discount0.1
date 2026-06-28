---@class OptionsHeroSetView:OOPopBase
---@field m_model OptionsHeroSetModel
local M = class("OptionsHeroSetView",LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsHeroSet"
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
	local race_hero_cell1 = self:findGameObject("race_hero_cell1")
	local race_hero_cell2 = self:findGameObject("race_hero_cell2")
	local race_hero_cell3 = self:findGameObject("race_hero_cell3")
	local race_hero_cell4 = self:findGameObject("race_hero_cell4")
	local race_hero_cell5 = self:findGameObject("race_hero_cell5")
	self.cellView = {
		[1] = {
			name = "race_hero_cell1",
			obj = race_hero_cell1,
		},
		[2] = {
			name = "race_hero_cell2",
			obj = race_hero_cell2,
		},
		[3] = {
			name = "race_hero_cell3",
			obj = race_hero_cell3,
		},
		[4] = {
			name = "race_hero_cell4",
			obj = race_hero_cell4,
		},
		[5] = {
			name = "race_hero_cell5",
			obj = race_hero_cell5,
		},
	}
	self.m_model.selectType_index = 1;
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local item = self:findGameObject(v.btn)
		local lan_text = "new_str_0065"
		if self.m_model.selectType_index == i then
			UIUtil.setToggleIsOn(item.transform, true)
			UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
		end
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("tab_btn",{index = data,value = __TAB_BTN_NODE[data]})
				UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
			end
		end, i, self.m_uiName)
	end

	self:initHeroCell("race_hero_cell1")
	self:initHeroCell("race_hero_cell2")
	self:initHeroCell("race_hero_cell3")
	self:initHeroCell("race_hero_cell4")
	self:initHeroCell("race_hero_cell5")
	
	--self.time_remain = self:findText("time_remain");
	--self.race_hero = self.m_model:switchHeroList(1)
	--self.cd_time = self.m_model.m_time;
	--if self.cd_time > 0 then
	--	GameUtil:remainingTimeUpdate(self.m_control, "wish_time_update", self.time_remain, self.cd_time, "wish_time_end", 1,"tid#wish4")
	--else
	--	self.time_remain.text = "";
	--end
	
	self:setTextByLanKey("left_tips", "gua_ji_xia_ke_str_002")
	self.race_hero = self.m_model:switchHeroList(0)
	self:refreshUI()
end

function M:initHeroCell( cell_name )
	local cell_object = self:findGameObject(cell_name);
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	local have_panel = luaBehaviour:FindGameObject("have_panel")
	local no_panel = luaBehaviour:FindGameObject("no_panel")
	local stars = luaBehaviour:FindGameObject("stars")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
	have_panel:SetActive(false);
	stars:SetActive(false);
	no_panel:SetActive(true);
end


function M:refreshUI()
	self:updateSendList()
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
			one_line_count = 4,
			spacing = spacing,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.select_cell_object = cell_object;
				local finish = self.m_model:isFinishHero(cell_data.id)
				if finish == 1 then
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#wish3"), delay_close = 2})
				else
					self:updateMsg("select_hero", cell_data.id)
				end
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, self.m_scroll_view_update_move_flag)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, cell_data)
	if obj == nil then
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return
	end
	local heroOid = cell_data.id
	self:setTextByLanKey("common_title_text", "gua_ji_xia_ke_str_001")
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local finish = self.m_model:isFinishHero(heroOid)
	if finish == 1 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", true)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
	end
	
	local hero_cfg = self.m_model:getHero(heroOid)
	if hero_cfg then
		local itemData = self.m_model:getHeroData(heroOid)
		GameUtil:updateItemElementByData(obj, itemData)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isInSlot(heroOid) == true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
	end
	local has_hero = self.m_model:hasHeros(heroOid)
	if has_hero == false then
		local item_img = luaBehaviour:FindImage("item_img")
		item_img.material = self.hui.material;
	else
		local item_img = luaBehaviour:FindImage("item_img")
		item_img.material = nil;
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