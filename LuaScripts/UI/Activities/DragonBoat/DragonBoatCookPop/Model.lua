---@class DeliciousFeastCookPopModel: OODataBase
local M = class("DragonBoatCookPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()

end

function M:checkCanCook()
    return self.m_params.maxNum > 0
end

function M:getMaxCookNum()
    return self.m_params.maxNum
end

function M:getTargetItemData()
    return self.m_params.item_data.target_data
end

function M:getVersion()
    return self.m_params.version
end

function M:getMaterialItemData()
    return self.m_params.item_data.materials_data
end

function M:getCurIndex()
    --比例不同
    return self.m_params.index
end

function M:checkActivityOpen()
    local openId = self.m_params.openId
    local activityData = nil
    activityData = UserDataManager:getActivesDataByOpenId(openId)
    if not activityData then
        return false
    end
    if activityData.open_status == 2 then
        return false
    end
    --直接用展示时间
    local curTime = UserDataManager:getServerTime()
    local endTime = activityData.show_start_ts or 0
    return curTime <= endTime
end

function M:getCookId()
   return self.m_params.item_data.id
end

return M