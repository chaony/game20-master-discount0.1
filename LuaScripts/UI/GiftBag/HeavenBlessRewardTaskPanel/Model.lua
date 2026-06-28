local M = class("HeavenBlessRewardTaskPanelModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_draw_data = self.m_params.draw_data
	self.m_actives = self.m_draw_data.actives
	self.m_version = self.m_actives[1].version
	self.m_openId = self.m_draw_data.open_id
	self:getData("common_quest_index",{open_id = self.m_openId, vsn = self.m_version})
end

function M:onEnter()
	--Logger.logError(self.m_data,"连连看数据~~~~~~~~~~~~~")
	self.m_select_index = 1
	self.m_task_data = self.m_params.task_data
	self.m_shop_done = self.m_params.shop_done
	self.m_login_done = self.m_params.login_done
	self.m_days,self.m_quest = self:getTotleDay()
	self:refreshData()
	self.m_day = self:getDay()
	if self.m_day > 1 and self.m_day <= self.m_days then
		self.m_select_index = GameUtil:formatNum(self.m_day)
	end
	self.today = GameUtil:formatNum(self.m_day)
	--local lost =  self:get_recruit_tab()
end

function M:refreshData(data)
	if data then
		self.m_data = data
	end
end

--更新数据
function M:updateData(response)
	table.merge(self.m_data,response)
	self.m_days,self.m_quest = self:getTotleDay()
end

function M:checkCanQuick()
	for i = 1, self.m_day do
		if self:checkCanGetByDay(i) == true then
			return true
		end
	end
	return false
end

--获取天数,任务数据
function M:getTotleDay()
	local every_day_quest = {}
	--登录奖励
	local lianliankan_quest_login =  ConfigManager:getCfgByName("lianliankan_quest_login")
	if lianliankan_quest_login[self.m_openId] then
		for i, v in ipairs(lianliankan_quest_login[self.m_openId][1]) do
			if every_day_quest[i] then
				table.insert(every_day_quest[i], { cfg = v, id = i, shop_type = true, log_type = true, status = 4 })
			else
				local day_quest = {}
				table.insert(day_quest, { cfg = v, id = i, shop_type = true, log_type = true, status = 4 })
				every_day_quest[i] = day_quest
			end
		end
	end
	--购买奖励
	local lianliankan_quest_shop = ConfigManager:getCfgByName("lianliankan_quest_shop")
	if lianliankan_quest_shop[self.m_openId] then
		for i, v in ipairs(lianliankan_quest_shop[self.m_openId][1]) do
			if every_day_quest[i] then
				table.insert(every_day_quest[i], { cfg = v, id = i, shop_type = true, status = 4 })
			else
				local day_quest = {}
				table.insert(day_quest, { cfg = v, id = i, shop_type = true, status = 4 })
				every_day_quest[i] = day_quest
			end
		end
	end
	--任务奖励
	local lianliankan_quest =  ConfigManager:getCfgByName("lianliankan_quest")
	if lianliankan_quest[self.m_openId] then 
		for i, v in pairs(lianliankan_quest[self.m_openId][1]) do
			local quest_statue = self:getQuestStuage(i)
			if quest_statue.status == 1 then
				quest_statue = 2
			elseif quest_statue.status == 0 then
				quest_statue = 1
			else
				quest_statue = 0
			end
			if every_day_quest[v.day] then
				table.insert(every_day_quest[v.day], { cfg = v,id = i ,status = quest_statue})
			else
				local day_quest = {}
				table.insert(day_quest,{ cfg = v,id = i ,status = quest_statue})
				every_day_quest[v.day] = day_quest
			end
		end
	end
	for i, v in ipairs(every_day_quest) do
		local sort_tab = every_day_quest[i]
		table.sort(sort_tab,function(data1,data2)
			if data1.status == data2.status then
				return data1.id < data2.id
			else
				return data1.status > data2.status
			end
		end)
	end
	return #every_day_quest,every_day_quest
end

--活动开启总时间
function M:getDay()
	local reg_ts = 0
	for k,v in pairs(self.m_draw_data.actives) do
		local act_cfg = self:checkActiveCfgById(v.id)
		if v.open_status > 0 and act_cfg.version == self.m_version then
			reg_ts = v.start_ts
			break
		end
	end
	local server_ts = UserDataManager:getServerTime()
	local day = GameUtil:NumberOfDaysInterval(server_ts, reg_ts, 0)
	local m_day = day + 1
	return day + 1
end

--获取任务领取状态
function M:getQuestStuage(id)
	local quest_table = self.m_data.quests or {}
	for i, v in pairs(quest_table) do
		if i == tostring(id) then
			return v
		end
	end
	return {status = 0, value = 0}
end


function M:checkActiveCfgById(id)
    local active_tab = ConfigManager:getCfgByName("active")
    return active_tab[id]
end

function M:checkBuy()
    for k, v in pairs(self.m_data.shop_data) do
        if self.m_select_index ==  tonumber(k) then
            return v
        end
    end
    return 0
end

--是否已签到 -1已结束 0签到 1已签到
function M:checkLogin()
	--当前天数 领取天数 
	if self.m_select_index < self.today then --当前页签小于签到天数
		return -1 --已结束	
	end
	if self.today == self.m_select_index and self.m_data.login_data == self.today then
		return 1 --已签到
	end
	if self.today == self.m_select_index and self.m_data.login_data ~= self.today then
		return 0	--签到
	end
end

--每日红点
function M:checkRedPointByDay(index)
	if self.today == index and self.m_data.login_data ~= index then
		return true
	end
	for i, v in pairs(self.m_quest[index]) do
		local quest_table = self.m_data.quests or {}
		for quest_i, quest_v in pairs(quest_table) do
			if quest_i == tostring(v.id) and quest_v.status == 1 then
				return true
			end
		end
	end
	return false
end

return M