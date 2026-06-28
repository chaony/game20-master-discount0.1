---@class HeroBagView:OOPopBase
---@field m_model HeroBagModel
local M = class("HeroBagView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroBag"
M.m_iphoneXAdapter = true
M.m_left_node = nil
M.m_center_node = nil
M.m_right_node = nil

M.lua_name1 = "UI.HeroBag.HeroBagListNode"
M.lua_name2 = "UI.HeroBag.HeroBagHeroNode"
M.lua_name3 = "UI.HeroBag.HeroBagDescNode"

local __TAB_BTN_NODE = { 
	{name = "center", lua_name = "UI.HeroBag.HeroBagHeroNode"}, -- 英雄
	{name = "left", lua_name = "UI.HeroBag.HeroBagListNode"}, -- 背包
	{name = "right", lua_name = "UI.HeroBag.HeroBagDescNode"}, -- 详情
}

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

function M:onEnter()
	self.m_content_panel = self:findGameObject("content_panel")
	self.m_hero_bag_bg = self:findGameObject("HeroBag_bg")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 8})
	self.m_cur_tab_node = {}
	self:updateAttrMoney()
	self:setTextByLanKey("close_title_text", "new_str_0012")
	for k,v in pairs(__TAB_BTN_NODE) do
		--if v.name ~= "right" then
			local tab_cls = CustomRequire(v.lua_name)
			local temp_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
			temp_node:InitType(self.m_model.m_type, true)
			self.m_cur_tab_node[v.name] = temp_node
			self:setHeroBagBg()
		-- else
		-- 	self.m_control:setOnceTimer(0.3, function ()
		-- 		local tab_cls = CustomRequire(v.lua_name)
		-- 		local temp_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
		-- 		temp_node:InitType(self.m_model.m_type, true)
		-- 		self.m_cur_tab_node[v.name] = temp_node	
		-- 	end)
		-- end
	end
	if self.m_bg_scale ~= 1 then
        local bg_node = self:findGameObject("bg_obj")
        UIUtil.setScale(bg_node.transform, self.m_bg_scale)
	end
	UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
	self.m_control:refreshSortBtn()
	--快速导航
	if self.m_model.m_is_quick_open_needed == true then
		self:setObjectVisible("guide_btn", true)
		local guide_btn_obj = self:findGameObject("guide_btn")
		if guide_btn_obj then
			guide_btn_obj.transform.localPosition = Vector3(190, -22.9, 0)
		end
	end
	self:setObjectVisible("combat_suppress_btn",false)
end

function M:fingerSliding(locat)
	if locat then
		self:updateMsg("Sliding_right")
	else
		self:updateMsg("Sliding_left")
	end
end

function M:refreshMaskStatus()
	local left_node = self.m_cur_tab_node["left"]
	if left_node then
		left_node:refreshMaskStatus()
	end
end

function M:switchType(type)
	self.m_model.m_type = type
	-- for k,v in pairs(self.m_cur_tab_node) do
	-- 	v:InitType(self.m_model.m_type, false)
	-- end
	for k,v in ipairs(__TAB_BTN_NODE) do
		local node = self.m_cur_tab_node[v.name]
		if node then
			node:InitType(self.m_model.m_type, false)
		end 
	end
	if type == 2 then
		self:runAnim("HeroBag_bg_1")
	elseif type == 1 then
		self:runAnim("HeroBag_bg_2")
	end
	--self:setCombatRepressVisible()
end

function M:setCanvas(obj)
	local m_canvas = obj:GetComponent("Canvas")
	m_canvas.sortingOrder = self.m_sortOrder + 100
end

