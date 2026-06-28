---@class RewardControl:OOControlBase
---@field m_model RewardModel
local M = class("RewardControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self:setTimer(1,handler(self,self.UpdateTime))
    self.m_guide_file_name = "UI.Reward.Guide"
    EventDispatcher:registerEvent("subscribe_buy_event", {self, self.eventHandle})
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(32, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:eventHandle(msg, data)
    if msg == "subscribe_buy_event" then
        self.m_view:refreshUI()
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point" ,nil ,"parent")
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 16})
    elseif msg == "offer_lv" then --等级
        self:openView("Reward.RewardLv", {lv = self.m_model.bounty_lv, single_rank = self.m_model.single_rank , team_rank = self.m_model.team_rank})
    elseif msg == "tiwn_tog" then --单人悬赏
        self.m_model.cur_type = 1
        self.m_view:seleteTag(1)
    elseif msg == "team_tog" then --团队悬赏
        self.m_model.cur_type = 2
        self.m_view:seleteTag(2)
    elseif msg == "reset_btn" then--刷新
        self:refreshTask()
    elseif msg == "open_send" then --派遣
        local params = { --师徒
            id = data.id, 
            reward = data.reward,
            cell_data = data.cell_data,
            self_hero = self.m_model.self_hero,
            lifetime = data.lifetime,
            master_hero = self.m_model.m_master_info.hero_info or {},
            uid = self.m_model.m_master_info.uid,
            evo_condition = data.cell_data.data.evo_condition,
            index = data.index
        }
        self.m_view.opensend_btn:SetActive(false)
        self:openView("Reward.RewardSend", params)
    elseif msg == "resresh" then 
        self.m_model:setTaskList(data)
        self:refreshData(data)
    elseif msg == "resreshAll" then 
        self.m_model:setTaskAllList(data)
        self.m_view:refreshTask()
    elseif msg =="special_btn" then
        self:openView("Reward.RewardSpecial", self.m_model.m_data)
        --self:updateMsg("update_selfHero", {data_hero = self.m_model.self_hero },"WorldMap.WorldMapRewardNew.WorldMapRewardSend")
    elseif msg == "last_btn" then--点击lastbtn
        self.m_view:setLoopScrollOffset(false)
    elseif msg == "next_btn" then--点击nextbtn
        self.m_view:setLoopScrollOffset(true)
    elseif msg == "get_reward" then --领取
        self:getReward(data)
    elseif msg == "chakan_btn" then --打开日志
       self:openView("Reward.RewardPop", data)
    elseif msg == "aid_btn" then --我的外援
        self:openView("Reward.RewardHelp")
    elseif msg == "one_key_dispath_btn" then --一键派遣
        local cur_single_data = {}
        for k,v in pairs(self.m_model.single_data) do
            if v.data.quest_status == 0 then
                table.insert(cur_single_data,v)
            end
        end
        local params = {
            self_hero = self.m_model.self_hero,
            master_hero = self.m_model.m_master_info.hero_info or {},
            single_data = cur_single_data,
            uid = self.m_model.m_master_info.uid
        }
        self:openView("Reward.RewardHeroDispatch",params)
    elseif msg == "one_keyreward_btn" then --一键领取
        self:gotAwardBtnEvent()
    elseif msg == "check_guide" then
        self.m_guide:checkGuide()
    elseif msg == "order_img" then
        local itemData = {RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_model.common[324].value[2], 0}
        GameUtil:lookInfoTips(self.m_control, {click_transform = self.m_view.order_img.transform, data = itemData})
    elseif msg == "refresh_img" then
        local itemData = {RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_model.common[323].value[2], 0}
        GameUtil:lookInfoTips(self.m_control, {click_transform = self.m_view.refresh_img.transform, data = itemData})
    elseif msg == "diamond_img" then
        local itemData = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0}
        GameUtil:lookInfoTips(self.m_control, {click_transform = self.m_view.diamond_img.transform, data = itemData})
    elseif msg == "speed_send" then --加速完成
        self:speed_Reward(data)
    elseif msg == "intelligence_btn" then
        --self:openView("Reward.RewardIntelligence")
        local params = {top = true}
        params.click_transform = self.m_view:findGameObject("intelligence_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[1].name
        params.msg = cfg[1].des
        if UserDataManager:hasRewardSubscribe() then
            params.status_text = "bounty_str_0019"
        else
            params.btn_text = "new_str_0801"
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
            end
        end
        GameUtil:lookInfoTips(self.m_control, params)
    end
end

function M:gotAwardBtnEvent()
    local isCanGot = self.m_model:isCanGotTask()
    if isCanGot then
        self:auto_receive()
    else
        local isDispatchCondition = self.m_model:isSatisfyDispatchCondition()
        if isDispatchCondition then
            -- 一键派遣 
            self:autoDispatch()
        end
    end
end

function M:autoDispatch()
    local isPopWindow = RedPointUtil:localRedPointJudge("autoDispatchPop_everyRedDot")
    if isPopWindow then
        -- 弹出二级确认框
        self:openView("Reward.AutoDispatchPop", {callBack = function()
            self:clickDispatchEvent()
        end})
    else
        -- 不弹窗，直接激活格子
        self:clickDispatchEvent()
    end
end

function M:clickDispatchEvent()
    local allTaskData = self.m_model:getTaskList()
    local targetTaskLevel = ConfigManager:getCommonValueById(695) or 0
    local canOverTaskData = {}
    for _, itemData in pairs(allTaskData) do
        if itemData.cfg.rank >= targetTaskLevel and itemData.data.quest_status == 0 then
            table.insert(canOverTaskData, itemData)
        end
    end
    local canOverTaskCount = table.nums(canOverTaskData)
    if canOverTaskCount > 0 then
        local rewardConfigData = ConfigManager:getCommonValueById(324) or 0
        local itemData = RewardUtil:getProcessRewardData(rewardConfigData)
        local allNeedCount = itemData.data_num * canOverTaskCount
        if itemData.user_num >= allNeedCount then
            local function callback(response)
                self.m_model:refreshinitData(response)
                self:refreshData()
            end
            self.m_model:getNetData("auto_do_quest", {}, callback)            
        else
            -- 悬赏令够不够
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("offerAward_str_0005"), delay_close = 2})
        end
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("offerAward_str_0004"), delay_close = 2})
    end
