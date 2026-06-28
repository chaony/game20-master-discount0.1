--==================================
-- file:  View.lua
-- brief:  清凉夏日排行榜
-- author:  LiuMiao
-- date:  2022/7/4
--==================================
local M = class("ActiveBossCoolRankPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/ActiveBoss/ActiveBossCoolRankPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "new_str_0235" }, -- 排行榜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "new_str_0373" }, -- 奖励
	{btn_key = "tog_3", text_key = "tog_3_text", show_text = "new_str_0062" }, -- 任务
}

function M:onEnter()
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
	end
	self:setTextByLanKey("common_title_text", "new_str_0114")
	self:switchNode(self.m_model.m_sel_tab_index)
end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:switchNode(index)
	self:setObjectVisible("tips_active_text", index==1)
	self:setTextByLanKey("tips_active_text", "cool_summer_rank_0001")
    self:setObjectVisible("RankListNode", index == 1)
    self:setObjectVisible("RewardNode", index == 2)
	self:setObjectVisible("TaskListNode",index == 3)
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
	if self.m_model.m_sel_tab_index == 1 then
		self:updateLoopScroll()
		local own_info = self:findGameObject("own_info")
		self:updateTeam(own_info, self.m_model:myRanks(), true)
	elseif self.m_model.m_sel_tab_index == 2 then 
		self:UpdateRewardLoopScroll()
	elseif self.m_model.m_sel_tab_index ==3 then
		self:updateTaskLoopScroll()
	end
	self:UpdataRedPoint()
end

function M:UpdataRedPoint()
	local flag = self.m_model:isPointHaveRed() 
	self:setObjectVisible("tog_3_red_point_img",flag)
end

----创建排行列表------------------------------------------------------------------------------------------
function M:updateLoopScroll()
	local data = self.m_model:getRanks()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid})
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_scroll_view.m_scroll_rect.viewport.rect.height - self.m_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
		if self.m_control.m_load_end == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_scroll_view.m_scroll_rect.viewport.rect.height - self.m_scroll_view.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_scroll_view.m_scroll_rect.content.rect.height
	self.m_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_load_end = false
end

function M:updateTeam(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil and cell_data.rank ~= 0 then
			if cell_data.rank <= 3 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
			--local head_node = luaBehaviour:FindGameObject("head_node")
			--GameUtil:setUserAvatar(head_node, cell_data.user,nil,nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
			--local server_name = ""
			--if tonumber(cell_data.user.server) == 0 then
			--	server_name = UserDataManager.server_data:getServerName()
			--else
			--	server_name = UserDataManager.server_data:getServerNameById(cell_data.user.server)
			--end
			--LuaBehaviourUtil.setText(luaBehaviour, "level_text", server_name)
			--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", cell_data.user.level)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(cell_data.score))
		elseif next(cell_data) ~= nil and cell_data.rank == 0  then 
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				if self.m_model.m_data and self.m_model.m_data.rank and self.m_model.m_data.rank > 0 then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", self.m_model.m_data.rank)
				else
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				end
				
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
				
				--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", UserDataManager.user_data:getUserStatusDataByKey("level"))
				local score = self.m_model.m_data and self.m_model.m_data.score or 0
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(score))
				--local head_node = luaBehaviour:FindGameObject("head_node")
				--local user = UserDataManager.user_data.user_status
				--GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
				--local server_name = UserDataManager.server_data:getServerName()
				--LuaBehaviourUtil.setText(luaBehaviour, "level_text", server_name)
			end
		end 
	end
end


----创建奖励列表------------------------------------------------------------------------------------------
function M:UpdateRewardLoopScroll()
    local data = self.m_model.ranks_rewards
	if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view2:reloadData(data)
    end
end

function M:updateRewardItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3) 
        if index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", "a_phb_icon_"..index, "common_ui")
        else
            local rank_str = data.id
            if data.id > 3 then
                if index == #self.m_model.ranks_rewards then
                    rank_str = data.rank[1]..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = data.rank[1] .."-"..data.rank[2]
                end
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        end
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.rank_reward, true, true)
    end    
