local M = class("LuckyDogShopView", LikeOO.OOPopBase)

M.m_uiName = "LuckyDog/LuckyDogShop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_fTime = 0
    
    --获取组件
    local reward_list = self:findGameObject("reward_list")
    self.arrow = self:findGameObject("arrow")
    local gacha_cfg = self.m_model:getGachaCfg()
    self.btn_one = self:findGameObject("btn_one")
    self.btn_ten = self:findGameObject("btn_ten")
    self:setTextByLanKey("refresh_text", "lucky_dog_008", gacha_cfg.refresh or 1)
    self:setTextByLanKey("once_text", "lucky_dog_009", gacha_cfg.gacha1 or 10)
    self:setTextByLanKey("ten_text", "lucky_dog_010", gacha_cfg.gacha10 or 100)
    self:setTextByLanKey("score_title_text", "lucky_dog_006")
    self:setObjectVisible("arrow", false)

    --奖池
    local helf_width = 225
    local helf_height = 172
    local coordinate_arr = {Vector2(0, 1), Vector2(0.46, 1), Vector2(1, 1),
                            Vector2(1, 0.3), Vector2(1, -0.3), Vector2(1, -1),
                            Vector2(0.46, -1), Vector2(0, -1), Vector2(-0.46, -1), Vector2(-1, -1),
                            Vector2(-1, -0.3), Vector2(-1, 0.3), Vector2(-1, 1),
                            Vector2(-0.46, 1)}
    local big_reward_flag_arr = self.m_model:getBigRewardFlagArray()
    local gift_data = self.m_model:getGiftData()
    local iconCount = #gift_data
    local angle = 360 / iconCount
    self.m_angle_unit = angle
    self.item_list = {}
    for i = 1, iconCount do
        local item = ResourceUtil:LoadUIGameObject("LuckyDog/LuckyDogItemNode", Vector3.zero, nil)
        item.transform.localScale = Vector3.New(1, 1, 1)
        local obj_glow
        local lucky_dog_left_text
        local lucky_dog_bg_big
        local lucky_dog_left_bg_image
        if big_reward_flag_arr[i] == true then
            lucky_dog_bg_big = UIUtil.setObjectVisible(item.transform, true, "content/lucky_dog_bg_big")
            lucky_dog_left_bg_image = UIUtil.setObjectVisible(item.transform, true, "content/lucky_dog_left_bg_image")
            lucky_dog_left_text = UIUtil.setObjectVisible(item.transform, true, "content/lucky_dog_left_bg_image/lucky_dog_left_text")
            obj_glow = UIUtil.setObjectVisible(item.transform, true, "content/lucky_dog_bg_glow")
            UIUtil.setObjectVisible(item.transform, false, "content/lucky_dog_bg_small")
        end
        item.transform:SetParent(reward_list.transform, false)
        local x = coordinate_arr[i].x * helf_width
        local y = coordinate_arr[i].y * helf_height
        item.transform.localPosition = Vector2.New(x, y)
        local fx_compass = GameUtil:createPrefab("LuckyDog/LuckyDogShopFx", item.transform)
        local luaBehaviour = UIUtil.findLuaBehaviour(fx_compass)
        local img_fx = luaBehaviour:FindGameObject("img_fx")
        local rotation_z = -angle * (i - 1)
        img_fx.transform.localEulerAngles = Vector3.New(0, 0, rotation_z)
        local img_finish = luaBehaviour:FindGameObject("img_finish")
        local UI_Reward_LingQu_003 = luaBehaviour:FindGameObject("UI_Reward_LingQu_003")
        local ShuaXin_001 = luaBehaviour:FindGameObject("UI_Compass_ShuaXin_001")
        local ShuaXin_002 = luaBehaviour:FindGameObject("UI_Compass_ShuaXin_002")
        local img_select_1 = luaBehaviour:FindGameObject("UI_Compass_SBaoZha_001")
        local img_select_2 = luaBehaviour:FindGameObject("UI_Compass_SBaoZha_002")
        local img_select_3 = luaBehaviour:FindGameObject("UI_Compass_FBaoZha_001")
        local img_select_4 = luaBehaviour:FindGameObject("UI_Compass_FBaoZha_002")
        local LOD0_glow_1 = luaBehaviour:FindGameObject("LOD0_glow_1")
        img_select_1.transform.localEulerAngles = Vector3.New(0, 0, rotation_z)
        img_select_2.transform.localEulerAngles = Vector3.New(0, 0, rotation_z)
        img_select_3.transform.localEulerAngles = Vector3.New(0, 0, -rotation_z)
        img_select_4.transform.localEulerAngles = Vector3.New(0, 0, -rotation_z)
        self.item_list[i] = { item = item, img_fx = img_fx, img_finish = img_finish,
                              UI_Reward_LingQu_003 = UI_Reward_LingQu_003, ShuaXin_001 = ShuaXin_001,
                              ShuaXin_002 = ShuaXin_002, img_select_1 = img_select_1, img_select_2 = img_select_2, LOD0_glow_1 = LOD0_glow_1,
                              obj_glow = obj_glow, lucky_dog_left_text = lucky_dog_left_text, lucky_dog_bg_big = lucky_dog_bg_big, lucky_dog_left_bg_image = lucky_dog_left_bg_image}
    end
    
    self.m_update_key = "update_lucky_dog_shop"
    GameMain.addUpdate(self.m_update_key, handler(self, self.update))
    
    self:refreshUI(true)
