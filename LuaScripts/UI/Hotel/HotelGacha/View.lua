local M = class("HotelGachaView",LikeOO.OOPopBase)

M.m_uiName = "Hotel/HotelGacha"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __ATTR_TEXT = {
    [1] = {func_text = "hotel_text_041", attr_text = "hotel_text_015"}, --寻芳  魅力
    [2] = {func_text = "hotel_text_042", attr_text = "hotel_text_016"}, --结交  交流
    [3] = {func_text = "hotel_text_048", attr_text = "hotel_text_017"}, --驯马  服务
}

function M:onEnter()
    local cfg = self.m_model.m_cfg
    local attr_id = cfg.gacha_attr_id
    local func_name = Language:getTextByKey(__ATTR_TEXT[attr_id].func_text)
    local attr_name = Language:getTextByKey(__ATTR_TEXT[attr_id].attr_text)
    self:setTextByLanKey("common_title_text", "hotel_text_051", cfg.name, func_name)
	self:setTextByLanKey("c_hint_text", "hotel_text_046", attr_name, func_name)
    self:setTextByLanKey("gacha_hint_text", cfg.gacha_tips)
    self:setText("gacha_btn_text", func_name)
    self:setTextByLanKey("open_hero_btn_text", "hotel_text_045")
    self:setTextByLanKey("close_hero_btn_text", "hotel_text_047")
    self:setTextByLanKey("hero_hint_text", "hotel_text_029")
    self:setTextByLanKey("reward_btn_text", "hotel_text_044")

    self:closeHeroList()
    self:refreshUI()
    self:refreshHero(1, self.m_model.m_heroes[1])
    self:refreshHero(2, self.m_model.m_heroes[2])
end

function M:refreshUI()
    self:setTextByLanKey("times_text", "hotel_text_007", self.m_model.m_times)
    self:setText("des_text", self.m_model.m_reward_record)
    --需要延迟一下才能在第二次以后有用，否则只会在首次调用时有用
    self.m_control:setOnceTimer(0.2, function ()
        local scroll_rect = self:findGameObject("text_scroll")
        local des_scroll_rect = scroll_rect:GetComponent("ScrollRect")
        des_scroll_rect.verticalNormalizedPosition = 0 --scroll滚动到底
    end)
end

function M:refreshHero(index, oid)
    local obj = self:findGameObject("hero" .. index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local unlock_obj = luaBehaviour:FindGameObject("unlock")
    local lock_obj = luaBehaviour:FindGameObject("lock")
    local blank_obj = luaBehaviour:FindGameObject("blank")
    unlock_obj:SetActive(false)
    lock_obj:SetActive(false)
    blank_obj:SetActive(false)
    --lock
    local lock_level = self.m_model.m_cfg.open_gacha_room_level[index]
    if self.m_model.m_room_lv < lock_level then
        lock_obj:SetActive(true)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lock_text", "hotel_text_049", self.m_model.m_cfg.name, lock_level)
        return
    end
    --blank
    if oid == nil or oid == "" then
        blank_obj:SetActive(true)
        return
    end
    unlock_obj:SetActive(true)
    local hero_data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local hero_spine_name = cfg.hero_spine
    local hero_spine = luaBehaviour:FindGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(hero_spine,"RoleSpine/" .. hero_spine_name,"idle", 0,true)
    --evo
    LuaBehaviourUtil.setImg(luaBehaviour,"hero_evo", GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui")
    --name
    local class_str = Language:getTextByKey(cfg.class)
    local name_str = Language:getTextByKey(cfg.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"hero_name", name_str)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"hero_name2", class_str)
    --race
    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
    LuaBehaviourUtil.setImg(luaBehaviour, "hero_race", race, ResourceUtil:getLanAtlas())
    --attr icon
    local attr_id = self.m_model.m_cfg.gacha_attr_id
    local attr_icon = luaBehaviour:FindImage("attr_icon")
    GameUtil:updateResourcesImg( attr_icon, "Texture/hotel/gacha_attr_" .. attr_id)
    --attr value
    local attrs = self.m_model:getHeroAttrs(oid)
    local attr_value = Language:getTextByKey("hotel_text_052", attrs[attr_id], Language:getTextByKey(__ATTR_TEXT[attr_id].attr_text))
    LuaBehaviourUtil.setText(luaBehaviour,"attr_text", attr_value)
end

--显示侠客列表
function M:showHeroList()
    self:setObjectVisible("R", false)
    self:setObjectVisible("hero_panel", true)
    self:setObjectVisible("open_hero_btn", false)
    self:setObjectVisible("close_hero_btn", true)
    self:refreshHeroList()
end

function M:closeHeroList()
    self:setObjectVisible("R", true)
    self:setObjectVisible("hero_panel", false)
    self:setObjectVisible("open_hero_btn", true)
    self:setObjectVisible("close_hero_btn", false)
end

function M:refreshHeroList()
    local data = self.m_model:getHeroes()
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("hero_list")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local cell_data = data[index]
                self:listItemHandle(cell_object, index, cell_data)
            end,
            update_cell = function(index, cell_object, cell_data)
                self:listItemHandle(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "check_flag" then
                else
                    self:updateMsg("up_hero", {oid = cell_data})
                end
                --if index ~= self.m_model.m_select_index then
                --    self.m_model.m_select_index = index
                --end
            end,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:listItemHandle(obj, index, cell_data)
    if cell_data == nil or cell_data == "" then
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local oid = cell_data
    local heroNode = luaBehaviour:FindGameObject("hero_node")
    GameUtil:updateHeroContent(heroNode, oid)
    --name & attrs
    local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", cfg.name)
    local attrs = self.m_model:getHeroAttrs(oid)
    for i = 1, #attrs do
        LuaBehaviourUtil.setSliderValue(luaBehaviour, "attr_" .. i, attrs[i] / 100)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_text_" .. i, Language:getTextByKey(__ATTR_TEXT[i].attr_text) .. "  " .. attrs[i])
    end
    --是否忙碌
    local is_busy = self.m_model:isHeroBusy(oid)
    if is_busy == true then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_flag",true)
        --LuaBehaviourUtil.setText(luaBehaviour, "room_text", room.name)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_flag",false)
        LuaBehaviourUtil.setText(luaBehaviour, "room_text", "")
    end
end

return M