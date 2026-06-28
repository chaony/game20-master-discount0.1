local M = class("UnionMainPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:managementBtnHandle(false)
    audio:SendEvtUI("Amb_2D_indoor_fire")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "log_btn" then
        self:openView("Union.UnionLogPop")
    -- elseif msg == "applyes_btn" then
    --     self:openView("Union.UnionApplyPop")
    -- elseif msg == "out_btn" then
    --     self:outRequest()
    -- elseif msg == "kick_btn" then
    --      self:kickRequest(data)
    elseif msg == "no_open_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
    elseif msg == "cell_btn" then
        self:openView("Pops.PlayerInfo", {uid = data.uid, guild = self.m_model.m_data, look_model = 3})
    elseif msg == "management_btn" then
        self:managementBtnHandle(not self.m_management_btn_show)
    elseif msg == "management_close_btn" or msg == "management_close_btn2" then
        self:clearRedPoint()
        self:managementBtnHandle(false) 
    elseif msg == "impeach_btn" then --弹劾
        local function callFunc(response, tag, status_code)
            if response then
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("union_str_0060"), delay_close = 2})
                self.m_model.m_data.can_impeach = 0
                self.m_model:updateData(response)
                self.m_view:refreshUI()
            end 
        end
        self.m_model:getNetData("guild_impeach_president", nil, callFunc)
    elseif msg == "upgrade_union_btn" then -- 公会升级
        self:managementBtnHandle(false)
        local guild = ConfigManager:getCfgByName("guild")
        if guild[self.m_model.m_data.guild.level + 1] then
            self:openView("Union.UnionUpgradePop", self.m_model.m_data)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0041"), delay_close = 2})
        end
    elseif msg == "applyes_btn" then  -- 入会申请
        self:managementBtnHandle(false)
        self:openView("Union.UnionApplyPop", {member = #self.m_model.m_list_data})
    elseif msg == "notice_set_btn" then -- 修改公告
        self:managementBtnHandle(false)
        self:openView("Union.UnionNoticePop", {guild = self.m_model.m_data.guild})
    elseif msg == "info_set_btn" then -- 信息设置
        self:managementBtnHandle(false)
        self:openView("Union.UnionOptionPop", {guild = self.m_model.m_data.guild})
    elseif msg == "mail_btn" then -- 全员邮件
        if self.m_model:checkCanSendMail() == true then
            self:managementBtnHandle(false)
            self:openView("Union.UnionMailPop")
        else
            local tim = self.m_model:getMailDownTime()
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("union_str_0058",tim), delay_close = 2})
        end
    elseif msg == "find_union_btn" then -- 查找帮会
        self:managementBtnHandle(false)
        self:openView("Union.UnionFindPop")
    elseif msg == "shop_btn" then -- 公会商店
        self:openView("Shop", {shop_type = 2, pop_from_func_id = -1})
    elseif msg == "shenlu_btn" then -- 神炉
        self:openView("Union.UnionArtifactPop", {data = self.m_model.m_data})
    elseif msg == "give_btn" then -- 捐献
        --local max_times = ConfigManager:getVipValueByKey("contribution_times", 1)
        --local contribution_times = self.m_model.m_data.contribution_times or 0
        --if max_times <= contribution_times then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0017"), delay_close = 2})
        --    return
        --end
        --self:openView("Union.UnionContributionPop", {times = self.m_model.m_data.contribution_times})
        local guild_sign = self.m_model.m_data.guild_sign or 0
        if guild_sign == 0 then
            self:signRequest()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0017"), delay_close = 2})
        end
    elseif msg == "notice_btn" then -- 公会公告
        self:openView("Union.UnionNoticePop", {guild = self.m_model.m_data.guild})
    elseif msg == "member_btn" then -- 公会成员
        self:openView("Union.UnionMemberPop", {data = self.m_model.m_data})
    elseif msg == "exit_union_btn" then -- 退出公会
        self:managementBtnHandle(false)
        --if self.m_model:getIsManager() == self.m_model.m_manage_enum_tab.others then
        --    self:outRequest()
        --else
        --end
        local pos = self.m_model:getIsManager()
        local tips_id = pos == self.m_model.m_manage_enum_tab.others and "union_str_0067" or "tid#Guild_" .. pos
        local params =
        {
            on_ok_call = function(msg)
                self:outRequest()
            end,
            no_close_btn = false,
            tow_close_btn = true,
            ok_text = Language:getTextByKey("new_str_0315"),
            text = Language:getTextByKey(tips_id)
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        self.m_view:refreshUI()
    elseif msg == "unionwar_btn" then -- 帮会战
        local flag, tips = BtnOpenUtil:isBtnOpen(156)
        if flag then
            self:requestUnionWar()
        else
            GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
        end
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()    
    elseif msg == "refreshNetData" then
        local function callback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("guild_index", nil, callback)
    end  
end

function M:clearRedPoint()
    if RedPointUtil:hasRedPointById(168) then
        local function clearRedCall()
            UserDataManager:removeRedDotByKey("guild_impeach")
            self.m_view:refreshRedPoint()
        end
        self.m_model:getNetData("red_dot_clear", {red_dot_type = {"guild_impeach"}}, clearRedCall)
    end
end

function M:outRequest()
    local function outCallback(response)
        UserDataManager.guild_lv = 0
        UserDataManager.guild_lv = 0
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView("Union.UnionHall")
        self:closeView()
    end
    self.m_model:getNetData("guild_leave_guild", nil, outCallback)
end

function M:kickRequest(data)
    local function kickRequest(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.member = data.uid
    self.m_model:getNetData("guild_kick_member", params, kickRequest)
end

function M:signRequest()
    local function signRequestcall(response)
        RewardUtil:rewardTipsByData(response.reward)
        UserDataManager:removeRedDotByKey("guild_sign")
        self.m_model:updateData({guild_sign = response.guild_sign, guild = response.guild})
        self.m_model:updateTripodOnceRedPoint()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("guild_sign", nil, signRequestcall)
end

function M:managementBtnHandle(isShow)
    self.m_management_btn_show = isShow
    self.m_view:managementBtnHandle(self.m_management_btn_show)
end

function M:requestUnionWar()
    self:openView("UnionWar", { union_data = self.m_model.m_data} )
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
