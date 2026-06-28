local M = class("ChivalryMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_is_token = self.m_params.is_token or false
    self:getData()
end

local ACTIVE_TAB = {
    {id = 1,open_id = 394}, 	--长歌行
    {id = 2,open_id = 395}, 	--谪仙试炼
    {id = 3,open_id = 314}, 	--诗书绘卷
    {id = 4,open_id = 397}, 	--黄金屋
    {id = 5,open_id = 346}, 	--花落谁家
    {id = 6,open_id = 398}, 	--翰林书院
}

function M:onEnter()
    self.open_id = 393
end

function M:netData(data, tag)
    table.merge(self.m_data, data or {})
end


--获取活动数据
function M:getActiveData(open_id)
    local id = self.open_id
    if open_id then
        id = open_id
    end
    local version = self:getActVsn(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == id and v.version == version then
            return v
        end
    end
    local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
    for i,v in pairs(active_recharge_tab) do
        if v.open_id == open_id and v.version == self.m_data.version then
            return v
        end
    end
    return nil
end

--获取活动信息
function M:getActiveTab()
    local active_tab = {}
    for i, v in ipairs(ACTIVE_TAB) do
        local active_data = self:getActiveData(v.open_id)
        local params = {id = v.id,open_id = v.open_id,btn_name = active_data.name}
        table.insert(active_tab,params)
    end
    return active_tab
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
    open_id = open_id or 393
    local active = nil
    if is_recharge then
        active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
    else
        active = UserDataManager:getActivesDataByOpenId(open_id)
    end
    if active and active.version then
        return active.version
    end
    if is_recharge then
        local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
        for i,v in pairs(active_recharge_tab) do
            if v.open_id == open_id then
                local cur_tim =  UserDataManager:getServerTime()
                local start_ts = GameUtil:stringToTimesTamp(v.start_time)
                local end_ts = GameUtil:stringToTimesTamp(v.end_time)
                local show_ts = 0
                if v.show_time ~= "" then
                    show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
                end
                local is_end = cur_tim < end_ts or show_ts == 1
                if cur_tim > start_ts and is_end then
                    return v.version
                end
            end
        end
    else
        local active = ConfigManager:getCfgByName("active")
        for i,v in pairs(active) do
            if v.open_id == open_id then
                local cur_tim =  UserDataManager:getServerTime()
                local start_ts = GameUtil:stringToTimesTamp(v.start_time)
                local end_ts = GameUtil:stringToTimesTamp(v.end_time)
                local show_ts = 0
                if v.show_time ~= "" then
                    show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
                end
                local is_end = cur_tim < end_ts or show_ts == 1
                if cur_tim > start_ts and is_end then
                    return v.version
                end
            end
        end
    end
    return 1
end

--获取活动开启状态  0:未开启  1:活动期  2:展示期
function M:getActiveStatus()
    local active_data = self:getActiveData()
    local start_time = GameUtil:stringToTimesTamp(active_data.start_time) --活动开始时间
    local end_time = GameUtil:stringToTimesTamp(active_data.end_time) --活动结束时间
    local show_time = GameUtil:stringToTimesTamp(active_data.show_time) --活动结束时间
    local cur_tim = UserDataManager:getServerTime() --当前时间
    if cur_tim >= start_time and cur_tim <= end_time then --活动期
        return 1
    elseif cur_tim <= show_time and cur_tim > end_time then --展示期
        return 2
    else
        return 0
    end
end

--获取活动table
function M:getAllActiveTab()
    return ACTIVE_TAB
end


return M
