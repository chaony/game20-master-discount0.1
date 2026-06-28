local M = class("GifBagDay14Node", LikeOO.OOUIbase)
--7日登录
M.m_uiName = "GiftBag/GifBagDay14Node"
M.cacheSpineName = ""
function M:onEnter()
    self.m_gray_image = self:findImage("gary_img")
    self.m_end_ts = 0
    self:showUI(false)
end

--暂时无用
function M:switchInit(url, callback, id)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.id = id
    self.m_model:initData2(url, callFunc)
end

function M:switchUI(id)
    self.id = id
    self:refreshUI()
end


function M:refreshUI()
    if self.m_model.m_seven_tour_data == nil or self.id == nil or next(self.m_model.m_seven_tour_data) == nil then
        return
    end
    self:showUI(true)
    self.m_end_ts = self.m_model:getSevenDayEndTime(self.id)
    self:updateTime()
    self.m_version = self.m_model:getSevenDayVersion(self.id)
    self.select_index = self.m_model:getIndexBySevenDay(self.id)
    self:updateRewardData()
    self:setSpine()
end

function M:updateRewardData()
    local data = self.m_model:get_seven_tour(self.m_version)
    for i = 1, 7 do
        local item = self:findGameObject("day_" .. i)
        self:updateItem(i, item, data[i])
    end
    local type = true
    for i = 1,self.select_index do
        if self.m_model:getStatus(self.m_version,i) == false then
            type = false
            break 
        end
    end
    local get_day_btn = self:findButton("get_day_btn")
    if type == true then
        self:setTextByLanKey("get_day_text", "new_str_0080")
        if get_day_btn then
            get_day_btn.interactable = false
        end
    else
        get_day_btn.interactable = true
        self:setTextByLanKey("get_day_text", "new_str_0056")
    end
end

function M:updateItem(index, obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    --local bg_img = UIUtil.findImage(obj.transform)
    if LuaBehaviour then
        local type = self.m_model:getStatus(self.m_version,index)
        local title_name = LuaBehaviour:FindText("tit_text")--UIUtil.setTextByLanKey(obj.transform, "tit_text", data.name)
        title_name.text = Language:getTextByKey(data.name)
        local name_text = LuaBehaviour:FindText("item_name")
        --local img = LuaBehaviour:FindImage("img")
        if title_name then
            if index == self.select_index then
                title_name.color = Color.New(255 / 255, 228 / 255, 136 / 255)
            else
                title_name.color = Color.New(255 / 255, 253 / 255, 247 / 255)
            end
        end
        local content = LuaBehaviour:FindGameObject("content")
        if type == false and index <= self.select_index then
            UIUtil.setImgAlpha(obj.transform, 0)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rew_light", true)
            UIUtil.setLocalPosition(content.transform, nil, -20)
        else
            UIUtil.setImgAlpha(obj.transform, 1)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rew_light", false)
            UIUtil.setLocalPosition(content.transform, nil, 0)
        end
        local rew_parent = LuaBehaviour:FindGameObject("rew_parent")
        UIUtil.destroyAllChild(rew_parent.transform)
        local itemNode = nil
        if (index == 7) then
            if (self.m_version == 1) then
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
        local reward_data = RewardUtil:getProcessRewardData(data.reward[1])
        name_text.text = reward_data.name
        if itemNode then
            if type == false then
                if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or index == 7 then
                    GameUtil:creatCommonActiveEffect(itemNode, reward_data.quality)
                end
            else
                local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
                if itemLuaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", true)
                end
            end
        end
    end
end

function M:specialDayBtnEvent()
    local allAwardData = self.m_model:get_seven_tour(self.m_version)
    if not allAwardData or table.nums(allAwardData) <= 0 then
        return
    end
    local data = allAwardData[7]
    if not data then
        return
    end
    local show_data = RewardUtil:getProcessRewardData(data.reward[1])
    local isShowBtnType = (self.m_model:getCurCanGotAwardDay(self.m_version, self.select_index) == 7) and 1 or -1
    self.m_control:openView("Item.HeroBox", {show_data = show_data, use_num = show_data.data_num, isShowBtnType = isShowBtnType, isShowDropType = 1,
                                             callBack = function(heroIndex)
                                                 self:gotBtnEvent(heroIndex)
                                             end })
end

function M:onButtonClick(obj, name)
    if name == "get_day_btn" then
        local curIndex = self.m_model:getCurCanGotAwardDay(self.m_version, self.select_index)
        if (self.m_version == 1) and (curIndex == 7) then
            self:specialDayBtnEvent()
        else
            self:gotBtnEvent()
        end
    else
        self:updateMsg(name)
    end
end

-- heroIndex 英雄三选一才会有
function M:gotBtnEvent(heroIndex)
    local index = self.m_model:getCurCanGotAwardDay(self.m_version, self.select_index)
    local params = {day = index, version = self.m_version}
    if heroIndex then
        params.item_index = heroIndex
    end
    self:updateMsg("get_seven_reward", params)
end

function M:setSpine()
    --local data = self.m_model:get_seven_tour(self.m_version)
    self:setObjectVisible("dayTexture_2", false)
    self:setObjectVisible("dayTexture_5", false)
    self:setObjectVisible("dayTexture_7", false)
    local index, reward, des = self:getnextHero()
    if des then
        self:setTextByLanKey("active_title_text", des)
    else
        self:setTextByLanKey("active_title_text", "")
    end
    if (self.m_version == 2 and index == 5) or (self.m_version == 1 and index == 2) then
        self:setObjectVisible("dayTexture_" .. index, true)
    end
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
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
        end
    end
end

function M:getnextHero()
    local data = self.m_model:get_seven_tour(self.m_version)
    local star_num = math.floor(self.select_index)
    -- for i = 1,7 do
    --     if self.m_model:getStatus(self.m_version,i) == false then
    --         star_num = i
    --         break 
    --     end
    -- end
    for i = star_num, 7 do
        local reward = data[i]["reward_show"]
        local type = self.m_model:getStatus(self.m_version,i)
        if type == false and next(reward) ~= nil then
            if reward[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
                return i, reward, data[i].des
            end
        end
    end
    return 7, data[7]["reward_show"], data[7].des
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

function M:updateTime()
	if self.m_end_ts and self.m_end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.m_end_ts - UserDataManager:getServerTime())
		self:setTextByLanKey("time_down", time_show)
        self:setObjectVisible("time_down", true)
    else
        self:setObjectVisible("time_down", false)    
	end
end

function M:showUI(bl)
    self:setObjectVisible("rewardNodes", bl)
    self:setObjectVisible("show_7_bg", bl)
    self:setObjectVisible("time_down", bl)
    self:setObjectVisible("dayTexture_2", false)
    self:setObjectVisible("dayTexture_5", false)
    self:setObjectVisible("dayTexture_7", false)
    self:setObjectVisible("get_day_btn", bl)
end

function M:destroy()
    M.super.destroy(self)
end

return M