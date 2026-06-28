local M = class("ActiveBossCoolRankPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        self:updateMsg("refresh_ui", nil, "Activities.ActiveBoss")
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "load_rank" then
        self:loadRank()
    elseif msg == "receive_warrior_reward" then -- 领取战令奖励
        self:requestReceiveWarriorReward(data)
    elseif msg == "receive_task_reward_btn" then -- 领取任务奖励
        self:requestReceiveSelfTaskReward(data)
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
    end
end

function M:getReward(data)
    local function callback(response)
--[[        if response.update then
            self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg(99999)
            return
        end]]
        self.m_model:InitTaskData(response)
  
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data.id
    params.version = self.m_model.version
    params.open_id = self.m_model.open_id
    self.m_model:getNetData("common_world_boss_recv_quest_reward", params, callback)
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        if index == 3 then
            if self.m_model.war_order_data then
                self.m_view:switchNode(index)
                return
            end
            local callback = function(response)
                self.m_model:InitWarriorData(response)
                self.m_view:switchNode(index)
            end
            local params = {}
            params.open_id = self.m_model.open_id
            params.vsn = self.m_model.m_version
            self.m_model:getNetData("war_order_common_war_order_index",params,callback)
        else
            self.m_view:switchNode(index)
        end
    end
end

function M:loadRank()
    local cur_num, total_num = self.m_model:getRankNums()
    if cur_num >= 100 or cur_num >= total_num then
        return
    end
    self.m_view:lockTouch()
    local function netCallback(response)
        --Logger.log(response,"loadRank ====")
        self.m_view:unlockTouch()
        self.m_model:updateRank(response)
        self.m_load_end = true
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("common_world_boss_select_combat_rank", {start = cur_num + 1, stop = cur_num + 20}, netCallback, true, true)
end

--领取占令奖励
function M:requestReceiveWarriorReward(data)
    local status = self.m_model:getWrriorRewardStatus(data)
    if status == 1then
        local function receiveWarriorCallback(response)
            --Logger.log(response,"receiveWarriorCallback =====")
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:InitWarriorData(response)
            self.m_view:refreshUI()
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.war_order_data.war_order.cur_version
        params.reward_id = data
        self.m_model:getNetData("war_order_receive_common_reward", params, receiveWarriorCallback)
    end
end

--领取任务奖励
function M:requestReceiveSelfTaskReward(data)
    local function callback(response)
        self.m_model:InitTaskData(response.daily_quests)
        RewardUtil:rewardTipsByData(response.reward)
        local callback1 = function(response_)
            self.m_model:InitWarriorData(response_)
            self.m_view:refreshUI()
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.m_version
        self.m_model:getNetData("war_order_common_war_order_index", params, callback1)
    end
    local params = {}
    params.quest_id = data.id
    params.vsn = self.m_model.m_version
    params.open_id = self.m_model.open_id
    self.m_model:getNetData("common_world_boss_recv_quest_reward", params, callback)
end

function M:requestIndexData()
    local function indexCallback(response)
        self.m_model:InitWarriorData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.vsn = self.m_model.m_version
    --params.reward = 
    self.m_model:getNetData("war_order_common_war_order_index", params, indexCallback)
end
--调用sdk充值
function M:buyForSDK(charge_id)
--[[    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:requestIndexData()
        end)
        return
    end]]
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


return M
