local M = class("ActiveCurrentMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.is_token = self.m_params.is_token
	self:getData("hero_event_index",{version = self.m_params.open_active_data.version })
end

function M:onEnter()
	--Logger.logError(self.m_data,"self.m_data~~~~~~~~~~~")
	--Logger.logError(self.m_params,"self.m_params~~~~~~~~~~~")
end

--更新数据
function M:updateData(response)
	table.merge(self.m_data,response)
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_params.open_active_data.start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	local new_remain_day = remain_day
	if remain_day < 1 then
		remain_day = 1
	elseif remain_day > 7 then
		remain_day = 7
	end
	return remain_day,new_remain_day
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:getActivityName(open_id)
	return self.activity_openID_name_cache[open_id]
end

function M:getLockTip(activity_data)
	local start_date = TimeUtil.gmTime(activity_data.start_ts or 0)
	local end_date = TimeUtil.gmTime(activity_data.end_ts or 0)
	--local star_date_str = start_date.year .. "年" .. start_date.month .. "月" .. start_date.day .. "日"
	--local end_date_str = end_date.year .. "年" .. end_date.month .. "月" .. end_date.day .. "日"
	local star_date_str = start_date.month .. "月" .. start_date.day .. "日"
	local end_date_str = end_date.month .. "月" .. end_date.day .. "日"
	return Language:getTextByKey("evil_shadow_str_005", star_date_str, end_date_str)
end

--月影试炼
function M:getHeirloom()
	if self.m_data then
		return self.m_data.heirlooms or {}
	end
	return {}
end

function M:getEnemy()
	if self.m_data then
		return self.m_data.enemys or {}
	end
	return {}
end

function M:getMaxDamage()
	if self.m_data then
		return self.m_data.max_damage or 0
	end
	return 0
end

--兑换
function M:getExchangeDoneData()
	return self.m_data.exchange_done or {}
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	--return event[self.m_data.version or 1] or {}
	return event[self.m_data.version] or {}
end

--获取spine信息
function M:getSkinData(skin_id)
	local hero_skin = ConfigManager:getCfgByName("hero_skin")
	return hero_skin[skin_id] or {}
end

--获取活动时间
function M:getActiveTime(open_id)
	local active = ConfigManager:getCfgByName("active")
	for i, v in pairs(active) do
		if v.open_id == open_id and v.version == self.m_data.version then
			return v.start_time,v.end_time
		end
	end
	return "2022-01-12 00:00:00","2022-01-18 23:59:59"
end

--活动时间转换成string类型
function M:changeActiveTimeToString(open_id)
	local start_time,end_time = self:getActiveTime(open_id)
	local start_time_table = string.split(string.split(start_time," ")[1],"-") 
	local end_time_table = string.split(string.split(end_time," ")[1],"-")
	return start_time_table,end_time_table
end

--获取开启活动数据
function M:getOpenActive(open_id)
	local active = ConfigManager:getCfgByName("active")
	for i, v in pairs(active) do
		if v.open_id == open_id and v.version == self.m_data.version then
			local active_name,active_img = self:getActiveData(v.open_id)
			local params = {
				cfg = v,
				open_id = v.open_id,
			}
			return params
		end
	end
	local active_recharge = ConfigManager:getCfgByName("active_recharge")
	for i, v in pairs(active_recharge) do
		if v.open_id == open_id and v.version == self.m_data.version then
			local active_data = self:getActiveData(v.open_id)
			local params = {
				cfg = v,
				open_id = v.open_id,
			}
			return params
		end
	end
	return nil
end

--获取入口展示数据
function M:getShowOpenData(open_table)
	local active_data = {}
	for i, v in ipairs(open_table) do
		local info = self:getOpenActive(v)
		if info ~= nil then
			table.insert(active_data,info)
		end
	end
	return active_data
end

--获取活动开启数据
function M:getActiveData(open_id)
	local active = ConfigManager:getCfgByName("active")
	for i, v in pairs(active) do
		if v.open_id == open_id and v.version == self.m_data.version then
			return {name = v.name,bg_img = v.bg_img}
		end
	end
	return {}
end

--获取活动开启状态  0:未开启  1:活动期  2:展示期
function M:getActiveStatus()
	local start_time = self.m_params.open_active_data.start_ts --活动开始时间
	local end_time = self.m_params.open_active_data.end_ts --活动结束时间
	local show_data = self.m_params.open_active_data.show_start_ts --活动展示结束时间
	local cur_tim = UserDataManager:getServerTime() --当前时间
	if cur_tim >= start_time and cur_tim <= show_data then --活动期
		return 1
	elseif cur_tim > show_data and cur_tim <= end_time then --展示期
		return 2
	else
		return 0
	end
end

--判断是否有红点
function M:IsHasRedPoint(open_id)
	local version = self.m_data.version or 0
	if open_id == 249 then --里程奖励
		return RedPointUtil:hasRedPointById(open_id, version) == true and self:getActiveStatus(open_id) == 1
	elseif open_id == 248 then --礼包
		return RedPointUtil:hasRedPointById(open_id) == true and self:getActiveStatus(open_id) == 1
	elseif open_id == 250 then --战斗
		return RedPointUtil:hasRedPointById(open_id) == true and self:getActiveStatus(open_id) == 1
	elseif open_id == 268 then --兑换
		return RedPointUtil:localRedPointJudge("EvilShadowExchange") == true
	elseif open_id == 269 then --花落
		return RedPointUtil:hasRedPointById(open_id, version) == true and self:getActiveStatus(open_id) == 1
	end
	return false
end

return M
