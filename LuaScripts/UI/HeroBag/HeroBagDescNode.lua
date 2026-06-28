---@class HeroBagDescNode:OOUIbase
local M = class("HeroBagDescNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroBagDescNode"

local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", lua_name = "UI.HeroBag.HeroAttributeNode", text_name = "tog_1_text", text_key = "hero_ui_str_0002", red_point_img = "tog_1_red_point_img" }, -- 属性
	{btn_key = "tog_2", lua_name = "UI.HeroBag.HeroMeridianNode", text_name = "tog_2_text", text_key = "hero_ui_str_0006", red_point_img = "tog_2_red_point_img" }, -- 经脉
	{btn_key = "tog_3", lua_name = "UI.HeroBag.HeroBagNode", text_name = "tog_3_text",  text_key = "hero_ui_str_0010", red_point_img = "tog_3_red_point_img" }, -- 逸闻
	{btn_key = "tog_4", lua_name = "UI.HeroBag.HeroFriendShipNode", text_name = "tog_4_text",  text_key = "hero_ui_str_0013", red_point_img = "tog_4_red_point_img",open_id = 181 }, -- 羁绊(8.6改为好友度)
	{btn_key = "tog_5", lua_name = "UI.HeroBag.HeroSkinNode", text_name = "tog_5_text",  text_key = "hero_ui_str_0024", red_point_img = "tog_5_red_point_img"}, -- 皮肤
	{btn_key = "tog_6", lua_name = "UI.HeroBag.HeroDestinyStar", text_name = "tog_6_text",  text_key = "destinyStar_text_0010", red_point_img = "tog_6_red_point_img" }, -- 天命
	{btn_key = "tog_7", lua_name = "UI.HeroBag.HeroAwakeSystem", text_name = "tog_7_text",  text_key = "awake_system_text_0010", red_point_img = "tog_7_red_point_img" }, -- 登仙
	{btn_key = "tog_8", lua_name = "UI.HeroBag.HeroEchoNode", text_name = "tog_8_text",  text_key = "hero_ui_str_0049", red_point_img = "tog_8_red_point_img" }, -- 共鸣
}

function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
		if v.open_id then
			self:setObjectVisible(v.btn_key, BtnOpenUtil:isBtnOpen(v.open_id) == true)
		end
    end     
	--self:switchTabNode(self.m_model.m_open_tab_index)
	if self.m_model.m_select_oid and self.m_model.m_type == 2 then
		self:refreshUI()
		self.m_control:setOnceTimer(0.05, function ()
			self:changeTab(self.m_model.m_open_tab_index)
		end)
	end
end

function M:InitType(c_type, first)
	if c_type == 1 then
		local move_x = self.m_model:getCurMoveX(877.5, self.m_control.m_view.m_view_width)
		if first == false then
			local callback = function ()
				self.m_rt.gameObject:SetActive(false)
			end
			GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
		else
			self.m_rt.localPosition = Vector3.New(move_x,0,0)
		end
    elseif c_type == 2 then
		self.m_rt.gameObject:SetActive(true)
		local move_x = self.m_model:getCurMoveX(377.5, self.m_control.m_view.m_view_width)
		if first == false then
			GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
		else
			self.m_rt.localPosition = Vector3.New(move_x,0,0)
		end
	else
		local move_x = self.m_model:getCurMoveX(377.5, self.m_control.m_view.m_view_width)
        self.m_rt.localPosition = Vector3.New(move_x,0,0)
        self.m_rt.gameObject:SetActive(true)
    end
	if first == false then
	    self:refreshUI()	
	else 
		if self.m_model.m_mode == 3 then
			self:refreshUI()
		end	
	end

end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:changeTab(index)
	for k,v in pairs(self.m_toggle_btns) do
		self.m_toggle_btns[k].isOn = k == index
	end
end

function M:switchTabNode(index)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	local btn_tab = __TAB_BTN_NODE[index]
	for k,v in pairs(__TAB_BTN_NODE) do
		local tog_text = self:findText(v.text_name)
		if index == k then
			tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
		else
			tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
		end
	end
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:getSkillIcon(index)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		return self.m_cur_tab_node:getSkillIcon(index)
	end
	return nil
end

function M:setShowQuickLevelUp(lv)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:setShowQuickLevelUp(lv)
	end
end