function M:refreshUI(data, ref_tab_key)
	self:updateAttrMoney()
	if ref_tab_key == nil then
		for k,v in ipairs(__TAB_BTN_NODE) do
			local node = self.m_cur_tab_node[v.name]
			if node then
				node:refreshUI(data)
			end 
		end
	else
		for k,v in pairs(self.m_cur_tab_node) do
			if ref_tab_key[k] then 
				v:refreshUI(data)
			end
		end	
	end
	local last_lv = self.m_model.last_lv
	local cur_lv = self.m_model:getHero_lv()
	local cur_comb = self.m_model:getHero_Combat()
	local last_comb = self.m_model.last_combat or cur_comb
	if cur_lv > last_lv then
		self.m_model:detectionAttrs()
	end
	if cur_comb ~= last_comb then
		self.m_model:detectionAttrs()
	end
	self:setHeroBagBg()
end

function M:showFriendLevelUpEft()
	local right_node = self.m_cur_tab_node["right"]
	if right_node then
		right_node:showFriendLevelUpEft()
	end
end

function M:refreshLevelUpUI()
	self:updateAttrMoney()
	local right_node = self.m_cur_tab_node["right"]
	local center_node = self.m_cur_tab_node["center"]
	if right_node then
		right_node:refreshLevelUpUI()
	end
	if center_node then
		center_node:refreshLevelUpUI()
	end
	local last_lv = self.m_model.last_lv
	local cur_lv = self.m_model:getHero_lv()
	local cur_comb = self.m_model:getHero_Combat()
	local last_comb = self.m_model.last_combat or cur_comb
	if cur_lv > last_lv then
		self.m_model:detectionAttrs()
	end
	if cur_comb ~= last_comb then
		self.m_model:detectionAttrs()
	end
end

function M:updateAttrMoney()
	local item_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0})
	local new_tab = {}
	new_tab[self.m_model.data_coin.data_type] =  self.m_model.data_coin.user_num
	new_tab[self.m_model.data_exp.data_type] =  self.m_model.data_exp.user_num
	new_tab[RewardUtil.REWARD_TYPE_KEYS.DUST] =  item_data.user_num
	if self.m_attr_node.initiativeRefresh then
		--英雄升级为前端升级、扣除金币更新数值
		self.m_attr_node:initiativeRefresh(new_tab)
	end
end

function M:refreshRedPoint()
	for k,v in pairs(self.m_cur_tab_node) do
		if v.refreshRedPoint then
			v:refreshRedPoint()
		end
	end
end

function M:switchHeroTypeBtn()
	local cur_node = self.m_cur_tab_node["left"]
	if cur_node then
		cur_node:switchHeroBtnType()
	end
end

function M:updateSelectHero()
	local cur_node = self.m_cur_tab_node["left"]
	if cur_node then
		cur_node:updateSelectHero()
	end
	local right_node = self.m_cur_tab_node["right"]
	if right_node then
		right_node:updateSelectHero()
	end
end

function M:refreshFettersItem()
	local right_node = self.m_cur_tab_node["right"]
	if right_node then
		right_node:refreshFettersItem()
	end
end

function M:updateHerosScroll()
	local cur_node = self.m_cur_tab_node["left"]
	if cur_node then
		cur_node:switchRaceScroll()
	end
end

function M:switchTabNode(index)
	for k,v in ipairs(__TAB_BTN_NODE) do
		local node = self.m_cur_tab_node[v.name]
		if node and node.switchTabNode then
			node:switchTabNode(index)
		end 
	end
	-- for k,v in pairs(self.m_cur_tab_node) do
	-- 	if v.switchTabNode then
	-- 		v:switchTabNode(index)
	-- 	end
	-- end
end

function M:changeTab(index)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node then
		cur_node:changeTab(index)
	end
end

function M:updateSkillRedPoint(index, bl)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node then
		cur_node:updateSkillRedPoint(index, bl)
	end
end

function M:creatCurEffect(index, new_bl)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node then
		cur_node:creatCurEffect(index, new_bl)
	end
end

function M:creatJuQiEffect(auto,sig_data,callback)
	local cur_node = self.m_cur_tab_node["center"]
	if cur_node and self.m_model.m_sel_tab_index == 2 then
		cur_node:creatCurEffect(auto,sig_data,callback)
	end
end

