local M = class("WdTowerGiftPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_is_Tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("refreshRedPoint" ,nil ,"WdTower")
        self:closeView()
    elseif msg == "refreshData" then    
        self.m_view:refreshUI()
    elseif msg == "get_free_gift" then --领取免费奖励
        self:questFreeReward(data)
    elseif msg == "gift_btn" then
        local flag, push_gifts = self.m_model:getGiftStatus()
        local gift_btn = self.m_view:findGameObject("gift_btn")
        RedPointUtil:saveLocalRedPointFreshTime("wd_tower_reward_once")
        UserDataManager:removeRedDotByKey("month_card_alert")
        self.m_view:refreshRedPoint()
        if flag then
            self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts, open_type = "active", gift_btn = gift_btn, is_token = self.m_model.m_is_Tokens })
        end
    elseif msg == "help_btn" then
        local params = {}
        local content_id = self.m_model:getDesByKey("detail2") or "tid#TowerActiveDes_03"
        local title_id = self.m_model:getDesByKey("reward_title") or "tid#TowerActiveDes_03"
        params.title = title_id
        params.content = content_id
        self:openView("Pops.CommonHelpPop", params)
    end
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

-- 领取主线奖励 quest_id: 任务id
function M:questFreeReward(data)
    local function netCallback(response)
        if response.update == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
            return
        end
        if self.m_view then
            local function popCallBack()
                local have_effect, push_gifts = self.m_model:getGiftStatus()
                local is_new = false
                local new_id = nil
                for i, v in pairs(push_gifts) do
                    local limit_id = i
                    local end_ts = v
                    if self.m_model:checkFirstPop(limit_id, end_ts) then
                        is_new = true
                        new_id = limit_id
                        break
                    end
                end
                if have_effect and is_new then
                    local gift_btn = self.m_view:findGameObject("gift_btn")
                    self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts, open_type = "active", new_id = new_id, gift_btn = gift_btn, is_token = self.m_model.m_is_Tokens})
                end
            end
            self.m_model:updateRewardData(response.received)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward, nil, popCallBack) --展示已领取奖励
        end
    end
    local params = {gift_id = data.id, vsn = self.m_model.m_version}
    self.m_model:getNetData("wdtower_receive_free_gifts", params, netCallback)
end

return M;
