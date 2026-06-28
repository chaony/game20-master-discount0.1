local M = class("JewelGachaControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_can_show_new = true
    --self.m_show_new = false
end

function M:onHandle(msg , data)
    if msg == 99999 then
        --[[local jewels = UserDataManager.jewel_data:getJewels()
        if next(jewels) then
            self:openView("Jewel")
            local function delay_call()
                self:closeView()
            end
            self:setOnceTimer(0.5, delay_call)
        else
            self:closeView()
        end]]--
        self:closeView()
    elseif msg == "help_btn" then
        local params = {title = "predestined_str_004", content = "tid#Jewel_4"}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "book_btn" then
        self:openView("Jewel", {is_book = true})
    elseif msg == "main_btn" then
        self:openView("Jewel")
        local function delay_call()
            self:closeView()
        end
        self:setOnceTimer(0.5, delay_call)
    elseif msg == "wish_btn" then
        local times = data.times
        if times == nil then
            self:openView("Jewel.JewelGachaWishPop", {wishes = self.m_model.m_wishes})
            return
        end
        local is_can_getWish = self.m_model:isCanGetWish(times)
        if is_can_getWish == true then
            self:requestGetWish(times)--领取秘宝
            return
        end
        self:openView("Jewel.JewelGachaWishPop", {wish_times = times, wishes = self.m_model.m_wishes})
    elseif msg == "one_btn" then
        if self.m_model.m_is_can_gacha == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("jewel_text_026"), delay_close = 2})
            return
        end
        self:startGacha(1)
    elseif msg == "ten_btn" then
        if self.m_model.m_is_can_gacha10 == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("jewel_text_026"), delay_close = 2})
            return
        end
        self:startGacha(10)
    elseif msg == "update_wish" then
        local times = data.times
        local jewel_id = data.id
        local state = data.state
        self.m_model:updateWish(times, jewel_id, state)
        self.m_view:refreshWishJewels()
    elseif msg == "show_reward" then
        if next(self.m_model.m_show_reward) then
            RewardUtil:rewardTipsByRewards(self.m_model.m_show_reward, nil,{fly = false, fly_target = "bag_btn", target_control = self, tips_up = "jewel_text_018"})
            self.m_model.m_show_reward = {}
        end
    --[[elseif msg == "show_new" then
        if self.m_can_show_new and self.m_show_new then
            local card_id = self.m_model:getOpenNewCard()
            if card_id then
                self.m_can_show_new = false
                self:openView("Jewel.JewelNewPop", {id = card_id})
            else
                self.m_show_new = false
                self:openView("Jewel.JewelGachaResultPop", {reward = self.m_model.m_reward})
            end
        end
    elseif msg == "close_new" then
        self.m_can_show_new = true
        self:updateMsg("show_new")]]--
    end
end

function M:startGacha(times)
    local gacha_times = times
    self.m_view:lockTouch()
    self.m_view:playGacha()
    self:setOnceTimer(2.4, function()
        self.m_view:unlockTouch()
        self.m_view:closeGacha()
        self:requestGacha(gacha_times)
    end)
end

function M:requestGacha(times)
    local function callback(response)
        self.m_model:updateGacha(response)
        self.m_view:refreshTimes()
        self.m_view:refreshBtn()
        --先播放新宝物
        --self.m_show_new = true
        --self.m_can_show_new = true
        --self:updateMsg("show_new")
        --self:closeView("Jewel.JewelGachaResultPop")
        self:openView("Jewel.JewelGachaResultPop", {reward = response.reward})
    end
    local params = {num = times}
    self.m_model:getNetData("jewel_do_gacha", params, callback)
end

function M:requestGetWish(times)
    local function callback(response)
        UserDataManager.jewel_data:updateEffects(response.effects) --秘宝效果
        self.m_model:updateWish(response.num, nil, 1)
        self.m_view:refreshWishJewels()
        local jewel_id = response.jewel
        if response.item == nil then
            UserDataManager.jewel_data:updateActive(jewel_id)
            self:openView("Jewel.JewelNewPop", {id = jewel_id})
        else
            local function call_back()
                local reward = {}
                for k, v in pairs(response.item) do
                    reward[#reward + 1] = {103, tonumber(k), v}
                end
                RewardUtil:rewardTipsByRewards(reward,nil,{fly = false, fly_target = "bag_btn", target_control = self, tips_up = "jewel_text_018"})
            end
            local is_show_active = UserDataManager.jewel_data:checkActiveUI(jewel_id)
            if is_show_active == true then
                self:openView("Jewel.JewelNewPop", {id = jewel_id, callback = call_back})
            else
                call_back()
            end
        end
    end
    local params = {num = times}
    self.m_model:getNetData("jewel_do_wish", params, callback)
end

return M