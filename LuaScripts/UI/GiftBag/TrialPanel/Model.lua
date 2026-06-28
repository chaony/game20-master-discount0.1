local M = class("TrialPanelModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData("quest_recruit_index")
end

function M:onEnter()
    self.active_open = true
    self.m_sel_task_index = 1
    self.m_cur_version = 1
    self:getOpenActives()
    self.m_sel_tag_index = self.m_cur_version
    self:refreshData()
    self.m_sel_tab_index = self.m_day > 7 and 7 or self.m_day
end

function M:refreshData(data)
    if data then
        self.m_data = data
    end
    local active_data = self:getActiveById(self.m_sel_tag_index)
    if active_data then
        self.down_Tim = active_data.remain_ts
        self.star_ts = active_data.start_ts
        self:dayCompute(self.star_ts)
    end
    self.m_active_cfg = self:checkActives(active_data)
    if self.m_active_cfg then
        self.m_recruit_data = self.m_data.quest_data[tostring(self.m_active_cfg.version)]
        self.m_shop_done = self.m_recruit_data.shop_done
        self.m_score_done = self.m_recruit_data.score_done
        self.m_sel_tag_index = self.m_active_cfg.version
    end
end

function M:getActiveById(id)
    for k,v in pairs(self.m_data.actives) do
        if v.id == id then
            return v
        end
    end
end

function M:getOpenActives()
    if self.m_data and self.m_data.actives then
        for k,v in pairs(self.m_data.actives) do
            if UserDataManager:getServerTime() > v.start_ts and  v.remain_ts > 0 then
                local active_cfg = self:checkActives(v)
                self.m_cur_version = active_cfg.version
                return
            end
        end
    end
    if #self.m_data.actives > 0 then
        local active_cfg = self:checkActives(self.m_data.actives[1])
        self.m_cur_version = active_cfg.version
    end 
end

function M:checkLastVsn()
    local recruit_tab = ConfigManager:getCfgByName("recruit")
    if self.m_cur_version == #recruit_tab then
        for k,v in pairs(self.m_data.actives) do
            if v.id == #recruit_tab and v.remain_ts ==-1 then
                return true
            end
        end
    end
    return false
end

function M:checkVersionOpen(index)
    if self.m_data.quest_data[tostring(index)] then
        return true    
    end
    return false
end

function M:checkActives(active)
    local active_tab = ConfigManager:getCfgByName("active")
    return active_tab[active.id]
end

function M:checkPoint(day)
    local recruit_tab = ConfigManager:getCfgByName("recruit")[self.m_active_cfg.version] or {}
    for i,v in pairs(recruit_tab) do
        if v.reg_days == day then
            local data = self:getTaskCfg(i)
            if data and data.status == 1 then
                 return true
            end
        end
    end
    local day_bl = RedPointUtil:recruitShopDayRedPoint(self.m_sel_tag_index, day)
    if day_bl == false then
        if self.m_sel_tag_index ~= self.m_cur_version then
            return false
        end
        day_bl = self:checkLoginRedPoint(day)
    end
    return day_bl
end

function M:checkDayAndType(id)
    local open_tab = self:get_recruit_open()
    for k, v in pairs(open_tab) do
        for kk, vv in pairs(v.target1) do
            if vv == id then
                return k, 1
            end
        end
        for kk2, vv2 in pairs(v.target2) do
            if vv2 == id then
                return k, 2
            end
        end
    end
end

function M:dayCompute(star_ts)
    local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(server_ts, star_ts, 0)
    self.m_day = GameUtil:formatNum(day + 1)
end

--试炼活动任务
function M:get_recruit_tab()
    local new_tab = {}
    local recruit_tab = ConfigManager:getCfgByName("recruit")[self.m_active_cfg.version]
    local recruit_shop_tab = ConfigManager:getCfgByName("recruit_shop")[self.m_active_cfg.version]
    local recruit_login_tab = ConfigManager:getCfgByName("recruit_login")[self.m_active_cfg.version]
    local shop_cfg = recruit_shop_tab[self.m_sel_tab_index]
    local login_cfg = table.copy(recruit_login_tab[self.m_sel_tab_index]) 
    table.insert(new_tab, {id = self.m_sel_tab_index, name = "gf_str_0096", price_new = shop_cfg.price_new,  price_old = shop_cfg.price_old, reward = shop_cfg.reward, shop_type = true})
    login_cfg.id = self.m_sel_tab_index
    login_cfg.shop_type = true
    login_cfg.log_type = true
    table.insert(new_tab, login_cfg)
    for k, v in pairs(recruit_tab) do
        if v.reg_days == self.m_sel_tab_index then
            v.id = k
            v.shop_type = false
            table.insert(new_tab, v)
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

function M:taskNewSort(sort_tab)
    local function sortFunc(id_one, id_two)
        local can_buy_1 = id_one.shop_type == true and 1 or 0 -- 可购买
        local can_buy_2 = id_two.shop_type == true and 1 or 0 -- 可购买
		if can_buy_1 == can_buy_2 then
			return id_one.id < id_one.id
		else
			return can_buy_1 > can_buy_2
		end
    end
    table.sort(sort_tab, sortFunc)
end

function M:taskSort(sort_tab)
    local function sortFunc(id_one, id_two)
        local login_1 = id_one.log_type == true and 1 or 0 -- 可购买
        local login_2 = id_two.log_type == true and 1 or 0 -- 可购买
        local can_buy_1 = id_one.shop_type == true and 1 or 0 -- 可购买
        local can_buy_2 = id_two.shop_type == true and 1 or 0 -- 可购买
        local can_get_1 = self:checkCanGet(id_one) == true and 1 or 0
        local can_get_2 = self:checkCanGet(id_two) == true and 1 or 0
		if login_1 == login_2 then
            if can_buy_1 == can_buy_2 then
                if can_get_1 == can_get_2 then
                    return id_one.id < id_two.id
                else
                    return can_get_1 > can_get_2
                end
            else
                return can_buy_1 > can_buy_2
            end
        else
            return login_1 > login_2
        end
   
    end
    table.sort(sort_tab, sortFunc)
end

function M:checkCanGet(cfg)
    if cfg.shop_type == true then
        return true
    else
        local data = self:getTaskCfg(cfg.id)
        if data then
            return data.status == 1
        else
            return false    
        end
    end
end

--是否已领取
function M:checkReceived(cfg)
    if cfg.shop_type == true then
        if cfg.log_type and cfg.log_type == true then
			return not self:checkLogin()
        end
        return not self:checkBuy()
    else
        local data = self:getTaskCfg(cfg.id)
        if data then
            return data.status ~= 2
        end
        return false
    end
end

--是否已签到
function M:checkLogin()
    for k,v in pairs(self.m_recruit_data.login_done) do
        if v == self.m_sel_tab_index then
            return true
        end
    end
	return false	
end

function M:checkLoginRedPoint(day)
    if self:checkLastVsn() == true then
        return false
    end
    for k,v in pairs(self.m_recruit_data.login_done) do
        if v == day then
            return false
        end
    end
	return true	
end

function M:getShopStatus()
    local shop_tab = ConfigManager:getCfgByName("recruit_shop")[self.m_active_cfg.version]
    return shop_tab[self.m_sel_tab_index], self:checkBuy(self.m_sel_tab_index)
end

function M:checkBuy()
    for k, v in pairs(self.m_shop_done) do
        if self.m_sel_tab_index == v then
            return true
        end
    end
    return false
end

function M:getScoreData(id)
    for k, v in pairs(self.m_score_done) do
        if id == v then
            return v
        end
    end
    return nil
end

function M:getVsnScoreData(id, score_done)
    for k, v in pairs(score_done) do
        if id == v then
            return v
        end
    end
    return nil
end

function M:getTaskCfg(id)
    local recruit_tab = ConfigManager:getCfgByName("recruit")[self.m_active_cfg.version]
    local recruit_data = self.m_recruit_data.recruit_quests[tostring(id)] or {}
    return recruit_data
end

function M:getRecruitCfg(index)
    local recruit_tab = ConfigManager:getCfgByName("recruit_reward")[self.m_active_cfg.version]
    return recruit_tab[index]
end

function M:getRecruitLength(index)
    if index == 1 then
        local cur_data = self:getRecruitCfg(index)
        return cur_data.score
    else
        local last_data = self:getRecruitCfg(index - 1)
        local cur_data = self:getRecruitCfg(index)
        return cur_data.score - last_data.score
    end
end

function M:getScore()
    return self.m_recruit_data.score
end

function M:getStageName(stage_id)
    local stage_tab = ConfigManager:getCfgByName("stage")
    local data = stage_tab[stage_id]
    if data == nil then
        return "nil"
    end
    return Language:getTextByKey(data.map_point_name) 
end

function M:ItemSort(items)
    items = items or {}
    local function sortFunc(id_one, id_two)
        local cfg_1, data_1 = self:getTaskCfg(id_one)
        local cfg_2, data_2 = self:getTaskCfg(id_two)
        local finish_1 = data_1.status == 2 and 1 or 0
        local finish_2 = data_2.status == 2 and 1 or 0
        if finish_1 == finish_2 then
            return id_one < id_two
        else
            return finish_1 < finish_2
        end
    end
    table.sort(items, sortFunc)
    return items
end

function M:checkRewardHero()
    local recruit_cfg = ConfigManager:getCfgByName("recruit_show")[self.m_sel_tag_index]
    return recruit_cfg.reward_show[1]
end

function M:chectVerTagRedPoint(index)
    if self.m_data.quest_data[tostring(index)] == nil then
        return false
    end
    if index >= self.m_cur_version then
        return false
    end
    local red_point = self:checkVersionPoint(index)
    if red_point == false then
        for i = 1,7 do
            red_point = RedPointUtil:recruitShopRedPoint(index, i)
            if red_point == true then
                return red_point
            end
        end
    end
    if red_point == false then
        local vsn_data = self.m_data.quest_data[tostring(index)]
        for i = 1, 5 do
        	local activ_cfg = self:getRecruitCfg(i)
            local score_data = self:getVsnScoreData(i,vsn_data.score_done)
            if vsn_data.score >= activ_cfg.score and score_data == nil then
                return true
            end
        end
    end
    return red_point
end

function M:checkVersionPoint(ver)
    local recruit_tab = ConfigManager:getCfgByName("recruit")[ver] or {}
    for i,v in pairs(recruit_tab) do
        local data = self:getVerTaskCfg(ver, i)
        if data and data.status == 1 then
             return true
        end
    end
    return false
end

function M:getVerTaskCfg(ver,id)
    local recruit_tab = ConfigManager:getCfgByName("recruit")[ver]
    local quest_data =  self.m_data.quest_data[tostring(ver)]
    local recruit_data = quest_data.recruit_quests[tostring(id)] or {}
    return recruit_data
end

return M
