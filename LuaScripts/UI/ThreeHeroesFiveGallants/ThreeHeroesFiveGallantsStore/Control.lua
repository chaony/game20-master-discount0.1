local M = class("ThreeHeroesFiveGallantsStoreControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_model.Map2DControl:init(self)
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:updateMsg("refresh_data", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMain")
        self:closeView()
    elseif msg == "box_reward" then --领取奖励
        self:questRewardBox(data.data)
    elseif msg == "box_click" then  --点击奖励
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == 2})
    elseif msg == "btn_1" then
        self:openStore(1)
    elseif msg == "btn_2" then
        self:openStore(2)
    elseif msg == "btn_3" then
        self:openStore(3)
    elseif msg == "btn_4" then
        self:openStore(4)
    elseif msg == "btn_left" then --左按钮 + 
        self.m_model.current_tab  = self.m_model.current_tab + 1
        self.m_view:refreshUI()
    elseif msg == "btn_right" then --右按钮 -
        self.m_model.current_tab  = self.m_model.current_tab - 1
        self.m_view:refreshUI()
    end
end

--领取奖励
function M:questRewardBox(data)
    local function netCallback(response)
        if response then
            self.m_model:updateData(response.recv_chivalrous)
            self.m_view:refreshReward()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.vsn = self.m_model:getVersion()
    params.gift_id = data.id
    self.m_model:getNetData("chivalrous_recv_dust_of_dreams", params, netCallback)
end

--打开故事页面
function M:openStore(id)
    local store_id = (self.m_model.current_tab - 1) * 4 + id
    local store_data = self.m_model.m_store_data[store_id] or {}
    if store_data.open_condition then
        if store_data.open_condition == -1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("three_heroes_five_gallants_text_0028"), delay_close = 2})
            return 
        elseif store_data.open_condition > self.m_model.m_score then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("three_heroes_five_gallants_text_0030", store_data.open_condition), delay_close = 2})
            return 
        end
    end
    self.m_model.Map2DControl:openMap2D(store_data.map_id or 10001)
end

return M