function M:playSigEffect(auto)
	local cur_node = self.m_cur_tab_node["center"]
	if cur_node and cur_node.playSigEffect and self.m_model.m_sel_tab_index == 2 then
		if auto ~= 1 and auto ~= 0 then
			cur_node:playSigEffect()
		end
	end
end

function M:playSigBreachEffect(callback)
	local cur_node = self.m_cur_tab_node["center"]
	if cur_node and cur_node.playSigBreachEffect and self.m_model.m_sel_tab_index == 2 then
		cur_node:playSigBreachEffect(callback)
	end
end

function M:switchMeridianByIndex(index)
	local cur_node = self.m_cur_tab_node["center"]
	if cur_node and self.m_model.m_sel_tab_index == 2 then
		cur_node:switchMeridianByIndex(index)
		local cur_node = self.m_cur_tab_node["right"]
		if cur_node then
			cur_node:refreshUI()
		end
	end
end

function M:updateEquipState(bl)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node and self.m_model.m_sel_tab_index == 1 then
		cur_node:updateEquipState(bl)
	end
end

function M:sliderTop()
	local cur_node = self.m_cur_tab_node["left"]
	if cur_node and self.m_model.m_sel_tab_index == 1 then
		cur_node:sliderTop()
	end
end

function M:enterHideSkillRedPoint()
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node and self.m_model.m_sel_tab_index == 1 then
		cur_node:enterHideSkillRedPoint()
	end
end

function M:refreshFetterRedPoint()
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node and self.m_model.m_sel_tab_index == 4 then
		cur_node:hideRedPoint()
	end
end

function M:getSkillIcon(index)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node and self.m_model.m_sel_tab_index == 1 then
		return cur_node:getSkillIcon(index)
	end
	return nil
end

function M:getBreakSkillIcon(name)
	local cur_node=self.m_cur_tab_node["center"]
	if cur_node then
		return cur_node:getSkillIcon(name)
	end
	return nil
end

function M:setShowQuickLevelUp(lv)
	local cur_node = self.m_cur_tab_node["right"]
	if cur_node and self.m_model.m_sel_tab_index == 1 then
		cur_node:setShowQuickLevelUp(lv)
	end
end
-- 刷新图鉴红点
function M:refreshTJRedPoint()
	if self.m_cur_tab_node["left"] then
		self.m_cur_tab_node["left"]:refreshTJRedPoint()
	end
end

--设置英雄背景
function M:setHeroBagBg()
	local hero_Data = self.m_model:getSelectHeroData()
	local star_id,is_fate = self.m_model:getFatesInfo(hero_Data.oid)
	local bg_img_name = is_fate and "a_tmhx_hero_bg" or "a_ws_bg"
	GameUtil:updateResourcesImg(self.m_hero_bag_bg,"Texture/"..bg_img_name)
end

--设置战力压制的值
function M:setCombatRepressText()
	local _,nums = GameUtil:countCombatRepressGrade(self.m_model.m_selected_id)
	local _,nums2 = GameUtil:countGlobalCombatRepressGrade()
	self:setTextByLanKey("main_bd_btn_text", "combat_suppress_system_text_003",nums+nums2)
end

--隐藏战力压制的UI
function M:setCombatRepressVisible()
	if self.m_model.m_type == 2 and self.m_model.m_sel_tab_index == 1 and BtnOpenUtil:isBtnOpen(402) then
		self:setObjectVisible("combat_suppress_btn",true)
		self:setCombatRepressText()
	else
		self:setObjectVisible("combat_suppress_btn",false)		
	end
end

function M:destroy()
	for k,v in pairs(self.m_cur_tab_node) do
		v:destroy()
	end
	if  table.nums(self.m_cur_tab_node) > 0 then
		self.m_cur_tab_node = {}
	end 
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end
--------------------------------------------------------符篆
function M:updateCurrentView()
	local temp_node = self.m_cur_tab_node["center"]
	 if temp_node then
		 temp_node:updateCurrentView(self.m_model.is_open_type)
	 end
end

return M