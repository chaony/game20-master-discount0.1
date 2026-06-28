local M = class("DrawTaskPanelModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_select_index = 1
	self.m_task_data = self.m_params.task_data
	self.m_shop_done = self.m_params.shop_done
	self.m_login_done = self.m_params.login_done
	self.m_draw_data = self.m_params.draw_data
	self.m_version = self.m_draw_data.version
	self:refreshData()
	self.m_day = self:getDay()
	if self.m_day > 1 and self.m_day <= 7 then
		self.m_select_index = GameUtil:formatNum(self.m_day)
	end
	--local lost =  self:get_recruit_tab()
end

function M:refreshData(data)
	if data then
		self.m_data = data
	end
end

function M:checkCanQuick()
	for i = 1, self.m_day do
		if self:checkCanGetByDay(i) == true then
			return true
		end
	end
	return false
end

function M:checkCanGetByDay(index)
	if self.m_day < index then
		return false
	end
	--签到任务
	if self:checkLoginByIndex(index) == false then
		return true
	end
	--任务
	local draw_tab = ConfigManager:getCfgByName("draw_quest")
	local version_tab = draw_tab[self.m_version]
	for k,v in pairs(version_tab) do
		if v.day == index then
			local data = self:getTaskDataById(k)
			if data.status == 1 then
				return true
			end
		end
	end
	return false
end

function M:getDay()
	local reg_ts = 0
	for k,v in pairs(self.m_draw_data.actives) do
		local act_cfg = self:checkActiveCfgById(v.id)
		if v.open_status > 0 and act_cfg.version == self.m_draw_data.version then
			reg_ts = v.start_ts
			break
		end
	end
    local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(server_ts, reg_ts, 0)
    local m_day = day + 1
	return day + 1
end

function M:checkActiveCfgById(id)
    local active_tab = ConfigManager:getCfgByName("active")
    return active_tab[id]
end

function M:getTaskTabByDay()
	local draw_quest_tab = ConfigManager:getCfgByName("draw_quest")
	local version_tab = draw_quest_tab[self.m_version]
	local day_tab = {}
	for i,v in pairs(version_tab) do
		if v.day == self.m_select_index then
			table.insert(day_tab, {cfg = v, id = i})
		end
	end
	return day_tab
end

--活动任务
function M:get_recruit_tab()
    local new_tab = {}
    local draw_tab = ConfigManager:getCfgByName("draw_quest")
    local draw_shop_tab = ConfigManager:getCfgByName("draw_shop")
	local draw_login_tab = ConfigManager:getCfgByName("draw_login")
    local shop_cfg = draw_shop_tab[self.m_version][self.m_select_index]
	local login_cfg = draw_login_tab[self.m_version][self.m_select_index]
    table.insert(new_tab, {id = self.m_select_index + 10 , cfg = shop_cfg, shop_type = true})
	table.insert(new_tab, {id = self.m_select_index, cfg = login_cfg, shop_type = true, log_type = true})
	local version_tab = draw_tab[self.m_version]
    for k, v in pairs(version_tab) do
        if v.day == self.m_select_index then
            v.id = k
            v.shop_type = false
            table.insert(new_tab, {id = k, cfg = v, shop_type = false})
        end
    end
    local get_list = {}
    local no_get_list = {}
    for i, v in pairs(new_tab) do
        if self:checkReceived(v) == true then
            table.insert(no_get_list, v)
        else
            table.insert(get_list, v)
        end
    end
	self:taskSort(no_get_list)
	self:taskSort(get_list)
	local task_list = {}
	for i = 1, #no_get_list do
		table.insert(task_list, no_get_list[i])
	end
	for i = 1, #get_list do
		table.insert(task_list, get_list[i])
	end
    return task_list
end

function M:getTaskDataById(id)
	return self.m_task_data[tostring(id)]
end

function M:taskSort(sort_tab)
    local function sortFunc(id_one, id_two)
        local can_buy_1 = id_one.shop_type == true and 1 or 0 -- 可购买
        local can_buy_2 = id_two.shop_type == true and 1 or 0 -- 可购买
        local can_get_1 = self:checkCanGet(id_one) == true and 1 or 0
        local can_get_2 = self:checkCanGet(id_two) == true and 1 or 0
		if can_buy_1 == can_buy_2 then
            if can_get_1 == can_get_2 then
                return id_one.id < id_two.id
            else
                return can_get_1 > can_get_2
            end
		else
			return can_buy_1 > can_buy_2
		end
    end
    table.sort(sort_tab, sortFunc)
end

function M:checkRedPointByDay(index)
	if self.m_day < index then
		return false
	end
	--签到任务
	if self:checkLoginByIndex(index) == false then
		return true
	end
	--首次查看
	local shop_first = RedPointUtil:drawTaskShopDayRedPoint(index)
	if shop_first == true then
		return shop_first
	end
	--任务
	local draw_tab = ConfigManager:getCfgByName("draw_quest")
	local version_tab = draw_tab[self.m_version]
	for k,v in pairs(version_tab) do
		if v.day == index then
			local data = self:getTaskDataById(k)
			if data.status == 1 then
				return true
			end
		end
	end
	return false
end

function M:checkCanGet(cfg)
    if cfg.shop_type == true then
        return true
    else
        local data = self:getTaskDataById(cfg.id)
        return data.status == 1
    end
end

--是否已领取
function M:checkReceived(cfg)
	if cfg.shop_type == true then
		if cfg.log_type and cfg.log_type == true then
			return not self:checkLogin()
		else
			return cfg.cfg.time - self:checkBuy() > 0
		end
    else
        local data = self:getTaskDataById(cfg.id)
		if data then
			return data.status ~= 2
		end
    end
	return false
end

function M:checkBuy()
    for k, v in pairs(self.m_shop_done) do
        if self.m_select_index ==  tonumber(k) then
            return v
        end
    end
    return 0
end

--是否已签到
function M:checkLogin()
	for i,v in pairs(self.m_login_done) do
		if v == self.m_select_index then
			return true
		end
	end
	return false	
end

function M:checkLoginByIndex(index)
	for i,v in pairs(self.m_login_done) do
		if v == index then
			return true
		end
	end
	return false
end

return M