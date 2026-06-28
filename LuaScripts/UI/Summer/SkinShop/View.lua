local M = class("SkinShopView", LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Summer/SkinShop"
M.m_iphoneXAdapter = true

function M:onEnter()
    -- local skill_firstword = string.sub(skill_describe, 1, 3)
    -- local heroPos = string.split(hero_type[2],skill_firstword)
    -- self:setTextByLanKey("tips_skill_firstword",skill_firstword)
    -- self:setTextByLanKey("tips_skill_text",heroPos[2])

    self:setTextByLanKey("get_text", "gf_str_0048")
    self:setTextByLanKey("activeOver_text", "new_str_0793")
    self:setTextByLanKey("text_price_title", "summer_text_price")

    self:setTextByLanKey("close_title_text", self.m_model.m_params.back_name)

    self:setSpine()
    self:updateSkill()
    self:setMoney()
    self:updateTime()
    self:refreshUI()

    if self:isSkinShow() then
        self:showSkinInfo()
    else
        self:showHeroInfo()
    end
end

function M:showHeroInfo()
    self:setObjectVisible("hero_root", true)
    self:setObjectVisible("skin_root", false)

    local heroCfg = self.m_model.m_hero_cfg
    local class_str = Language:getTextByKey(heroCfg.class)
    local name_str = Language:getTextByKey((heroCfg.name))
    self:setTextByLanKey("Hero_Name_text", string.cutTextForString(name_str .. "·" .. class_str))
    local race = GlobalConfig.TYPE_HERO_RACE[heroCfg.race].big_race_icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "Camp_Icon")
    local hero_type = string.split(Language:getTextByKey(heroCfg.type_des03), "·")
    self:setTextByLanKey("tips_heroPos_text", hero_type[1])
    local skill_describe = hero_type[2]
    self:setTextByLanKey("tips_skill_text", skill_describe)

    self:setObjectVisible("img_heroEvo", heroCfg.evo > 4)
end

function M:showSkinInfo()
    self:setObjectVisible("hero_root", false)
    self:setObjectVisible("skin_root", true)

    local heroCfg = self.m_model.m_hero_cfg
    self:setObjectVisible("img_skinEvo", heroCfg.evo > 4)

    local class_str = Language:getTextByKey(self.m_model.m_hero_cfg.class)
    local skinData = self.m_model.m_params.skin_cfg
    local skinCfg = skinData.item_cfg
    local name_str = Language:getTextByKey(skinCfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local pro = GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].pro_icon
    self:setImg(pro, "hero_ui", "pro_img_btn")
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].big_race_icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "hero_race")
    self:setTextByLanKey("img_tips_text", "hero_ui_str_0026")
    self:setTextByLanKey("skin_attr_text", "hero_ui_str_0027")
    -- self.big_close_btn = self:findGameObject("big_close_btn")
    --local frame_data = GlobalConfig.QUALITY_FRAME[self.m_model.m_hero_cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(m_hero_cfg.Ex_hero,m_hero_cfg.max_evo), "common_ui","hero_evo")

    -- self:setTextByLanKey("get_title_text", "new_str_0554")
    local poetry = string.gsub(Language:getTextByKey(skinCfg.poetry), "\\n", "\n")
    self:setText("skin_info_text", poetry)
    local skin_name_img = self:setImg("a_name_" .. skinData.data_id, ResourceUtil:getLanAtlas(), "skin_name_img")
    skin_name_img:SetNativeSize()
    self:setObjectVisible("new_skin", false)

    --quality
    local skin_quality = skinCfg.skin_quality
    if skin_quality ~= 0 then
        self:setObjectVisible("skin_quality", true)
        self:setImg(
            "a_hero_skin_" .. GameUtil:fillNumWithZero(skin_quality, 2),
            ResourceUtil:getLanAtlas(),
            "skin_quality"
        )
    else
        self:setObjectVisible("skin_quality", false)
    end

    local attrs = UserDataManager:appendAttrs(skinCfg.attr)
    local attr_data = {}
    for i, v in pairs(attrs) do
        table.insert(attr_data, {i, v})
    end
    if table.nums(attr_data) > 0 then
        self:updateSkipArtList(attr_data)
    else
        self:setTextByLanKey("attr_value_text", "new_str_0825")
    end
end

