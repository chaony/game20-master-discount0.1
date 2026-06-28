local M = class("SecretRewardTaskPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_quests = self.m_params.quests or 1
    self.m_version = self.m_params.version or 1
    self.m_buy_times = self.m_params.buy_times or 0
end

function M:refreshData(data)
    if data and data.quests then
        self.m_quests = data.quests
    end
end

function M:checkCanQuick()
    if self.m_quests then
        for k,v in pairs(self.m_quests) do
            if v.status == 1 then
                return true
            end
        end
    end
    return false
end

function M:getTaskTab()
    local new_cfg = {}
    local scroll_tab = ConfigManager:getCfgByName("secret_quest")
    local cfg = scroll_tab[self.m_version]

    for k,v in pairs(cfg) do
        table.insert(new_cfg, {id = k, cfg = v})
    end
    self:questSort(new_cfg)
    return new_cfg or {}
end

--活动任务
function M:get_recruit_tab()
    local new_tab = {}
    local scroll_tab = ConfigManager:getCfgByName("secret_quest")
	local version_tab = scroll_tab[self.m_version]
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


--是否已领取
function M:checkReceived(cfg)
	if cfg.shop_type == true then
		return (cfg.cfg.time - self.m_buy_times) > 0
    else
        local data = self:getTaskData(cfg.id)
        return data.status ~= 2
    end
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

function M:questSort(sort_tab)
    local function sortFunc(id_one, id_two)
        local can_get_1 = self:getTaskData(id_one.id)
        local can_get_2 = self:getTaskData(id_two.id)
        local get_type1 = can_get_1.status == 1 and 1 or 0
        local get_type2 = can_get_2.status == 1 and 1 or 0
	    if get_type1 == get_type2 then
            return id_one.id < id_two.id
        else
            return get_type1 > get_type2
        end
    end
    table.sort(sort_tab, sortFunc)
end

function M:getTaskData(id)
    if self.m_quests then
        return self.m_quests[tostring(id)]
    end
    return {}
end


function M:checkCanGet(cfg)
    if cfg.shop_type == true then
        return true
    else
        local data = self:getTaskData(cfg.id)
        return data.status == 1
    end
end

return M
