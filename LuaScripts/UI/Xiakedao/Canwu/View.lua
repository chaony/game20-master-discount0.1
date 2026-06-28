---@class CanwuView:OOPopBase
local M = class("CanwuView",LikeOO.OOPopBase)

M.m_uiName = "HangReward/HangReward"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "UI.Xiakedao.Canwu.CanwuEarningsNode", text_key = "tog_1_text",show_text_lan_id = "new_str_1121", show_text = "挂机收益" , red_point_img = "battle_red_point_img"}, -- 收益
	{btn_key = "tog_2", lua_name = "UI.HangReward.HongQuickNode", text_key = "tog_2_text",show_text_lan_id = "handreward_type_2", show_text = "快速挂机" , red_point_img = "battle_red_point_img"}, -- 快速
	--{btn_key = "tog_3", lua_name = "UI.HangReward.HongEventNode", text_key = "tog_3_text", show_text = "事件" , red_point_img = "battle_red_point_img"}, -- 事件
}
M.COMMON_COLLOR_1 =  Color( 252/255, 255/255, 242/255, 1)
M.COMMON_COLLOR_2 =  Color( 156/255, 214/255, 218/255, 1)
function M:onEnter()
	self.m_toggle_btns = {}
	self.m_content_panel = self:findGameObject("content_panel")
	self.reward_grid = self:findGameObject("reward_grid")
	for k,v in pairs(__TAB_BTN_NODE) do
		--self:setTextByLanKey(v.text_key, v.show_text_lan_id)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end
	-- self:switchTabUpdate(true, self.m_model.m_open_tab_index)
	self:setObjectVisible("tog_3", false)	
	--self:setObjectVisible("Tog_Group", GameVersionConfig.Is_BIGGAMEAPP)
	self:setObjectVisible("Tog_Group", false)
	self:refreshRedPoint()
end

function M:refreshUI()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
	self:refreshRedPoint()
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
	self:setTextByLanKey("title_text", __TAB_BTN_NODE[index].show_text_lan_id)
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
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:setTime()
	if self.m_cur_tab_node and self.m_cur_tab_node.setTime then
		self.m_cur_tab_node:setTime()	
	end
end

function M:creatReward(normal_reward)
	local rewards = RewardUtil:mergeRewardAndFormat(normal_reward)
	local num = #rewards
	self.m_item = {}
	local mystic_piece_flag = false
	for i = 1, num do
		local data = rewards[i]
		local item = GameUtil:createItemElement(data, false, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		if self.m_item[i] == nil then
			self.m_item[i] = {}
			self.m_item[i].obj = item
		end
	end
	self:itemFlyAction()
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
	local delay = 0
	local target = self.m_model:getTarget()
    for k, v in pairs(self.m_item) do
		self:flyMove(v.obj, delay, target)
		delay = delay + 0.03
		if v.type == RewardUtil.REWARD_TYPE_KEYS.COIN or v.type  == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
			for i = 1, 8 do
				local item_obj = U3DUtil:Instantiate( v.obj );
				local random_y = Mathf.Random(10,200)
				local pos = v.obj.transform.localPosition + Vector3(4 * i, random_y, 0)
				self:flyMove(item_obj, delay, target, pos)
				delay = delay + 0.03
			end
		end
    end
end

function M:flyMove( obj, delay, target, pos )
	obj.transform:SetParent(static_rootControl.m_view.m_ui_obj.transform, true)
	obj.transform.localScale = Vector3(1,1,1)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour then
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)  
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text_bg_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text", false)
	end
	if pos ~= nil then
		obj.transform.localPosition = pos;
	end
	local tweener = obj.transform:DOScale(0.4, 1)
	CS.wt.framework.TweenTool.Bezier(
			obj,
			target.transform,
			0.6,
			CS.wt.framework.BezierType.Bezier_Level2,
			delay,
			false,
			function()
				tweener:Kill()
				UIUtil.destroyObject(obj)
				static_rootControl:updateMsg("bag_action", nil, "parent")
			end
	)
end

function M:refreshQuickPop()
	if self.m_cur_tab_node then
        self.m_cur_tab_node:setGetImg()
    end
end

function M:refreshRedPoint()
	local red_flag = RedPointUtil:isFuncRedPointById(8)
	self:setObjectVisible("tog_2_red_point_img", red_flag == true)
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end


return M