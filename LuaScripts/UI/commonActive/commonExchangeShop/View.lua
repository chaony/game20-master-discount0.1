local M = class("commonExchangeShopView",LikeOO.OOPopBase)

M.m_uiName = "commonActive/commonExchangeShop"
M.m_size_type = 2
M.m_iphoneXAdapter = true


function M:onEnter()
	self.avtive_data = self.m_model:getActiveData()
	self:setTextByLanKey("close_title_text", self.avtive_data.name)
	self:setTextByLanKey("common_title_text", "evil_shadow_str_011")
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("QiXiExchangeRedDot")
	RedPointUtil:saveLocalRedPointFreshTime("ChivalryFillExchangeShopRedDot")
end

function M:refreshUI()
	self:refreshTaskList()
end

function M:refreshTaskList()
	local data = self.m_model:getExchangeShopData()
	if self.m_taskScroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:refreshTaskItem(cell_obj, cell_data,false)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
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
				self.m_control:updateMsg("reward_btn", params)
			end
		}
		self.m_taskScroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_taskScroll_view:reloadData(data, true)
	end
end

function M:refreshTaskItem(cell_obj, cell_data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if LuaBehaviour then
		local left_node = LuaBehaviour:FindGameObject("left_node")
		local right_node = LuaBehaviour:FindGameObject("right_node")
		local reward_btn = LuaBehaviour:FindImage("reward_btn")
		local data = self.m_model:getEatExchangeData(cell_data.id)
		local can_change = true
		local num = cell_data.allCount - cell_data.curExchangeCount
		self:createRewards(left_node.transform, cell_data.xlsxData.need_reward, true)
		self:createRewards(right_node.transform, cell_data.xlsxData.out_reward, false)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
		if cell_data.xlsxData.times == 0 then
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("gf_str_0105"))
		else
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
		end
		for k,v in ipairs(cell_data.xlsxData.need_reward) do
			local need_data = RewardUtil:getProcessRewardData(v)
			if need_data.data_num > need_data.user_num then--道具不足
				can_change = false
			else
				if cell_data.xlsxData.times > 0 and num <= 0 then
					can_change = false
				end
			end
		end
		if can_change == false then
			reward_btn.material = self.m_gray_img.material
		else
			reward_btn.material = nil
		end
		if cell_data.xlsxData.times > 0 and num <= 0 then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", true)
		else
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", false)
		end
	end
end

function M:createRewards(reward_node, rewards, show_bl)
	UIUtil.destroyAllChild(reward_node)
	for k, v in pairs(rewards) do
		local item = GameUtil:createItemElement(v,true, true)
		item.transform:SetParent(reward_node, false)
		local LuaBehaviour = UIUtil.findLuaBehaviour(item)
		local data = RewardUtil:getProcessRewardData(v)
		local num_text = LuaBehaviour:FindText("count_text")
		if show_bl == true then
			if data.data_num > data.user_num then
				num_text.text = "<color=#F33535>".. data.user_num.."</color>/<color=#FFFFFF>"..data.data_num.."</color>"
			else
				num_text.text = "<color=#FFFFFF>".. data.user_num.."/"..data.data_num.."</color>"
			end
		end
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