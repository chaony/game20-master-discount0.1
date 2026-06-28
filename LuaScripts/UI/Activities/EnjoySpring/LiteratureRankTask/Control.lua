local M = class("LiteratureRankTaskControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
        self:updateMsg("refresh_literatureRedDot", nil, "Activities.EnjoySpring")
    elseif msg == "rank_tab" then
        audio:SendEvtUI("UI_Tab_N1")
        self.m_model:setRankTabIndex(data)
        self.m_view:refreshUI()
    elseif msg == "task_tab" then
        audio:SendEvtUI("UI_Tab_N3")
        self.m_model:setTaskTabIndex(data)
        self.m_view:refreshUI()
    elseif msg == "Invite_btn" then -- 邀请
        if self.m_model:getActStatus() == 1 then
            if self.m_model.m_task_tab == 1 then
                local task_cfg = self.m_model:getTask()
                if task_cfg then
                    local params = {}
                    params.create_time = self.m_model:getTaskCreateTime()
                    params.star = task_cfg.star
                    self:openView("Activities.EnjoySpring.LiteratureSharePop",params)
                end
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "remove_friend_btn" then -- 移除好友
        if self.m_model:getActStatus() == 1 then
            self:removeFriend()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "refresh_task_btn" or msg == "refresh_task_btn2" then -- 刷新任务
        if self.m_model:getActStatus() == 1 then
            self:refreshTask()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "remove_task_btn" then -- 移除任务
        if self.m_model:getActStatus() == 1 then
            self:removeTask()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "receive_warrior_reward" then -- 领取战令奖励
        self:requestReceiveWarriorReward(data)
    elseif msg == "receive_task_reward_btn" then -- 领取任务奖励
        self:requestReceiveSelfTaskReward()
    elseif msg == "receive_friend_task_reward_btn" then -- 领取好友任务奖励
        self:requestReceiveFriendTaskReward()
    elseif msg == "buy_btn" then -- 购买奖励
        if self.m_model:getActStatus() == 1 then
            local pay_status = self.m_model:getwrriorPayStatus()
            if pay_status == 0 then
                local war_order = self.m_model:getWarriorCfg()
                self:buyForSDK(war_order.charge_id)
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0048"), delay_close = 2})
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg== "other_head" then
        local friend_user = self.m_model.m_task_tab == 1 and  self.m_model.m_data.my_task.receive or self.m_model.m_data.friend_task.invite
        if friend_user and next(friend_user) then
            self:openView("Pops.PlayerInfo", {uid = friend_user.uid})
        end
    elseif msg == "show_rank_list_btn" then -- 查看排行榜
        local params = {}
        params.version = self.m_model.m_data.version
        if self.m_model.m_rank_tab == 1 then
            params.force = self.m_model.m_data.force
            self:openView("Activities.EnjoySpring.LiteratureRankListPop", params)
        else
            params.data = self.m_model.m_data.force_rank
            params.force = self.m_model.m_data.force
            self:openView("Activities.EnjoySpring.LiteratureGroupRankListPop", params)
        end
    elseif msg == "help_btn" then
        local content = Language:getTextByKey("tid#enjoy_spring_Des")
        local open_data = self.m_model:getActiveCfgByOpenId(self.m_model.open_id)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    elseif msg == "refres_index" then
        self:refreshIndexData()
    end
end

--  刷新
function M:refreshIndexData()
    local function netCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("enjoy_spring_wenqu_index", nil, netCallback)
end

function M:refreshTask()
    local received_count, max_count = self.m_model:getTaskReceivedCount()
    if received_count >= max_count then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("enjoySpring_str_0044"), delay_close = 2})
        return
    end
    
    local cost = self.m_model:getFreshTaskCost()
    local params = {
        text = Language:getTextByKey("enjoySpring_str_0025", cost[3]),
        cost = cost,
        tow_close_btn = true,
        on_ok_call = function ()
            self:requestFreshTask()
        end
    }
    self:openView("Pops.CommonPop", params, true)
end

function M:requestFreshTask()
    local function freshTaskCallback(response)
        --Logger.log(response,"requestFreshTask =====")
        self.m_model:updateData(response)
        self.m_view:refreshTask()
    end
    self.m_model:getNetData("enjoy_spring_refresh_task", nil, freshTaskCallback)
end

function M:removeTask()
    local params = {
        text = Language:getTextByKey("enjoySpring_str_0026"),
        tow_close_btn = true,
        on_ok_call = function ()
            self:requestRemoveTask()
        end
    }
    self:openView("Pops.CommonPop", params, true)
end

function M:requestRemoveTask()
    local function removeTaskCallback(response)
        if response then
            self.m_model:updateData({friend_task = {}})
            self.m_view:refreshTask()
        end
    end
    self.m_model:getNetData("enjoy_spring_abandon_task", nil, removeTaskCallback)
end

function M:removeFriend()
    local self_status, friend_status = self.m_model:getTaskStatus()
    if friend_status > 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("enjoySpring_str_0042"), delay_close = 2})
        return
    end
    
    local receive_task_time = self.m_model:getFriendReceiveTaskTime()
    if receive_task_time then
        local server_time = UserDataManager:getServerTime()
        local down_time = 3600 - (server_time - receive_task_time)
        if down_time > 0 then
            local time_format = GameUtil:formatTimeBySecond(down_time)
            local params = {
                text = Language:getTextByKey("enjoySpring_str_0043", time_format),
                tow_close_btn = true,
            }
            self:openView("Pops.CommonPop", params, true)
            return
        end
    end

    local params = {
        text = Language:getTextByKey("enjoySpring_str_0027"),
        tow_close_btn = true,
        on_ok_call = function ()
            self:requestRemoveFriend()
        end
    }
    self:openView("Pops.CommonPop", params, true)
end

function M:requestRemoveFriend()
    local function removeFriendCallback(response)
        --Logger.log(response,"requestRemoveFriend ====")
        if response then
            self.m_model:updateData(response)
            self.m_view:refreshTask()
        end
    end
    self.m_model:getNetData("enjoy_spring_cull_friend", nil, removeFriendCallback)
end

function M:requestReceiveSelfTaskReward()
    local function selfTaskRewardCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("enjoy_spring_my_task_reward", nil, selfTaskRewardCallback)
end

function M:requestReceiveFriendTaskReward()
    local function friendTaskCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("enjoy_spring_friend_task_reward", nil, friendTaskCallback)
end

function M:requestReceiveWarriorReward(data)
    local status = self.m_model:getWrriorRewardStatus(data)
    if status == 1then
        local function receiveWarriorCallback(response)
            --Logger.log(response,"receiveWarriorCallback =====")
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.m_data.war_order.cur_version
        params.reward_id = data
        self.m_model:getNetData("war_order_receive_common_reward", params, receiveWarriorCallback)
    end
end

function M:requestIndexData()
    local function indexCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("enjoy_spring_wenqu_index", nil, indexCallback)
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:requestIndexData()
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(2, function ()
        self.m_view:unlockTouch()
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
            self:requestIndexData()
        end
    end)
end

--使用代金券购买
function M:buyUseVoucher(data, callback)
    local function receivetCallback(response)
        if callback then
            callback()
        end
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[data]
    if cfg == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0129",data), delay_close = 2})
        return
    end
    local voucher_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
    if voucher_data.user_num < cfg.price then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0130",data), delay_close = 2})
        return
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

return M;
