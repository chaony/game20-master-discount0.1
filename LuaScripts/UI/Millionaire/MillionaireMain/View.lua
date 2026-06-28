local M = class("MillionaireMainView",LikeOO.OOPopBase)

M.m_uiName = "Millionaire/MillionaireMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_material = self:findText("material_node").material
	self.m_streetfood_text_material = self:findText("streetfood_goto_text")
	self.m_Inn_text_material = self:findText("Inn_goto_text")
	self.m_tavern_text_material = self:findText("tavern_goto_text")
	self.m_streetfood_material = self:findImage("streetfood_goto")
	self.m_Inn_material = self:findImage("Inn_goto")
	self.m_tavern_material = self:findImage("tavern_goto")
	if self.m_model.active_data then
		self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
	end
	self.items = self.m_model:getAllItem()
	self:updateActivityTimer()
	self:refreshUI()
end

function M:refreshUI()
	self:refreshRedPoint()
	for k, v in pairs(self.items) do
		self:setTextByLanKey(v.title_name, v.title_text)
		self:setTextByLanKey(v.goto_name, "millionaire_text_004")
		self:setTextByLanKey(v.progress_name_des, Language:getTextByKey("millionaire_text_005",self.m_model:getCurrentReturnMoney(k)))
		self:setTextByLanKey(v.progress_name, Language:getTextByKey("millionaire_text_006",self.m_model:getMaxReturnMoney(k)))
	end
	if self.m_model.is_show_time then
		self:isOpenEntry()
	end
end

function M:refreshRedPoint()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local open_id_red = RedPointUtil:localRedPointJudge(v.red_key)
		if self.m_model.is_show_time then
			open_id_red = false
		end
		self:setObjectVisible(v.red_name, open_id_red)
	end
end

--刷新活动时间
function M:updateActivityTimer()
	local surplus_time = 0
	local endTimer = self.m_model.m_data.actives[1].end_ts
	local cur_tim = UserDataManager:getServerTime() --服务器时间
	if endTimer ~= nil then
		surplus_time = endTimer - cur_tim
	end
	if surplus_time < 0 or self.m_model.m_data.actives[1].show_start_ts < self.m_model.m_data.actives[1].end_ts then
		if self.m_model.is_show_time == nil then
			self.m_model.is_show_time = true
			self:isOpenEntry()
		end
		self:setTextByLanKey("time_text", "gf_str_0085")
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
		if self.m_model.day == nil or  remain_day ~= self.m_model.day then
			self.m_model.day = remain_day
			self:refreshRedPoint()
		end
		local show_time = ""
		if remain_day > 0  then
			show_time = Language:getTextByKey("millionaire_text_007",remain_day) --重置剩余天
		elseif remain_day <= 0 and remain_hour > 0 then
			show_time = Language:getTextByKey("millionaire_text_008",remain_hour) --重置剩余小时
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min > 0 then
			show_time =  Language:getTextByKey("millionaire_text_012",remain_min) --重置剩余分钟
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 and remain_sec > 0 then
			show_time = Language:getTextByKey("millionaire_text_013",remain_sec) --重置剩余秒
		end
		self:setTextByLanKey("time_text", show_time) --重置剩余时间
	end
end

--是否开启入口
function M:isOpenEntry()
	if self.m_model.is_show_time then
		self.m_streetfood_material.material = self.m_gray_material
		self.m_streetfood_text_material.material = self.m_gray_material
		self.m_Inn_material.material = self.m_gray_material
		self.m_Inn_text_material.material = self.m_gray_material
		self.m_tavern_material.material = self.m_gray_material
		self.m_tavern_text_material.material = self.m_gray_material
	else
		self.m_streetfood_material.material = nil
		self.m_streetfood_text_material.material = nil
		self.m_Inn_material.material = nil
		self.m_Inn_text_material.material = nil
		self.m_tavern_material.material = nil
		self.m_tavern_text_material.material = nil
	end
end

return M