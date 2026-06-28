---@class CoolSummerGiftBagView: OOPopBase
---@field m_model CoolSummerGiftBagModel
local M = class("CoolSummerGiftBagView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGiftBag"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    local attr_mode = 1
    if self.m_model.is_tokens == true then
        attr_mode = 20
    end
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
    -- local activityXlsxData = self.m_model:getXlsxActivityByOpenId(self.m_model.m_open_id, true)
    self.avtive_data = self.m_model:getActiveData()
    if self.avtive_data then
        self:setTextByLanKey("close_title_text", self.avtive_data.name )
    end
    --清凉夏日
    local image_name = self:findImage("Image_bg")
    --GameUtil:updateResourcesImg( image_name, "Texture/map_plot/a_map_juqing_bg_139")
    GameUtil:updateResourcesImg( image_name, "Texture/map_plot/a_map_juqing_bg_155")
    
    self:setTextByLanKey("text_timer", self.m_model:getActiveShowTime())
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    self:updateBagNode()
    self:setHeroInfo()
end

function M:updateBagNode()
    local data = self.m_model:get_ladderGiftData()
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("btns_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:setRewardInfo(index,cell_object,cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data and cell_data.xlsxData then
                    self:updateMsg("buy", cell_data)
                end
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_rightloop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_rightloop_scroll_view:reloadData(data, true)
    end
    self:updateJianTou()
end

--设置礼包信息
function M:setRewardInfo(index,cell_object,cell_data)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local reward = cell_data.xlsxData.reward or {}
    local reward_node = luaBehaviour:FindGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 0.8)
    local bg_img = luaBehaviour:FindGameObject("bg_img")
    local btn_buy = luaBehaviour:FindButton("buy_btn")
    --设置价格
    local price = cell_data.xlsxData.charge_id == 0 and Language:getTextByKey("new_str_0278") or Language:getTextByKey("gf_str_0029",cell_data.xlsxData.price)
    LuaBehaviourUtil.setText(luaBehaviour, "buy_text", price)
    --是否能购买
    if cell_data.buyCount < cell_data.xlsxData.time_limit then
        GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian01")
        btn_buy.interactable = true
    else
        GameUtil:updateResourcesImg(bg_img, "Texture/ActiveCurrent/a_tbh_libao_biaoqian02")
        btn_buy.interactable = false
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_text", "flower_text_0015")
    end
    --设置名称
    local buy_num = cell_data.xlsxData.time_limit - cell_data.buyCount >= 0 and cell_data.xlsxData.time_limit - cell_data.buyCount or 0
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"title_text",Language:getTextByKey("gf_str_0050",buy_num))
    self:updateJianTou()
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:updateActivityTimer()
    local min_unit = 60
    local hour_unit = min_unit * 60
    local time_now = UserDataManager:getServerTime()
    local time_day_end = TimeUtil.getIntTimestamp(time_now) + hour_unit * 24 * 1
    local time_left = time_day_end - time_now
    local hour_left = math.floor(time_left / (hour_unit))
    local min_left = math.floor((time_left - hour_unit * hour_left) / min_unit)
    local sec_left = math.floor(time_left - hour_unit * hour_left - min_unit * min_left)
    local timerFormat = Language:getTextByKey("evil_shadow_str_010", hour_left, min_left, sec_left)
    self:setText("text_timer", timerFormat)
end

function M:updateJianTou()
    local loop_view = self.m_rightloop_scroll_view
    local loop_view_num = 2
    if loop_view and loop_view.m_line_count > loop_view_num then
        if loop_view:getVerticalNormalizedPosition() < 0.1 then
            self:setObjectVisible("jiantou_bottom_img", false)
        else
            self:setObjectVisible("jiantou_bottom_img", true)
        end
        if loop_view:getVerticalNormalizedPosition() > 0.9 then
            self:setObjectVisible("jiantou_top_img", false)
        else
            self:setObjectVisible("jiantou_top_img", true)
        end
    else
        self:setObjectVisible("jiantou_bottom_img", false)
        self:setObjectVisible("jiantou_top_img", false)
    end
end


function M:setHeroInfo()
    local xlsxData = self.m_model.m_hero_gift_cfg
    local reward = xlsxData.reward
    local reward_data = RewardUtil:getProcessRewardData(reward[1])
    self:setText("text_discountText", xlsxData.return_per)
    self:setTextByLanKey("text_originalMoney", "petard_text_0024", xlsxData.price_old)

    local btn_buySkinBtn = self:findImage("btn_buySkinBtn")
    if self.m_model:checkClothGift() == 1 then
        btn_buySkinBtn.material = self.m_gray_img.material
        self:setTextByLanKey("text_buySkinText", "gf_str_0048")
    else
        btn_buySkinBtn.material = nil
        self:setTextByLanKey("text_buySkinText", "new_str_0789", tostring(self.m_model.m_hero_gift_cfg.price_new) )
    end

    -- 设置名字
    local heroId = reward_data.item_cfg.hero
    if heroId == nil then
        heroId = reward_data.data_id
    end
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(heroId)
    local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)
    local class_str = Language:getTextByKey(hero_cfg.class)
    local name_str = Language:getTextByKey(shin_data_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    --local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero,hero_cfg.max_evo), "common_ui","hero_evo")
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
        end
    elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        local cur_skin_cfg = ConfigManager:getHeroSkinCfg(reward_data.data_id)
        local icon = cur_skin_cfg.hero_spine
        if self.cacheSpineName == icon then
            return
        else
            self.cacheSpineName = icon
        end
    end
    if self.cacheSpineName then
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
    end
    local look_hero_info = self:findGameObject("look_hero_info")
    UIUtil.setButtonClick(
            look_hero_info.transform,
            function()
                if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
                    static_rootControl:openView("Pops.HeroLookInfo", {hero_id = heroId, is_new = false})
                elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
                    static_rootControl:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
                end
            end
    )
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M