end

function M:refreshUI(init)
    self:setText("score_text", self.m_model:getScore())
    local pool_data = self.m_model:getGiftData()
    local big_reward_flag_arr = self.m_model:getBigRewardFlagArray()
    for k, v in pairs(self.item_list) do
        v.img_finish:SetActive(false)
        v.img_fx:SetActive(false)
        v.UI_Reward_LingQu_003:SetActive(false)
        local data = pool_data[k]
        if data then
            if data.cfg.reward_grade == 1 then --大奖
                v.UI_Reward_LingQu_003:SetActive(true)
            end
            GameUtil:updateItemElement(v.item, data.cfg.reward[1], true, true)
            if data.left_times == 0 then
                v.img_finish:SetActive(true)
                v.UI_Reward_LingQu_003:SetActive(false)
            end
        end
        if (not init) or big_reward_flag_arr[k] == true then
            if v.lucky_dog_left_text and data.left_times then
                UIUtil.setText(v.lucky_dog_left_text.transform, Language:getTextByKey("lucky_dog_020", data.left_times))
            end
            if data.left_times ~= 0 then
                v.ShuaXin_001:SetActive(false)
                v.ShuaXin_001:SetActive(true)
            end
            if data.left_times == 0 then
                UIUtil.setObjectVisible(v.obj_glow.transform, false)
                --UIUtil.setObjectVisible(v.lucky_dog_left_bg_image.transform, false)
            end
        end
    end
end

function M:update()
    if self.go then
        self.m_fTime = self.m_fTime + CS.UnityEngine.Time.deltaTime
        if self.m_fTime < 0.5 then
            self.m_fVelocity = self.m_angle_unit * self.m_fTime
            if self.m_fVelocity < 3 then
                self.m_fVelocity = 3
            end
        elseif self.m_fTime >= 1 then
            self.m_fVelocity = 150 / (10 ^ self.m_fTime)
        end
        if (self.m_fVelocity <= 2.5) then
            self.m_fVelocity = 2.5
            local reward_index, reward_data = self.m_model:getRewardIndexAndData()
            local value = 360 - ((reward_index - 1) * self.m_angle_unit)
            local diff = self.arrow.transform.eulerAngles.z - value
            if math.abs(self.arrow.transform.eulerAngles.z) <= 1 then
                diff = 360 - value
            end
            if (math.abs(diff) <= 2) then
                if self.time == nil then
                    self.time = self.m_fTime
                end
                self:PlayResultFx(reward_index)
                self.arrow.transform.rotation = Quaternion.Euler(0, 0, value)
                if self.m_fTime >= self.time + 0.8 then
                    self.time = nil
                    self.m_fVelocity = 0
                    self.m_fTime = 0
                    self.start = false
                    self.go = false
                    RewardUtil:rewardTipsByRewards(reward_data, function() self:refreshUI()  end)
                end
                --end
            else
                self.arrow.transform:Rotate(Vector3.forward, (-1) * self.m_fVelocity)
                local index = math.floor((360 - self.arrow.transform.localEulerAngles.z) / self.m_angle_unit) + 1
                self:PlayFx(index)
            end
        else
            self.arrow.transform:Rotate(Vector3.forward, (-1) * self.m_fVelocity)
            local index = math.floor((360 - self.arrow.transform.localEulerAngles.z) / self.m_angle_unit) + 1
            self:PlayFx(index)
        end
    end
end

--播放转动选中特效
function M:PlayFx(index)
    local pool_data = self.m_model:getGiftData()
    local data
    for k, v in pairs(self.item_list) do
        data = pool_data[k]
        if k == index then
            if data.left_times ~= 0 then
                v.LOD0_glow_1:SetActive(false)
                v.LOD0_glow_1:SetActive(true)
            end
            break
        end
    end
end

--播放选中结果特效
function M:PlayResultFx(index)
    if self.is_play then
        return
    end
    audio:SendEvtUI("UI_TanCeOK")
    self.is_play = true
    self.m_control:setOnceTimer(0.25, function()
        for m, n in pairs(self.item_list) do
            if m == index then
                n.ShuaXin_002:SetActive(false)
                n.ShuaXin_002:SetActive(true)
            end
        end
    end)
end

function M:destroy()
    GameMain.removeUpdate(self.m_update_key)
    self.m_fTime = 0
    self.m_fVelocity = 0
    self.time = nil
    self.start = false
    self.go = false
    M.super.destroy(self)
end

return M