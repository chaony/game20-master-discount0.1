---@class PetBreedingMainModel: OODataBase
local M = class("PetBreedingMainModel", LikeOO.OODataBase)


function M:onCreate()
    M.super.onCreate(self)
    self:getData("pet_index")
end

function M:onEnter()
    Logger.log(self.m_data, "pet_index ===== ")
    self.m_data = self.m_data or {}
    self.m_list_show = true
end

function M:updateData(data)
    if data then
        table.merge(self.m_data, data)
    end
end

---检测蓬莱工坊按钮图标状态
function M:checkPetFactoryBtnImageStatus()
    local res = false

    -- VIP 加成计算
    local vipCfg = ConfigManager:getCfgByName("vip")
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local maxHour = 0
    if vipCfg[curVipLevel].factory_time_limit ~= nil then
        maxHour = vipCfg[curVipLevel].factory_time_limit
    end

    -- 最长挂机时间
    local maxIdleSecond = maxHour * 3600
    local idleStartTime = self.m_data.pet_factory_idle_start_time or UserDataManager:getServerTime()
    local curIdleSecond = UserDataManager:getServerTime() - idleStartTime 

    if curIdleSecond >= maxIdleSecond * 0.5 and idleStartTime ~= 0 then 
        res = true
    end
    
    return res
end

function M:setListShowType(flag)
    self.m_list_show = flag
end

return M