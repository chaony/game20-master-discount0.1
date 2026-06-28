local M = class("HeroBookView", LikeOO.OOPopBase)

M.m_uiName = "HeroBook/HeroBook"
M.m_iphoneXAdapter = true
M.m_size_type = 1

local __TAB_BTN_NODE = {
	{btn = "martial_1_toggle", name = "martial_1_text", race = 1, lua_name = "UI.HeroBook.HeroBookNode1" },
	{btn = "martial_2_toggle", name = "martial_2_text", race = 2, lua_name = "UI.HeroBook.HeroBookNode2"  },
	{btn = "martial_3_toggle", name = "martial_3_text", race = 3, lua_name = "UI.HeroBook.HeroBookNode3"  },
	{btn = "martial_4_toggle", name = "martial_4_text", race = 4, lua_name = "UI.HeroBook.HeroBookNode4"  },
	{btn = "martial_5_toggle", name = "martial_5_text", race = 5, lua_name = "UI.HeroBook.HeroBookNode5"  },
	{btn = "martial_6_toggle", name = "martial_6_text", race = 6, lua_name = "UI.HeroBook.HeroBookNode6"  },
	{btn = "martial_7_toggle", name = "martial_7_text", race = 7, lua_name = "UI.HeroBook.HeroBookNode7"  },
}

function M:onEnter()
	RedPointUtil:saveLocalRedPointFreshTime("tj_lv_up_red_point")
	self.m_content_panel = self:findGameObject("content_panel")
	self.m_cur_tab_node = {}
	self.right_bottom = self:findGameObject("right_bottom")
	self:setTextByLanKey("close_title_text", "hero_ui_str_0016")
    for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
        local have_hero = self.m_model:checkRaceTypeCount(v.race)
        local trans = UIUtil.findImage(tog_btn.gameObject.transform, "Image")
        if not have_hero then
            trans.material = nil
        end
        if i == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
        tog_btn.interactable = not have_hero
		self:setObjectVisible("race_mask_"..i, have_hero == true)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
                self:updateMsg("check_tag", data)
			end 
		end, i, self.m_uiName)
	end
	self.m_model.m_sel_tab_index = self.m_model.m_open_tab_index
	self:switchRacePanel(self.m_model.m_sel_tab_index)
	self:refreshUI()
	self:refreshBottomRedPoint()
end
--- 刷新金木水火红点
function M:refreshBottomRedPoint()
	local race_list = self.m_model:getCanHeroRoleType()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local red_point_img = UIUtil.findImage(tog_btn.gameObject.transform, "red_point_img")
		if table.indexof(race_list, v.race) then
			red_point_img.gameObject:SetActive(true)
		else
			red_point_img.gameObject:SetActive(false)
		end
	end
end

function M:refreshUI()
	UIUtil.destroyAllChild(self.right_bottom.transform)
	local rewardNode = self.m_model:getAllReward()
	if rewardNode[3] > 0 then
		self.rewardItem = GameUtil:createItemElement(rewardNode, true, false, function ()
			self:updateMsg("get_reward")
		end)
		self.rewardItem.transform:SetParent(self.right_bottom.transform, false)
	end
	if self.m_model.active_num and  self.m_model.active_num > 0 then
		local str_show = Language:getTextByKey("hero_ui_str_0019", self.m_model.active_num)
		self:setTextByLanKey("get_text", "hero_ui_str_0019", self.m_model.active_num)
		self:setObjectVisible("get_text", true)	
	else
		self:setObjectVisible("get_text", false)	
	end
end

function M:itemFlyAction(obj)
	local target = self:findGameObject("right_bottom")
	self:flyMove(obj,0.1,target)
end

function M:flyMove(obj, delay, target)
	obj.transform:SetParent(self.m_ui_obj.transform, true)
	obj.transform.localScale = Vector3(1,1,1)	
	local tweener = obj.transform:DOScale(0.8, 1)
	CS.wt.framework.TweenTool.Bezier(
			obj,
			target.transform,
			0.5,
			CS.wt.framework.BezierType.Bezier_Level2,
			delay,
			true,
			function()
				tweener:Kill()
				self:creatTx()
				UIUtil.destroyObject(obj)
			end
	)
end

function M:creatTx()
	if self.rewardItem then
		if self.jihuo_02 == nil then
			self.jihuo_02 = self:creatJiHuo_002(self.rewardItem.transform)
			self.m_control:setOnceTimer(1.5, function()
				ResourceUtil:ReturnItem(self.jihuo_02)
				self.jihuo_02 = nil
			end )
		end
	end
end


function M:creatJiHuo_002(parent)
	local gift_item = ResourceUtil:GetUIEffectItem("HeroBook/UI_HeroBook_JiHuo_002", Vector3.zero, nil)
	gift_item.transform:SetParent(parent, false)
	return gift_item
end


function M:switchTabNode(index)
	if self.m_cur_tab_node[index] then
		for k,v in pairs(self.m_cur_tab_node) do
			if index == k then
				v:moveIn()
			else
				v:moveOut()
			end
		end
		return
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    local tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
		self.m_cur_tab_node[index] = tab_node
		for k,v in pairs(self.m_cur_tab_node) do
			if index == k then
				v:moveIn()
			else
				v:moveOut()
			end
		end
	end
end

function M:switchRacePanel(index)
	self:switchTabNode(index)
end

function M:refreshRedPoint()
	if self.m_cur_tab_node[self.m_model.m_sel_tab_index] then
		self.m_cur_tab_node[self.m_model.m_sel_tab_index]:updateHeroUIInfo()
	end
end

function M:destroy()
	for k,v in pairs(self.m_cur_tab_node) do
		v:destroy()
	end
	self.m_cur_tab_node = {}
    M.super.destroy(self)
end

return M