function M:refreshUI(data)
	for k,v in pairs(__TAB_BTN_NODE) do
		local btn_tab = __TAB_BTN_NODE[k]
		if btn_tab.btn_key == "tog_2" then
			local tog_btn = self.m_toggle_btns[k]
			if self.m_model.m_hero_list_type == 2 or self.m_model:IsLink() == true then
				tog_btn.gameObject:SetActive(false)
			else
				tog_btn.gameObject:SetActive(self.m_model:checkInitEvo() == true)
			end
		elseif btn_tab.btn_key == "tog_3" then
			local tog_btn = self.m_toggle_btns[k]
			--if self.m_model.m_mode == 3 then
				tog_btn.gameObject:SetActive(false)
			--end
		elseif btn_tab.btn_key == "tog_4" then 
			local tog_btn = self.m_toggle_btns[k]
			if self.m_model.m_mode == 3 or self.m_model:checkOpenFriendShip() == false then
				tog_btn.gameObject:SetActive(false)
			else
				tog_btn.gameObject:SetActive(true)
			end
		elseif btn_tab.btn_key == "tog_5" then
			local tog_btn = self.m_toggle_btns[k]
			local btn_show = self.m_model:getHeroSkinBtnShow()
			tog_btn.gameObject:SetActive(btn_show)
			if not btn_show and k == self.m_model.m_sel_tab_index then
				self:switchTabUpdate(true, 1)
			end
		elseif btn_tab.btn_key == "tog_6" then
			local tog_btn = self.m_toggle_btns[k]
			local btn_show = self.m_model:getHeroStarBtnShow()
			tog_btn.gameObject:SetActive(btn_show)
			if not btn_show and k == self.m_model.m_sel_tab_index then
				self:switchTabUpdate(true, 1)
			end
		elseif btn_tab.btn_key == "tog_7" then
			local tog_btn = self.m_toggle_btns[k]
			local btn_flag = self.m_model:dealState()
			tog_btn.gameObject:SetActive(btn_flag ~= 0)
			--local data, cfg = self.m_model:getSelectHeroData()
			--tog_btn.gameObject:SetActive(btn_flag ~= 0 and cfg.is_sp == 0) -- 非SP侠客显示登仙
		elseif btn_tab.btn_key == "tog_8" then
			local tog_btn = self.m_toggle_btns[k]
			tog_btn.gameObject:SetActive(false)
			--local data, cfg = self.m_model:getSelectHeroData()
			--tog_btn.gameObject:SetActive(data.evo >= 19 and cfg.is_sp == 1) --彩色品质的SP侠客显示共鸣
		end
		if btn_tab.open_id and self.m_model.m_mode ~= 3 then
			self:setObjectVisible(v.btn_key, BtnOpenUtil:isBtnOpen(v.open_id) == true)
		end
	end
	self:refreshRedPoint()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI(data)
	end
end

function M:refreshLevelUpUI()
	if self.m_cur_tab_node and self.m_cur_tab_node.refreshLevelUpUI then
		self.m_cur_tab_node:refreshLevelUpUI()
	end
end

function M:showFriendLevelUpEft()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:showFriendLevelUpEft()
	end
end

function M:refreshRedPoint()
	if self.m_toggle_btns[4] then
		if self.m_model.m_selected_id and self.m_model.m_mode ~= 3 and BtnOpenUtil:isBtnOpen(181) == true then
			local jb_redPoint = RedPointUtil:checkHeroFrendLevelUp(self.m_model.m_selected_id)
			self:setObjectVisible("tog_4_red_point_img", jb_redPoint == true and self.m_model:checkOpenFriend() == true)  
		else
			self:setObjectVisible("tog_4_red_point_img", false)  
		end
	end
	if self.m_toggle_btns[2] then
		if self.m_model.m_selected_id and self.m_model.m_mode ~= 3 then
			local jb_redPoint = RedPointUtil:checkHeroCanEquipMysticById(self.m_model.m_selected_id)
			jb_redPoint = jb_redPoint or RedPointUtil:checkHeroSigCanLevelUpById(self.m_model.m_selected_id)
			self:setObjectVisible("tog_2_red_point_img", jb_redPoint == true)
		else
			self:setObjectVisible("tog_2_red_point_img", false)
		end
	end
	if self.m_toggle_btns[5] then
		local skip_redPoint = RedPointUtil:checkHeroSkipRedPointById(self.m_model.m_selected_id)
		self:setObjectVisible("tog_5_red_point_img", skip_redPoint == true)
	end
end

function M:hideRedPoint()
	if self.m_toggle_btns[4] then
		self:setObjectVisible("tog_4_red_point_img", false)  
	end
end

function M:updateSkillRedPoint(index, bl)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1  then
		self.m_cur_tab_node:updateSkillRedPoint(index, bl)
	end
end

function M:creatCurEffect(index, new_bl)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:creatCurEffect(index, new_bl)
	end
end

function M:updateEquipState(bl)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:updateEquipState(bl)
	end
end

function M:enterHideSkillRedPoint()
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 and self.m_cur_tab_node.enterSetSkillRedPoint then
		self.m_cur_tab_node:enterSetSkillRedPoint()
	end
end

function M:updateSelectHero()
	if self.m_cur_tab_node and self.m_cur_tab_node.updateSelectHero then
		self.m_cur_tab_node:updateSelectHero()
	end
end


function M:refreshFettersItem()
	if self.m_cur_tab_node and self.m_cur_tab_node.refreshFettersItem then
		self.m_cur_tab_node:refreshFettersItem()
	end
end
function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end


return M