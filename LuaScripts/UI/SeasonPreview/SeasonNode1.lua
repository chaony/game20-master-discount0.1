local M = class("SeasonNode1",LikeOO.OOUIbase)

M.m_uiName = "SeasonPreview/season_1"

function M:onEnter()
    self:setTextByLanKey("gift_btn_text", "new_str_1095")
    self:setTextByLanKey("reward_btn_text", "season_gift_text")
end

function M:initUi( ui_data)
    self.m_ui_data = ui_data
    for i, v in pairs(ui_data.btn_name) do
        self:onBtnClick(ui_data.btn_name[i] .. "_btn", ui_data.btn_name[i])
    end
    for i = 1, 2 do
        self:onBtnClick("hero_detail" .. i, "hero_detail",  i)
    end
    self:onBtnClick("gift_btn", "gift_btn")
    self:onBtnClick("reward_btn", "reward_btn")
end

function M:onBtnClick( btn_name, msg, params)
    local function btnClick(trans,params)
        self:updateMsg(msg, params)
    end
    local btn = self:findGameObject(btn_name)
    UIUtil.setButtonClick(btn.transform, btnClick, params)
end

function M:updateFuncDesNode(func_name)
    self:setObjectVisible("func_des_pop_btn", self.m_model.m_is_show_func_node)
    if self.m_model.m_is_show_func_node then
        local btn_id = self.m_model:getSeasonBtnId()[func_name .. "_btn"]
        local btn_func_cfg = self.m_model:getFuncCfgById(btn_id)
        self:setTextByLanKey("func_des_text", btn_func_cfg.des)
        self:setText("func_name_text", btn_func_cfg.name)

        local img = btn_func_cfg.jump_icon or ""
        if  ResourceUtil:GetSprite(img,"main_ui") then
            self:setImg(img,"main_ui","func_icon")
        else
            self:setImg(img,"main_ui2","func_icon")
        end
    end
end

function M:refreshUI()
    for i, v in pairs(self.m_ui_data.btn_name) do
        local btn_id = self.m_model:getSeasonBtnId()[v .. "_btn"]
        local btn_func_cfg = self.m_model:getFuncCfgById(btn_id)
        local entrance_des = btn_func_cfg.entrance_des
        local des = btn_func_cfg.des
        local func_name = btn_func_cfg.name
        self:setTextByLanKey(v .. "_btn_text", func_name)
        self:setTextByLanKey(v .. "_des_text", entrance_des)
    end
    self:setObjectVisible("UI_Xian_ShanGuang_001", self.m_model.m_can_get_reward)
    self:setObjectVisible("reward_red_point_img", self.m_model.m_can_get_reward)
    local gift_btn_open_flag = self.m_model.m_show_gift_btn_flag
    local gift_red_flag = RedPointUtil:getCommonGiftRedByOpenId(313, true)
    self:setObjectVisible("gift_red_point_img", gift_red_flag)
    self:setObjectVisible("gift_btn", gift_btn_open_flag)
    self:setObjectVisible("gift_btn_text", gift_btn_open_flag)
    self:setObjectVisible("UI_Xian_ShanGuang_002", gift_red_flag and gift_btn_open_flag)
    self:updateHeroInfo()
end

function M:updateHeroInfo()
    local hero_id_tab = self.m_model:getShowHeroId()
    for i = 1, #hero_id_tab do
        local hero_id = hero_id_tab[i]
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
        local hero_name = hero_cfg.name
        local hero_class = hero_cfg.class
        --self:setTextByLanKey("hero_type" .. i .. "_text", hero_name)
        --self:setTextByLanKey("hero_name" .. i .. "_text", hero_class)
        --self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui","hero_evo")
        --name
        self:setTextByLanKey("hero_name1_" .. i, hero_name)
        self:setTextByLanKey("hero_name2_" .. i, hero_class)
        --race
        local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
        self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race_" .. i)
    end
end

function M:updateTime()
    local end_time = self.m_model.m_end_time
    local occ_time = end_time - UserDataManager:getServerTime()
    if occ_time > 0 and end_time > 0 then
        local tim = GameUtil:formatTimeBySecond(occ_time, 999)
        if occ_time < 3600 then
            self:setTextByLanKey("count_time_text", "new_str_1031")
        else
            self:setTextByLanKey("count_time_text", "new_str_1028", tim)
        end
    else
        self.m_control:setOnceTimer(0.1, function ()
            UserDataManager:setSeasonPreviewStatus(1)
            self:updateMsg("refreshRedPoint",nil, "Main.TotalWorld")
            self:updateMsg("refreshRedPoint",nil, "Main")
            self:updateMsg(99999)
        end)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M