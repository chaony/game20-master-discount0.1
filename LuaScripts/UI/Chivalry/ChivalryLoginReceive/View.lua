local M = class("ChivalryLoginReceiveView",LikeOO.OOPopBase)

M.m_uiName = "Chivalry/ChivalryLoginReceive"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	if self.m_model.is_tokens == true then
		self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 20})
	end
	self.hui_img_material = self:findImage("hui_img").material
	--滑动条组件
	self.m_box_node = self:findGameObject("cell_father")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	local active_data = self.m_model:getActiveData()
	if active_data then
		self:setTextByLanKey("close_title_text", active_data.name)
	end
	self:setTextByLanKey("buy_btn_text", "new_str_0789", self.m_model:getBuyWarPrice())
	self:refreshUI()
end

function M:refreshUI()
	self:refreshReward()
	self:setObjectVisible("buy_btn",self.m_model.m_data.war_order.pay_status == 0)
end


--奖励
function M:refreshReward()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data = self.m_model:getRewardBoxData() --获取显示奖励，领取进度
	local width = self.m_box_node_rt.rect.width
	local height = self.m_box_node_rt.rect.height
	local box_num = #show_data
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("Chivalry/ChivalryLoginReceive_cell", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalScale(transform, 1, 1, 1.0)
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		local width_temp_1 =  math.modf((i-1)/5)
		local width_temp_2 = (i%5) == 0 and 5 or (i%5)
		UIUtil.setLocalPosition(task_box, (width-60)*width_temp_2/5 - width*0.6 + width_temp_1*65 , height/2 - height*(0.25+width_temp_1*0.5))
		local function btns(trans,params)
			if data.status_reward_1 == 1 or data.status_reward_2 == 1 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			--else
			--	self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local box_img_1 = luaBehaviour:FindGameObject("reward_1") --免费奖励父物体
		local reward_item_1 = GameUtil:createRewards(box_img_1.transform, cfg.free_reward, true, true, nil, 0.85)
		local box_img_2 = luaBehaviour:FindGameObject("reward_2") --付费奖励父物体
		local reward_item_2 = GameUtil:createRewards(box_img_2.transform, cfg.fee_incentives, true, true, nil, 0.85)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_name", "active_current_str_0002",GameUtil:numberToChineseString(i)) --第几天
		local item_luaBehaviour_1 = UIUtil.findLuaBehaviour(reward_item_1[1])
		local item_luaBehaviour_2 = UIUtil.findLuaBehaviour(reward_item_2[1])
		local item_img_1 = item_luaBehaviour_1:FindImage("item_img")
		local quality_img_1 = item_luaBehaviour_1:FindImage("quality_img")
		local item_img_2 = item_luaBehaviour_2:FindImage("item_img")
		local quality_img_2 = item_luaBehaviour_2:FindImage("quality_img")
		--未购买战令，战令奖励上锁
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour_2, "lock_image", self.m_model.m_data.war_order.pay_status == 0)
		--奖励领取状态
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour_1, "duigoudi_img", data.status_reward_1 == 2)
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour_2, "duigoudi_img", data.status_reward_2 == 2)
		--奖励框状态
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_img_bg", data.status_reward_1 == 1 or data.status_reward_2 == 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_name_di", data.status_reward_1 == -1)
		--奖励天数显示颜色
		local color = (data.status_reward_1 == 1 or data.status_reward_2 == 1 or data.status_reward_1 == -1) and Color( 255/255, 250/255, 229/255) or Color( 177/255, 173/255, 153/255)
		LuaBehaviourUtil.setTextColor(luaBehaviour, "active_name", color)
		--奖励置灰
		if data.status_reward_1 == -1 then
			item_img_1.material = self.hui_img_material
			quality_img_1.material = self.hui_img_material
			item_img_2.material = self.hui_img_material
			quality_img_2.material = self.hui_img_material
		else
			item_img_1.material = nil
			quality_img_1.material = nil
			item_img_2.material = nil
			quality_img_2.material = nil
		end
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour_1, "add_panel", data.status_reward_1 == 1)
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour_2, "add_panel", data.status_reward_2 == 1 and self.m_model.m_data.war_order.pay_status == 1)
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