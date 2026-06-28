---@class PengLaiBazaarMainControl: OOControlBase
---@field m_model PengLaiBazaarMainModel
---@field m_view PengLaiBazaarMainView
local M = class("PengLaiBazaarMainControl", LikeOO.OOControlBase)

---摊位数据映射
local BAZAAR_POS_LIST = {
    ["booth_pos_01"] = {pos = 1},
    ["booth_pos_02"] = {pos = 2},
    ["booth_pos_03"] = {pos = 3},
    ["booth_pos_04"] = {pos = 4},
    ["booth_pos_05"] = {pos = 5},
    ["booth_pos_06"] = {pos = 6},
    ["booth_pos_07"] = {pos = 7},
    ["booth_pos_08"] = {pos = 8},
    ["booth_pos_09"] = {pos = 9},
    ["booth_pos_vip_1"] = {pos = 1, vip = true},
    ["booth_pos_vip_2"] = {pos = 2, vip = true},
}

---奖励领取按钮位置映射
local BAZAAR_GET_REWARD_BTN_LIST = {
    ["get_reward_btn_1"] = {pos = 1},
    ["get_reward_btn_2"] = {pos = 2},
    ["get_reward_btn_3"] = {pos = 3},
    ["get_reward_btn_4"] = {pos = 4},
    ["get_reward_btn_5"] = {pos = 5},
    ["get_reward_btn_6"] = {pos = 6},
    ["get_reward_btn_7"] = {pos = 7},
    ["get_reward_btn_8"] = {pos = 8},
    ["get_reward_btn_9"] = {pos = 9},
    ["get_reward_vip_btn_1"] = {pos = 1, vip = true},
    ["get_reward_vip_btn_2"] = {pos = 2, vip = true},
}

function M:onEnter()
    M.super.onCreate(self)
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    self.m_checkRewardState_timer_id = self:setTimer(60, handler(self, self.requestIndexData))
    ---今日热卖道具
    self.m_popularItemObj = nil
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "refresh_entrances" then
        -- 刷新红点和入口状态
        self.m_view:refreshEntrances()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "pengLai_text_003"
        params.content = "tid#bazaar_des_001"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "bazaar_update_ui" then
        if data then 
            self.m_model:setBazaarData(data)
        end
        
        if self.m_view then 
            self.m_view:refreshUI()
        end
    elseif msg == "bag_btn" then
        self:openView("Item.ItemList", {isShowRunescapeItem = false})
    elseif msg == "bazzar_btn" then
        local desc = self.m_model.m_curUpgradeCfg.des
        local obj = self.m_view:findGameObject("desc_pos_cmp")
        GameUtil:lookInfoTips(self, {click_transform = obj.transform, msg = Language:getTextByKey(desc)})
    elseif msg == "getAll_btn" then
        if self.m_model:checkRewardState() then 
           self:requestCollectQuick()
        end
    elseif BAZAAR_POS_LIST[msg] ~= nil then
        local value = BAZAAR_POS_LIST[msg]
        self:openBuildInfoPopView(value.pos, value.vip)
    elseif BAZAAR_GET_REWARD_BTN_LIST[msg] ~= nil then
        local value = BAZAAR_GET_REWARD_BTN_LIST[msg]
        self:receiveRewardByPos(value.pos, value.vip)
    end
end

---领取奖励
---@param pos number 位置索引，从 1 开始
function M:receiveRewardByPos(pos, vipPos)
    if self.m_model:checkRewardState(pos, vipPos) then
        self:requestCollect(pos - 1, vipPos)
    end
end

---打开建筑信息弹窗
---@param pos number 位置索引，从 1 开始
---@param isVipPos boolean 是否是VIP席位
function M:openBuildInfoPopView(pos, isVipPos)
    local isLock = self.m_model:checkBazaarIsLock(pos, isVipPos)
    local isEmpty = self.m_model:checkBazaarIsEmpty(pos, isVipPos)

    -- 显示类型：1=建造，2=建筑详情
    local type = 1
    local buildID = 0
    local isFinished = false
    local rewards = {}
    if isLock then
        local msgStr = Language:getTextByKey("pengLai_text_020")
        if isVipPos then 
            msgStr = Language:getTextByKey("pengLai_text_021")
        end
        GameUtil:lookInfoTips(self, { msg = msgStr, delay_close = 2 })
        return
    end
    
    if isEmpty then
        type = 1
    else
        type = 2
        local curBuildData = self.m_model:getBazaarDataByPos(pos, isVipPos)
        if curBuildData ~= nil and curBuildData.build_id ~= nil then 
            buildID = curBuildData.build_id
            rewards = curBuildData.gifts
            isFinished = curBuildData.finished == 1
        end
    end
    
    --- 已完成的建筑，直接领取奖励，不弹出预览弹窗
    if isFinished then
        self:requestCollect(pos - 1, isVipPos)
        return
    end
    
    local data = {
        showType = type, 
        buildId = buildID, 
        rewards = rewards,
        pos = pos,
        isVipPos = isVipPos,
        curLevel = self.m_model.m_curLevel,
        buildings = self.m_model.m_buildings,
        vipBuildings = self.m_model.m_vipBuildings,
        popularItem = self.m_model.m_popularItem,
        quickTimes = self.m_model.m_quickTimes,
        leftTimeFunc = function(pos, isVipPos) 
            return self.m_model:getCurPosLeftTimeStr(pos, isVipPos)
        end,
        getBazaarDataFunc = function(pos, isVipPos) 
            return self.m_model:getBazaarDataByPos(pos, isVipPos)
        end
    }
    
    self:openView("PengLaiBazzar.PengLaiBazzarInfoPop", data)
end

---=======================================================

---重新请求首页数据
function M:requestIndexData()
    local function callback(response)
        self:notifyUpdateRedPoint()
        if response then 
            self.m_model:setBazaarData(response)
        end
        
        if self.m_view then
            self.m_view:refreshUI()
        end
    end

    print("[REQ _ INDEX]")
    self.m_model:getNetData("bazaar_index", {}, callback)
end

---收集奖励请求
---@param pos number 位置索引，序号从 0 开始
---@param isVipPos boolean 是否是VIP席位
function M:requestCollect(pos, isVipPos)
    isVipPos = isVipPos or 0
    local function callback(response)
        self:notifyUpdateRedPoint()
        if self.m_view then
            self.m_view:refreshUI()
        end
    end

    print("[REQ _ COLLECT]" .. table.dump({pos = pos, is_vip_pos = isVipPos}, true, 5))
    self.m_model:getNetData("bazaar_collect", {pos = pos, is_vip_pos = isVipPos}, callback)
end

---一键收集请求
function M:requestCollectQuick()
    local function callback(response)
        self:notifyUpdateRedPoint()
        if self.m_view then
            self.m_view:refreshUI()
        end
    end

    self.m_model:getNetData("bazaar_collect_quick", {}, callback)
end

function M:notifyUpdateRedPoint()
    self:updateMsg("refresh_entrances", nil, "PengLaiBazzar.PengLaiBazzarIsland")
    self:updateMsg("refresh_red_point", nil, "Main")
end

---============================================================

---倒计时回调
function M:updateTime()
    if self.m_view then 
        self.m_view:refreshMapCellTimer()
    end
end

---============================================================

function M:destroy()
    -- 清理计时器
    if self.m_timer_id then 
        self:removeTimer(self.m_timer_id)
        self.m_timer_id = nil
    end
    
    if self.m_checkRewardState_timer_id then
        self:removeTimer(self.m_checkRewardState_timer_id)
        self.m_checkRewardState_timer_id = nil
    end
    
    M.super.destroy(self)
end

return M
