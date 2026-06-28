local M = class("LoyaltyMainView",LikeOO.OOPopBase)

M.m_uiName = "Loyalty/LoyaltyMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("title_txt_1", "national_beautiful_text_0006")
	self:setTextByLanKey("tips_text", "national_beautiful_text_0003")
 	self.m_gray_material = self:findText("material_node").material
	if self.m_model.active_data then
		local start_time = self:getTime(self.m_model.active_data.start_time)
		local end_time = self:getTime(self.m_model.active_data.end_time)
		self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
		self:setTextByLanKey("activ_over_txt", Language:getTextByKey("spring_festival_002",start_time,end_time))
	end
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local show_active_data = self.m_model:getActiveData(v.open_id)
		if show_active_data then
			self:setTextByLanKey(v.btn_name .. "_text", show_active_data.name)
		end
	end
	self:updateActivityTimer()
	self:refreshUI()
end

function M:refreshUI()
	self:refreshRedPoint()
	self:refreshTimeLimit()
end

function M:refreshRedPoint()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local open_id_red = RedPointUtil:hasRedPointById(v.open_id)
		local is_open = self.m_model:getItemTimeLimit(v.btn_name) == 1
		local is_show_red = open_id_red and is_open
		self:setObjectVisible(v.btn_name .. "_red_point_img", is_show_red)
	end
end

function M:refreshTimeLimit()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local time_limit = self.m_model:getItemTimeLimit(v.btn_name)
		if time_limit == 1 then --活动期
			self:setObjectVisible(v.btn_name, true)
		elseif time_limit == 2 then --展示期，置灰
			--local btn_img = self:findImage(v.btn_name)
			--local btn_text = self:findText(v.btn_name .. "_text")
			--btn_img.material = self.m_gray_material
			--btn_text.material = self.m_gray_material
		else --未开启
			--self:setObjectVisible(v.btn_name, false)
		end
	end
end

--刷新活动时间
function M:updateActivityTimer()
	local surplus_time = 0
	local activityData = self.m_model.open_active_data
	local endTimer = UserDataManager:getServerTime() - 1
	if activityData then
		endTimer = activityData.end_ts
	end
	local cur_tim = UserDataManager:getServerTime() --服务器时间
	if endTimer ~= nil then
		surplus_time = endTimer - cur_tim
	end
	if surplus_time < 0 then
		self:setTextByLanKey("activ_over_txt", "gf_str_0085")
		self:setObjectVisible("title_txt_1",false)
		self:setTextByLanKey("title_txt_2", "")
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
		local show_time = ""
		if remain_day > 0 then
			show_time = Language:getTextByKey("three_heroes_five_gallants_text_0013",remain_day,remain_hour,remain_min)
		else
			show_time = Language:getTextByKey("three_heroes_five_gallants_text_0014",remain_hour,remain_min,remain_sec)
		end
		self:setTextByLanKey("title_txt_2", show_time) --重置剩余时间
	end
end

--获取时间
function M:getTime(time)
	local date_time_list = string.split(time," ")
	local date_list = string.split(date_time_list[1],"-")
	local time_list = string.split(date_time_list[2],":")
	return Language:getTextByKey("spring_festival_001",date_list[2],date_list[3],time_list[1],time_list[2])
end

return M