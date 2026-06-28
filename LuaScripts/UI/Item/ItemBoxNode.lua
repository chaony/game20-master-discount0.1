--- 
local M = class("ItemBoxNode",LikeOO.OOUIbase)

M.m_uiName = "Item/ItemBoxNode"

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self:setTextByLanKey("box_title_text", "new_str_0497")
	self.m_icon_node = self:findGameObject("icon_node")
	self:setObjectVisible("red_point_img", false)
	self:setTextByLanKey("use_btn_text", "new_str_0056")
end

function M:onButtonClick(obj, name)
	if name == "use_btn" then
		self:useItem()
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("item_des_text", "new_str_0496")
	self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	local effect = item_cfg.effect
	local item_data, _ = UserDataManager.item_data:getItemDataById(show_data.data_id)
	local show_data = self:getBoxRewardData(effect, item_data.received or {},{has_ts = item_data.used_ts or nil,use_day = item_data.used_times or nil})
	self:updateBoxLoopScroll(show_data)
end

function M:getBoxRewardData(effect, received,params)
	local box_special_cfg = ConfigManager:getBoxSpecialCfg(effect)
	local show_data = {}
	for k,v in pairs(box_special_cfg) do
		-- 1=登陆天数  2=玩家等级 total_login_days
		local target_type = v.target_type or 0
		local target_id = v.target_id or 0
		local cur_value = 0
		if target_type == 1 then -- 登陆天数
			cur_value = UserDataManager:getTempData("total_login_days") or 0
		elseif target_type == 2 then -- 玩家等级
			cur_value = UserDataManager.user_data:getUserStatusDataByKey("level") or 0
		elseif target_type == 3 then --获取道具天数
			cur_value = self:getCurrentDay(params.has_ts,params.use_day,target_type)
		elseif target_type == 4 then --每天领取
			cur_value = self:getCurrentDay(params.has_ts,params.use_day,target_type)
		end
		local status = 0
		if target_type == 4 then
			status = self:getCurrentDay(params.has_ts,params.use_day,target_type) == 0 and -1 or 1
		else
			local index = table.indexof(received, k)
			if index ~= false then --已领取
				status = -1
			else
				if cur_value >= target_id then --可领取
					status = 1
				end
			end
		end
		table.insert(show_data, {id = k, cfg = v, status = status})
	end
	table.sort(show_data, function(data1, data2)
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end)
	return show_data
end
function M:getCurrentDay(endTime,use_day,type)
	if type == 3 then
		if not use_day or not endTime then
			return 1
		end
		local cur_shop_date = TimeUtil.gmTime(endTime)
		local cur_server_date = TimeUtil.gmTime(UserDataManager:getServerTime())
		if cur_shop_date.year == cur_server_date.year and cur_shop_date.month == cur_server_date.month and cur_shop_date.day == cur_server_date.day then
			return use_day or 0
		else
			return use_day + 1
		end
	elseif type == 4 then
		if not endTime then
			return 1
		end
		local cur_shop_date = TimeUtil.gmTime(endTime)
		local cur_server_date = TimeUtil.gmTime(UserDataManager:getServerTime())
		if cur_shop_date.year == cur_server_date.year and cur_shop_date.month == cur_server_date.month and cur_shop_date.day == cur_server_date.day then
			return 0
		else
			return 1
		end
	end
 
end



function M:updateView(data)
	self.m_show_data = data
	self:refreshUI()
end

--[[
	创建列表
]]
function M:updateBoxLoopScroll(show_data)
	local data = show_data or {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("box_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--self:useItem(index)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data, received_status)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	local drop = cell_data.cfg.drop or {}
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "condition_text", cell_data.cfg.text)
	local status = cell_data.status or 0
	if status == -1 then
		local status_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "status_text", "new_str_0080")
		status_text.color = GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_10
	else
		if status == 1 then --可领取
			local status_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "status_text", "new_str_0655")
			status_text.color = GlobalConfig.COMMON_COLLOR.COMMON_13
		else
			local status_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "status_text", "new_str_0057")
			status_text.color = GlobalConfig.COMMON_COLLOR.COMMON_12
		end
	end
	GameUtil:createRewards(reward_node.transform, drop, true, true, nil, 0.75)
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "items_update" then
		self:refreshUI()
	end
end

function M:getUseNum()
	local item_data = UserDataManager.item_data:getItemDataById(self.m_show_data.data_id)
	local user_num = item_data and item_data.num or 0
	return math.min(1, user_num)
end

--[[
    item_id: 道具id item_num: 道具数量 item_index: 玩家自选道具
]]
function M:useItem(index)
	local item_num = self:getUseNum()
	if item_num < 1 then
		local show_data = self.m_show_data
		local item_cfg = show_data.item_cfg
		GameUtil:lookInfoTips(self.m_comtrol, {msg = Language:getTextByKey(item_cfg.sort == 2 and "new_str_0051" or "new_str_0052"), delay_close = 2})
		return
	end
	local item_id = self.m_show_data.data_id
	local function netCallback(response)
		RewardUtil:rewardTipsByData(response.reward)
	end
	if self.m_loop_scroll_view then
		local reward_flag = false
		local show_data = self.m_loop_scroll_view.m_show_data or {}
		for k,v in ipairs(show_data) do
			if v.status == 1 then
				reward_flag = true
				local params = {item_id = item_id, item_num = item_num or 1, item_index = v.id}
				self.m_model:getNetData("item_use_item", params, netCallback)
				break
			end
		end
		if not reward_flag then
			GameUtil:lookInfoTips(self.m_comtrol, {msg = Language:getTextByKey("new_str_0661"), delay_close = 2})
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M