end
--刷新占令----------------------------------------------
local slider_value = {0.05, 0.20, 0.35, 0.505, 0.66, 0.81, 1}
function M:refreshWarrior()
	local war_order, cfg = self.m_model:getWarriorCfg()
	--local war_order, cfg = self.m_model.war_order, self.m_model.tongyong_warrior_reward
	
	if not war_order or not cfg then return end
	local pay_status = self.m_model:getwrriorPayStatus()
	if pay_status == 0 then
		local show_price = GameUtil:getMoneyTypeNum(war_order.price).. Language:getTextByKey("new_str_0037")
		self:setText("buy_btn_text", show_price)
	else
		self:setTextByLanKey("buy_btn_text", "petard_text_0018")
	end

	if cfg then
		local max_value = 0
		for i,v in pairs(cfg) do
			local reward_node = self:findGameObject("reward_node_" .. i)
			local luaBehaviour = reward_node:GetComponent("LuaBehaviour")
			LuaBehaviourUtil.setText(luaBehaviour,"reward_num_text", v.condition)
			local item = luaBehaviour:FindGameObject("ItemNode")
			local item_luaBehaviour = item:GetComponent("LuaBehaviour")
			local receive_status = self.m_model:getWrriorRewardStatus(i) --判断是否到了领取条件
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "can_get_img", receive_status == 1)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "receive_reward_btn", receive_status == 1)
			if v.free_reward and next(v.free_reward) then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_bg_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_top_img", false)
				GameUtil:updateItemElement(item,v.free_reward[1], true,true)
				LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "lock_image", false)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_bg_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "vip_top_img", true)
				GameUtil:updateItemElement(item,v.fee_incentives[1], true,true)
				LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "lock_image", pay_status == 0)
			end
			LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", receive_status == 2)
			if max_value < v.condition then
				max_value = v.condition
			end
			local receive_reward_btn = luaBehaviour:FindGameObject("receive_reward_btn")
			UIUtil.setButtonClick(receive_reward_btn.transform, function(obj, data)
				audio:SendEvtUI("UI_Pay")
				self:updateMsg("receive_warrior_reward", data)
			end, i, nil, self.m_uiName)
		end
		local value = self.m_model:getWrriorValue()
		local warrior_slider = self:findSlider("warrior_slider")
		value = math.min(value, max_value)
		local realValue = 0
		local index = math.min(math.floor(value/10), #slider_value)
		if index == 0 then
			realValue = (value%10)/10 *slider_value[index+1]
		elseif index ==7 then
			realValue = slider_value[index]
		else
			realValue = slider_value[index]+ (value%10)/10 *(slider_value[index+1]-slider_value[index])
		end
		warrior_slider.value = realValue or 0
		self:setText("share_task_value_text", tostring(value) .. "/" .. max_value)
	end
end

--刷新任务列表
function M:refreshTaskList()
	local data = self.m_model:getQuestList()
		if self.m_scroll_view3 == nil then
			local loopscroll = self:findGameObject("loopscroll_task2")
			local params = {
				show_data = data,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_obj, cell_data)
					self:UpdataTaskItem(index, cell_obj, cell_data)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)
					if click_name == "get_btn" then
						self:updateMsg("receive_task_reward_btn", cell_data)
					elseif click_name == "jifen_obj" then
						-- 点击积分弹出
						GameUtil:lookInfoTips(self.m_control, { click_transform = click_object.transform, msg = Language:getTextByKey("cool_summer_rank_0002") })
					end
				end
			}
			self.m_scroll_view3 = LoopScrollViewUtil.new(params)
		else
			self.m_scroll_view3:reloadData(data)
		end
end

function M:UpdataTaskItem(index, cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", "new_str_0056")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "under_way_text", "gf_str_0071")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "done_text", "new_str_0080")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cell_data.name1)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "jifen_reward_num_text", cell_data.war_order)
		if  cell_data.target_type == 391 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.name2, GameUtil:formatValueToString(cell_data.real_value))
		elseif cell_data.target_type == 390 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.name2, cell_data.target_value..Language:getTextByKey("legend_str_029"))
		elseif cell_data.target_type == 389 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.name2, cell_data.target_value..Language:getTextByKey("gf_str_0135"))
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.name2)
		end
		local reward_node = luaBehaviour:FindGameObject("reward_node")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", cell_data.status == 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_under", cell_data.status == 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_done", cell_data.status == 2)
		if reward_node then
			GameUtil:createRewards(reward_node.transform, cell_data.reward, true, true)
		end
	end
end
-- 刷新任务数据
function M:updateTaskLoopScroll() 
	self:refreshWarrior()-- 刷新占令
	self:refreshTaskList()--刷新任务列表
end
return M