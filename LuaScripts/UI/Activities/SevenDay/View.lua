local M = class("SevenDayPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/SevenDay/SevenDayPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setText("close_title_text", "")
	self:refreshUI()
	self:initDownTime()
end

function M:refreshUI()
	self.time_list = {}
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_seven_cfg
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id, cfg)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local receive_btn = luaBehaviour:FindButton("receive_btn")
	local reward_content = luaBehaviour:FindGameObject("reward_panel")
	local name_text = luaBehaviour:FindText("name_text")
	local receive_btn_text = luaBehaviour:FindText("receive_btn_text")
	name_text.text = Language:getTextByKey(cfg.name)

	GameUtil:createRewards(reward_content.transform, cfg.reward, true, true, nil, nil, true)

	local status = self.m_model:getStatus(cfg.day)
	receive_btn.interactable = status == 1
	self.time_list[obj] = nil
	if status == 0 then
		local reg_ts = UserDataManager.reg_ts
		local server_ts = UserDataManager:getServerTime()
		local time = (cfg.day - 1)*86400 - server_ts + reg_ts
		local day = GameUtil:getTimeLayoutBySecond(time)
		if day and day > 0 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "activities_str_0004", day)
		else
			local str = GameUtil:formatTimeBySecond(time)
			LuaBehaviourUtil.setText(luaBehaviour, "receive_btn_text", str)
			self.time_list[obj] = cfg.day
		end
	elseif status == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0080")
	end
end

function M:initDownTime()
	local function tick(_, dt)
		local reg_ts = UserDataManager.reg_ts
		local server_ts = UserDataManager:getServerTime()
		for k,v in pairs(self.time_list) do
			local time = (v - 1)*86400 - server_ts + reg_ts
			if time < 0 then
				self:updateMsg("downtime")
			else
				local str = GameUtil:formatTimeBySecond(time)
				local luaBehaviour = k:GetComponent("LuaBehaviour")
				local receive_btn_text = luaBehaviour:FindText("receive_btn_text")
				receive_btn_text.text = str
			end
		end
	end
	self.m_control:setTimer(1, tick)
end

return M