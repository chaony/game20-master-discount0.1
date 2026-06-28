local M = class("DaySevenSPCardPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("active_seven_tour_index")
end

function M:onEnter()
    self.m_callback = self.m_params.callback
    self.m_callback_new = self.m_params.callback_new
	self.m_seven_tour_data = self.m_data
    self:getSevenDayVersion()
    self.m_day = self:getIndexBySevenDay(self.id)
end

function M:updateData(data)
    if data then
        self.m_data = data or {}
        table.merge(self.m_seven_tour_data, self.m_data)
        self:getSevenDayVersion()
        self.m_day = self:getIndexBySevenDay(self.id)
    end
end

function M:getSevenDayVersion()
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_seven_tour_data.actives) do
        if v.open_status > 0 then
            local active_cfg = active_tab[v.id] 
            self.id = v.id
            self.m_version = active_cfg.version
        end
    end   
end

function M:getIndexBySevenDay(id)
    if self.m_seven_tour_data == nil then
        return 1
    end
    local active_tab = ConfigManager:getCfgByName("active")
    local active_cfg = active_tab[id]
    local seven_tour = self.m_seven_tour_data.seven_tour[tostring(active_cfg.version)]
    if seven_tour then
        local day = GameUtil:NumberOfDaysInterval(UserDataManager:getServerTime(), seven_tour.stime, 0)
        day = day +1
        return day
    end
    return 1
end

--14日登录
function M:get_seven_tour()
    local seven_tour_tab = ConfigManager:getCfgByName("seven_tour")
    return seven_tour_tab[self.m_version or 1]
end

--14日数据
function M:getStatus(day)
    local seven_tour = self.m_seven_tour_data.seven_tour[tostring(self.m_version)]
    if self.m_day < day then
        return 0 --未开启
    elseif self.m_day == day then
        for i, v in ipairs(seven_tour.received) do
            if v == day then
                return 2 -- 以领取
            end
        end
        return 1 -- 可领取
    else
        for i, v in ipairs(seven_tour.received) do
            if v == day then
                return 4 -- 曾领取
            end
        end
        return 3 -- 已过期
    end
end

-- 获取当前应该得到奖励的天数
function M:getCurCanGotAwardDay()
    local seven_tour = self.m_seven_tour_data.seven_tour[tostring(self.m_version)]
    local curIndex = 0
    if not seven_tour.received then
        return curIndex
    end
    for i = 1,self.m_day do
        if not seven_tour.received[i] then
            curIndex = i
            break
        end
    end
    return curIndex
end

function M:nextCanGet()
    for i = 1,self.m_day do
        if self:getStatus(i) == 1 or self:getStatus(i) == 3 then
            return true
        end
    end
    return false
end

return M