local M = class("SeasonNode10",LikeOO.OOUIbase)

M.m_uiName = "SeasonPreview/season_10"

function M:onEnter()
    self.m_func_bg_img = self:findImage("func_bg_img")
    self.m_func_name_img = self:findImage("func_name_img")
    self.m_jump_icon = self:findImage("func_icon")
    self:setTextByLanKey("road_btn_text", "achievement_text20")
    self:setTextByLanKey("vedio_btn_text", "new_str_0469")
    self:setTextByLanKey("road_title_btn_text", "")
    self:setTextByLanKey("gift_btn_text", "new_str_1095")
end

function M:initUi( ui_data)
    self.m_ui_data = ui_data
    local btn_node = self:findGameObject("btn_node")
    btn_node.gameObject:SetActive(false)
    --for i, v in pairs(ui_data.btn_name) do
    --    local btn_id = self.m_model:getSeasonBtnId()[v .. "_btn"]
    --    local btn_func_cfg = self.m_model:getFuncCfgById(btn_id)
    --    local func_name = btn_func_cfg.name
    --    self:setTextByLanKey(v .. "_btn_text", func_name)
    --    self:onBtnClick(ui_data.btn_name[i] .. "_btn", ui_data.btn_name[i])
    --end
    
    self:onBtnClick("road_btn", "road_btn")
    self:onBtnClick("road_help_btn", "road_help_btn")
    self:onBtnClick("hero_detail" .. 1, "hero_detail",  1)
    self:onBtnClick("reward_btn", "reward_btn")
    local open_flag = BtnOpenUtil:isBtnOpen(240)
    self:setObjectVisible("season_chengjiu", open_flag)
end

function M:onBtnClick( btn_name, msg, params)
    local function btnClick(trans,params)
        self:updateMsg(msg, params)
    end
    local btn = self:findGameObject(btn_name)
    UIUtil.setButtonClick(btn.transform, btnClick, params)
end

local jump_icon_tab = {"a_dqsj_cwmz", "a_dqsj_tdsc"}
function M:updateFuncDesNode(func_name)
    self:setObjectVisible("func_des_pop_btn", self.m_model.m_is_show_func_node)
    if self.m_model.m_is_show_func_node then
        local btn_id = self.m_model:getSeasonBtnId()[func_name .. "_btn"]
        local btn_func_cfg = self.m_model:getFuncCfgById(btn_id)
        self:setTextByLanKey("func_des_text", btn_func_cfg.des)
        self:setText("func_name_text", btn_func_cfg.name)
        local img = jump_icon_tab[btn_id - 21] or ""

        GameUtil:updateResourcesImg(self.m_jump_icon, "Texture/season_preview/" .. img)
        self.m_jump_icon:SetNativeSize()
        GameUtil:updateResourcesImg(self.m_func_bg_img, "Texture/season_preview/a_saiji2_caihongbg")
        self.m_jump_icon:SetNativeSize()
        self.m_func_bg_img:SetNativeSize()
    end
end

function M:refreshUI()
    --for i, v in pairs(self.m_ui_data.btn_name) do
        --local btn_id = self.m_model:getSeasonBtnId()[v .. "_btn"]
        --local btn_func_cfg = self.m_model:getFuncCfgById(btn_id)
        --local entrance_des = btn_func_cfg.entrance_des
        --local des = btn_func_cfg.des
        --local func_name = btn_func_cfg.name
        --self:setTextByLanKey(v .. "_btn_text", func_name)
    --end
    self:setObjectVisible("UI_Xian_ShanGuang_001", self.m_model.m_can_get_reward)
    self:setObjectVisible("reward_red_point_img", self.m_model.m_can_get_reward)
    self:updateHeroInfo()
    self:setSpine()
    local red_flag = RedPointUtil:isFuncRedPointById(240)
    self:setObjectVisible("season_red_point_img", red_flag)
    local gift_btn_open_flag = self.m_model.m_show_gift_btn_flag
    local gift_red_flag = RedPointUtil:getCommonGiftRedByOpenId(313, true)
    self:setObjectVisible("gift_red_point_img", gift_red_flag)
    self:setObjectVisible("gift_btn", gift_btn_open_flag)
    self:setObjectVisible("gift_btn_text", gift_btn_open_flag)
    self:setObjectVisible("UI_Xian_ShanGuang_002", gift_red_flag and gift_btn_open_flag)
end

function M:setSpine()
    for i = 1, 1 do
        local hk_obj = self:findGameObject("hero_sk" .. i)
        local c_id = self.m_model:getShowHeroId()[i]
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(c_id))
        local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
        GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
    end
end

function M:updateHeroInfo()
    local hero_id_tab = self.m_model:getShowHeroId()
    for i = 1, 1 do
        local hero_id = hero_id_tab[i]
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
        local hero_name = hero_cfg.name
        local hero_class = hero_cfg.class
        self:setTextByLanKey("hero_name" .. i .. "_text", hero_name)
        self:setTextByLanKey("hero_type" .. i .. "_text", hero_class)

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