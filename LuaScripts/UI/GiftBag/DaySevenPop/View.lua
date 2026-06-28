local M = class("DaySevenPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/DaySevenPop"
M.m_size_type = 2

function M:onEnter()
	self.m_gray_image = self:findImage("gary_img")
    UserDataManager:removeRedDotByKey("seven_tour_once")
    self:setTextByLanKey("day7_reward_text", "")

    self:setTextByLanKey("get_day_text", "new_str_0056")
	self:refreshUI()
end

function M:refreshUI()
    self:updateRewardData()
    local type = self.m_model:getStatus(self.m_model.m_day)
    if type == 1 or type == 3 then
        self:setObjectVisible("get_day_btn", true)
    else
        self:setObjectVisible("get_day_btn", false)    
    end
    local _, _, des = self:getnextHero()
    if des then
        self:setTextByLanKey("active_title_text", des)
    else
        self:setTextByLanKey("active_title_text", "")
    end
end

function M:updateRewardData()
    local data = self.m_model:get_seven_tour()
    for i = 1, 7 do
        local item = self:findGameObject("day_"..i)
        self:updateItem(i, item, data[i])
    end
end

function M:updateItem(index, obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local title_name = UIUtil.setTextByLanKey(obj.transform, "tit_text", data.name)
    local bg_img = UIUtil.findImage(obj.transform)
    if LuaBehaviour then
        local type = self.m_model:getStatus(index)
        local img = LuaBehaviour:FindImage("img")
        local can_click = false
        if type == 3 or type == 1 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rew_light", true)
            can_click = false
            UIUtil.setLocalPosition(obj.transform, nil, 25)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rew_light", false)    
            can_click = true
            UIUtil.setLocalPosition(obj.transform, nil, 0)
        end
        local rew_parent = LuaBehaviour:FindGameObject("rew_parent")
        UIUtil.destroyAllChild(rew_parent.transform)
        local itemNode = nil
        if (index == 7) then
            if (self.m_model.m_version == 1) then
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "img_dropImg", true)
                itemNode = GameUtil:createItemElement(data.reward[1], true, false, function() 
                    self:specialDayBtnEvent()
                end)
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "img_dropImg", false)
                itemNode = GameUtil:createItemElement(data.reward[1], true, true)
            end
        else
            itemNode = GameUtil:createItemElement(data.reward[1], true, true)
        end
        itemNode.transform:SetParent(rew_parent.transform, false)
        if itemNode then
            local reward_data = RewardUtil:getProcessRewardData(data.reward[1])
            if type ~= 2 and type ~= 4 then 
                if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
                    GameUtil:creatCommonActiveEffect(itemNode, reward_data.quality, 0.9)
                end
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "item_name",reward_data.name)
            if index == 7 then
                self:setTextByLanKey("day7_reward_text", string.cutTextForString(Language:getTextByKey(reward_data.name)))
            end
        end
        local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
        local quality_img =  itemLuaBehaviour:FindImage("quality_img")
        local item_img =  itemLuaBehaviour:FindImage("item_img")
        local duigoudi_img =  itemLuaBehaviour:FindGameObject("duigoudi_img")
        if type == 2 or type == 4 then
            -- self:setGary(title_name, true)
            -- self:setGary(img, true)
            -- self:setGary(quality_img, true)
            -- self:setGary(item_img, true)
            duigoudi_img:SetActive(true)
        else
            duigoudi_img:SetActive(false)
            -- self:setGary(title_name, false)
            -- self:setGary(img, false)
            -- self:setGary(quality_img, false)
            -- self:setGary(item_img, false)
        end
    end
end

function M:specialDayBtnEvent()
    local allAwardData = self.m_model:get_seven_tour()
    if not allAwardData or table.nums(allAwardData) <= 0 then
        return
    end
    local data = allAwardData[7]
    if not data then
        return
    end
    local show_data = RewardUtil:getProcessRewardData(data.reward[1])
    local isShowBtnType = (self.m_model:getCurCanGotAwardDay() == 7) and 1 or -1
    self.m_control:openView("Item.HeroBox", {show_data = show_data, use_num = show_data.data_num, isShowBtnType = isShowBtnType, isShowDropType = 1,
                                             callBack = function(heroIndex)
                                                 local cudDay = self.m_model.m_day
                                                 for i = 1,self.m_model.m_day do
                                                     if self.m_model:getStatus(i) == 1 or self.m_model:getStatus(i) == 3 then
                                                         cudDay = i
                                                         break
                                                     end
                                                 end
                                                 self.m_control:getSeven_Tour(cudDay, heroIndex)
                                             end})
end

function M:setSpine()
    local data = self.m_model:get_seven_tour()
    self:setObjectVisible("dayTexture_2", false)
    self:setObjectVisible("dayTexture_7", false)
    local index, reward = self:getnextHero()
    self:setObjectVisible("dayTexture_"..index, true)
    local reward_data = RewardUtil:getProcessRewardData(reward[1])
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            local play_img = self:findGameObject("hero_spine")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
        end
    end
end

function M:getnextHero()
    local data = self.m_model:get_seven_tour()
    local star_num = math.floor(self.m_model.m_day)
    for i= star_num, 7 do
        local reward = data[i]["reward"]
        local type = self.m_model:getStatus(i)
        if type ~= 2 and type ~= 4 then
            if reward[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
                return i, reward, data[i].des
            end
        end
    end
    return 7, data[7]["reward"], data[7].des
end

function M:setGary(obj, bl)
    if obj then
        if bl == true then
            obj.material = self.m_gray_image.material
        else
            obj.material = nil
        end
    end
end

return M