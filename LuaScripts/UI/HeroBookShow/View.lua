local M = class("HeroBookShowView",LikeOO.OOPopBase)

M.m_uiName = "HeroBookShow/HeroBookShow"
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "UI.HeroBookShow.HeroDescNode", text_name = "tog_1_text", text_key = "简介", red_point_img = "tog_1_red_point_img" },
	--{btn_key = "tog_2", lua_name = "UI.HeroBookShow.HeroMeridianNode", text_name = "tog_2_text", text_key = "经脉", red_point_img = "tog_2_red_point_img" },
	{btn_key = "tog_3", lua_name = "UI.HeroBookShow.HeroInfoNode", text_name = "tog_3_text",  text_key = "逸闻", red_point_img = "tog_3_red_point_img" },
}

function M:onEnter()
	self.m_content_panel = self:findGameObject("content_panel")
	local tog_group = self:findGameObject("scroll_content")
	self.m_tog_group = UIUtil.findComponent(tog_group.transform, typeof(U3DUtil:Get_ToggleGroup()))
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end
	if self.m_model.m_type == 1 then
		self:setObjectVisible("bottom_img", false)
		--self:updateLoopScroll()
	else
		self:setObjectVisible("bottom_img", false)	
	end
	self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index, first_enter)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if index == 1 then
		self:setTextByLanKey("close_title_text", "简介")
	elseif index == 2 then
		self:setTextByLanKey("close_title_text","逸闻")
	end
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:refreshUI()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
	self:updateToggle()
end

function M:changeOffset(bl)
	local gg = 0
	if bl == true then
		gg = -1
	else
		gg = 1
	end
	if self.m_loop_scroll_view then
		self.m_loop_scroll_view:moveHorizontalPage(gg)
	end
end

function M:refreshRedPoint()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshRedPoint()
	end
end

function M:clickTips(msg)
	if self.m_cur_tab_node  and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:clickTips(msg)
	end
end

function M:changeTab(index)
	self.m_toggle_btns[index].isOn = true
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
	if self.m_model.m_type ~= 1 then
		return
	end
    self.m_hero_cell_tab = {} --缓存英雄数据
    local data = self.m_model.m_book_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_hero_cell_tab[index] = {obj = cell_object, data = cell_data}
				self:updateHeroData(cell_object, cell_data)
				local tog_btn = UIUtil.findToggle(cell_object.transform)
				tog_btn.isOn = cell_data.id == self.m_model.m_cur_id
				tog_btn.group = self.m_tog_group
				UIUtil.addToggleListener(tog_btn, function(is_on) self:switchHeroTabUpdate(is_on, cell_data) end,nil,self.m_uiName)
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateToggle()
	if self.m_hero_cell_tab then
		for k,v in pairs(self.m_hero_cell_tab) do
			if v.data.id == self.m_model.m_cur_id then
				local tog_btn = UIUtil.findToggle(v.obj.transform)
				tog_btn.isOn = true
			end
		end
	end
end

function M:updateHeroData(obj , data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local cfg = self.m_model:getCfgByCid(data.id)
	if LuaBehaviour then
		local farm = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cfg.evo]
		LuaBehaviourUtil.setImg(LuaBehaviour,"quality_img", "a_"..farm.frame_name.."_s" ,"hero_head_ui")
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "name_text", Language:getTextByKey(cfg.name))
	end
end

function M:switchHeroTabUpdate(is_on, cell_data)
	if is_on then
		self:updateMsg("change_hero", cell_data)
	end
end

return M