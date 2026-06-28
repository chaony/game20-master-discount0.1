local M = class("CelebrateOneYearMainView",LikeOO.OOPopBase)

M.m_uiName = "CelebrateOneYear/CelebrateOneYearMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	--self:setTextByLanKey("title_txt_1", "national_beautiful_text_0006")
	self:setTextByLanKey("tips_text", "celebrate_one_year_text_0001")
 	self.m_gray_material = self:findText("material_node").material
	if self.m_model.active_data then
		self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
	end
	self.items = self.m_model:getAllItem()
	for k, v in pairs(self.items) do
		if v.show_active_data then
			self:setTextByLanKey(v.btn_name .. "_text", v.show_active_data.name)
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
	for k, v in pairs(self.items) do
		local open_id_red = RedPointUtil:hasRedPointById(v.open_id)
		local is_open = self.m_model:getItemTimeLimit(v.btn_name) == 1
		local is_show_red = open_id_red and is_open
		self:setObjectVisible(v.btn_name .. "_red_point_img", is_show_red)
	end
end

function M:refreshTimeLimit()
	for k, v in pairs(self.items) do
		local time_limit = self.m_model:getItemTimeLimit(v.btn_name)
		if time_limit == 1 then --活动期
			self:setObjectVisible(v.btn_name, true)
		elseif time_limit == 2 and v.show_start_open then --展示期，置灰
			--local btn_img = self:findImage(v.img_name)
			--local btn_text = self:findText(v.btn_name .. "_text")
			--btn_img.material = self.m_gray_material
			--btn_text.material = self.m_gray_material
		else --未开启
			--local btn_img = self:findImage(v.img_name)
			--local btn_text = self:findText(v.btn_name .. "_text")
			--btn_img.material = self.m_gray_material
			--btn_text.material = self.m_gray_material
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
		self:setTextByLanKey("title_txt_2", "gf_str_0085")
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
		local show_time = ""
		if remain_day > 0 then
			show_time = Language:getTextByKey("celebrate_one_year_text_0002",remain_day,remain_hour,remain_min)
		else
			show_time = Language:getTextByKey("celebrate_one_year_text_0003",remain_hour,remain_min,remain_sec)
		end
		self:setTextByLanKey("title_txt_2", show_time) --重置剩余时间
		--self:setTextByLanKey("title_txt_2", show_time2) --重置剩余时间
	end
	--子活动入口时间
	for i, v in ipairs(self.items) do
		if v.show_active_data and v.show_active_data.end_time then
			local end_ts = v.show_active_data.end_time
			local start_ts = v.show_active_data.start_time
			local end_time = GameUtil:stringToTimesTamp(end_ts)
			local start_time = GameUtil:stringToTimesTamp(start_ts)
			local active_surplus_time = 0
			if end_time then
				active_surplus_time = end_time - cur_tim
			end
			local time_text_name = "item_"..i.."_time_text"
			if cur_tim >= end_time then
				self:setTextByLanKey(time_text_name, "gf_str_0085")
			elseif cur_tim < start_time  then
				local start_surplus_time = start_time - cur_tim
				local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(start_surplus_time) --换算剩余时间
				local show_time2 = GameUtil:formatTimeBySecond(start_surplus_time) --换算剩余时间
				local show_time = ""
				if remain_day > 0 then
					show_time = Language:getTextByKey("celebrate_one_year_text_0004",remain_day,remain_hour,remain_min)
				else
					show_time = Language:getTextByKey("celebrate_one_year_text_0005",remain_hour,remain_min,remain_sec)
				end
				--self:setTextByLanKey(time_text_name, show_time)
				self:setTextByLanKey(time_text_name,"celebrate_one_year_text_0007", show_time2)
				self:setObjectVisible("item_"..i.."_time_di",false)
				self:setObjectVisible("item_"..i.."_time_text",false)
			else
				local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(active_surplus_time) --换算剩余时间
				local show_time = ""
				local show_time2 = GameUtil:formatTimeBySecond(active_surplus_time) --换算剩余时间
				if remain_day > 0 then
					show_time = Language:getTextByKey("celebrate_one_year_text_0002",remain_day,remain_hour,remain_min)
				else
					show_time = Language:getTextByKey("celebrate_one_year_text_0003",remain_hour,remain_min,remain_sec)
				end
				--self:setTextByLanKey(time_text_name, show_time) --重置剩余时间
				self:setTextByLanKey(time_text_name,"celebrate_one_year_text_0008", show_time2) --重置剩余时间
				self:setObjectVisible("item_"..i.."_time_di",true)
				self:setObjectVisible("item_"..i.."_time_text",true)
			end
		end
end
end

return M