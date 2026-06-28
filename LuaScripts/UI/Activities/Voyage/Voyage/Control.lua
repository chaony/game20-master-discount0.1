local M = class("VoyageControl",LikeOO.OOControlBase)

function M:onEnter()
    SceneManager:changeScene(SceneManager.SceneID.VoyageScene)
    EventDispatcher:registerEvent("voyage_show_reward_event", {self,self.voyageShowReward})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    audio:SendEvtUI("UI_DaoShuaiMZ")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "gift_bag_btn" then
        local version = UserDataManager:getOpenActiveVersion(140)
        StatisticsUtil:doPointActive(153,version)
        self:openView("Activities.Voyage.VoyageGiftBag", {data = self.m_model.m_data})
    elseif msg == "reward_preview_btn" then
        local rewards = self.m_model:getGachaShipRewards()
        self:openView("Pops.RewardPreviewPop", {show_rewards = rewards})
    elseif msg == "explain_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = "tid#Gacha_ship_1", content = "tid#Gacha_ship_2" })
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 10})
    elseif msg == "challenge_btn" then
        local chase_count = self.m_model:getChaseCount()
        local canStartFlag = nil
        if SceneManager.curScene.guide then
            canStartFlag = SceneManager.curScene.guide:getCanStartFlag()
        end
        if self.m_model:isMaxTime() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
            return
        end
        if not canStartFlag or self.m_model.m_can_start == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0727", data.name), delay_close = 2})
        else
            local cost = self.m_model:getChaseCostByTimes(chase_count)
            if #cost > 0 then
                local data = RewardUtil:getProcessRewardData(cost[1])
                if data.user_num < data.data_num then
                    local flag = QuickOpenFuncUtil:hasCostsTips(cost)
                    if not flag then
                        local text = Language:getTextByKey("new_str_0098", data.name)
                        if data.item_cfg.gain and data.item_cfg.gain ~= "" then
                            text = text .. "\n" .. Language:getTextByKey(data.item_cfg.gain)
                        end
                        GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
                    end
                else
                    self:highGachaVoyageGetGacha(chase_count)
                    self.m_model.m_can_start = false
                end
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("config cost is null", data.name), delay_close = 2})
            end
        end
    elseif msg == "select_ten_btn" then
        self.m_model:changeChaseCount()
        self.m_view:updateSelectTenStatus()
    elseif msg == "box_reward_btn" then
        local rewards = self.m_model:getBoxRewards()
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.transform})
    elseif msg == "refresh_ui" then
        self:highGachaVoyageIndex()
    elseif msg == "cost_item_icon" then
        local chase_count = self.m_model:getChaseCount()
        local cost = self.m_model:getChaseCostByTimes(chase_count)
        if cost[1] then
            GameUtil:lookInfoTips(self, {click_transform = data.transform, data = cost[1], top = true})
        end
    elseif msg == "skip_anim_btn" then
        self.m_model:changeSkipAnimFlag()
        self.m_view:updateSkipAnimStatus()
    elseif msg == "update_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "box_click" then
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1, offset_y = -200})
    elseif msg == "box_reward" then
        self:highGachaVoyageRecvBox(data.data)
    end
end

--  宝箱奖励 box_id
function M:highGachaVoyageRecvBox(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
        if response.update == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
        end
    end
    local params = {box_id = data.id, version = self.m_model.m_data.voyage_etime}
    self.m_model:getNetData("high_gacha_voyage_recv_box", params, netCallback)
end

--  盗帅迷踪抽卡  pool_id: 8 gacha_type: 抽卡次数
function M:highGachaVoyageGetGacha(times)
    local function netCallback(response)
        if response then
            --SceneManager.curScene.guide:startGoto(times)
            if self.m_model.m_skip_anim_flag then
                EventDispatcher:dipatchEvent("voyage_show_reward_event")
            else
                self.m_view:lockTouch()
                SceneManager:getCurSceneView():play(times == 1 and "DaoShuaiMiZong_Timeline_1v1" or "DaoShuaiMiZong_Timeline_1V10", false)
                audio:SendEvtUI(times == 1 and "DaoShuaix1" or "DaoShuaix10")
                self:setOnceTimer(times == 1 and 4.16 or 8.15, function()
                    self.m_view:unlockTouch()
                    SceneManager:getCurSceneView():resetTimeLineCamera()
                    SceneManager:getCurSceneView():play("DaoShuaiMiZong_Timeline_idle", true)
                    --SceneManager:getCurSceneView():setCameraControllerTarget(true)
                    EventDispatcher:dipatchEvent("voyage_show_reward_event")
                end)
                --self:setOnceTimer(1.15, function()
                --    SceneManager:getCurSceneView():setCameraControllerTarget(false)
                --end)
            end
        else
            self.m_model.m_can_start = true
        end
    end
    local params = {pool_id = self.m_model.m_gacha_id, gacha_type = times or 1}
    self.m_model:getNetData("high_gacha_voyage_get_gacha", params, netCallback, nil, true)
end

--  刷新
function M:highGachaVoyageIndex()
    local function netCallback(response)
        self.m_view:refreshUI()
        self:updateMsg("update_data", self.m_model.m_data, "Activities.Voyage.VoyageGiftBag")
    end
    self.m_model:getNetData("high_gacha_voyage_index", {}, netCallback)
end

--显示奖励回调
function M:voyageShowReward( eventName, data )
    local reward_show = self.m_model.m_data.reward_show
    self.m_view:refreshUI()
    if reward_show and next(reward_show) then
        self.m_view:lockTouch()
        RewardUtil:rewardTipsByRewards(reward_show,function()
            local progress_reward = self.m_model.m_data.progress_reward
            if progress_reward and next(progress_reward) then
                self:setOnceTimer(0.1, function()
                    self.m_view:unlockTouch()
                    RewardUtil:rewardTipsByData(progress_reward)
                    self.m_model.m_can_start = true
                end)
            else
                self.m_view:unlockTouch()
                self.m_model.m_can_start = true
            end
        end)
        self.m_model.m_data.reward_show = nil
    else
        self.m_model.m_can_start = true
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" then
        self.m_model:changeChaseCount(true)
        self.m_view:refreshUI()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("voyage_show_reward_event", {self,self.voyageShowReward})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
