local M = class("QiXiExchangeView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiExchange"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	self.avtive_data = self.m_model:getActiveData()
	self:setTextByLanKey("close_title_text", self.avtive_data.name)
	self:setTextByLanKey("common_title_text", "evil_shadow_str_011")
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("QiXiExchangeRedDot")
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
				--计算可兑换数量
				local num_array = {} --道具可兑换的次数列表
				for k,v in pairs(cell_data.xlsxData.need_reward) do
					local need_data = RewardUtil:getProcessRewardData(v)
					table.insert(num_array, math.floor(need_data.user_num / need_data.data_num))
				end
				table.sort(num_array, function(a, b) return a < b end) --从小到大排序
				local exchange_times = cell_data.allCount - cell_data.curExchangeCount --可以兑换次数
				local exchange_max_num = math.min(num_array[1] or 1, exchange_times)
				--兑换奖励
				local out_reward_name = nil
				for k,v in pairs(cell_data.xlsxData.out_reward) do
					local out_data = RewardUtil:getProcessRewardData(v)
					if out_reward_name == nil then
						out_reward_name = out_data.name
					else
						out_reward_name = out_reward_name .. " & " .. out_data.name
					end
				end
				local params = {
					item_msg = out_reward_name,
					m_max_buyNum = exchange_max_num,
					clickBuy = function (m_times)
						self:updateMsg("reward_btn",{gift_id = cell_data.id, num = m_times})
					end
				}
				self.m_control:openView("Pops.CommonExchangePop", params)
				--local params = {gift_id = cell_data.id}
				--self.m_control:updateMsg("reward_btn", params)
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
		--local data = self.m_model:getEatExchangeData(cell_data.id)
		local num = cell_data.allCount - cell_data.curExchangeCount
		self:createRewards(left_node.transform, cell_data.xlsxData.need_reward, true)
		self:createRewards(right_node.transform, cell_data.xlsxData.out_reward, false)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
		if cell_data.xlsxData.times == 0 then
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("gf_str_0105"))
		else
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
		end
		local can_change = true
		if cell_data.xlsxData.times > 0 and num <= 0 then
			can_change = false
		end
		if can_change == true then
			for k,v in ipairs(cell_data.xlsxData.need_reward) do
				local need_data = RewardUtil:getProcessRewardData(v)
				if need_data.data_num > need_data.user_num then--道具不足
					can_change = false
					break
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