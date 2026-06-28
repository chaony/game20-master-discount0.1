local M = class("QiXiMainView",LikeOO.OOPopBase)

M.m_uiName = "LuckyDog/LuckyDogMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_material = self:findText("material_node")
	self.m_fTime = 0
	self.m_tips_0_text_obj = self:findGameObject("tips_0_text")
	self.m_tips_1_text_obj = self:findGameObject("tips_1_text")
	local tips_text = self.m_model:getNextTips()
	if tips_text then
		self:setObjectVisible("tips_bg_image", true)
		UIUtil.setText(self.m_tips_0_text_obj.transform, tips_text)
		UIUtil.setText(self.m_tips_1_text_obj.transform, self.m_model:getNextTips())
	else
		self:setObjectVisible("tips_bg_image", false)
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
	local active_data = self.m_model:getActiveData() or {}
	self:setText("close_title_text", active_data.name or "")
	self:setTextByLanKey("count_down_title_text", "lucky_dog_005")
	self:setTextByLanKey("score_title_text", "lucky_dog_006")
	self:setTextByLanKey("shop_btn_text", "lucky_dog_002")
	self:refreshUI()
	self.m_update_key = "update_lucky_dog_main"
	GameMain.addUpdate(self.m_update_key, handler(self, self.update))
	RedPointUtil:saveLocalRedPointFreshTime("LuckyDogRedDot")
end

function M:refreshUI()
	self:setText("score_text", self.m_model:getScore())
	self:createLoopScroll()
end

function M:createLoopScroll()
	local data = self.m_model:getGiftData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:updateCell(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("get_gift", cell_data)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:updateCell(index, obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local parent = luaBehaviour:FindGameObject("itemParent")
		UIUtil.destroyAllChild(parent.transform)
		self:creatRewards(parent.transform, cell_data.cfg.reward)

		LuaBehaviourUtil.setSliderValue(luaBehaviour, "times_total_slider", cell_data.amount / cell_data.cfg.count)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "times_total_text", cell_data.amount .. "/" .. cell_data.cfg.count)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "times_self_text", "lucky_dog_003", cell_data.loot_times .. "/" .. cell_data.cfg.limit)
		
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "lucky_dog_001")
		local buy_btn = luaBehaviour:FindImage("buy_btn")
		if cell_data.amount >= cell_data.cfg.count or cell_data.loot_times >= cell_data.cfg.limit then
			buy_btn.material = self.m_gray_material.material
		else
			buy_btn.material = nil
		end
	end
end

function M:creatRewards(parent, rewards)
	UIUtil.destroyAllChild(parent)
	local items = {}
	for k, v in pairs(rewards) do
		local item = GameUtil:createItemElement(v, true, true)
		local data = RewardUtil:getProcessRewardData(v)
		item.transform:SetParent(parent, false)
		items[k] = item
		if data.data_type == 130 then
			GameUtil:creatCommonActiveEffect(item)
		end
	end
	return items
end

function M:update()
	self.m_fTime = self.m_fTime + CS.UnityEngine.Time.deltaTime
	if self.m_fTime >= 5 then
		local up_one = self.m_tips_0_text_obj
		if self.m_tips_1_text_obj.transform.localPosition.y > self.m_tips_0_text_obj.transform.localPosition.y then
			up_one = self.m_tips_1_text_obj
		end
		self.m_tips_0_text_obj.transform.localPosition = self.m_tips_0_text_obj.transform.localPosition + Vector2.New(0, 1)
		self.m_tips_1_text_obj.transform.localPosition = self.m_tips_1_text_obj.transform.localPosition + Vector2.New(0, 1)
		if up_one.transform.localPosition.y >= 30 then
			local tips_text = self.m_model:getNextTips()
			if tips_text then
				UIUtil.setText(up_one.transform, tips_text)
			end
			self:setObjectVisible("tips_bg_image", tips_text ~= nil)
			up_one.transform.localPosition = Vector2.New(0, -30)
			self.m_fTime = 0
		end
	end
end

function M:updateActivityTimer()
	local time_left = self.m_model:getTimeLeft()
	if time_left > 0 then
		self:setTextByLanKey("count_down_text", GameUtil:formatTimeBySecond(time_left))
	else
		self:updateMsg(99999)
		self:updateMsg(99999, nil, "LuckyDog.LuckyDogShop")
		self:updateMsg(99999, nil, "LuckyDog.LuckyDogDrawPop")
	end
end

function M:destroy()
	GameMain.removeUpdate(self.m_update_key)
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M