local M = class("ActivitiesPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/ActivitiesPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setText("close_title_text", "")
	self:refreshUI()
	self:initDownTime()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	self.time_list = {}
	local data = self.m_model.m_data
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("cell_click", cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id)
	local data = self.m_model:getDataByIndex(id)
	local active_id = data.active_id
	local active_cfg = ConfigManager:getCfgByName("active")
	local cfg = active_cfg[active_id]
	-- Logger.log(cfg,"cfg =====")
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local name_img = luaBehaviour:FindGameObject("name_img")
	local banner_bg = luaBehaviour:FindGameObject("banner_bg")
	local name_text = luaBehaviour:FindText("name_text")
	local red_point = luaBehaviour:FindGameObject("red_point")
	name_text.text = Language:getTextByKey(cfg.name)
	GameUtil:setLanImgText(luaBehaviour:FindRectTransform("name_img"), cfg.name_img)
	LuaBehaviourUtil.setImg(luaBehaviour, "banner_bg", cfg.banner_bg, "active_ui")
	local time_text = luaBehaviour:FindText("time_text")
	if data.remain_ts == 0 then
		time_text.text = Language:getTextByKey("activities_str_0007")
	elseif data.remain_ts > 0 then
		local server_time = UserDataManager:getServerTime()
		local str = GameUtil:formatTimeBySecond(data.end_ts - server_time)
		LuaBehaviourUtil.setText(luaBehaviour, "time_text", str)
		self.time_list[obj] = data.end_ts
	else
		time_text.text = Language:getTextByKey("activities_str_0008")
	end
	local red_flag = RedPointUtil:isFuncRedPointById(cfg.open_id)
	if red_point then
		red_point:SetActive(red_flag == true)
	end
	if id%2 == 0 then
		UIUtil.setLocalScale(banner_bg.transform, -1)
		UIUtil.setLocalPosition(name_img.transform, 268)
		-- UIUtil.setLocalPosition(time_text.gameObject.transform, 204)
		-- time_text.alignment = CS.UnityEngine.TextAnchor.MiddleLeft
	else
		UIUtil.setLocalScale(banner_bg.transform, 1)
		UIUtil.setLocalPosition(name_img.transform, 645)
		-- UIUtil.setLocalPosition(time_text.gameObject.transform, 709)
		-- time_text.alignment = CS.UnityEngine.TextAnchor.MiddleRight
	end
end

function M:initDownTime()
	local function tick(_, dt)
		local server_ts = UserDataManager:getServerTime()
		for k,v in pairs(self.time_list) do
			local time = v - server_ts
			if time < 0 then
				self:updateMsg("downtime")
			else
				local str = GameUtil:formatTimeBySecond(time)
				local luaBehaviour = k:GetComponent("LuaBehaviour")
				local time_text = luaBehaviour:FindText("time_text")
				time_text.text = str
			end
		end
	end
	self.m_control:setTimer(1, tick)
end

return M