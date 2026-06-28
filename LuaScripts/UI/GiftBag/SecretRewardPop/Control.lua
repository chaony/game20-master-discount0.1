local M = class("SecretRewardPopControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_XLQB")
    self:updateTime()
    self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        self:updateMsg("common_refresh", nil, "parent") 
		self:closeView()
    elseif msg == "get_ace_pag_btn" then -- 获取更多
        local end_ts = self.m_model:getEndTs()
        if end_ts > 0 then
            local params = {
                version = self.m_model.m_data.version,
                quests= self.m_model.m_data.quests,
                buy_times = self.m_model.m_data.buy_times,
            }
            self:openView("GiftBag.SecretRewardTaskPop", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:updateMsg(99999)
        end
    elseif msg == "yulan_btn" then -- 大奖预览
        local rewards = self.m_model:getBigRewardsShowData()
        self:openView("Pops.RewardPreviewPop", {show_rewards = rewards, openType = 1})
    elseif msg == "next_layer" then
        self:getNetUrl(data)
    elseif msg == "reward_btn" then -- 礼包
        local end_ts = self.m_model:getEndTs()
        if end_ts > 0 then
            self:openView("GiftBag.SecretRewardGiftPop")
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:updateMsg(99999)
        end
    elseif msg == "exchange_btn" then -- 兑换
        self:openView("GiftBag", {mode = 1, open_id = 251})
    elseif msg == "help_btn" then -- 帮助q
        local params = {}
        params.title = self.m_model:getPanelName()
        params.content = self.m_model:getScrollCfg().des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "box_click" then --查看奖励
        local reawrd_index = data.data
        local is_look = data.is_look
        local rewards = self.m_model:getProgressRewardData()
        if rewards[reawrd_index] then
            local itemData = rewards[reawrd_index].reward
            local show_check_mark =  true
            if is_look then
                show_check_mark = false
            end
            self:openView("Pops.LookRewardTips",{rewards = itemData, click_transform = data.click_transform, show_check_mark = show_check_mark})
        end
    elseif msg == "box_reward" then --领奖
        local function callback(response)
            if response and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model.got_milepost_reward = response.got_milepost_reward or {}
            self.m_view:refreshBoxStatus()
        end
        self.m_model:getNetData("secret_get_milepost_reward", { layer = data.layer, vsn = self.m_model.m_version}, callback)
    elseif msg == "btn_one" then --抽一次 
        self:goForward(1)
    elseif msg == "btn_five" then --抽五次
        self:goForward(5)
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "updateScrollData" then
        self.m_model.m_data.quests = data.quests
    end
end
-- 抽奖
function M:goForward(num)
    local count = self.m_model:getUserItemCount()
    if count < num then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    if self.m_model:checkMaxFloor() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("secret_reward_pop_text010"), delay_close = 2})
        return
    end
    local end_ts = self.m_model:getEndTs()
    if end_ts <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        self:updateMsg(99999)
    end
    local function callback(response)
        if response and response.reward then
            self.m_view:lockTouch()
            self.m_view:refreshAllRedPoint()
            self.m_model.last_position = response.pos +1
            self.m_view:gacha(response.reward)
            local time = response.step * 0.9
            self:setOnceTimer(time, function ()
                self.m_view:unlockTouch()
            end)
        end
    end
    self.m_model:getNetData("secret_go_forward", {times = num, vsn = self.m_model.m_version}, callback)
end

function M:getNetUrl(data)
    local function callback(response)
        self.m_model:updateData(response)
        if data.callBack then
            data.callBack()
        end
    end
    self.m_model:getNetData("secret_index", nil, callback)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;