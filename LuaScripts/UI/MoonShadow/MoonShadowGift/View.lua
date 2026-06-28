local M = class("MoonShadowGiftView",LikeOO.OOPopBase)

M.m_uiName = "MoonShadow/MoonShadowGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "moon_shadow_str_003")
	self.m_node_cache = {}
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("MoonShadowGift")
end

--刷新UI
function M:refreshUI()
	local attr_mode = 1
	if self.m_model.is_tokens == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	self:updateBagNode()
end

function M:updateBagNode()
	for index = 1, 4 do
		local data = self.m_model:getShowData(index)
		
		if self.m_node_cache[index] == nil then
			self.m_node_cache[index] = {}
		end
		if self.m_node_cache[index].luaBehaviour == nil then
			local name = "bag_node_" .. index
			local object = self:findGameObject(name)
			local transform = object.transform
			self.m_node_cache[index].luaBehaviour = UIUtil.findLuaBehaviour(transform)
		end
		if data == nil or data.times and data.time_limit and data.times >= data.time_limit then --购买次数已满，或者数据非法时，锁住购买按钮
			local bg_img = self.m_node_cache[index].luaBehaviour:FindGameObject("bg_img")
			GameUtil:updateResourcesImg(bg_img, "Texture/moon_shadow/a_yycs_yilinqulibaochendi")
			local btn_buy = self:findButton("buy_btn_" .. index)
			btn_buy.enabled = false
		end
		if data then
			LuaBehaviourUtil.setTextByLanKey(self.m_node_cache[index].luaBehaviour, "title_text", data.gift_name)
			local price_str = "免费"
			if data.price ~= nil and data.price ~= 0 then
				price_str = data.price .. "元"
			end
			LuaBehaviourUtil.setText(self.m_node_cache[index].luaBehaviour, "buy_text", price_str)
			self:updateLoopscroll(index, data.reward)
		end
	end
end

function M:updateLoopscroll(node_index, data)
	if self.m_node_cache[node_index].looscrollview == nil then
		local loopscroll = self.m_node_cache[node_index].luaBehaviour:FindGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			init_cell = function(index, cell_object)
				local cell_data = data[index]
				local itemNode = GameUtil:createPrefab("Common/ItemNode")
				local canvas_group = itemNode:GetComponent("CanvasGroup")
				canvas_group.blocksRaycasts = false
				itemNode.name = "cell_content"
				itemNode.transform:SetParent(cell_object.transform, false)
				if cell_data then
					self:updateLoopscrollCell(index, itemNode, cell_data)
				end
			end,
			update_cell = function(index, cell_object, cell_data)
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if not IsNull(content_tran) then
					self:updateLoopscrollCell(index, cell_object, cell_data)
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_node_cache[node_index].looscrollview = LoopScrollViewUtil.new(params)
	else
		self.m_node_cache[node_index].looscrollview:reloadData(data)
	end
end

function M:updateLoopscrollCell(index, cell_object, cell_data)
	local item_data = RewardUtil:getProcessRewardData(cell_data)
	GameUtil:updateItemElementByData(cell_object, item_data, true, true)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end


return M