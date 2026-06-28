local M = class("RecruitPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("quest_recruit_index")
end

function M:onEnter()
	self.red_point = {}
	local reg_ts = UserDataManager.reg_ts
	local server_ts = UserDataManager:getServerTime()
	local reg_zero = TimeUtil.getIntTimestamp(reg_ts)
	local day = math.max(math.floor((server_ts - reg_zero)/86400), 0)
	self.m_open_day = day + 1
	self.m_day = self.m_open_day < 5 and self.m_open_day or 5
	self:updateData(self.m_data)
end

function M:updateData(data)
	self.recruit_quests = data.recruit_quests
	local quest = {}
	local recruit = ConfigManager:getCfgByName("recruit")
	for k,v in pairs(self.red_point) do
		self.red_point[k] = false
	end
	for k,v in pairs(self.recruit_quests) do
		local id = tonumber(k)
		local cfg = recruit[id]
		if quest[cfg.reg_days] == nil then
			quest[cfg.reg_days] = {}
		end
		table.insert(quest[cfg.reg_days], {id = id,data = v, cfg = cfg})
		if self.m_open_day >= cfg.reg_days and self.red_point[cfg.reg_days] then
			if self.red_point[cfg.reg_days] == false then
				self.red_point[cfg.reg_days] = v.status == 1 
			end
		elseif self.m_open_day >= cfg.reg_days then
			self.red_point[cfg.reg_days] = v.status == 1 
		else
			self.red_point[cfg.reg_days] = false	
		end
	end

	local function sortFunc(data1,data2)
		return data1.cfg.order < data2.cfg.order
	end
	for i,v in ipairs(quest) do
		table.sort(v,sortFunc)
	end
	self.m_quest = quest
end

function M:getListData(day)
	return self.m_quest[self.m_day] or {}
end

function M:selectDay(day)
	self.m_day = day
end

function M:getStatus(index)
	local list_data = self:getListData()
	local data = list_data[index]
	if data.data.status and data.data.status == 2 then
		return 2 -- 已领取
	end

	if data.data.value < data.cfg.target_value then
		return 0 -- 未完成
	end
	return 1 -- 可领取
end

return M
