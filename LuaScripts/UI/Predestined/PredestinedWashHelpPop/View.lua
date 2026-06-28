local M = class("PredestinedWashHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "Predestined/PredestinedWashHelpPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "predestined_str_023")
	self.time_text = self:findText("time_text")
	self.m_gray_img = self:findImage("gray_img")
	self.m_is_update = true
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	self.m_gift_tab = {}
	local data = self.m_model:get_ladderGiftData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
				self:updateCell(cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local cfg = cell_data.xlsxData
				if cfg.price == 0 then
					self:updateMsg("get_free_ladder_gift", { id = cfg.id} )
				else
					self:updateMsg("buy", cell_data.xlsxData.charge_id)
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data, true)
	end
end

function M:updateCell(itemObj, data)
	if IsNull(itemObj) then
		return
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(itemObj)
	if not luaBehaviour then
		return
	end
	-- 奖励
	--local transform = itemObj.transform
	local giftData = data
	if not giftData then
		return
	end
	local xlsxData = giftData.xlsxData
	local awardData = {}
	table.insert(awardData, xlsxData.return_money[1])
	for k,v in ipairs(xlsxData.reward) do
		table.insert(awardData, v)
	end
	local reward_node = luaBehaviour:FindGameObject("itemParent")
	UIUtil.destroyAllChild(reward_node.transform)
	for k,v in ipairs(awardData) do
		local itemNode = GameUtil:createItemElement(v, true, true)
		itemNode.transform:SetParent(reward_node.transform, false)
	end

	-- 按钮
	local btn_buyBtn = luaBehaviour:FindGameObject("buy_btn")
	UIUtil.setButtonClick(
			btn_buyBtn.transform,
			function()
				if giftData.isCanBuy == true then
					if xlsxData.price_type == 1 or xlsxData.price == 0 then --元宝购买
						self:updateMsg("get_free_ladder_gift", { id = xlsxData.id})
					elseif xlsxData.price_type == 2 then --花钱购买
						self.m_control:buyForSDK(xlsxData.charge_id)
					end
				end
			end
	)
	--LuaBehaviourUtil.setImg(luaBehaviour, "btn_awardBtn", xlsxData.background, "item_icon")

	-- LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_itemHint", "petard_text_0020", xlsxData.return_per)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", xlsxData.gift_name .. xlsxData.return_moneyper)

	local refresh = xlsxData.refresh or 0 -- 0不限次  1每日刷新 2 每期刷新
	if xlsxData.time_limit <= 0 then --限购次数为0，也算不限次
		refresh = 0
	end
	if refresh == 0 then -- 无限制
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"times_text", "new_str_0729")
	else
		local count = xlsxData.time_limit - giftData.buyCount
		if count <= 0 then
			LuaBehaviourUtil.setText(luaBehaviour, "times_text", "")
		else
			if refresh == 1 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"times_text", "new_str_1025", count)
			else
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"times_text", "new_str_0796", count)
			end
		end
	end

	local isCanBuy = xlsxData.time_limit - giftData.buyCount > 0 or refresh == 0
	local priceFormat = Language:getTextByKey("petard_text_0018")
	if isCanBuy then
		priceFormat = xlsxData.price <= 0 and Language:getTextByKey("predestined_str_026") or Language:getTextByKey("petard_text_0011", xlsxData.price)
	end
	--local priceFormat = (not isCanBuy) and Language:getTextByKey("petard_text_0018") or Language:getTextByKey("petard_text_0011",xlsxData.price)
	LuaBehaviourUtil.setText(luaBehaviour, "buy_btn_text", priceFormat)
	local btn_buyBtnImg = luaBehaviour:FindImage("buy_btn")
	if not giftData.isCanBuy then
		btn_buyBtnImg.material = self.m_gray_img.material
	else
		btn_buyBtnImg.material = nil
	end
end

function M:updateTime()
	if self.m_is_update == false then
		return
	end
	local next_fresh_time = TimeUtil.getIntTimestamp(UserDataManager.m_gacha_predestined_end)
	local end_ts = next_fresh_time + 24 * 3600
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time, 2)
		self.time_text.text = Language:getTextByKey("predestined_str_024", text)
	else
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self.time_text.text = Language:getTextByKey("gf_str_0085")
		--self:updateMsg("time_end")
		self.m_is_update = false
	end
end

return M