function M:updateSkipArtList(attr_data)
    if self.m_art_scroll_view == nil then
        local loopscroll = self:findGameObject("skin_attr_scroll")
        local params = {
            show_data = attr_data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local art_name = GameUtil:getAttrsName(cell_data[1])
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_name", art_name)
                    local attr_value = cell_data[2] or 0
                    attr_value = math.floor(attr_value)
                    if GameUtil:attrTransition(cell_data[1]) == true then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_num", GameUtil:formatNum(attr_value) .. "%")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_num", GameUtil:formatNum(attr_value))
                    end
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_art_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_art_scroll_view:reloadData(attr_data, true)
    end
end

function M:isSkinShow()
    return self.m_model.m_params.skin_cfg ~= nil
end

function M:setSpine()
    local spine_name = self.m_model.m_hero_cfg.hero_spine or "hero_0506_SkeletonData"
    if self:isSkinShow() then
        spine_name = self.m_model.m_params.skin_cfg.item_cfg.hero_spine
    end
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "idle", 0, true)
end

--技能更新
function M:updateSkill()
    local skills = self.m_model.m_hero_cfg.skill
    for i = 1, 4 do
        self:setObjectVisible("di_" .. i, false)
    end
    for k, v in pairs(skills) do
        if k <= 4 then
            self:setObjectVisible("di_" .. k, true)
            local str_name = "skill" .. k .. "_img"
            local show_text = "skill_" .. k .. "_text"
            local cur_skill = GameUtil:getSkill(v[1][1])
            self:setTextByLanKey(show_text, cur_skill.show_type)
            self:setImg(cur_skill.icon, "skill_icon", str_name)
        end
    end
end

function M:setMoney()
    --价格设置
    local check_item = self.m_model:getMoney()
    local price_old = check_item["price_old"]
    local price_new = check_item["price_new"]
    local return_per = check_item["return_per"]
    --self:setTextByLanKey("price_Number",string.cutTextForString(price_old .. "tid#Surname_91"))
    local price_old_text = GameUtil:getMoneyTypeNum(price_old)-- Language:getTextByKey("gf_str_0029", price_old)
    self:setTextByLanKey("price_Number", price_old_text)
    --self:setTextByLanKey("buyprice",price_new .. "元购买" .. "new_str_0037")
    local price_new_text = GameUtil:getMoneyTypeNum(price_new) --Language:getTextByKey("new_str_0789", )
    self:setTextByLanKey("buyprice", price_new_text)
    self:setTextByLanKey("per_text", return_per)
end

--更新时间
function M:updateTime()
    local ServerTime = UserDataManager:getServerTime()
    --服务器时间
    local remain_tim = self.m_model.m_active_time.end_ts - ServerTime --剩余时间
    local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
    local time_text = 1
    if remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 then --小于一分钟
        time_text = Language:getTextByKey("new_str_0842", remain_sec)
    elseif remain_day <= 0 and remain_hour <= 0 then --小于一小时
        time_text = Language:getTextByKey("new_str_0417", remain_min)
    elseif remain_day <= 0 then --小于一天
        time_text = Language:getTextByKey("new_str_0791", remain_hour)
    else
        time_text = Language:getTextByKey("gf_str_0016", remain_day)
    end
    self:setTextByLanKey("time_remaining", time_text) --重置剩余时间
end

--刷新界面
function M:refreshUI()
    local btn_buy_show = false
    local get_btn_show = false

    if self:isSkinShow() then
        local skinBuyData = self.m_model.m_params.skin_bought
        if skinBuyData[1] ~= nil then --已经购买过英雄
            get_btn_show = true
        else --没购买过英雄
            btn_buy_show = true
        end
    else
        if self.m_model.m_hero_bought[1] ~= nil then --已经购买过英雄
            get_btn_show = true
        else --没购买过英雄
            btn_buy_show = true
        end
    end

    -- local btn_buy = self:findGameObject("btn_buy")
    -- local get_btn = self:findGameObject("get_btn")
    -- btn_buy.gameObject:SetActive(btn_buy_show)
    -- get_btn.gameObject:SetActive(get_btn_show)
    self:setObjectVisible("btn_buy", btn_buy_show)
    self:setObjectVisible("get_btn", get_btn_show)
    self:setObjectVisible("price", btn_buy_show)
end

function M:destroy()
    M.super.destroy(self)
end

return M
