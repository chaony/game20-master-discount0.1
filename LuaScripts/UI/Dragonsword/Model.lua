local M = class("DragonswordModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("active_dragonsword_quest_index")
end

local ACTIVE_TAB = {
	{open_id = 253,btn_name = "story_active_btn" }, --龙泉逸闻
	{open_id = 254,btn_name = "star_light_active_btn" }, --铸剑龙渊
	{open_id = 255,btn_name = "battle_active_btn" }, --剑池试炼
}

function M:onEnter()
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_params.open_active_data.start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	if remain_day < 1 then
		remain_day = 1
	elseif remain_day > 7 then
		remain_day = 7
	end
	return remain_day
end

--刷新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

--获取活动信息
function M:getActiveData(open_id)
	local active = ConfigManager:getCfgByName("active")
	for i, v in pairs(active) do
		if v.open_id == open_id then
			return v
		end
	end
end

--获取活动名称
function M:getActiveName(open_id)
	local open_condition = ConfigManager:getCfgByName("open_condition")
	return open_condition[open_id] or {}
end

--获取open_id
function M:getOpenId(btn_name)
	for i, v in pairs(ACTIVE_TAB) do
		if v.btn_name == btn_name then
			return v.open_id
		end
	end
	return 0
end

--是否有任务红点
function M:isHasQuestRed()
	for i, v in pairs(self.m_data.quests) do
		if v.status == 1 then
			return true
		end
	end
	return false
end

--是否有故事红点
function M:isHasStoryRed()
	--local active_data = self:getActiveData(254)
	--local start_time = GameUtil:stringToTimesTamp(active_data.start_time) --活动开始时间
	--local surplus_time = UserDataManager:getServerTime() - start_time --从活动开始到当前时间的差值
	--local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	local open_story_num = self:setCurrentDay()
	if #self.m_data.login_recv < open_story_num then
		return true
	end
	return false
end

--是否有里程碑红点
function M:isHasMilepost()
	local dragonsword_milepost = ConfigManager:getCfgByName("dragonsword_milepost")
	local milepost_data = dragonsword_milepost[self.m_data.version] or {}
	for i, v in pairs(milepost_data) do
		if v.score <= self.m_data.score then
			local is_receive = self:getIsReceiveMilepost(i)
			if not is_receive then
				return true
			end
		end
	end
	return false
end

--获取是否领取了积分奖励
function M:getIsReceiveMilepost(score_id)
	for i, v in pairs(self.m_data.score_done) do
		if v == score_id then
			return true
		end
	end
	return false
end

return M
