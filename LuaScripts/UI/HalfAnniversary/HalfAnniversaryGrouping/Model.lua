---@class HalfAnniversaryGroupingModel: OODataBase
local M = class("HalfAnniversaryGroupingModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("gift_grouping_index")
end

function M:onEnter()
    self:initData()
end

function M:initData()
    self.m_open_id = self.m_params.open_id or 333
    self.m_sel_index = self.m_params.index or 1
    self.m_curSeason = UserDataManager:getCurSeason()
    self.m_giftList = {}
    self.m_stageList = {}
    self:refreshMainData(self.m_data)
    self:initStageData()
end

function M:refreshMainData(data)
    self.m_version = data.version
    self.m_total_pay_times = data.total_pay_times
    self.self_total_payment = data.self_total_payment
    self.m_active_day = data.active_day
    self:initGiftData()
end

function M:initStageData()
    local stageData = ConfigManager:getCfgByName("public_gift_quest")
    self.m_stageList = stageData[self.m_version].phase or {}
end


function M:initGiftData()
    --先取天数，再取小于当前赛季的所有赛季
    local giftData = ConfigManager:getCfgByName("public_gift")
    local dayGiftList = giftData[self.m_version][self.m_active_day]
    local curSeason = self.m_curSeason
    self.m_giftList = {}
    for k1, v1 in pairs(dayGiftList) do
        if k1 <= curSeason then
            for k2,v2 in pairs(v1) do
                table.insert(self.m_giftList,{ gift_cfg = v2, gift_id = k2 })
            end

        end
    end
    local a = 1
end

function M:getStageData()
    return self.m_stageList
end

function M:getCurDayGiftData()
    local curDayGiftList = table.copy(self.m_giftList)
    for k1, v1 in pairs(self.m_self_group_list) do
        for k2, v2 in pairs(curDayGiftList) do
            if v2.gift_cfg.charge_id == v1.charge_id then
                table.remove(curDayGiftList, k2)
                break
            end
        end
    end
    table.sort(curDayGiftList, function(data1, data2)
        return data1.gift_id < data2.gift_id;
    end)
    return curDayGiftList
end


function M:getCurDayPhaseConfigByGiftId(gift_id)
    local list = self.m_giftList or {}
    if list[gift_id] then
        return list[gift_id].gift_cfg.phase
    end
end

function M:getTotalTimes()
    return self.m_total_pay_times
end

function M:getMaxTimes()
    return self.m_stageList[3].phase
end

function M:setTotalTimes(times)
    self.m_total_pay_times = times or 0
end

function M:getRtnValue()
    local total_num = self.m_total_pay_times
    local rtn_factor = 0
    local rtn_num = 0
    for k, v in ipairs(self.m_stageList) do
        if total_num >= v.phase then
            rtn_factor = v.rtn
        end
    end
    rtn_num = math.floor(self.self_total_payment * rtn_factor)
    return rtn_num
end

function M:setTotalPayValue(value)
    self.self_total_payment = value or 0
end

function M:updateGroupList(data)
    self.m_cur_group_list = data or {}
end

function M:getGroupList()
    return self.m_cur_group_list
end

function M:updateSelfGroupList(data)
    self.m_self_group_list = data or {}
end

function M:getSelfGroupList()
    return self.m_self_group_list
end

function M:getRefreshGroupId()
    if self.m_cur_group_list and #self.m_cur_group_list > 0 then
        local group_ids = {}
        for k, v in ipairs(self.m_cur_group_list) do
            table.insert(group_ids, v.group_id)
        end
        return group_ids
    end
    return {}
end

function M:sortGroupList(model)
    if self.m_cur_group_list and #self.m_cur_group_list > 1 then
        if model == 1 then
            table.sort(self.m_cur_group_list, function(data1, data2)
                if data1.create_time ~= data2.create_time then
                    return data1.create_time > data2.create_time
                elseif #data1.pay_uids ~= #data2.pay_uids then
                    return #data1.pay_uids > #data2.pay_uids
                elseif data1.price ~= data2.price then
                    return data1.price > data2.price
                else
                    return data1.group_id > data2.group_id
                end

            end)
        elseif model == 2 then
            table.sort(self.m_cur_group_list, function(data1, data2)
                if #data1.pay_uids ~= #data2.pay_uids then
                    return #data1.pay_uids > #data2.pay_uids
                elseif data1.create_time ~= data2.create_time then
                    return data1.create_time > data2.create_time
                elseif data1.price ~= data2.price then
                    return data1.price > data2.price
                else
                    return data1.group_id > data2.group_id
                end
            end)
        elseif model == 3 then
            table.sort(self.m_cur_group_list, function(data1, data2)
                if data1.price ~= data2.price then
                    return data1.price > data2.price
                elseif data1.create_time ~= data2.create_time then
                    return data1.create_time > data2.create_time
                elseif #data1.pay_uids ~= #data2.pay_uids then
                    return #data1.pay_uids > #data2.pay_uids
                else
                    return data1.group_id > data2.group_id
                end
            end)
        end
    end

end

function M:getVersion()
    return self.m_version
end

function M:getSelIndex()
    return self.m_sel_index
end

function M:setSelIndex(index)
    self.m_sel_index = index
end

function M:setSearchState(isOpenSearch)
    self.m_isOpenSearch = isOpenSearch
end

function M:getSearchState()
    return self.m_isOpenSearch
end

function M:getActivityData()
    return UserDataManager:getActivesDataByOpenId(self.m_open_id)
end

return M