end

function M:speed_Reward(data)
    local params =
    {  
        on_ok_call = function(msg)
            local function callback(response)
                response.isSort = false
                self.m_model:setTaskList(response,data)
                self:refreshData()
                self:getReward(data.cell_data.id)
            end
            local quest_main = ConfigManager:getCfgByName("bounty_quest")
            local cfg = quest_main[data.cell_data.id]
            local cfg_type =cfg.type
            self.m_model:getNetData("quick_finish", {quest_id = data.cell_data.id, quest_type = cfg_type,}, callback)
        end,   
        text = Language:getTextByKey("new_str_0706"),
        cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0, self.m_model.common[335].value[1][1]},
        consume = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0, self.m_model.common[335].value[1][3]},
    }
    self:openView("Pops.CommonPop",params,nil,true)
end

function M:UpdateTime()
    self.m_model.dataTime = self.m_model.dataTime - 1
    self.m_view:setResetTim()
end

--一键领取
function M:auto_receive()
    if self.m_model:checkCanGetReward() == false then
        return
    end
    local function callback(response)
        if self.m_view then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model:refreshinitData(response)
        self:refreshData()
    end
    self.m_model:getNetData("bounty_auto_receive", nil, callback)
end

function M:refreshTask()
    if self.m_model:isMaxTime() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
        return
    end
    local common = ConfigManager:getCfgByName("common")
    self.m_model.callback_tasts = UserDataManager.local_data:getUserDataByKey("reward_callback_tasts", nil)
    if self.m_model.callback_tasts ~= nil then
        local server_ts = UserDataManager:getServerTime()
        local day = GameUtil:NumberOfDaysInterval(self.m_model.callback_tasts,server_ts)
        if day >= 1 then
            self.m_model.toDay_HasHighLevelTasks = true
        else
            self.m_model.toDay_HasHighLevelTasks = false
        end
    end
    if self.m_model.free_refresh < common[326].value then
        self:beRefreshTask()
    else
        if self.m_model.toDay_HasHighLevelTasks or self.m_view.maxRank > 3 then
            local item_data = UserDataManager.item_data:getItemDataById(common[323].value[2])
            if self.m_view.isCommon ~= nil and self.m_view.isCommon then
                local params =
                {
                    isreward = true,
                    istoday = true,
                    today_isyes = true,
                    on_ok_call = function(msg)
                        if msg.cur_server_ts ~= nil then
                            self.m_model.callback_tasts = msg.cur_server_ts
                            UserDataManager.local_data:setUserDataByKey("reward_callback_tasts", self.m_model.callback_tasts or nil)
                        end
                        if msg.reward_isOk ~= nil then
                            if msg.reward_isOk then
                                if item_data.num > 0 then
                                    self:beRefreshTask()
                                else
                                    self:refreshCallback()
                                end
                            end
                        end
                    end,
                    reward_text = Language:getTextByKey("new_str_0702"),
                    today_text = Language:getTextByKey("new_str_0911")
                }
                self:openView("Pops.CommonPop",params,nil,true)
            else
                self:refreshCallback()
            end
        else
            self:refreshCallback()
        end
    end
