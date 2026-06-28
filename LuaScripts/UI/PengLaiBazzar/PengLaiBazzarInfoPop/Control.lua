---@class PengLaiBazzarInfoPopControl: OOControlBase
---@field m_model PengLaiBazzarInfoPopModel
---@field m_view PengLaiBazzarInfoPopView
local M = class("PengLaiBazzarInfoPopControl", LikeOO.OOControlBase)

---显示模式
M.m_initShowType = 1
---当前建筑ID
M.m_build_id = 0

function M:onEnter()
    M.super.onCreate(self)

    self.m_initShowType = self.m_model.m_showType or 1
    self.m_build_id = (self.m_model.m_buildID and self.m_model.m_buildID ~= 0) or 101

    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "build_one_btn" then
        local pos = self.m_model.m_curPos - 1
        self:requestBuildBazaar(self.m_model.m_buildID, pos, self.m_model.m_isVipPos)
    elseif msg == "build_all_btn" then
        self:requestBuildBazaarQuick(self.m_model.m_buildID)
    elseif msg == "speed_up_btn" then
        self:requestFinishQuick(self.m_model.m_curPos - 1, self.m_model.m_isVipPos)
    elseif msg == "close_desc_btn" then
        if self.m_view then 
            self.m_view.m_showStyle = self.m_initShowType
            self.m_view:switchShowType()
        end
    elseif msg == "information_btn" then
        if self.m_view then
            self.m_view.m_showStyle = 3
            self.m_view:switchShowType()
        end
    elseif msg == "building_list_item_select" then
        if self.m_view and data then
            self.m_model:switchSelectData(data)
            self.m_view:refreshUI()
        end
    end
end

---=======================================================

---请求建筑摊位
---@param buildID number 建筑的配置ID
---@param pos number 位置索引，序号从 0 开始
---@param isVipPos number 是否是 VIP 位置，0-否；1-是
function M:requestBuildBazaar(buildID, pos, isVipPos)
    isVipPos = isVipPos and 1 or 0
    local function callback(response)
        self:updateMsg("bazaar_update_ui", response, "PengLaiBazzar.PengLaiBazzarMain")
        self:notifyUpdateRedPoint()
        self:closeView()
    end

    print("[REQ _ BUILD]" .. table.dump({build_id = buildID, pos = pos, is_vip_pos = isVipPos}, true, 5))
    self.m_model:getNetData("bazaar_build", {build_id = buildID, pos = pos, is_vip_pos = isVipPos}, callback)
end

---快速建造请求
---@param buildID number 建筑配置ID
function M:requestBuildBazaarQuick(buildID)
    if self.m_model.m_costType == 1 then
        -- 快速建筑时，如果使用道具，需要二次确认
        local params =
        {
            on_ok_call = function(msg)
                local function callback(response)
                    self:updateMsg("bazaar_update_ui", response, "PengLaiBazzar.PengLaiBazzarMain")
                    self:notifyUpdateRedPoint()
                    self:closeView()
                end

                if self.m_view and self.m_model then
                    print("[REQ _ BUILD _ QUICK]" .. table.dump({build_id = buildID}, true, 5))
                    self.m_model:getNetData("bazaar_build_quick", {build_id = buildID}, callback)
                end
            end,
            text = string.format(Language:getTextByKey("pengLai_text_025"))
        }
        self:openView("Pops.CommonPop", params)
    else
        local function callback(response)
            self:updateMsg("bazaar_update_ui", response, "PengLaiBazzar.PengLaiBazzarMain")
            self:notifyUpdateRedPoint()
            self:closeView()
        end

        if self.m_view and self.m_model then
            print("[REQ _ BUILD _ QUICK]" .. table.dump({build_id = buildID}, true, 5))
            self.m_model:getNetData("bazaar_build_quick", {build_id = buildID}, callback)
        end
    end
end

