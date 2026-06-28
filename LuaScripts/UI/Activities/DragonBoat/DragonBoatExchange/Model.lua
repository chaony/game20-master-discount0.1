---@class DeliciousFeastExchangeModel: OODataBase
local M = class("DragonBoatExchangeModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    local param = {}
    param.open_id = self.m_params.openId
    param.vsn = self.m_params.versionId
    self:getData("active_common_exchange_index", param)
end

function M:onEnter()
    self.m_openId = self.m_params.openId
    self.m_version = self.m_params.versionId
    self.active_data = GameUtil:getActiveData(self.m_openId)
    if self.active_data == nil then
        self.active_data = {
            name = "feast_text_0004"
        }
    end
    self:refreshExchangeData(self.m_data.exchange)
    self:getActStatus()
end

function M:refreshExchangeData(data)
    if data then
        self.m_exchange_data = data
    end
end

function M:getXlsxActivityByOpenId(openId, isRechargeActivity)
    local xlsxName = isRechargeActivity and "active_recharge" or "active"
    local active = ConfigManager:getCfgByName(xlsxName)
    for _,itemData in pairs(active) do
        if (itemData.version == self.m_version) and (openId == itemData.open_id) then
            return itemData
        end
    end
    return nil
end

function M:getActStatus()
    self.m_act_data = UserDataManager:getActivesDataByOpenId(self.m_openId)
    if self.m_act_data and self.m_act_data.open_status then
        return self.m_act_data.open_status
    end
    return 0
end

function M:getEndTs()
    if self.m_act_data and self.m_act_data.end_ts then
        return self.m_act_data.end_ts - UserDataManager:getServerTime()
    end
    return 0
end

--神飨兑换奖励列表
function M:get_exchange_limit_cfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("tongyong_exchange")
    local version_tab = exchange_limit_tab[self.m_openId][version]
    local new_tab = {}
    local cur_season = UserDataManager:getCurSeason()
    local self_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local season_condition_flag = false
    for i = 1, #version_tab do
        local cur_cfg = version_tab[i]
        cur_cfg.id = i
        season_condition_flag = false
        if cur_cfg.season1 and cur_cfg.season and cur_cfg.vip then
            if cur_cfg.season1 == -1 then
                if cur_cfg.season <= cur_season and cur_cfg.vip <= self_vip then
                    season_condition_flag = true
                end
            elseif cur_cfg.season1 == cur_season and cur_cfg.vip <= self_vip then
                season_condition_flag = true
            end
        end
        if season_condition_flag == true then
            table.insert(new_tab, cur_cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getExchangeData( id_one.id)
        local data_2 = self:getExchangeData( id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.times > 0 and data_1 >= id_one.times then
            time1 = 0
        end
        if id_two.times > 0 and data_2 >= id_two.times then
            time2 = 0
        end
        if time1 == time2 then
            return id_one.id < id_two.id
        else
            return time1 > time2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getExchangeData(id)
    if self.m_exchange_data ~= nil then
        for k, v in pairs(self.m_exchange_data) do
            if k == tostring(id) then
                return v
            end
        end
    end
    return 0
end

function M:checkIsOfficial()
    return self.m_params.isOfficial
end

function M:getSpineName()
    return self.m_params.spineName
end

return M