local M = class("MoonShadowDateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_day_name_cache = {
		{day = 1, name_day = "第一天", name_zhuan = "传记一"},
		{day = 2, name_day = "第二天", name_zhuan = "传记二"},
		{day = 3, name_day = "第三天", name_zhuan = "传记三"},
		{day = 4, name_day = "第四天", name_zhuan = "传记四"},
		{day = 5, name_day = "第五天", name_zhuan = "传记五"},
		{day = 6, name_day = "第六天", name_zhuan = "传记六"},
		{day = 7, name_day = "第七天", name_zhuan = "传记七"},
	}
	self.m_version = self.m_params.version or 0
	self.m_score = self.m_params.score or 0
	self.m_score_done = self.m_params.score_done or {}
	self.m_current_day = self.m_params.current_day or 0
	self.m_current_day_update = self.m_current_day
	self.m_task_detail_cfg_data = self.m_params.task_detail_data
	self:updateRewardBoxData()
end

function M:getVersion()
	return self.m_version
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:setCurrentDayUpdate(day)
	if day > self.m_current_day then
		day = self.m_current_day
	end
	self.m_current_day_update = day
end

function M:getCurrentDayUpdate()
	return self.m_current_day_update
end

function M:setTaskDetailCfgData(data)
	self.m_task_detail_cfg_data = data or {}
end

--右上，传记详情
function M:getZhuanjiDetailName()
	if self.m_current_day_update > 0 and self.m_current_day_update < 8 then
		return self.m_day_name_cache[self.m_current_day_update].name_zhuan
	end
	return ""
end

function M:getZhuanjiDetailTitle()
	local story_tab = ConfigManager:getCfgByName("mood_shadow_story") or {}
	local story_data = story_tab[self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.name
	end
	return ""
end

function M:getZhuanjiDetailContent()
	local story_tab = ConfigManager:getCfgByName("mood_shadow_story") or {}
	local story_data = story_tab[self.m_version] or {}
	local story_item = story_data[self.m_current_day_update]
	if story_item then
		return story_item.story
	end
	return ""
end

function M:getZhuanjiDetailData(day)
	day = day or self.m_current_day_update 
	local detail_data = {}
	local task_detail_tab = ConfigManager:getCfgByName("mood_shadow_quest") or {}
	local task_detail_data = task_detail_tab[self.m_version] or {}
	local item_temp
	for key_cfg, item_cfg in pairs(self.m_task_detail_cfg_data) do
		item_temp = {}
		for key_detail, item_detail in pairs(task_detail_data) do
			if item_detail.day == day and tonumber(key_cfg) == key_detail then
				table.merge(item_temp, item_cfg)
				table.merge(item_temp, item_detail)
				item_temp.quest_id = key_detail
				if item_temp.status == 2 then
					item_temp.status = -1
				end
				table.insert(detail_data, item_temp)
				break
			end
		end
	end
	
	table.sort(detail_data, function(item1, item2)
		return item1.status > item2.status
	end)
	
	
	return detail_data
end

--右下，传记
function M:getZhuanjiData()
	for index, item in ipairs(self.m_day_name_cache) do
		item.red_point = self:isZhuanjiItemHasRewardToGet(index)
		if index > self.m_current_day then --真实的当前天数
			item.status = 0 --未开启
			item.red_point = false
		elseif index == self.m_current_day_update then --点击传记的下标
			item.status = 2 --当前
		else
			if self:isZhuanjiItemComplete(index) then
				item.status = 1	--已完成
			else
				item.status = 3 --已开启，未完成
			end
		end
	end
	return self.m_day_name_cache
end

function M:isZhuanjiItemComplete(day)
	local task_data = self:getZhuanjiDetailData(day) or {}
	for _, item in ipairs(task_data) do
		if item.status == 0 then
			return false
		end
	end
	return true
end

function M:isZhuanjiItemHasRewardToGet(day)
	local task_data = self:getZhuanjiDetailData(day) or {}
	for _, item in ipairs(task_data) do
		if item.status == 1 then
			return true
		end
	end
	return false
end

--左下，宝箱
function M:updateRewardBoxDataScore(score)
	self.m_score = score
end

function M:updateRewardBoxDataScoreDone(data)
	self.m_score_done = data or {}
end

function M:updateRewardBoxData()
	local show_data = {}
	local moon_shadow_reward = ConfigManager:getCfgByName("mood_shadow_reward")[self.m_version] or {}
	for k,v in pairs(moon_shadow_reward) do
		local score = v.score or 0
		local status = 0
		if table.keyof(self.m_score_done, k) then
			status = -1-- 已领取
		else
			if self.m_score >= score then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = k, cfg = v, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.score < data2.cfg.score
	end)
	self.m_arena_reward_week_data = show_data
end

function M:getRewardBoxData()
	return self.m_arena_reward_week_data, self.m_score
end

return M
