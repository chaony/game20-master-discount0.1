---@class PengLaiBazzarInfoPopModel: OODataBase
local M = class("PengLaiBazzarInfoPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_rewards = {}
    self.m_showType = self.m_params.showType
    self.m_curLevel = self.m_params.curLevel
    self.m_curPos = self.m_params.pos or 1
    self.m_selectedIndex = 1
    self.m_isVipPos = self.m_params.isVipPos or false
    self.m_quickTimes = self.m_params.quickTimes or 0

    -- 当前表中所有摊位建筑
    self.m_allBuildings = ConfigManager:getCfgByName("bazaar_build")
    self.m_allUpgradeCfg = ConfigManager:getCfgByName("bazaar_upgrade")
    self.m_curUpgradeCfg = self.m_allUpgradeCfg[self.m_curLevel]
    -- 优先取配置中的值，否则默认选中第一个
    self.m_buildID = self.m_params.buildId ~= 0 and self.m_params.buildId or self.m_curUpgradeCfg.build[1]
    
    --- 服务器数据
    self.m_buildings = self.m_params.buildings or {}
    self.m_vipBuildings = self.m_params.vipBuildings or {}
    self.m_popularItem = self.m_params.popularItem or 0
    
    self.m_leftTimeFunc = self.m_params.leftTimeFunc or nil
    self.m_getBazaarDataFunc = self.m_params.getBazaarDataFunc or nil
    self.m_cfg = self.m_allBuildings[self.m_buildID]
    
    if self.m_showType == 1 then
        --- 直接读取配置表中的奖励
        self.m_rewards = self.m_cfg.item_show
    elseif self.m_showType == 2 then
        --- 获取当前的产出
        self.m_rewards = self.m_params.rewards or {}
    end
    
    -- 建造消耗类型 1 = 道具 2 = 元宝
    self.m_costType = 1
end

---=======================================

---通过位置获取摊位数据
---@param pos number pos 从 1 开始
---@param isVipPos boolean 是否是VIP席位
function M:getBazaarDataByPos(pos, isVipPos)

    if isVipPos then
        -- 检测VIP席位
        for i, v in pairs(self.m_vipBuildings) do
            if v.pos == pos - 1 then
                return v
            end
        end
    else
        -- 检测普通席位
        for i, v in pairs(self.m_buildings) do
            if v.pos == pos - 1 then
                return v
            end
        end
    end

    return nil
end

---判断当前建筑是否是今日热卖
function M:checkIsPopular(buildId) 
    local res = false

    for i, v in pairs(self.m_allBuildings) do
        if v.id == buildId then
            for ii, vv in pairs(v.item_show) do
                if vv[2] == self.m_popularItem then 
                    res = true
                    break
                end
            end
        end 
    end
    
    return res
end

---=======================================

---获取可快速开店的总数
function M:getCanQuickBuildCount() 
    local res = 0
    for i, v in pairs(self.m_buildings) do
        if not v or not v.build_id then
            res = res + 1
        end
    end

    for i, v in pairs(self.m_vipBuildings) do
        if not v or not v.build_id then
            res = res + 1
        end
    end

    -- 计算VIP地格
    local maxVipBuildingCount = 0
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    if curVipLevel ~= 0 then
        local vipCfg = ConfigManager:getCfgByName("vip")
        local curVipCfg = vipCfg[curVipLevel]
        if curVipCfg and curVipCfg.bazaar then
            maxVipBuildingCount = curVipCfg.bazaar > 0 and curVipCfg.bazaar or 0
        end
    end
    
    local maxBuildCount = self.m_curUpgradeCfg.num + maxVipBuildingCount
    if res > maxBuildCount then 
        res = maxBuildCount
    end
    
    return res
end

---=======================================

function M:switchSelectData(cellData) 
    --print("[switchSelectData]\t" .. table.dump(cellData, true, 5))
    if cellData.data then
        self.m_buildID = cellData.data
        self.m_cfg = self.m_allBuildings[self.m_buildID]
        self.m_selectedIndex = cellData.index 
        self:setClickTransform(cellData.cell_obj)

        if self.m_showType == 1 then
            --- 直接读取配置表中的奖励
            self.m_rewards = self.m_cfg.item_show
        elseif self.m_showType == 2 then
            --- 获取当前的产出
            self.m_rewards = self.m_params.rewards or {}
        end
    end
end

function M:setClickTransform(trans) 
    self.m_click_transform = trans
end

---获取剩余加速次数
function M:getLeftSpeedUpCount()
    local res = 0
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    if curVipLevel ~= 0 then
        local vipCfg = ConfigManager:getCfgByName("vip")
        local curVipCfg = vipCfg[curVipLevel]
        if curVipCfg and curVipCfg.bazaar_finish_time then
            res = curVipCfg.bazaar_finish_time > 0 and curVipCfg.bazaar_finish_time - self.m_quickTimes or 0
        end
    end
    
    return res
end

--- 设置道具消耗类型
function M:setCostType(type) 
    self.m_costType = type
end

return M