end

function M:refreshCallback()
    local renovate_tab = ConfigManager:getCfgByName("renovate")
    self.m_model.callback_time = UserDataManager.local_data:getUserDataByKey("reward_callbackTime", nil)
    if self.m_model.callback_time ~= nil then
        local server_ts = UserDataManager:getServerTime() 
        local day = GameUtil:NumberOfDaysInterval(self.m_model.callback_time,server_ts)
        if day >= 1 then
            self.m_model.toDay_active = true
        else
            self.m_model.toDay_active = false
        end
    end
    local num = self.m_model.pay_refresh
    if num > 20 then
        num = 20
    end
    if self.m_model.toDay_active then
        local item_data,item_cfg = UserDataManager.item_data:getItemDataById(self.m_model.common[323].value[2])
        if item_data.num <= 0 then
            local count = 50
            local params =
            {  
                no_close_btn = false,
                istoday = true,
                on_ok_call = function(msg)
                    if msg.cur_server_ts ~= nil then
                        self.m_model.callback_time = msg.cur_server_ts
                        UserDataManager.local_data:setUserDataByKey("reward_callbackTime", self.m_model.callback_time or nil)
                    end
                    self:beRefreshTask()
                end,   
                text = Language:getTextByKey("new_str_0214"),
                cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0, renovate_tab[13].cost[num][2]},
                consume = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,renovate_tab[13].cost[num][3] },
            }
            self:openView("Pops.CommonPop",params,nil,true)
        else
            self:beRefreshTask()
        end
    else
        local item_data,item_cfg = UserDataManager.item_data:getItemDataById(self.m_model.common[323].value[2])
        if item_data.num > 0 then
            self:beRefreshTask()
        else
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0, renovate_tab[13].cost[num][3]})
            if data.user_num < data.data_num then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
                return
            end
            self:beRefreshTask()
        end
    end
end

function M:beRefreshTask()
    local function callback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
        self.m_model.task_temp_list = {}
        self.m_model:initData(response, true)
        self.m_view:refreshTask()
        self.m_view:refreshLoopScroll()
    end
    self.m_model:getNetData("bounty_refresh_quest", nil, callback)
end


function M:getReward(id)
    local function callback(response)

        if self.m_view then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model:refreshinitData(response)
        -- self.m_view:updateUI(id)
        self:refreshData()
    end

    local id = id
    local cfg = self.m_model:getBountyBuId(id)
    local type =cfg.type
    self.m_model:getNetData("bounty_receive",{quest_id = id, quest_type = type,}, callback)  
end



function M:refreshData(data)
    self.m_view:refreshTask(data)
end


function M:destroy()
    EventDispatcher:unRegisterEvent("subscribe_buy_event", {self, self.eventHandle})
    M.super.destroy(self)
end




return M
