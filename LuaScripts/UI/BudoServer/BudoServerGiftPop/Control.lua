local M = class("BudoServerGiftPopControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_is_Tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("refreshRedPoint" ,nil ,"BudoServer")
        self:closeView()
    elseif msg == "refreshData" then    
        self.m_view:refreshUI()
    elseif msg == "get_free_gift" then --领取免费奖励
        self:questFreeReward(data)
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0009"
        params.content = "tid#TowerActiveDes_03"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "gift_btn" then
        local flag, push_gifts = self.m_model:getGiftStatus()
        RedPointUtil:saveLocalRedPointFreshTime("tower_active_reward_once")
        self.m_view:refreshRedPoint()
        if flag then
            local gift_btn = self.m_view:findGameObject("gift_btn")
            self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts, open_type = "active", gift_btn = gift_btn, is_token = self.m_model.m_is_Tokens})
        end
    end
end


-- 领取主线奖励 quest_id: 任务id
function M:questFreeReward(data)
    local function netCallback(response)
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
                    self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts, open_type = "active", gift_btn = gift_btn, new_id = new_id, is_token = self.m_model.m_is_Tokens})
                end
            end
            RewardUtil:rewardTipsByData(response.reward, nil, popCallBack) --展示已领取奖励
            self.m_model:updateRewardData(response.free_gifts)
            self.m_view:refreshUI()
        end
    end
    local params = {reward_id = data.id}
    self.m_model:getNetData("tower_active_receive_free_reward", params, netCallback)
end

return M;
