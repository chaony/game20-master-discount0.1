local M = class("LimitedTimeLoginView", LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Summer/LimitedTimeLogin"

function M:onEnter()
    self:setTextByLanKey("activeOver_text", "new_str_0786")
    self:setTextByLanKey("tips_text_zi", "new_str_0808") --开启侠客选择箱即可获得以上任一侠客
    self:setTextByLanKey("heroNmae_text_1", "tid#HeroName_402")
    --五毒教
    
    self.dayBasePos = {}
    for i = 1, 7 do

        local day_btn = self:findButton("Day_" .. i)
        --设置状态
        local btnTrans = day_btn.transform:GetComponent("RectTransform")
        local pos = btnTrans.anchoredPosition
        self.dayBasePos[i] = pos.y
    end
    self:setTextByLanKey("close_tips_text", "new_str_0905")
    self:refreshUI()
end

--刷新
function M:refreshUI()
    self.active_time = self.m_model.m_active_time.end_ts - self.m_model.m_active_time.start_ts
    self.remain_ts = self.m_model.m_active_time.remain_ts
    local active_day = GameUtil:getTimeLayoutBySecond(self.active_time)
    local remain_day, hour = GameUtil:getTimeLayoutBySecond(self.remain_ts)
    local time_text = Language:getTextByKey("new_str_0787", remain_day, hour)
    self:setTextByLanKey("time_text", time_text)
    self.day = active_day - remain_day --活动进行时间

    local login_data, big_reward_data = self.m_model:getDayData()
    for i = 1, 7 do
        local day = self:findGameObject("Day_" .. i)
        self:setObjectVisible("Day_" .. i, true)
        --设置日期
        self:setTextByLanKey("day_" .. i .. "_text", login_data[i].name)
        --设置奖励
        local reward = login_data[i].reward or {}
        local reward_node = UIUtil.findRectTransform(day.transform, "Img_reward_" .. i)
        GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
    end

    self:updateDayReward()
end

--设置奖励
function M:updateDayReward()
    local big_reward_btn = self:findButton("btn_bigGiftBag_bg")
    local login_data, big_reward_data = self.m_model:getDayData()
    local itemData = RewardUtil:getProcessRewardData(big_reward_data[1].reward[1])
    self.rewardCfg = itemData
    UIUtil.setImg(big_reward_btn.transform, itemData.icon_name, itemData.atlas_name, "TreasureChest_Img") --设置元宝图标
    self:setTextByLanKey("TreasureChest_Num", itemData.data_num)
    --登录奖励设置
    for i = 1, 7 do
  
        local day_btn = self:findButton("Day_" .. i)
        --设置状态
        local btnTrans = day_btn.transform:GetComponent("RectTransform")
        local pos = btnTrans.anchoredPosition 
        local basePos =self.dayBasePos[i]
        if (self.day + 1 )>= i then --可以领取
            if self.m_model:hasDay(i) then --已领取
                self:setObjectVisible("Img_reward_light_" .. i, false)
                self:setObjectVisible("Img_received_" .. i, true)
                day_btn.interactable = false
                pos.y = basePos
            else --待领取
                self:setObjectVisible("Img_reward_light_" .. i, true)
                self:setObjectVisible("Img_received_" .. i, false)
                day_btn.interactable = true
                pos.y = basePos+30
            end
        else --不能领取
            self:setObjectVisible("Img_reward_light_" .. i, false)
            self:setObjectVisible("Img_received_" .. i, false)
            day_btn.interactable = false
            pos.y = basePos
        end
        btnTrans.anchoredPosition = pos
    end

    self:setObjectVisible("img_bigRecive", false)

    --大奖设置
    if self.day >= 6 then --可以领取

        if self.m_model:hasDay(0) then --已领取
            self:setTextByLanKey("txt_bigGift", "summer_text_received")--已领取
            -- self:findGameObject
            big_reward_btn.interactable = false
            self:setObjectVisible("img_bigRecive", true)
            local itemIcon = self:findGameObject("TreasureChest_Img").transform:GetComponent("Image")
            itemIcon.color = Color.New(0.5, 0.5, 0.5, 1)
        else -- 带领取
            self:setTextByLanKey("txt_bigGift", "summer_text_readyReceive")--可领取
            self.rewardStatus = self:getRewardStatus()
            big_reward_btn.interactable = true
        end
    else --不能领取
        self:setTextByLanKey("txt_bigGift","summer_text_afterDayCountReceive", 6 - self.day)
        big_reward_btn.interactable = false
    end
end

--设置大奖是否可领
function M:getRewardStatus()
    for i = 1, 7 do
        if not self.m_model:hasDay(i) then
            return false
        end
    end
    return true
end

--刷新时间
function M:updateTime()
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    local remain_tim = self.m_model.m_active_time.end_ts - cur_tim --剩余时间
    local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
    local time_text = 1
    if remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 then --小于一分钟
        time_text = Language:getTextByKey("new_str_0844", remain_sec)
    elseif remain_day <= 0 and remain_hour <= 0 then --小于一小时
        time_text = Language:getTextByKey("new_str_0843", remain_min)
    elseif remain_day <= 0 then --小于一天
        time_text = Language:getTextByKey("new_str_0788", remain_hour)
    else
        -- time_text = Language:getTextByKey("new_str_0787", remain_day, remain_hour)
        time_text = Language:getTextByKey("activities_str_0004", remain_day)
    end
    self:setTextByLanKey("time_text", time_text) --重置剩余时间
end

function M:destroy()
    M.super.destroy(self)
end

return M
