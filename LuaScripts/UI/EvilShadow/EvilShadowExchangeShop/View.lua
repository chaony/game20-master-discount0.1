local M = class("EvilShadowExchangeShopView",LikeOO.OOPopBase)

M.m_uiName = "EvilShadow/EvilShadowExchangeShop"
M.m_size_type = 3
M.m_iphoneXAdapter = true


function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1, item_id = 5354})
	self:setTextByLanKey("common_title_text", "evil_shadow_str_011")
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowExchange")
end

function M:refreshUI()
	self:refreshTaskList()
end

function M:refreshTaskList()
	local data = self.m_model:getExchangeShopData()
	if self.m_taskScroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:refreshTaskItem(cell_obj, cell_data,false)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "btn_goBtn" or click_name == "btn_canGotBtn" then
					audio:SendEvtUI("UI_Tab_N5")
					if cell_data.curExchangeCount >= cell_data.allCount then
						GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("doubleFestival_text_0025"), delay_close = 2})
						return
					end
					if cell_data.userNum < cell_data.needNum then
						GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("doubleFestival_text_0026"), delay_close = 2})
						return
					end
					local params = {gift_id = cell_data.id}
					self.m_control:updateMsg("btn_gotShopTaskBtn", params)
				end
			end
		}
		self.m_taskScroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_taskScroll_view:reloadData(data, true)
	end
end

function M:refreshTaskItem(cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local transform = cell_obj.transform
		local xlsxData = cell_data.xlsxData
		local needAwardData = xlsxData.need_reward[1]
		local awardDatas = xlsxData.out_reward
		---- 奖励
		for i = 1, 3 do
			local awardData = (i == 1) and needAwardData or awardDatas[(i - 1)]
			local reward_node = UIUtil.findRectTransform(transform, "awardNode"..i)
			UIUtil.destroyAllChild(reward_node)
			if awardData then
				local itemNode = GameUtil:createItemElement(awardData, true, true)
				itemNode.transform:SetParent(reward_node.transform, false)
			end
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_goBtnText","doubleFestival_text_0014")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_canGotBtnText","doubleFestival_text_0014")
		local isCanGot = (cell_data.userNum >= cell_data.needNum) and (cell_data.curExchangeCount < cell_data.allCount)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_canGotBtn", isCanGot)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_goBtn", (not isCanGot))
		local residueCount = (xlsxData.times - cell_data.curExchangeCount)
		residueCount = residueCount > 0 and residueCount or 0
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_residueText","doubleFestival_text_0024", residueCount )
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M