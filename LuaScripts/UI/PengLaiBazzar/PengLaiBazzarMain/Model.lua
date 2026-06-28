---@class PengLaiBazaarMainModel: OODataBase
local M = class("PengLaiBazaarMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("bazaar_index")
end

function M:onEnter()
    self:initData()
    self:setBazaarData(self.m_data)
end

function M:initData()
    -- 建筑状态变化记录
    self.m_buildingsChangeState = {}
    self.m_vipBuildingsChangeState = {}
end

---设置集市数据
function M:setBazaarData(msgData)
    self.m_curTotalExp = msgData.exp
    self.m_curLevel = msgData.lv
    
    self.m_maxBuildingNum = msgData.max_cell
    self.m_maxVipBuildingNum = msgData.vip_max_cell
    
    local upgradeCfg = ConfigManager:getCfgByName("bazaar_upgrade")
    self.m_curUpgradeCfg = upgradeCfg[self.m_curLevel]
    -- 判断当前等级的可解锁地格数量
    if self.m_curUpgradeCfg and self.m_maxBuildingNum > self.m_curUpgradeCfg.num then
        self.m_maxBuildingNum = self.m_curUpgradeCfg.num
    end

    -- VIP 加成计算
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    if curVipLevel ~= 0 then
        local vipCfg = ConfigManager:getCfgByName("vip")
        local curVipCfg = vipCfg[curVipLevel]
        if curVipCfg and curVipCfg.bazaar then
            self.m_maxVipBuildingNum = curVipCfg.bazaar
        end
    end
    
    self.m_popularItem = msgData.popular_item
    self.m_weightUp = msgData.weight_up
    self.m_drop_up = msgData.drop_up
    -- VIP 已加速次数
    self.m_quickTimes = msgData.quick_times
    
    self.m_unlockBuildingNum = 0
    self.m_emptyBuildingNum = 0

    -- 清空之前的赋值
    self.m_buildings = {}
    self.m_vipBuildings = {}

    -- 记录普通建筑
    for i, data in ipairs(msgData.buildings) do
        
        if data ~= {} and data.build_id then
            -- 统计已解锁摊位数
            self.m_unlockBuildingNum = self.m_unlockBuildingNum + 1
        elseif data.build_id == nil then
            -- 未解锁的不计入总数，统计空地数量
            if not self:checkBazaarIsLock(i, false) then
                self.m_emptyBuildingNum = self.m_emptyBuildingNum + 1
            end
        end
        print("pos = " .. data.pos)
        print(table.dump(data.gifts or {}, true, 5))

        local isNew = false
        local isDestroy = false
        local isGetReward = data.finished == 1
        local tempData = self.m_buildingsChangeState[i]
        if tempData then
            isNew = not tempData.isNew and data.build_id ~= nil  
            isDestroy = not data.build_id and tempData.build_id ~= nil
        end
        
        local stateData = {
            build_id = data.build_id,
            showNew = isNew,
            showDestroy = isDestroy,
            showGetReward = isGetReward
        }
        self.m_buildingsChangeState[i] = stateData
        
        table.insert(self.m_buildings, data)
    end

    -- 记录vip建筑
    for i, data in ipairs(msgData.vip_buildings) do
        
        if data ~= {} and data.build_id then
            -- 统计已解锁摊位数
            self.m_unlockBuildingNum = self.m_unlockBuildingNum + 1
        elseif data.build_id == nil then
            -- 未解锁的不计入总数，统计空地数量
            if not self:checkBazaarIsLock(i, true) then
                self.m_emptyBuildingNum = self.m_emptyBuildingNum + 1    
            end
        end
        print("vip pos = " .. data.pos)
        print(table.dump(data.gifts or {}, true, 5))

        local isNew = false
        local isDestroy = false
        local isGetReward = data.finished == 1
        local tempData = self.m_vipBuildingsChangeState[i]
        if tempData then
            isNew = not tempData.isNew and data.build_id ~= nil
            isDestroy = not data.build_id and tempData.build_id ~= nil
        end

        local stateData = {
            build_id = data.build_id,
            showNew = isNew,
            showDestroy = isDestroy,
            showGetReward = isGetReward
        }

        self.m_vipBuildingsChangeState[i] = stateData
        
        table.insert(self.m_vipBuildings, data)
    end
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
    print("网络数据回调 ============>" .. tag)
    if tag == "bazzar_index" or tag == "bazaar_build" or tag == "bazaar_build_quick" then
        self:setBazaarData(data)
    elseif tag == "bazaar_collect" or tag == "bazaar_collect_quick" then
        if data then
            -- 显示通用奖励界面
            if data.reward then
                RewardUtil:rewardTipsByData(data.reward)
            end

            -- 更新数据
            if data.bazaar then
                self:setBazaarData(data.bazaar)
            end
        end
    elseif tag == "bazaar_finish_quick" then
        self:setBazaarData(data)
    end
end

---================================================================

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

---通过位置获取摊位状态变化数据
---@param pos number pos 从 1 开始
---@param isVipPos boolean 是否是VIP席位
function M:getBazaarChangeStateDataByPos(pos, isVipPos)
    if isVipPos then
        -- 检测VIP席位
        return self.m_vipBuildingsChangeState[pos]
    else
        -- 检测普通席位
        return self.m_buildingsChangeState[pos]
    end

    return nil
end

---================================================================

---是否可以收集奖励
---@param pos number 位置序号，从 1 开始，如果不填，则表示判断全部
---@param isVipPos boolean 是否是VIP席位
function M:checkRewardState(pos, isVipPos)
    local res = false
    if not pos then
        for i, v in ipairs(self.m_vipBuildings) do
            if v.build_id ~= nil and v.gifts ~= nil then
                res = #v.gifts ~= 0
                if res then
                    return true
                end
            end
        end

        for i, v in ipairs(self.m_buildings) do
            if v.build_id ~= nil and v.gifts ~= nil then
                res = #v.gifts ~= 0
                if res then
                    return true
                end
            end
        end
    else
        local isLock = self:checkBazaarIsLock(pos, isVipPos)
        local curBuilding = self:getBazaarDataByPos(pos, isVipPos)
        if curBuilding ~= nil and curBuilding.gifts ~= nil and not isLock then
            res = #curBuilding.gifts ~=0
        end
    end 
    
    return res
end

---检测此位置是否锁定
---@param pos number 位置序号，从 1 开始
---@param isVipPos boolean 是否是VIP席位
function M:checkBazaarIsLock(pos, isVipPos)
    local res = true
    -- 第一个普通建筑默认解锁
    if pos == 1 and not isVipPos then
        res = false
        return res        
    end

    if isVipPos then
        -- VIP 席位检测
        local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
        if curVipLevel ~= 0 then
            local vipCfg = ConfigManager:getCfgByName("vip")
            local curVipCfg = vipCfg[curVipLevel]
            if curVipCfg.bazaar and curVipCfg.bazaar ~= 0 and curVipCfg.bazaar >= pos then
                res = false
            end
        end    
    else
        local upgradeCfg = ConfigManager:getCfgByName("bazaar_upgrade")
        local curUpgradeCfg = upgradeCfg[self.m_curLevel]
        -- 判断当前等级的可解锁空地数量
        if curUpgradeCfg and curUpgradeCfg.num >= pos then
            res = false
        end 
    end
    
    return res
end

---检测此位置是否是空地，此处的空地，指已解锁可使用的空地
---@param pos number 位置序号，从 1 开始
---@param isVipPos boolean 是否是VIP席位
function M:checkBazaarIsEmpty(pos, isVipPos) 
    local res = false

    local isLock = self:checkBazaarIsLock(pos, isVipPos)
    if not isLock then 
        local curBuildData = self:getBazaarDataByPos(pos, isVipPos)
        if not curBuildData or not curBuildData.build_id then 
            res = true
        end
    end
    
    return res
end

---================================================================

---获取建筑Spine资源名称
function M:getBuildSpineName(buildID)
    local res = ""
    local buildCfgs = ConfigManager:getCfgByName("bazaar_build")
    if buildID ~= nil and buildID ~= 0 then
        local curCfg = buildCfgs[buildID] or {}
        res = curCfg.spine or ""
    end
    
    if res ~= "" then
        res = "RoleSpine/" .. res .. "_SkeletonData"   
    end
    
    return res
end

---获取经验进度进度
function M:getBazaarExpProgress() 
    local cur = self.m_curTotalExp
    local max = 0
    local upgradeCfg = ConfigManager:getCfgByName("bazaar_upgrade")
    local curLevelCfg = upgradeCfg[self.m_curLevel]
    
    if curLevelCfg then
        max = curLevelCfg.exp
    end

    return cur, max
end

---获取经验进度文本
function M:getBazaarExpProgressStr()
    local cur, max = self:getBazaarExpProgress()
    local expStr = ""

    if max == 0 then
        expStr = Language:getTextByKey("options_str_0039")
    else
        expStr = cur .. "/" .. max
    end
    
    return expStr
end

---获取当前位置摊位的剩余时间
function M:getCurPosLeftTime(pos, isVipPos)
    local curBuild = self:getBazaarDataByPos(pos, isVipPos)

    -- 空判断
    local isDataNull = curBuild == nil
    if isDataNull then 
        return -1, -1, false
    end
    
    local server_time = UserDataManager:getServerTime()
    local isFinished = curBuild.finished == 1 or false
    local totalTime = (curBuild.end_time and curBuild.create_time) and curBuild.end_time - curBuild.create_time or 0
    local leftTime = curBuild.end_time and curBuild.end_time - server_time or 0
    
    return leftTime, totalTime, isFinished
end

---获取当前位置摊位的剩余时间文本
function M:getCurPosLeftTimeStr(pos, isVipPos) 
    local res = ""
    local leftTime, totalTime, isFinished = self:getCurPosLeftTime(pos, isVipPos)
    if isFinished then
        res = Language:getTextByKey("activities_str_0007")
    else 
        res = GameUtil:formatTimeBySecond(leftTime, 999)
    end
    
    return res
end

---获取当前位置摊位的剩余时间进度
function M:getCurPosLeftTimeProgress(pos, isVipPos) 
    local res = 0
    local leftTime, totalTime, isFinished = self:getCurPosLeftTime(pos, isVipPos)
    if isFinished then
        res = 1
    elseif totalTime ~= 0 then
        res = 1 - leftTime / totalTime
    end
    
    return res
end

return M