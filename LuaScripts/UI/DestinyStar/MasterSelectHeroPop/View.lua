local M = class("MasterSelectHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "DestinyStar/MasterSelectHeroPop"
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

	self:setTextByLanKey("common_title_text",self.m_model.m_open_type == "master" and "fate_building_text_0010" or "fate_building_text_0012")
	self:setTextByLanKey("sure_btn_text", "fate_building_text_0013")
	self.race_hero = self.m_model:switchHeroList(0)
	self:refreshUI()
end

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
			one_line_count = 6,
			spacing = spacing,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_model.m_select_hero_id == cell_data.oid then
					self.m_model.m_select_hero_id = ""
				elseif self.m_model:heroIsMaster(cell_data.oid, true) and self.m_model.m_open_type == "master" then
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("fate_building_text_0016"), delay_close = 2})
					return
				else
					self.m_model.m_select_hero_id = cell_data.oid
				end
				self.select_cell_object = cell_object;
				self.m_loop_scroll_view:reloadData(self.race_hero, true)
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, cell_data)
	if obj == nil then
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return
	end
	local heroOid = cell_data.oid
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local itemData = self.m_model:getHeroDataById(cell_data)
	GameUtil:updateItemElementByData(obj, itemData)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", cell_data.oid == self.m_model.m_select_hero_id)
	local is_up = self.m_model:heroIsMaster(heroOid)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", is_up and cell_data.oid ~= self.m_model.m_select_hero_id)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish", "UnionWar_str_029")
end

function M:destroy()
	M.super.destroy(self)
end

return M