---快速完成请求
---@param pos number 位置索引，序号从 0 开始
---@param isVipPos number 是否是 VIP 位置，0-否；1-是
function M:requestFinishQuick(pos, isVipPos)
    isVipPos = isVipPos and 1 or 0
    local curBuildingCfg = self.m_model.m_allBuildings[self.m_model.m_buildID]
    local finishCost = curBuildingCfg.finish_cost[1]
    local costPrice = finishCost[3]

    -- 检测摆摊结束
    if self:onBuildingSpeedUpCheck() then
        return
    end

    local bazaar_speed_up_tips = UserDataManager.local_data:getUserDataByKey("bazaar_speed_up_tips", 0)
    local save_time_tab = TimeUtil.gmTime(bazaar_speed_up_tips)
    local server_time = UserDataManager:getServerTime()
    local server_time_tab = TimeUtil.gmTime(server_time)

    -- 如果已经勾选不提示，则不需要二次确认
    if bazaar_speed_up_tips ~= 0 and save_time_tab.day == server_time_tab.day then
        local function callback(response)
            self:updateMsg("bazaar_update_ui", response, "PengLaiBazzar.PengLaiBazzarMain")
            self:notifyUpdateRedPoint()
            self:closeView()
        end

        if self.m_view and self.m_model then
            print("[REQ _ FINISH _ QUICK]" .. table.dump({pos = pos, is_vip_pos = isVipPos}, true, 5))
            self.m_model:getNetData("bazaar_finish_quick", {pos = pos, is_vip_pos = isVipPos}, callback)
        end
        return
    end
    
    -- 消耗钻石时，需要二次确认
    local params =
    {
        on_ok_call = function(params)
            local function callback(response)
                self:updateMsg("bazaar_update_ui", response, "PengLaiBazzar.PengLaiBazzarMain")
                self:notifyUpdateRedPoint()
                self:closeView()
            end

            -- 检测摆摊结束
            if self:onBuildingSpeedUpCheck() then
                static_rootControl:closeView("Pops.CommonPop")
                return
            end
            
            if self.m_view and self.m_model then
                print("[REQ _ FINISH _ QUICK]" .. table.dump({pos = pos, is_vip_pos = isVipPos}, true, 5))
                self.m_model:getNetData("bazaar_finish_quick", {pos = pos, is_vip_pos = isVipPos}, callback) 
            end

            if params.isToday then
                UserDataManager.local_data:setUserDataByKey("bazaar_speed_up_tips", UserDataManager:getServerTime())
            end
        end,
        text = string.format(Language:getTextByKey("pengLai_text_019"), costPrice),
        istoday = true,
        today_isyes = true,
    }
    self:openView("Pops.CommonPop", params)
end

function M:onBuildingSpeedUpCheck()
    local res = false
    local curBuildData = self.m_model:getBazaarDataByPos(self.m_model.m_curPos, self.m_model.m_isVipPos)
    if curBuildData then
        if curBuildData.finished == 1 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pengLai_text_024"), delay_close = 2 })
            self:closeView()
            res = true
        end
    end
    
    return res
end

function M:notifyUpdateRedPoint()
    self:updateMsg("refresh_entrances", nil, "PengLaiBazzar.PengLaiBazzarIsland")
    self:updateMsg("refresh_red_point", nil, "Main")
end

---=======================================================

---倒计时回调
function M:updateTime()
    if self.m_view and self.m_view.m_initShowStyle == 2 and self.m_model.m_leftTimeFunc then
        local timeStr = self.m_model.m_leftTimeFunc(self.m_model.m_curPos, self.m_model.m_isVipPos)
        -- 倒计时结束后，关闭弹窗
        if timeStr == Language:getTextByKey("activities_str_0007") then
            -- 此时如果有二次确认弹窗打开，也主动关闭一下
            static_rootControl:closeView("Pops.CommonPop")
            self:closeView()
        else
            self.m_view:refreshLeftTime(timeStr)    
        end
    end
end

---=======================================================

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
        self.m_timer_id = nil
    end
    M.super.destroy(self)
end

return M