---@class FormationView : OOPopBase
---@field m_model FormationModel
local M = class("FormationView", LikeOO.OOPopBase)

M.m_uiName = "Formation/Formation"
M.m_iphoneXAdapter = true
M.m_size_type = 1
M.m_cache_ui_flag = true

local __TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text", race = 0},
    {btn = "martial_1_toggle", name = "martial_1_text", race = 1},
    {btn = "martial_2_toggle", name = "martial_2_text", race = 2},
    {btn = "martial_3_toggle", name = "martial_3_text", race = 3},
    {btn = "martial_4_toggle", name = "martial_4_text", race = 4},
    {btn = "martial_5_toggle", name = "martial_5_text", race = 5},
    {btn = "martial_6_toggle", name = "martial_6_text", race = 6},
    {btn = "martial_7_toggle", name = "martial_7_text", race = 7}
}

local __MULT_TEAM_TAB_BTN = {
    {btn_key = "one_togglebtn", btn_text = "one_togglebtn_text", btn_img_name = "one_img",  text_key = "1"}, -- 队伍1
    {btn_key = "two_togglebtn", btn_text = "two_togglebtn_text", btn_img_name = "two_img", text_key = "2"}, -- 队伍2
    {btn_key = "three_togglebtn", btn_text = "three_togglebtn_text", btn_img_name = "three_img", text_key = "3"}, -- 队伍3
    {btn_key = "four_togglebtn", btn_text = "four_togglebtn_text", btn_img_name = "four_img", text_key = "4"}, -- 队伍3
    {btn_key = "five_togglebtn", btn_text = "five_togglebtn_text", btn_img_name = "five_img", text_key = "5"} -- 队伍3
}

local __UNION_WAR_ATTACK_BTN = {
    {btn_key = "node_g1", text_key = 1}, -- 队伍1
    {btn_key = "node_g2", text_key = 2}, -- 队伍2
    {btn_key = "node_g3", text_key = 3},-- 队伍3
    {btn_key = "node_g4", text_key = 4}, -- 队伍3
    {btn_key = "node_g5", text_key = 5} ,-- 队伍3
}

local _MINING_TAB_BTN = {
    {btn_key = "mine_team_mem1", text_key = "1", open_id = 182}, -- 队伍1
    {btn_key = "mine_team_mem2", text_key = "2", open_id = 183}, -- 队伍2
    {btn_key = "mine_team_mem3", text_key = "3", open_id = 184}, -- 队伍3
    {btn_key = "mine_team_mem4", text_key = "4", open_id = 185} -- 队伍3
}

local __UNION_WAR_RED_POINT_IMAGE = {
    [1] = "team_mem1_img_red_point",
    [2] = "team_mem2_img_red_point",
    [3] = "team_mem3_img_red_point",
    [4] = "team_mem3_img_red_point",
    [5] = "team_mem3_img_red_point",
}
local _MINING_RED_POINT_IMAGE = {
    [1] = "mine_team_mem1_img_red_point",
    [2] = "mine_team_mem2_img_red_point",
    [3] = "mine_team_mem3_img_red_point",
    [4] = "mine_team_mem4_img_red_point"
}

--缓存英雄数据
local HERO_LIST = {}
local DEP_EF_NAME = "UI_MazeStage_Zhanli_001" -- 阵法特效名字

function M:create()
    local is_horizontally = CS.wt.framework.ResourcesHelper.useHovBattle
    M.super.create(self)
end

function M:onEnter()
    self.cache_dep_id = self.m_model.m_atk_deployment or 1
    self.m_race = 0
    self.prefix = ""
    self.helperList = {}
    self:setObjectVisible("weapon_node", false)
    self.m_multi_bg_rt = self:findRectTransform("multi_bg")
    self.m_canvasScale = self.m_ui_obj:GetComponent("CanvasScaler")
    self.m_gray_image = self:findImage("gray_image")
    self.is_horizontally = CS.wt.framework.ResourcesHelper.useHovBattle
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        self.m_model.show_pet_bl = true
    end
    --种族阵容限定
    self:refreshRacesIcon()
    --种族选择标签
    self:initRacesTabBtn()
    self:setCloseText(true)
    self:initNodeVisible()
    self:initLabelDes()
    --通用多阵容编队
    self:initMultTabBtn()
    --帮会战编队
    self:initUnionMultTabBtn()
    --苗疆觅宝编队
    self:initMiningMultTabBtn()

    --rta布阵倒计时
    self:InitBuzhenCountDown()
    
    self:updateBuffLv(self.m_model:getAddBuffLv(), true)
    self:setEnemyBuffLv()
    
    self:initRelicInfoNode()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
        self:doEnterAnim()
    end
    self:updateDeployment()
    self:refreshUI()
    if self.m_model:getSaveTeamBtnShow() then
        self:setObjectVisible("weapon_node", false)
    end
    self:setTogText(1)
    self:updateMultiFormationBtnLoopScroll()
    self:refreshBuzhenRedPoint()
    self:refreshFormationSkipBattleBtn()
    self:initUnionWarUi()
    self:setTextByLanKey("wea_tips_text", "game_panel_5")
    self:setTextByLanKey("bottom_return_text", "new_str_0006")
    self:setTextByLanKey("pet_bottom_return_text", "new_str_0006")
    self:setTextByLanKey("sz_duizhandi", "new_str_0297")
    self:setTextByLanKey("buzhen_btn_text", "buzhen_btn_tex")
    self:setTextByLanKey("array_btn_text", "array_btn_tex")
    self:setTextByLanKey("main_bd_btn_text", "UnionWar_str_005")
    self:setTextByLanKey("txt_t1", "jg_team_text",1)
    self:setTextByLanKey("txt_t2", "jg_team_text",2)
    self:setTextByLanKey("txt_t3", "jg_team_text",3)
    self:setTextByLanKey("txt_status1", "UnionWar_str_095")
    self:setTextByLanKey("txt_status2", "UnionWar_str_095")
    self:setTextByLanKey("txt_status3", "UnionWar_str_095")
    self:setTextByLanKey("txt_test_battle", "mn_tz_text")
    self:setTextByLanKey("difficulty_title_text", "UnionWar_str_105")
    self:setTextByLanKey("pet_tips_text", "new_str_1106")
    self:updateRaceToggle() -- 刷新种族标签
    --self:initCreatHerosByActiveHeavenHeros()
    self:setObjectVisible("pet_node", false)
    --self:setObjectVisible("pet_node", self.m_model:showPets() == true)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        self:setTextByLanKey("pet_tips_text", "settlement_pet_0003")
        self:setObjectVisible("heroBuff", false)
        self:setObjectVisible("enemyBuff", false)
    else
        self:setObjectVisible("heroBuff", true)
        self:setObjectVisible("enemyBuff", true)    
    end
    self:refreshCombatSuppressSystem()
    self:refreshZFLianSaiView()
    --助战系统
    self:initSupportNode()
end

--助战提示
function M:initSupportNode()
    self.timer_id =self.m_control:setOnceTimer(2,function()
        local visible=self.m_model:heroIsInsupport()
        self:setObjectVisible("support_node",visible)
        if visible then
            self.support_btn_trans=self:findGameObject("support_icon").transform
        end
        self.timer_id=nil
    end)
end

function M:initNodeVisible()
    for k, v in pairs(__UNION_WAR_RED_POINT_IMAGE) do
        self:setObjectVisible(v, false)
    end
    local addition_panel = self:findGameObject("addition_panel")
    addition_panel:SetActive(false)
    
    local gu_jian_team_mult_flag = true
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        gu_jian_team_mult_flag = self.m_model.m_team_nums > 1
    end
    self:setObjectVisible(
            self.prefix .. "mult_team_toggles",
            self.m_model.m_mult_team_flag 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.MINING_DEFENSE 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.UNIONWAR
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE_MINING_DEFENSE
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ONE
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE
                    and gu_jian_team_mult_flag
    )
    self:setObjectVisible(
            self.prefix .. "mine_team_toggle",
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE
    )
    self:setObjectVisible(self.prefix .. "mine_team_toggle",false)
    local showNode = self.m_model:showMultiFormationNodeFlag()
    self:setObjectVisible("multi_formation_node", showNode)
    self:setObjectVisible("save_btn", false)
    self:setObjectVisible("bottom_return", true)
    self:setObjectVisible("bottom_return_text", true)
    self:setObjectVisible(DEP_EF_NAME, false)
    self:setObjectVisible("bottom_herolist_obj", false)
    self:setObjectVisible("bottom_petlist_obj", false)
    self:setObjectVisible(self.prefix .. "start_btn", not(self.m_model:getSaveTeamBtnShow()))
    self:setObjectVisible(self.prefix .. "start_btn_text",  not(self.m_model:getSaveTeamBtnShow()))
    self:setObjectVisible(self.prefix .. "sz_duizhandi", self.m_model:isShowEnemyUI())
    self:setObjectVisible(self.prefix .. "enemyBuff", self.m_model:isShowEnemyUI())
    self:setObjectVisible("hint_btn2", self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.RAID and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI)
    self:setObjectVisible("stage_bg", self.m_model:checkShowStageName())
    self:setObjectVisible("stage_name", self.m_model:checkShowStageName())
    self:setObjectVisible("high_arena_btn", self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI )
    self:setObjectVisible("exit_story_btn", self.m_control:isStoryLevel())
    self:setObjectVisible("actower_add_node", self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER and self.m_model:getActowerDes() ~= "" )
    if self.m_model:getSaveTeamBtnShow() then
        self.m_model.m_bottom_type = 1
        self:switchBottomObjType()
        self:setObjectVisible("skip_select_node", false)
    else
        self:setObjectVisible("buzhen_btn", true)
        self:setObjectVisible("buzhen_btn_text", true)
        local show_skip_btn = self.m_model:showFormationSkipBtn()
        self:setObjectVisible("skip_select_node", show_skip_btn)
    end

    self:setObjectVisible("stage_bg", self.m_model.m_layer~=nil)
    self:setObjectVisible("stage_name", self.m_model.m_layer~=nil)
end

function M:refreshMultTeamToggles(is_show)
    local gu_jian_team_mult_flag = true
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        gu_jian_team_mult_flag = self.m_model.m_team_nums > 1
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        self:setObjectVisible(self.prefix .. "mult_team_toggles", is_show and gu_jian_team_mult_flag)
    end
end

function M:initLabelDes()
    self:setTextByLanKey("skip_select_text","new_str_0900")
    self:setTextByLanKey("combat_add_text", "new_str_0175")
    --生命
    self:setTextByLanKey("hp_add_name", "fb_str_0027")
    --攻击
    self:setTextByLanKey("dps_add_name", "fb_str_0028")
    --孤军深入
    self:setTextByLanKey("add_des_name", "fb_str_0030")
    self:setText(self.prefix .. "hero_combat_num", self.m_model:getHeroCombat())
    self:setText(self.prefix .. "enemy_combat_num", self.m_model:getEnemyCombat())
    self:setTextByLanKey(self.prefix .. "save_btnss_text", "new_str_0290")
    if self.m_model:checkShowStageName() == true then
        local curLevel = UserDataManager:getBattleStage()
        if curLevel > 6 and (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) then
            self:setTextByLanKey("stage_name",Language:getTextByKey("new_str_0124") .. " " .. self.m_model:getStageBattleName())
        else
            self:setTextByLanKey("stage_name", self.m_model:getStageBattleName())
        end
    end

    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
        self:setTextByLanKey("act_tower_des_text", self.m_model:getActowerDes())
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
        self:setTextByLanKey("stage_name","new_str_1131",self.m_model.m_layer)
    end

end

function M:refreshBuzhenRedPoint()
    if
    self.m_model.m_data.apostles and self.m_model.m_data.apostles.novice_hero and
            next(self.m_model.m_data.apostles.novice_hero) ~= nil
    then
        self:setObjectVisible("buzhen_btn_red", true)
        self:setObjectVisible("shangzhen_red", false)
    elseif
    self.m_model.m_data.apostles and self.m_model.m_data.apostles.bio_hero and
            next(self.m_model.m_data.apostles.bio_hero) ~= nil
    then
        self:setObjectVisible("buzhen_btn_red", true)
        self:setObjectVisible("shangzhen_red", false)
    else
        self:setObjectVisible("buzhen_btn_red", false)
        self:setObjectVisible("shangzhen_red", self.m_model:isHaveInToHero() == true)
    end
end

function M:initRelicInfoNode()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
        --五行阵遗物加成
        self:setObjectVisible(self.prefix .. "relic_info_node", false)
        self:setObjectVisible(self.prefix .. "relic_info_node_text", false)
        local heirloom_num = GameUtil:getHeirloomNum(self.m_model.m_heirlooms)
        for k, v in pairs({7, 5, 3}) do
            local heirloom_num_item = heirloom_num[v] or {}
            self:setTextByLanKey(self.prefix .. "relic_num_text_" .. k, tostring(heirloom_num_item.num or 0))
        end
        local addition_panel = self:findGameObject(self.prefix .. "addition_panel")
        addition_panel:SetActive(false)
        local add_value, _ = self.m_model:getHeirloomCombatAddRatio()
        self:setText("combat_add_value_text", string.format("+%0.2f%%", add_value * 100))
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
        --addition_panel:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), height)
        self:setObjectVisible(self.prefix .. "relic_info_node", false)
        self:setObjectVisible(self.prefix .. "relic_info_node_text", false)
        self:setTextByLanKey(self.prefix .. "addition_text", "world_boss_str_0008")
        --addition_panel:SetActive(true)
        local race_panel = self:findGameObject(self.prefix .. "race_panel")
        local num = race_panel.transform.childCount
        local height = 150
        for i = 1, num do
            local race_img = race_panel.transform:GetChild(i - 1)
            if i <= #self.m_model.m_addition_race then
                race_img.gameObject:SetActive(true)
                local rece_cfg = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_addition_race[i]]
                UIUtil.setImg(race_img, rece_cfg.big_race_icon, ResourceUtil:getLanAtlas(), "icon")
                height = height + 65
            else
                race_img.gameObject:SetActive(false)
            end
        end
    else
        self:setObjectVisible(self.prefix .. "relic_info_node", false)
        self:setObjectVisible(self.prefix .. "relic_info_node_text", false)
        local addition_panel = self:findGameObject(self.prefix .. "addition_panel")
        addition_panel:SetActive(false)
    end
end

function M:initRacesTabBtn()
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        local lan_text = "advanced_str_0011"
        if i > 1 then
            lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
            local have_hero = self.m_model:checkRaceTypeCount(v.race)
            local trans = UIUtil.findImage(tog_btn.gameObject.transform, "Image")
            if have_hero then
                trans.material = nil
            end
            tog_btn.interactable = have_hero
        else
            lan_text = Language:getTextByKey("new_str_0065") 
        end
        self:setTextByLanKey(v.name, lan_text)
        UIUtil.addToggleListener(
                tog_btn,
                function(is_on, data)
                    if is_on then
                        self.m_race = data - 1
                        self:setTogText(data)
                        self:updateLoopScroll(false)
                    end
                end,
                i,
                self.m_uiName
        )
    end
end

function M:initMultTabBtn()
    if self.m_model.m_mult_team_flag then
        self.m_toggle_btns = {}
        for k, v in pairs(__MULT_TEAM_TAB_BTN) do
            self:setTextByLanKey(v.btn_text, v.text_key)
            self:setObjectVisible(v.btn_key, k <= 3)
            self:setObjectVisible(v.btn_img_name, k<=3)
            local tog_btn = self:findToggle(v.btn_key)
            self.m_toggle_btns[k] = tog_btn
            tog_btn.isOn = k == self.m_model.m_formation_index
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
                    or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
            then
                self:setObjectVisible(v.btn_key, k <= self.m_model.m_team_nums)
                self:setObjectVisible(v.btn_img_name,  k <= self.m_model.m_team_nums)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR or
                    self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION or
                    self.m_model.m_mode ==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
                    self.m_model.m_mode ==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL then
                self:setObjectVisible(v.btn_key, k <= self.m_model.m_team_nums)
                self:setObjectVisible(v.btn_img_name,  k <= self.m_model.m_team_nums)
            elseif ( self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA) and k == 3 then
                self:setObjectVisible(v.btn_key, false)
                self:setObjectVisible(v.btn_img_name, false)
            end
            UIUtil.addToggleListener(tog_btn, function(is_on)
                if is_on then
                    self:updateMsg("mult_team_click", k)
                end
            end,nil,self.m_uiName)
        end
    end
end

function M:initUnionMultTabBtn()
    if self.m_model:showUnionWarTeamsMultBtn() then
        self.m_unionwar_attack_toggle_btns = {}
        local function __guildwar_isTeamAtk(idx)
            if self.m_model == nil or self.m_model.m_params.gvg_data == nil then
                return false
            end
            local atk_use = self.m_model.m_params.gvg_data.atk_use
            if atk_use and next(atk_use) then
                for k, v in pairs(atk_use) do
                    if v == idx then
                        return true
                    end
                end
            end

            return false
        end

        for k, v in pairs(__UNION_WAR_ATTACK_BTN) do
            local tog_btn = self:findToggle(v.btn_key)
            self.m_unionwar_attack_toggle_btns[k] = tog_btn
            if k == self.m_model.m_formation_index then
                tog_btn.isOn = true
            end
            UIUtil.addToggleListener(
                    tog_btn,
                    function(is_on)
                        if is_on and not __guildwar_isTeamAtk(k) then
                            self:updateMsg("mult_team_click", k)
                        end
                    end,
                    nil,
                    self.m_uiName
            )
        end
    end
end

function M:initMiningMultTabBtn()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE then
        self.m_mining_toggle_btns = {}
        for k, v in pairs(_MINING_TAB_BTN) do
            local tog_btn = self:findToggle(v.btn_key)
            self.m_mining_toggle_btns[k] = tog_btn
            local open_id = v.open_id
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_id)
            self:setObjectVisible(v.btn_key, open_flag)
            if k == self.m_model.m_formation_index then
                tog_btn.isOn = true
            end
            local races = GameUtil:getRacesByRegionId(k)
            local img_path = races and GlobalConfig.MINING_RACE_ICON[races[1]].name or ""
            self:setImg(img_path, ResourceUtil:getLanAtlas(), "background" .. k)
            UIUtil.addToggleListener(
                    tog_btn,
                    function(is_on)
                        if is_on then
                            self:updateMsg("mining_tab_click", k)
                        end
                    end,
                    nil,
                    self.m_uiName
            )
        end
    end
end

function M:initUnionWarUi()
    self:setObjectVisible("guildwar_top_node", false)
    self:setObjectVisible("guildwar_tog_test", false)
    self:setObjectVisible("guildwar_bottomleft_node", false)
    self:setObjectVisible("guildwar_reward_bgd", true)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
        self:showUnionWarTeamTog(true)
        self:setObjectVisible("guildwar_top_node", true)
        self:setObjectVisible("guildwar_reward_bgd", false)
        self:setObjectVisible("star_info", false)
        self:setObjectVisible("bgd_test_count", true)
        self:setObjectVisible("guildwar_tog_test", true)

        self.m_model.m_def_data.star = self.m_model.m_GVGstar
        self.m_model.m_difficulty = 0

        local btn_pull = self:findButton("btn_pull")
        UIUtil.setButtonClick(btn_pull,function()
            local difficulty = self.m_model.m_difficulty == 0 and 1 or 0
            self.m_model.m_difficulty = difficulty
            self:refreshGVGDifficulty()
        end)
        self:refreshGVGDifficulty()

        for i = 1, 3 do
            local btn_name = "change_di_"..i
            local btn = self:findButton(btn_name)
            UIUtil.setButtonClick(btn,function()
                audio:SendEvtUI("UI_Star_Change")
                self.m_model.m_def_data.star = i
                self:refreshGVGStar()
            end)
        end
        self:refreshGVGStar()

        for i = 1, 3 do
            local btnName = "img_star_bg_" .. i
            local btn = self:findButton(btnName)
            UIUtil.setButtonClick(
                    btn,
                    function()
                        audio:SendEvtUI("UI_Star_Change")
                        self.m_model.m_def_data.star = i
                        self:refreshGVGStar()
                    end
            )
        end
        self:refreshGVGUI()
        -- local tog = self:findToggle("guildwar_tog_test")
        -- UIUtil.addToggleListener(
        --         tog,
        --         function(is_on)
        --             UserDataManager.local_data:setUserDataByKey("simulated_battle_flag", is_on)
        --         end,
        --         nil,
        --         self.m_uiName
        -- )
    else
        self:setObjectVisible("bgd_test_count", false)
    end

end

--设置公会战难度
function M:refreshGVGDifficulty()
    local difficulty_item = self:findGameObject("difficulty_di")
    local difficulty_change = self:findGameObject("difficulty_change_di")
    local difficulty = self:findGameObject("difficulty")
    local rect = difficulty:GetComponent("RectTransform")
    difficulty_item:SetActive(self.m_model.m_difficulty == 0)
    difficulty_change:SetActive(self.m_model.m_difficulty ~= 0)
    local rece_height = self.m_model.m_difficulty == 0 and 65 or 165
    rect.sizeDelta = Vector2(rect.rect.width, rece_height)
    local handle_point = self.m_model.m_difficulty == 0 and "a_ui_currency_xiala" or "a_ui_currency_shouqi"
    self:setImg(handle_point,"common_ui","btn_pull")
end

function M:refreshGVGUI()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
        local issim = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
        self:setObjectVisible("guildwar_tog_close", issim == false)
        self:setObjectVisible("guildwar_tog_open", issim == true)

        -- local def_data = self.m_model.m_params.def_data
        local atk_use = self.m_model.m_params.gvg_data.atk_use
        for i = 1, 3 do
            local gameObj = self:findGameObject("tx_mask_" .. i)
            gameObj:SetActive(false)
        end
        local tog = self:findGameObject("guildwar_tog_test") 
        local locPos = tog.transform.localPosition
        locPos.x = 180
        
        if atk_use and next(atk_use) then
            self:findGameObject("buzhen_btn"):SetActive(false)
            self:findGameObject("buzhen_btn_text"):SetActive(false)
            self:setObjectVisible("weapon_node", false)
            locPos.x = 300
    

            for k, v in pairs(atk_use) do
                -- atk_use
                local gameObj = self:findGameObject("tx_mask_" .. v)
                gameObj:SetActive(true)
            end
        end
        tog.transform.localPosition = locPos
    end
end

function M:refreshGuildWarTogSelect(bl)
    UserDataManager.local_data:setUserDataByKey("simulated_battle_flag", bl)
    self:setObjectVisible("guildwar_tog_close", bl == false)
    self:setObjectVisible("guildwar_tog_open", bl == true)
end

function M:refreshGVGStar()
    for i = 1, 3 do
        local imgName = "img_star_" .. i
        local img = self:findGameObject(imgName)
        img:SetActive(i <= self.m_model.m_def_data.star)
    end

    
    
    self:setObjectVisible("guildwar_reward_bgd", true)
    self:setObjectVisible("star_pos", false)

    local cmCfg = ConfigManager:getCfgByName("common")
    local difficultSetting = cmCfg[490]
    local scaleNum = difficultSetting.value[self.m_model.m_def_data.star]
    local addVal = scaleNum - 100
    local txtInfo = Language:getTextByKey("UnionWar_rewardInfo") .. addVal .. "%"
    self:setText("txt_reward", txtInfo)

    local bufSetting = cmCfg[498]
    local enemybuf = bufSetting.value[self.m_model.m_def_data.star]

    -- local s1 =
    -- enemybuf[1]
    local function _getDisVal(dv)
        local val = dv - 100
        local s1 = " 0%"
        if val > 0 then
            s1 = "+" .. val .. "%"
        elseif val < 0 then
            s1 = val .. "%"
        end
        return s1
    end

    local txtInfo2 = Language:getTextByKey("UnionWar_enemyBuf", _getDisVal(enemybuf[1]), _getDisVal(enemybuf[2]))
    self:setText("txt_starinfo", txtInfo2)
    self:setObjectVisible("star_info", false)

    self:setTextByLanKey("difficulty_name",Language:getTextByKey("UnionWar_str_102",self.m_model.m_def_data.star))
    self:setTextByLanKey("enemyHf_name",Language:getTextByKey("UnionWar_str_103",_getDisVal(enemybuf[1])))
    self:setTextByLanKey("enemyAfk_name",Language:getTextByKey("UnionWar_str_103",_getDisVal(enemybuf[2])))
    for i = 1, 3 do
        local difficulty_name = "difficulty_name_"..i
        local difficulty_hf = "enemyHf_name_"..i
        local difficulty_akf = "enemyAfk_name_"..i
        local enemyAndbuf = bufSetting.value[i]
        self:setTextByLanKey(difficulty_name,Language:getTextByKey("UnionWar_str_102",i))
        self:setTextByLanKey(difficulty_hf,Language:getTextByKey("UnionWar_str_103",_getDisVal(enemyAndbuf[1])))
        self:setTextByLanKey(difficulty_akf,Language:getTextByKey("UnionWar_str_103",_getDisVal(enemyAndbuf[2])))
        local ok_img_name = "change_gou_"..i
        local ok_img = self:findGameObject(ok_img_name)
        ok_img:SetActive(i == self.m_model.m_def_data.star)
        local star_name = "difficulty_star_"..i
        if i > self.m_model.m_def_data.star then
            self:setImg("a_ui_currency_xing_di","common_ui",star_name)
        else
            self:setImg("a_bh_xing","active_ui",star_name)
        end
    end


    local gw_map = ConfigManager:getCfgByName("gw_map")
    local def_data = self.m_model.m_params.def_data

    local rwds = gw_map[def_data.cell_id].reward
    local newRwd = table.copy(rwds)

    for k, v in pairs(newRwd) do
        v[3] = math.floor(scaleNum * 0.01 * rwds[k][3])
    end

    local rwdNodes = self:findGameObject("pos_reward")
    GameUtil:createGiftRewards(rwdNodes.transform, newRwd, true, true, nil, 0.6)

   self:refreshRemainMockTimesText()

end

function M:refreshRemainMockTimesText()
    local remainMockTime = self.m_model.m_params.gvg_data.remain_mock_times
    self:setTextByLanKey("txt_test_count", "UnionWar_test_counts", remainMockTime or 0)
end

function M:refreshRacesIcon()
    if self.m_model.m_races ~= nil and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.MINING_DEFENSE
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.MINING
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE_MINING
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE_MINING_DEFENSE
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.WD_TOWER 
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.GVE_BATTLE 
            and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
        local shili_obj =  self:setObjectVisible("shili_root", true)
        self:setObjectVisible("shili1", false);
        self:setObjectVisible("shili2", false);
        self:setObjectVisible("shili3", false);
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD_DEFENSE then
            self:setTextByLanKey("shili_name","huashan_sword_text0014")
        else
            self:setTextByLanKey("shili_name","new_str_0752")
        end
        for i, v in ipairs(self.m_model.m_races) do
            if v ~= 7 then
                self:setObjectVisible("shili"..i, true);local race_img_info = GlobalConfig.TYPE_HERO_RACE[v];
                LuaBehaviourUtil.setImg(self.m_luaBehaviour, "shili"..i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
            end              
        end
        --由于新增了战力压制  对于不是PVP 将种族的位置上移
        local pos1 = Vector3.New(51.4,220.5,0)
        local pos2 = Vector3.New(51.4,140.5,0)
        if self.m_model:getPVPFlag() then
            shili_obj.transform.localPosition = pos2
        else
            shili_obj.transform.localPosition = pos1
        end
    elseif self.m_model.m_addition_race ~= nil and self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then --只有推荐阵营时 要显示势力加成提示 此功能暂时用在剑试天下boss战
        self:setTextByLanKey("shili_name","boss_fight_main_text_009")   --势力加成
        self:setRacesIcon(self.m_model.m_addition_race)
    else
        self:setObjectVisible("shili_root", false)
    end
end

function M:setRacesIcon(races)
    self:setObjectVisible("shili1", false);
    self:setObjectVisible("shili2", false);
    self:setObjectVisible("shili3", false);
    local shili_obj =  self:setObjectVisible("shili_root", true)
    for i, v in ipairs(races) do
        if v then   --不排除任何势力侠客
            self:setObjectVisible("shili"..i, true);local race_img_info = GlobalConfig.TYPE_HERO_RACE[v];
            LuaBehaviourUtil.setImg(self.m_luaBehaviour, "shili"..i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
        end
    end
    
    local pos1 = Vector3.New(51.4,220.5,0)
    local pos2 = Vector3.New(51.4,140.5,0)
    if self.m_model:getPVPFlag() then
        shili_obj.transform.localPosition = pos2
    else
        shili_obj.transform.localPosition = pos1
    end
end

function M:updateRaceToggle()
    for i, v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        if i > 1 then
            local have_hero = self.m_model:checkRaceTypeCount(v.race)
            local trans = UIUtil.findImage(tog_btn.gameObject.transform, "Image")
            if have_hero then
                trans.material = nil
            else
                trans.material = self.m_gray_image.material
            end
            tog_btn.interactable = have_hero
        end
    end
end

function M:refreshUI()
    if self.m_model.m_races ~= nil then
        self:updateLoopScrollRaces(self.m_model.m_races)
    else
        self:updateLoopScroll()
    end
    --self:updatePetLoopScroll()
    --self:refreshPetUI()
    self:updateAddValue()
    self:setBtnStatus()
    self:updateDeployment()
    local show_array_btn = self.m_model.m_bottom_type == 0 and self.m_model:showArrayBtn() == true
    self:setObjectVisible("array_btn", show_array_btn)
    self:setObjectVisible("array_btn_text", show_array_btn)
    self:setTextByLanKey("mercenary_itmes_text", "new_str_0623", self.m_model.novice_times)
    self:setObjectVisible("mercenary_itmes_bg_img", self.m_model.novice_times > 0)

    self:refreshRedPoint()
    self:race_tower_HeroNum()
    self:updateWeaNode()
    self:updateUnionWarSelectTeamTog()
    self:updateHeavenUI()
    self:updateCombatRepressLevel()
end

--争锋联赛限制显示初始化
function M:iniZFLianSaiLimit()
    self.limit_icon_trans=self:findGameObject("limit_icon").transform
    self:setImg( self.m_model.m_limit_cfg.rule_icon,"arena_ui","limit_icon")
end

--刷新英雄禁用相关显示
function M:refreshZFLianSaiView()
    if self.m_model.m_races ~= nil then
        self:updateLoopScrollRaces(self.m_model.m_races)
    else
        self:updateLoopScroll()
    end
    self:refreshZFLianSaiLimit()
    self:refreshForbiddenHero()
end

function M:updateAddValue()
    local openAddValue = false
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE 
    or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS 
    or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        local hp_rate = self.m_model.m_server_hp_coef - 100
        local dps_rate = self.m_model.m_server_dps_coef - 100
        if hp_rate > 0 then
            openAddValue = true
            self:setText("hp_add_value", "+" .. hp_rate .. "%")
            self:setText("dps_add_value", "+" .. dps_rate .. "%")
        end
    else
        openAddValue = false
    end
    self:setObjectVisible("add_value_bg", openAddValue)
    self:setObjectVisible("add_des_bg", openAddValue)
    self:setObjectVisible("add_value_info_btn", openAddValue)
    self:setObjectVisible("add_des_name", openAddValue)
    self:setObjectVisible("hp_add_name", openAddValue)
    self:setObjectVisible("hp_add_value", openAddValue)
    self:setObjectVisible("dps_add_name", openAddValue)
    self:setObjectVisible("dps_add_value", openAddValue)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE then
        self:setTextByLanKey("add_des_name", "fb_str_0030")
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
        self:setTextByLanKey("add_des_name", "fb_str_0033")
    end
end

function M:refreshRedPoint()
    if
        self.m_model.m_data.apostles and self.m_model.m_data.apostles.novice_hero and
            next(self.m_model.m_data.apostles.novice_hero) ~= nil
     then
        self:setObjectVisible("buzhen_btn_red", true)
        self:setObjectVisible("shangzhen_red", false)
    elseif
        self.m_model.m_data.apostles and self.m_model.m_data.apostles.bio_hero and
            next(self.m_model.m_data.apostles.bio_hero) ~= nil
     then
        self:setObjectVisible("buzhen_btn_red", true)
        self:setObjectVisible("shangzhen_red", false)
    else
        self:setObjectVisible("buzhen_btn_red", false)
        self:setObjectVisible("shangzhen_red", self.m_model:isHaveInToHero() == true)
    end
    self:refreshUnionWarTeamRedPoint()
    --self:refreshMiningDefenseTeamRedPoint()
end

function M:refreshUnionWarTeamRedPoint()
    --公会战编队
    if self.m_model:isUnionWarTeams() then
        for k, v in pairs(self.m_model.union_war_teams) do
            self:refreshUnionWarOneTeamRedPoint(v.team, k)
        end
    end
end

function M:refreshUnionWarSelectTeamRedPoint()
    self:refreshUnionWarOneTeamRedPoint(self.m_model.main_team, self.m_model.m_formation_index)
end

function M:refreshUnionWarOneTeamRedPoint(team, index)
    --公会战编队
    if self.m_model:isUnionWarTeams() then
        team = team or {}
        local show_red_point = false
        for i = 1, 5 do
            local val = team[i]
            if val == nil or val == "" then
                show_red_point = true
                break
            end
        end
        local union_war_red_point_img = __UNION_WAR_RED_POINT_IMAGE[tonumber(index)]
        self:setObjectVisible(union_war_red_point_img, show_red_point)
    end
end

function M:refreshMiningDefenseTeamRedPoint()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE then
        for k, v in pairs(self.m_model.mining_defense_teams) do
            local has_nomember = false
            for i = 1, 5 do
                if not v[i] or (v[i] and v[i] == "") then
                    has_nomember = true
                    break
                end
            end
            local mining_defense_red_point_img = _MINING_RED_POINT_IMAGE[tonumber(k)]
            self:setObjectVisible(mining_defense_red_point_img, has_nomember)
        end
    end
end

function M:setTogText(index)
    local col = Color.New((252 / 255), (255 / 255), (242 / 255), 1)
    local col2 = Color.New((166 / 255), (209 / 255), (209 / 255), 1)
    for k, v in pairs(__TAB_BTN_NODE) do
        local text = self:findText(v.name)
        local btn = self:findGameObject(v.btn)
        if index == k then
            text.color = col
        else
            text.color = col2
        end
    end
end

function M:nextBtnStatus()
    if self.m_model.m_mult_team_flag then
        if self.m_model.m_formation_index < self.m_model.m_team_nums then
            self.m_toggle_btns[self.m_model.m_formation_index + 1].isOn = true
        end
    end
end

function M:setBtnStatus()
    if self.m_model:showUnionWarTeamsMultBtn() then
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
            self:setTextByLanKey(self.prefix .. "start_btn_text", "new_str_0291")
        else
            self:setTextByLanKey(self.prefix .. "start_btn_text", "new_str_0290")
        end
    elseif self.m_model.m_mult_team_flag then    
        if self.m_model.m_formation_index < self.m_model.m_team_nums then
            self:setTextByLanKey(self.prefix.."start_btn_text", "new_str_0292")	
            self:setTextByLanKey(self.prefix.."save_btnss_text", "new_str_0292")	
        elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
            self:setTextByLanKey(self.prefix.."start_btn_text", "new_str_0290")
        else
            self:setTextByLanKey(self.prefix .. "start_btn_text", "new_str_0291")
            self:setTextByLanKey(self.prefix .. "save_btnss_text", "new_str_0290")
        end
    else
        self:setTextByLanKey(self.prefix .. "start_btn_text", "new_str_0291")
    end
end

function M:resetHeroCombat()
    local combat = self.m_model:getHeroCombat()
    self:setText(self.prefix.."hero_combat_num",combat)
    self:setText(self.prefix.."enemy_combat_num",self.m_model:getEnemyCombat())
    if self.m_model.temp_combat ~= 0 and self.m_model.temp_combat ~= combat then
        local prent = self:findGameObject("sz_duizhandi")
        local ex = self:creatEffect("UI_Formation_GuaJi_001", prent)
        self:setParticleRenderOrder(ex)
        self.m_control:setOnceTimer(
            2,
            function()
                U3DUtil:Destroy(ex)
            end
        )
    end
    self.m_model.temp_combat = combat
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("Formation/" .. tx_name, prent)
    --item.transform:SetParent(prent.transform, false)
    return item
end

function M:updateLoopScrollRaces(races, keep_offset)
    if keep_offset == nil then
        keep_offset = true
    end
    HERO_LIST = {}

    if self.m_race == 0 then
        if self.m_model.m_races ~= nil then
            self.m_model:getHeroByRaces(self.m_model.m_races)
        else
            self.m_model:getHeroByRace(self.m_race)
        end
    else
        self.m_model:getHeroByRace(self.m_race)
    end

    -- self.m_model:getHeroByRaces(races)
    local data = self.m_model.Filtrate_list
    if self.is_horizontally == false then
        if next(data) == nil then
            self:setObjectVisible("hero_node_obj", true)
            self:setTextByLanKey("hero_node_text", "new_str_0356")
        else
            self:setObjectVisible("hero_node_obj", false)
        end
    end

    if self.m_loop_scroll_view == nil then
        local loopscroll = nil
        local prefab_name = "Common/HeroNode"
        self.m_hero_is_big = false
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
            loopscroll = self:findGameObject("loopscroll_maze_stage")
            if loopscroll == nil then
                loopscroll = self:findGameObject("loopscroll")
                loopscroll:SetActive(true)
            else
                self:setObjectVisible("loopscroll", false)
            end
            prefab_name = "Common/HeroNode2"
            self.m_hero_is_big = true
        else
            loopscroll = self:findGameObject("loopscroll")
            self:setObjectVisible("loopscroll_maze_stage", false)
        end
        loopscroll:SetActive(true)
        local h_params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                HERO_LIST[cell_object] = cell_data
                self:updateHeroContent(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_card", {heroid = cell_data})
            end
            --prefab_name = prefab_name
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(h_params)
    else
        self.m_loop_scroll_view:reloadData(data, keep_offset)
    end
end

--[[
	英雄列表
]]
function M:updateLoopScroll(keep_offset)
    if keep_offset == nil then
        keep_offset = true
    end
    HERO_LIST = {}
    --点击全部
    if self.m_race == 0 then
        if self.m_model.m_races ~= nil then
            self.m_model:getHeroByRaces(self.m_model.m_races)
        else
            self.m_model:getHeroByRace(self.m_race)
        end
    else
        self.m_model:getHeroByRace(self.m_race)
    end

    local data = self.m_model.Filtrate_list
    if self.is_horizontally == false then
        if next(data) == nil then
            self:setObjectVisible("hero_node_obj", true)
            self:setTextByLanKey("hero_node_text", "new_str_0356")
        else
            self:setObjectVisible("hero_node_obj", false)
        end
    end

    if self.m_loop_scroll_view == nil then
        local loopscroll = nil
        local prefab_name = "Common/HeroNode"
        self.m_hero_is_big = false
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
            loopscroll = self:findGameObject("loopscroll_maze_stage")
            if loopscroll == nil then
                loopscroll = self:findGameObject("loopscroll")
                loopscroll:SetActive(true)
            else
                self:setObjectVisible("loopscroll", false)
            end
            prefab_name = "Common/HeroNode2"
            self.m_hero_is_big = true
        else
            loopscroll = self:findGameObject("loopscroll")
            self:setObjectVisible("loopscroll_maze_stage", false)
        end
        loopscroll:SetActive(true)
        local h_params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                HERO_LIST[cell_object] = cell_data
                self:updateHeroContent(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_card", {heroid = cell_data})
            end
            --prefab_name = prefab_name
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(h_params)
    else
        self.m_loop_scroll_view:reloadData(data, keep_offset)
    end
end


--宠物列表
function M:updatePetLoopScroll()
    local data = self.m_model.m_formation_pets or {}
    if self.m_pet_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("pet_loopscroll")
        local h_params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updatePetContent(cell_object,cell_data,index)
            end,
        }
        self.m_pet_loop_scroll_view = LoopScrollViewUtil.new(h_params)
    else
        self.m_pet_loop_scroll_view:reloadData(data, true)
    end
end

--更新宠物卡片
function M:updatePetContent(obj, petOid, cell_index)
    local pet_data, pet_cfg = self.m_model:getPetData(petOid)
    GameUtil:updatePetContentByData(obj, pet_data, nil, self.m_model.m_mode)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj) 
    if luaBehaviour then
        local yishangzhen = luaBehaviour:FindGameObject("battle_img") --已上阵
        local duigoudi_img = luaBehaviour:FindGameObject("duigou_img") --对勾
        local lock_image = luaBehaviour:FindGameObject("lock_img") --锁
        local mask_img = luaBehaviour:FindGameObject("mask_img") --
        local recommend_img = luaBehaviour:FindGameObject("recommend_img") -- 推荐
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sp_img", false)
     
        local pet_type_img = luaBehaviour:FindGameObject("pet_type_img")
        local in_team_flag = self.m_model:checkPetIsInTeam(petOid) --其他队伍上阵本宠物 仅适用于多阵容
        local samename_flag = self.m_model:checkSameNmaePetIsInTeam(petOid)  --所有队伍中是否已有同类型宠物 （已排除自己）
        local scrollRectClick = luaBehaviour.gameObject:GetComponent("ScrollRectClick")
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
            duigoudi_img:SetActive(self.m_model:checkPetIsInTeamByPetOid(petOid) == true)
        else
            duigoudi_img:SetActive(self.m_model:getCurPet() == petOid)
        end

        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
            lock_image:SetActive(self.m_model:checkPetIsInTeamByPetDouji(petOid) == true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lock_text","pet_evo_lv_0023")
        else
            lock_image:SetActive(in_team_flag == true or  samename_flag == true)
            if in_team_flag == true then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lock_text","pet_evo_lv_0022")
            elseif samename_flag == true then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lock_text","pet_evo_lv_0023")
            end
        end

        if scrollRectClick then
            local btn = luaBehaviour.gameObject:GetComponent("Button")
            btn.enabled = false
            scrollRectClick.index = cell_index
            local show_look_tips = false
            scrollRectClick:RegistClickCallBack(
                function(click_type, index)
                    if click_type == 2 then
                        if show_look_tips == false then
                            show_look_tips = true
                            local parms = {}
                            parms.click_transform = pet_type_img.transform
                            parms.top = true
                            parms.right = true
                            parms.pet_id = petOid
                            parms.delay_open = 0.1
                            parms.m_mode = self.m_model.m_mode
                            parms.finish = function ()
                                show_look_tips = false
                            end
                            GameUtil:lookPetInfoTips(self.m_control, parms)
                        end
                    else
                        if in_team_flag == true or  samename_flag == true then
                            return
                        end
                        self:updateMsg("click_pet_card", petOid)
                    end
                end
            )
        end
    end
end


function M:refreshPetUI()
    local pet_cell = self:findGameObject("pet_cell")
    local luaBehaviour = UIUtil.findLuaBehaviour(pet_cell)
    local cur_pet = self.m_model:getCurPet()
    if cur_pet == 0 or cur_pet == "" then --
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
    else
        local data, cfg =  self.m_model:getPetData(cur_pet)
        if cfg then
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", cfg.icon, "item_icon")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_img", true)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)   
        end
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE then
        UIUtil.setLocalPosition(pet_cell.transform, 100,-275,0)
    else
        UIUtil.setLocalPosition(pet_cell.transform, -50,-297,0)    
    end
end


function M:updatePlayShangZhenEffect(oid)
    for k, v in pairs(HERO_LIST) do
        if v == oid then
            local luaBehaviour = k:GetComponent("LuaBehaviour")
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Formation_ShangZhen_001", true)
                self.m_control:setOnceTimer(
                    0.5,
                    function()
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Formation_ShangZhen_001", false)
                    end
                )
            end
        end
    end
end

--更新所有卡牌状态
function M:updateAllState()
    for k, v in pairs(HERO_LIST) do
        local luaBehaviour = k:GetComponent("LuaBehaviour")
        local duigoudi_img = luaBehaviour:FindGameObject("battle_img")
        duigoudi_img:SetActive(false)
    end
    self:resetHeroCombat()
end

--更新某个卡牌状态
function M:updateCellState(id, bool)
    local obj = HERO_LIST[id]
    local cur_data, cur_cfg = self.m_model:getHero(id)
    for k, v in pairs(HERO_LIST) do
        local h_data, h_cfg = self.m_model:getHero(v)
        if cur_data == h_data and cur_cfg == h_cfg then
            local luaBehaviour = k:GetComponent("LuaBehaviour")
            local duigoudi_img = luaBehaviour:FindGameObject("battle_img")
            duigoudi_img:SetActive(bool)
        elseif cur_cfg == h_cfg then
            local lin_luaBehaviour = k:GetComponent("LuaBehaviour")
            local lock = lin_luaBehaviour:FindGameObject("lock_image")
            lock:SetActive(bool)
        end
    end
    self:resetHeroCombat()
end

function M:updateBuffLv(buff_data, first)
    if first == true then
        self:hideBuffTips()
    end
    local buff_img = self:findGameObject("heroBuff")
    GameUtil:updateBuffShow(buff_img, buff_data)
    self:resetHeroCombat()
    self:updateSetLeftBottomData()
    if buff_data.lv1 > 0 then
        --第一次激活
        local first_active = UserDataManager.local_data:getUserDataByKey("first_active_jiban", 0)
        if first_active == 0 then
            UserDataManager.local_data:setUserDataByKey("first_active_jiban", 1)
            self.m_model.activeTeamBl = true
            GameUtil:formationAddition(
                self.m_control,
                {
                    callback = function()
                        GameUtil:resetFormationAddition()
                        GameUtil:formationDes(self.m_control)
                    end
                }
            )
        elseif
            first == false and self.temp_buff_lv and self.temp_buff_lv < buff_data.lv1 and
                self.m_model:checkIsActiveTeam() == true
         then
            GameUtil:formationAddition(
                self.m_control,
                {
                    callback = function()
                        GameUtil:resetFormationAddition()
                    end
                }
            )
            self:showBuffTips(buff_data.lv1)
        end
    -- elseif buff_data.lv1 > 1 then
    --     if first == false and self.temp_buff_lv and self.temp_buff_lv < buff_data.lv1 and self.m_model:checkIsActiveTeam() == true then
    --         GameUtil:formationAddition(self.m_control, {callback= function ()
    --             GameUtil:resetFormationAddition()
    --         end})
    --         self:showBuffTips(buff_data.lv1)
    --     end
    end
    self.temp_buff_lv = buff_data.lv1
end

function M:showBuffTips(lv)
    -- if lv >= 2 then
    --     local data = self.m_model:getBuffNum(69+lv)
    --     if lv == 2 then
    --         self:setTextByLanKey("add_title", "fb_str_0022",3)
    --     elseif lv == 3 then
    --         self:setTextByLanKey("add_title", "fb_str_0023")
    --     elseif lv == 4 then
    --         self:setTextByLanKey("add_title", "fb_str_0022",4)
    --     elseif lv == 5 then
    --         self:setTextByLanKey("add_title", "fb_str_0022",5)
    --     end
    --     local num1 = data[1]
    --     local num2 = data[2]
    --     self:setTextByLanKey("add_num", Language:getTextByKey("fb_str_0007", num1).."%    "..Language:getTextByKey("fb_str_0008", num2).."%")
    --     self:setObjectVisible("add_bg", true)
    --     self:setObjectVisible("add_title", true)
    --     self:setObjectVisible("add_num", true)
    -- end
    -- self.m_control:setOnceTimer(3, handler(self, self.hideBuffTips))
end

function M:hideBuffTips()
    self:setObjectVisible("add_bg", false)
    self:setObjectVisible("add_title", false)
    self:setObjectVisible("add_num", false)
end

function M:setEnemyBuffLv()
    local buff_data = self.m_model:getEnemyAddBuffLv()
    local buff_img = self:findGameObject("enemyBuff")
    GameUtil:updateBuffShow(buff_img, buff_data)
end

--刷新英雄数据
function M:updateHeroContent(obj, heroOid, cell_index)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContent obj error！！！")
        return
    end
    local hero_data, hero_cfg = self.m_model:getHero(heroOid)
    GameUtil:updateHeroContentByData(obj, hero_data, hero_cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj) --obj:GetComponent("LuaBehaviour")
    if luaBehaviour then
        local yishangzhen = luaBehaviour:FindGameObject("battle_img") --已上阵
        local duigoudi_img = luaBehaviour:FindGameObject("duigou_img") --对勾
        local lock_image = luaBehaviour:FindGameObject("lock_img") --锁
        local lock_text = luaBehaviour:FindGameObject("lock_text") --锁
        local mask_img = luaBehaviour:FindGameObject("mask_img") --
        local mask_img2 = luaBehaviour:FindGameObject("mask_img2") --
        local recommend_img = luaBehaviour:FindGameObject("recommend_img") -- 推荐
        local ban_img=luaBehaviour:FindGameObject("ban_img")--ban选禁用

        local islock =nil
        -- 兼容公会战
        recommend_img:SetActive(self.m_model:isAdditionRace(hero_cfg.race))
        local is_die, hero_dyns = self.m_model:heroIsDie(heroOid)
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE and self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_MINING_DEFENSE then
            local in_main_flag = self.m_model:checkInTeams(heroOid)
            duigoudi_img:SetActive(in_main_flag)
            yishangzhen:SetActive(in_main_flag)
            lock_image:SetActive(false)
            local cardIcon_img = luaBehaviour:FindImage("hero_img")
            if is_die then
                cardIcon_img.material = self.m_gray_image.material
            else
                cardIcon_img.material = nil
            end
        elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
            -- 显示等级
            local show_lv = GameUtil:getDisplayLvByHeroData(hero_data, self.m_model.m_mode)
            local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            
            local in_main_flag = self.m_model:checkInTeams(heroOid)
            duigoudi_img:SetActive(in_main_flag)
            yishangzhen:SetActive(in_main_flag)
            lock_image:SetActive(false)
            local cardIcon_img = luaBehaviour:FindImage("hero_img")
            if is_die then
                cardIcon_img.material = self.m_gray_image.material
            else
                cardIcon_img.material = nil
            end
        elseif not self.m_model:showUnionWarTeamsMultBtn() then
            local in_team_flag = self.m_model:checkInTeams(heroOid)
            duigoudi_img:SetActive(in_team_flag)
            yishangzhen:SetActive(in_team_flag)
            local no_apostle_times = self.m_model:inquireApostleTimes(heroOid)
            local has_same_card = self.m_model:checkIsInTeam(heroOid)
            local has_apostle = self.m_model:inquireApostleInTeam(heroOid)
            local has_lock_hids =  self.m_model:checkIsLockHids(heroOid) --奇门遁甲检查队伍中是否有被锁英雄 

            local has_same_job_card=self.m_model:checkJobIsInTeam(heroOid)
            lock_image:SetActive(no_apostle_times or (not in_team_flag and (has_same_card or has_apostle or has_lock_hids)))


            if not in_team_flag then
                if has_same_card then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "UnionWar_str_031")
                elseif has_apostle then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "new_str_0860")
                elseif has_lock_hids then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "fb_str_0034")
                elseif has_same_job_card then
                    LuaBehaviourUtil.setText(luaBehaviour, "lock_text", "")
                end
            end
            if no_apostle_times then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "new_str_0859")
            end

            local cardIcon_img = luaBehaviour:FindImage("hero_img")

            if is_die then
                cardIcon_img.material = self.m_gray_image.material
                has_same_job_card=false
            elseif
                self.m_model:inquireApostleTimes(heroOid) == true or
                    (not in_team_flag and
                        (self.m_model:checkIsInTeam(heroOid) == true or self.m_model:inquireApostleInTeam(heroOid))) ==
                        true
             then
                cardIcon_img.material = self.m_gray_image.material
                has_same_job_card=false
            else
                cardIcon_img.material = nil
            end
            if in_team_flag == false then
                mask_img2:SetActive(has_same_job_card)
                --mask_img:SetActive(no_apostle_times or (not in_team_flag and (has_same_card or has_apostle or has_lock_hids)))
            end

            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
                local cur_season = UserDataManager:getCurSeason()
                local gve_cfg = ConfigManager:getCfgByName("gve")
                local gve_cfg_season = gve_cfg[cur_season] or {}
                local conversion_a = gve_cfg_season.conversion_a or 300 -- 最小等級
                local lv = math.max(hero_data.lv, hero_data.clv)
                local r_lv = math.max(lv, conversion_a)
                local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
                local upgrade_cfg = hero_upgrade[tonumber(r_lv)] or {}
                local show_lv = upgrade_cfg.display_level or 1
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
                local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
                local lv = math.max(hero_data.lv, hero_data.clv)
                if self.m_model.m_params.level_up == 1 then
                    lv = math.max(lv, 300)
                end
                local upgrade_cfg = hero_upgrade[tonumber(lv)] or {}
                local show_lv = upgrade_cfg.display_level or 1
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE then
                local show_lvXlsxData = ConfigManager:getCommonValueById(727) or {{3,150},{5,300}}
                local xlsxEvo = hero_cfg.evo
                local heroLv = 1
                local commonHeroData1 = show_lvXlsxData[1]
                local commonHeroData2 = show_lvXlsxData[2]
                if xlsxEvo == commonHeroData1[1] then
                    heroLv = commonHeroData1[2]
                elseif xlsxEvo == commonHeroData2[1] then
                    heroLv = commonHeroData2[2]
                end
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", heroLv)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then  --巅峰帮会战 
                local conversion_a = ConfigManager:getCommonValueById(776) or {{3,150},{5,300}}
                --local lv = math.max(hero_data.lv, hero_data.clv)
                --local r_lv = math.max(lv, conversion_a)
                local r_lv = conversion_a
                local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
                local upgrade_cfg = hero_upgrade[tonumber(r_lv)] or {}
                local show_lv = upgrade_cfg.display_level or 1
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE then
                if self.m_model.m_fair_fulwin == 1 then
                    local show_lvXlsxData = ConfigManager:getCommonValueById(721) or {{3,150},{5,300}}
                    local xlsxEvo = hero_cfg.evo
                    local heroLv = 1
                    local commonHeroData1 = show_lvXlsxData[1]
                    local commonHeroData2 = show_lvXlsxData[2]
                    if xlsxEvo == commonHeroData1[1] then
                        heroLv = commonHeroData1[2]
                    elseif xlsxEvo == commonHeroData2[1] then
                        heroLv = commonHeroData2[2]
                    end
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", heroLv)
                end
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
                local heroLv = 1
                heroLv = self.m_model.m_cur_stage_cfg.max_lv or 300
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", heroLv)
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO then
                local hero_isle_base_cfg=ConfigManager:getCfgByName("hero_isle_base")
                local heroLv=hero_isle_base_cfg.hero_level or 300
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", heroLv)
            elseif self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
                    self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL
                    or self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE or
                    self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA then

                if self.m_model.m_forbidden_hero_ids~=nil then
                    islock =table.indexof(self.m_model.m_forbidden_hero_ids,hero_data.id)
                end
                if islock then
                    lock_image:SetActive(islock)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"suo_img", not islock)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ban_img", islock)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_text",not islock)
                else
                    local islike=not in_team_flag and self.m_model:checkIsInTeam(heroOid)
                    lock_image:SetActive(islike)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"suo_img", not islike)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ban_img", not islike)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_text",islike)
                    if islike then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "fb_str_0041")
                    end
                    --如果已经是禁用的侠客肯定不在阵容中，也不会有同名的侠客
                    --if  not in_team_flag and self.m_model:checkIsInTeam(heroOid) == true then
                    --    lock_image:SetActive(true)
                    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"suo_img", false)
                    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ban_img", false)
                    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_text",true)
                    --else
                    --    lock_image:SetActive(false)
                    --end
                end
            elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
                local show_lvXlsxData = ConfigManager:getCommonValueById(778) or {{3,120},{5,2300}}
                --local show_lvXlsxData =  {{3,120},{5,500}}
                local xlsxEvo = hero_cfg.evo
                local heroLv = 1
                local commonHeroData1 = show_lvXlsxData[1]
                local commonHeroData2 = show_lvXlsxData[2]
                if xlsxEvo == commonHeroData1[1] then
                    heroLv = commonHeroData1[2]
                elseif xlsxEvo == commonHeroData2[1] then
                    heroLv = commonHeroData2[2]
                end
                --local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
                --local upgrade_cfg = hero_upgrade[tonumber(heroLv)] or {}
                --heroLv = upgrade_cfg.display_level or 1
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", heroLv)
            end
        else
            local in_main_flag = self.m_model:checkInTeams(heroOid)
            local taem_index, in_team_flag = self.m_model:checkInUnionWarTeams(heroOid)
            duigoudi_img:SetActive(in_main_flag)
            lock_image:SetActive(in_team_flag)
            yishangzhen:SetActive(in_main_flag)
            if in_team_flag then
                if taem_index == self.m_model.m_formation_index then
                    lock_image:SetActive(false)
                else
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "UnionWar_str_030", taem_index)
                end
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "UnionWar_str_031")
            end

            local cardIcon_img = luaBehaviour:FindImage("hero_img")
            if is_die then
                cardIcon_img.material = self.m_gray_image.material
            else
                cardIcon_img.material = nil
            end
        end

        --助战系统
        if self.m_model:checkIsInSupport(heroOid) then
            if (not duigoudi_img.activeSelf) and (not lock_image.activeSelf) and (not mask_img2.activeSelf)then
                lock_image:SetActive(true)
                ban_img:SetActive(false)
                lock_text:SetActive(true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "new_str_1150")
            end
        end
        -- 推图助战、迷宫佣兵
        local assist_img = luaBehaviour:FindGameObject("assist_img")
        assist_img:SetActive(hero_data.novice_apostle_flag == true or hero_data.assist_flg == true)
        local apostle_img = luaBehaviour:FindGameObject("apostle_applay_img")
        -- 好友佣兵
        apostle_img:SetActive(hero_data.apostle_flag == true or hero_data.bio_apostle_flag == true or hero_data.legend_apostle_flag == true or hero_data.acient_sword_flag == true or hero_data.raccon_assist_flag == true)
        -- 师徒助战
        local master_img = luaBehaviour:FindGameObject("master_img")
        master_img:SetActive(false)
        local hp_obj = luaBehaviour:FindGameObject("hp_obj")
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
            hp_obj:SetActive(true)
            local hp_pct = hero_dyns.hp_pct or 10240000 -- 血量万分比
            local mp_pct = hero_dyns.mp_pct or 0 -- 怒气万分比
            CommonUIUtil:updateHeroHpSlider(
                obj,
                GlobalTools:ToFloat(hp_pct) / 10000,
                GlobalTools:ToFloat(mp_pct) / 10000
            )
            local MainHeroNodeCell = UIUtil.findTrans(obj.transform, "MainHeroNodeCell")
            if MainHeroNodeCell then
                UIUtil.setLocalPosition(MainHeroNodeCell.transform, 61, 108, 0)
            end
        else
            hp_obj:SetActive(false)
            local MainHeroNodeCell = UIUtil.findTrans(obj.transform, "MainHeroNodeCell")
            if MainHeroNodeCell then
                UIUtil.setLocalPosition(MainHeroNodeCell.transform, 61, 94, 0)
            end
        end
        local season_buff_num = self.m_model:checkSeasonBuffByHero(hero_data.id)
        if season_buff_num > 0 then
            local str = "+%d\n %%"
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "season_buff_num", string.format(str, season_buff_num) )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "season_buff_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "season_buff_img", false)    
        end

        local scrollRectClick = luaBehaviour.gameObject:GetComponent("ScrollRectClick")

        if scrollRectClick then
            scrollRectClick.enabled=not islock
            if not islock then
                local btn = luaBehaviour.gameObject:GetComponent("Button")
                btn.enabled = false
                scrollRectClick.index = cell_index
                scrollRectClick:RegistClickCallBack(
                        function(click_type, index)
                            if click_type == 3 then
                                local info = UserDataManager.guide_data:getCurGuideInfo()
                                if info and info.key == "Formation" then
                                    return
                                end
                                self:updateMsg("drag_card", {heroid = heroOid})
                            elseif click_type == 1 then
                                self:updateMsg("click_card", {heroid = heroOid})
                            end
                        end
                )
            end
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img",true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lv_text",true)
        --战力压制的分数
        if self.m_show_combat_score == 1 then
            local _,store = GameUtil:countCombatRepressGrade(heroOid)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_repress_score_text",store)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_repress_score_text",true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_repress_score_bg",true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img",false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lv_text",false)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_repress_score_text",false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_repress_score_bg",false)
        end
    end
    self:setParticleRenderOrder(obj)
end

function M:doEnterAnim(backfunc)
    self:runAnim(
        "FormationEnter",
        backfunc or function()
            end
    )
end

function M:doExitAnim(backfunc)
    self:runAnim(
        "FormationExit",
        backfunc or function()
            end
    )
end

-- 阵法
function M:updateDeployment()
    local deployment = ConfigManager:getCfgByName("deployment")
    local atk_deployment = self.m_model.m_atk_deployment or 1
    local def_deployment = self.m_model.m_def_deployment or 1
    local hero_deployment_cfg = deployment[atk_deployment] or {}
    local enemy_deployment_cfg = deployment[def_deployment] or {}
    --self:setObjectVisible("hero_deployment", true)
    self:setImg(hero_deployment_cfg.icon, "battle_ui", "hero_deployment_icon")
    self:setTextByLanKey("hero_deployment_name_text", hero_deployment_cfg.name or "new_str_0092")
    -- local new_flag = UserDataManager:getNetDeploymentFlag()
    -- local hero_deployment_new_text = self:setTextByLanKey("hero_deployment_new_text", "new_str_0421")
    -- hero_deployment_new_text.gameObject:SetActive(new_flag)

    --self:setObjectVisible("enemy_deployment", def_deployment ~= -1)
    local enemy_deployment_icon = self:setImg(enemy_deployment_cfg.icon, "battle_ui", "enemy_deployment_icon")
    self:setTextByLanKey("enemy_deployment_name_text", enemy_deployment_cfg.name or "new_str_0092")
    -- local enemy_deployment_new_text = self:setTextByLanKey("enemy_deployment_new_text", "new_str_0421")
    -- enemy_deployment_new_text.gameObject:SetActive(false)
    enemy_deployment_icon.gameObject:SetActive(def_deployment > 0)
    self:updateSetLeftBottomDepl()
end

function M:playDeployementTx()
    local atk_deployment = self.m_model.m_atk_deployment or 1
    if self.cache_dep_id == nil then
        self.cache_dep_id = atk_deployment
    else
        if self.cache_dep_id ~= atk_deployment then
            self.m_control:setOnceTimer(
                2,
                function()
                    self:setObjectVisible(DEP_EF_NAME, false)
                end
            )
            self:setObjectVisible(DEP_EF_NAME, true)
        end
    end
end

function M:switchBottomObjType()
    local showNode = self.m_model:showMultiFormationNodeFlag()
    self:setObjectVisible("multi_formation_node", showNode)
    local bottom_obj = self:findGameObject("bottom_herolist_obj")
    if self.m_model.show_pet_bl == true then
        bottom_obj = self:findGameObject("bottom_petlist_obj")
        self:setObjectVisible("bottom_return", false)
        self:setObjectVisible("pet_bottom_return", true)
    else
        self:setObjectVisible("bottom_return", true)
        self:setObjectVisible("pet_bottom_return", false)
    end

    local buff_obj = self:findGameObject("Add_Buff")
    local buzhen_btn = self:findGameObject("buzhen_btn")
    local buzhen_btn_text = self:findGameObject("buzhen_btn_text")
    local array_btn = self:findGameObject("array_btn")
    local array_btn_text = self:findGameObject("array_btn_text")
    local start_btn = self:findGameObject("start_btn")
    local start_btn_text = self:findGameObject("start_btn_text")
    local trans = bottom_obj.transform
    local trans2 = buff_obj.transform
    if self.m_model.m_bottom_type == 0 then
        local function endCallFunc()
            local save_team = self.m_model:getSaveTeamBtnShow()
            start_btn:SetActive(save_team == false)
            start_btn_text:SetActive(save_team == false)
            buzhen_btn:SetActive(true)
            buzhen_btn_text:SetActive(true)
            self:showUnionWarTeamTog(true)
            bottom_obj:SetActive(false)
            self:setToggleState()
            if self.m_model:checkWeaOpen() == true then
                self:setObjectVisible("weapon_node", true)
            end
            self:setObjectVisible("array_btn", self.m_model:showArrayBtn() == true) --
            self:setObjectVisible("array_btn_text", self.m_model:showArrayBtn() == true)
            local show_skip_btn = self.m_model:showFormationSkipBtn()
            self:setObjectVisible("skip_select_node", show_skip_btn)
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(trans2:DOLocalMoveY(-320, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:SetLoops(1)
        end
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(trans:DOLocalMoveY(-587.5, 1):SetEase(Tweening.Ease.OutSine))
        sequence:OnComplete(endCallFunc)
        sequence:SetLoops(1)
    else
        start_btn:SetActive(false)
        start_btn_text:SetActive(false)
        buzhen_btn:SetActive(false)
        buzhen_btn_text:SetActive(false)
        self:showUnionWarTeamTog(false)
        array_btn:SetActive(false)
        array_btn_text:SetActive(false)
        bottom_obj:SetActive(true)
        self:setObjectVisible("weapon_node", false)
        self:setObjectVisible("skip_select_node", false)
        UIUtil.setLocalPosition(trans, nil,-400)
        local function endCallFunc()
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(trans:DOLocalMoveY(-287.5, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:SetLoops(1)
        end
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(trans2:DOLocalMoveY(-487.5, 0.05):SetEase(Tweening.Ease.OutSine))
        sequence:OnComplete(endCallFunc)
        sequence:SetLoops(1)
    end
    self:refreshRedPoint()
    
end

function M:updateSetLeftBottomData()
    local buff_data = self.m_model:getAddBuffLv()
    local buff_img = self:findGameObject("left_bottom_obj")
    GameUtil:updateBuffShow(buff_img, buff_data)
    if buff_data.lv1 >= 1 then
        self:setTextByLanKey("left_bottom_text1", "fb_str_000" .. (buff_data.lv1))
        self:setObjectVisible("add_art_text", true)
    else
        self:setTextByLanKey("left_bottom_text1", "new_str_0526")
        self:setObjectVisible("add_art_text", false)
    end
    local data = self.m_model:getBuffNum(buff_data.lv1)
    local num1 = data[1]
    local num2 = data[2]
    local str_text =
        Language:getTextByKey("fb_str_0007", num1) .. "%       " .. Language:getTextByKey("fb_str_0008", num2) .. "%"
    self:setTextByLanKey("add_art_text", str_text)
end

function M:updateSetLeftBottomDepl()
    local deployment = ConfigManager:getCfgByName("deployment")
    local atk_deployment = self.m_model.m_atk_deployment or 1
    local hero_deployment_cfg = deployment[atk_deployment] or {}
    self:setTextByLanKey("left_bottom_depl", hero_deployment_cfg.name or "new_str_0092")
    self:setTextByLanKey("left_bottom_depl2", hero_deployment_cfg.des or "new_str_0092")
    self:setImg("a_zd_sz_zhenfa", "battle_ui", "dep_icon")
end

function M:switchMultiFormationBtn()
    local multi_formation_btn_loopscroll = self:findGameObject("multi_formation_btn_loopscroll")
    local show_flag = multi_formation_btn_loopscroll.activeSelf
    multi_formation_btn_loopscroll:SetActive(not show_flag)
end

--[[
	创建列表
]]
function M:updateMultiFormationBtnLoopScroll()
    self.m_sel_cell_index = nil
    local data = {}
    local formation_data = UserDataManager.hero_data:getFormation()
    for i = 1, GlobalConfig.MULTI_FORMATION_MAX do
        local item_data = formation_data[tostring(i)] or {}
        local flag = GameUtil:teamNoHero(item_data.team)
        if not flag then
            table.insert(data, item_data)
        end
        if #data >= 3 then
            break
        end
    end
    self.m_multi_bg_rt.sizeDelta = Vector2(self.m_multi_bg_rt.rect.width, 35 + 70 * #data)
    if self.m_multi_formation_btn_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("multi_formation_btn_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local multi_formation_btn = luaBehaviour:FindImage("multi_formation_btn")
                local no_hero = GameUtil:teamNoHero(cell_data.team)
                local name_str = nil
                if no_hero then
                    name_str = Language:getTextByKey("new_str_0550")
                    multi_formation_btn.material = self.m_gray_image.material
                else
                    multi_formation_btn.material = nil
                    if cell_data.name then
                        name_str = cell_data.name
                    else
                        name_str = Language:getTextByKey("new_str_0551") .. tostring(index)
                    end
                end
                name_str = Language:getTextByKey("upper_num_str_000" .. index)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "multi_formation_btn_text", tostring(name_str))
                local btn_img_name =
                    GlobalConfig.MULTI_FORMATION_ICON[index] or
                    GlobalConfig.MULTI_FORMATION_ICON[#GlobalConfig.MULTI_FORMATION_ICON]
                --LuaBehaviourUtil.setImg(luaBehaviour, "multi_formation_btn", btn_img_name, "battle_ui")
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local team_lock = self.m_model:checkMultRace2(cell_data.team)
                if team_lock == false then
                    GameUtil:lookInfoTips(
                        static_rootControl,
                        {msg = Language:getTextByKey("new_str_0703"), delay_close = 2}
                    )
                    return
                end
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end
        }
        self.m_multi_formation_btn_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_multi_formation_btn_loop_scroll_view:reloadData(data, true)
    end
end

function M:openMultiFormationNode(params)
    self:closeMultiFormationNode()
    local MultiFormationNode = CustomRequire("UI.Formation.MultiFormationNode")
    self.m_multi_formation_node = MultiFormationNode.new(self.m_control, params)
end

function M:closeMultiFormationNode()
    if self.m_multi_formation_node then
        self.m_multi_formation_node:destroy()
        self.m_multi_formation_node = nil
    end
end

function M:refreshSaveBtn()
    if self.m_model:getSaveTeamBtnShow() then
        -- self:setObjectVisible(self.prefix.."save_btn",true)
        -- self:setObjectVisible(self.prefix.."bottom_return2",false)
        -- self:setObjectVisible(self.prefix.."bottom_return",false)
    else
        -- self:setObjectVisible(self.prefix.."save_btn",false)
        -- self:setObjectVisible(self.prefix.."bottom_return2",true)
        -- self:setObjectVisible(self.prefix.."bottom_return",true)
    end
end

--刷新争锋联赛限制规则
function M:refreshZFLianSaiLimit()
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
            self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
            self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE or
            self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA
    then
        self:iniZFLianSaiLimit()
        self:setObjectVisible("zfliansai_limit",true)
    else
        self:setObjectVisible("zfliansai_limit",false)
    end

end

--禁用侠客刷新
function M:refreshForbiddenHero()
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
            self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL
    then
        self:setObjectVisible("forbiddenHero",true)
    else
        self:setObjectVisible("forbiddenHero",false)
        return
    end
    if self.m_model.m_ban_num>0 then
        self:setObjectVisible("forbidden_hero1",self.m_model.m_ban_num>0)
        self:setObjectVisible("forbidden_hero2",self.m_model.m_ban_num>1)
        local forbidden_hero_ids=self.m_model.m_forbidden_hero_ids
        if forbidden_hero_ids[1] and forbidden_hero_ids[1]~=0 then
            self:setForbiddenHero(forbidden_hero_ids[1],self:findGameObject("forbidden_hero1").transform)
        else
            self:initNullForbiddenHero("forbidden_hero1")
        end

        if forbidden_hero_ids[2] and forbidden_hero_ids[2]~=0 then
            self:setForbiddenHero(forbidden_hero_ids[2],self:findGameObject("forbidden_hero2").transform)
        else
            if self.m_model.m_ban_num>1 then
                self:initNullForbiddenHero("forbidden_hero2")
            end
        end
    end
end



function M:setForbiddenHero(hero_id,cell_obj)
    local transform=cell_obj.transform
    local cfg = ConfigManager:getPlayerPictureCfg(hero_id)
    local hero_head_ui = nil
    if cfg ~= nil and next(cfg) then
        hero_head_ui = UIUtil.setImg(transform, cfg.icon, "hero_head_ui", "head/head_mask/head_icon")
        if not IsNull(hero_head_ui) then
            UIUtil.destroyAllChild(hero_head_ui.transform)
        end
    else
        hero_head_ui = UIUtil.setImg(transform, "TX_Temp", "hero_head_ui", "head/head_mask/head_icon")
        if not IsNull(hero_head_ui) then
            UIUtil.destroyAllChild(hero_head_ui.transform)
        end
    end

    --UIUtil.setObjectVisible(transform,false,"add_img")
    UIUtil.setObjectVisible(transform,true,"head")
    UIUtil.setObjectVisible(transform,false,"empty")
end

function M:initNullForbiddenHero(cell_name)
    local cell_object = self:findGameObject(cell_name).transform;
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL then
        --local add_img = luaBehaviour:FindGameObject("add_img")
        --local head_icon = luaBehaviour:FindGameObject("head")
        --head_icon:SetActive(false)
        --add_img:SetActive(true)
        UIUtil.setObjectVisible(cell_object,false,"head")
        UIUtil.setObjectVisible(cell_object,true,"empty")
    else
        UIUtil.setObjectVisible(cell_object,false,"head")
        UIUtil.setObjectVisible(cell_object,true,"empty")
    end
end



function M:setCloseText(bl)
    if bl == true then
        if
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE or
                self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE or
                self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD_DEFENSE or
                self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE or
                self.m_model.m_mode ==GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL
         then
            self:setTextByLanKey("close_title_text", "new_str_0590")
        else
            self:setTextByLanKey("close_title_text", "new_str_0386")
        end
    else
        self:setTextByLanKey("close_title_text", "new_str_0478")
    end
end

function M:createHelperUI(player)
    --local PlayerHelperTips = CustomRequire("UI.Common.CommonPlayerHelperTips")
    --local player_tip = PlayerHelperTips.new(self.m_control, {player = player})
    if self.m_model:inquireApostleInTeam(player.heroData.oid) == true then
        local player_tip = ResourceUtil:GetUIItem("Common/CommonPlayerHelperTips", self.content_node, "ui_prefabs")
        self.helperList[player.camp .. "_" .. player:get_playerInstanceId()] = player_tip
        self:refreshHelperUI(player)
    end
end

function M:refreshHelperUI(player)
    local helperUI = self.helperList[player.camp .. "_" .. player:get_playerInstanceId()]
    if helperUI ~= nil then
        local pos_3d = UIUtil.ScenePosToUI(player.position:toVector3())
        helperUI.transform.position = pos_3d
    end
end

function M:removeHelperUI(player)
    if self.helperList[player.camp .. "_" .. player:get_playerInstanceId()] ~= nil then
        --self.helperList[player.camp.."_"..player.index]:destroy()
        ResourceUtil:ReturnItem(self.helperList[player.camp .. "_" .. player:get_playerInstanceId()])
        self.helperList[player.camp .. "_" .. player:get_playerInstanceId()] = nil
    end
end

function M:switchRaceBtnList()
    local open_race_btn = self:findGameObject("open_race_btn")
    if self.m_model.race_toggle_type == true then
        self:setObjectVisible("toggle_panel", true)
        open_race_btn.transform.localRotation = Quaternion.Euler(0, 0, 180)
    else
        self:setObjectVisible("toggle_panel", false)
        open_race_btn.transform.localRotation = Quaternion.Euler(0, 0, 0)
    end
end

function M:refreshFormationSkipBattleBtn()
    self:setObjectVisible("skip_open_img", self.m_model.m_formation_skip_battle == 1)
    self:setObjectVisible("skip_close_img", self.m_model.m_formation_skip_battle ~= 1)
end

--种族塔可上阵英雄数量
function M:race_tower_HeroNum()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
        self:setObjectVisible("tower_race_obj", true)
        local c_hero_num = self.m_model:getInToHeros()
        local max_hero_num = self.m_model:checkStageUpNum() or 3
        self:setTextByLanKey("tower_hero_itmes_text", "budo_str_008", c_hero_num, max_hero_num)
    else
        self:setObjectVisible("tower_race_obj", false)
    end
end

function M:showUnionWarTeamTog(show)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
        self:setObjectVisible("guildwar_bottomleft_node", show)
        self:updateUnionWarHead()
    end
end

function M:updateUnionWarHead()
    for index = 1, 3 do
        local teamData = self.m_model.union_war_teams[tostring(index)]
        local headGameObj = self:findGameObject("tx_img_" .. index)
        headGameObj:SetActive(false)
        local headObj = self:findGameObject("tx_base_" .. index)
        headObj:SetActive(false)

        if teamData then
            local team = teamData.team
            for i = 1, 5 do
                if team[i] and team[i] ~= "" then
                    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(team[i])
                    if hero_data == nil then
                        hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataByDataAndId(self.m_model.m_other_heros, team[i])
                    end
                    if hero_cfg then
                        local img = headGameObj.transform:GetComponent("Image")
                        img.sprite = ResourceUtil:GetSprite(hero_cfg.icon, "hero_head_ui")

                        headObj:SetActive(true)
                        headGameObj:SetActive(true)
                        break
                    else
                        headObj:SetActive(false)
                        headGameObj:SetActive(false)
                    end
                end
            end
        end
        -- txBaseObj:SetActive(getHero)
    end
end

function M:updateUnionWarSelectTeamTog()
    if
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR
     then
        local selectTeam = self.m_model.m_formation_index
        for i = 0, 3 do
            local n2 = "img_head_select_" .. i
            if i == selectTeam then
                self:setObjectVisible(n2, true)
            else
                self:setObjectVisible(n2, false)
            end
        end
        self:updateUnionWarHead()
    end
end

--法宝更新
function M:updateWeaNode()
    if self.m_model:checkWeaOpen() == false then
        self:setObjectVisible("weapon_node", false)
        return
    end
    local slot_data = self.m_model.m_solts
    if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts and next (self.m_model.m_mult_solts) then
        slot_data = self.m_model.m_mult_solts[self.m_model.m_formation_index] or {}
    end
    self:setObjectVisible("weapon_node", true)
    local open_lokc_num = self.m_model:getTreasurePosNum()
    for i = 1,4 do
        local cur_wea_cion = slot_data[tostring(i)] or -1
        local wea_cell = self:setObjectVisible("wea_cell_"..i, open_lokc_num >= i)
        if cur_wea_cion and open_lokc_num >= i then --是否激活该槽位
            self:updateWeaSolt(wea_cell, i, cur_wea_cion)
        end
    end
    local wea_parent = self:findGameObject("wea_parent")
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE then
        UIUtil.setLocalPosition(wea_parent.transform, -270,-607,0)
    else
        UIUtil.setLocalPosition(wea_parent.transform, -456,-626,0)    
    end
end

--法宝槽位数据
function M:updateWeaSolt(obj, index, cur_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local cur_solt = self.m_model:getCurSoltWea(index)
        if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts then
            cur_solt = self.m_model:getMultCurSoltWea(index)
        end
        local wea_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_bg", false)
        for i = 1,7 do
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_"..i, false)
        end
        for i = 1, #cur_solt do
            local wea_id = cur_solt[i]
            local wea_cell = luaBehaviour:FindGameObject("wea_zd_"..i)
            if wea_id and wea_cell ~= nil then
                self:updateWeaCell(wea_cell, wea_id, index, i)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_"..i, i == 1)
            end
        end
        if not IsNull(wea_bg) then
            if #cur_solt == 3 then
                UIUtil:setLocalDelta(wea_bg.transform, 84, 236)
            elseif #cur_solt == 4 then  
                UIUtil:setLocalDelta(wea_bg.transform, 84, 320)
            elseif #cur_solt == 5 then  
                UIUtil:setLocalDelta(wea_bg.transform, 84, 390)
            elseif #cur_solt == 6 then
                UIUtil:setLocalDelta(wea_bg.transform, 84, 460)
            elseif #cur_solt == 7 then
                UIUtil:setLocalDelta(wea_bg.transform, 84, 528)
            else
                UIUtil:setLocalDelta(wea_bg.transform, 84, 175)
            end
        end
    end
end

--法宝数据
function M:updateWeaCell(obj, wea_id, index,pos)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local long_click = false
        if wea_id == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suo_img", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_team_bg", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_icon", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
        else
            local wea_data,wea_cfg = self.m_model:getWeaRelics(wea_id)
            if wea_cfg then
                local wea_lv_cfg = wea_cfg.detail[1]
                if wea_data then
                    wea_lv_cfg = wea_cfg.detail[wea_data.lv] or wea_cfg.detail[1]
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tre_lv_num", wea_data.lv)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suo_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_icon", true)
                    if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts then
                        local team_id = self.m_model:getMultWeaTeamIndex(wea_id)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "wea_team_text", Language:getTextByKey("new_str_0551")..team_id)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_team_bg", team_id ~= 0)
                    else
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_team_bg", false)    
                    end
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suo_img", true)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tre_lv_num", 1) 
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_team_bg", false)   
                end
             
                LuaBehaviourUtil.setImg(luaBehaviour, "wea_icon", wea_lv_cfg.icon, "mystic_ui")

            end
            
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
            if pos == 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_team_bg", false)   
            end
        end
        local changAn_btn = obj:GetComponent("ChangAn")
        local function open_wea() --点击遗物
            if wea_id == 0 then
                self.m_model.m_select_slot_index = index
                self:showSelectType()
                return
            end
            local wea_data,wea_cfg = self.m_model:getWeaRelics(wea_id)
            if wea_data then
                if self.m_model.m_select_slot_index > 0 then
                    self:updateMsg("switch_weapon",{wea_id = wea_id, index = index})
                else
                    self.m_model.m_select_slot_index = index
                    self:showSelectType()
                end
            else
                if wea_cfg.type == 2 then
                    GameUtil:lookInfoTips(self.m_control,{msg = Language:getTextByKey("weapon_str_0020"), delay_close = 2})  
                else
                    GameUtil:lookInfoTips(self.m_control,{msg = Language:getTextByKey("weapon_str_0015", wea_cfg.unlock), delay_close = 2})  
                end
            end
        end
        local function long_click_wea() --长按遗物
            local parms = {}
            parms.click_transform = obj.transform
            parms.top = true
            parms.right = true
            parms.wea_id = wea_id
            parms.delay_open = 0.1
            GameUtil:lookWeaponInfoTips(self.m_control, parms)
            if changAn_btn then
                changAn_btn:StopClick(false)
            end
        end
        local function m_levelupclick()-- 长按循环
            local wea_data,wea_cfg = self.m_model:getWeaRelics(wea_id)
            if wea_data then
                long_click = true
                long_click_wea()
            end
        end
        local function m_levelupclickup()
            if long_click == true then
                GameUtil:destroyWeaponLookInfoTips()
            else 
               open_wea()
            end
            long_click = false
        end
	
		if changAn_btn then
			changAn_btn:RegistButtonClick(m_levelupclickup, m_levelupclick)
		end
    end
end

--点击遗物槽位
function M:clickWeaSoltByIndex(index)
    self.m_model.m_select_slot_index = index
    self:showSelectType()
end

--打开切换法宝框
function M:showSelectType()
    audio:SendEvtUI("Play_UI_Tab")
    self:updateMsg("set_click", false)
    local wea_cell = self:findGameObject("wea_cell_"..self.m_model.m_select_slot_index)
    local luaBehaviour = UIUtil.findLuaBehaviour(wea_cell)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_bg", true)
    self:setObjectVisible("weapon_mask_btn", true)
    local cur_solt = self.m_model:getCurSoltWea(self.m_model.m_select_slot_index)
    if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts then
        cur_solt = self.m_model:getMultCurSoltWea(self.m_model.m_select_slot_index)
    end
    for i = 1,7 do
        local wea_id = cur_solt[i]
        if wea_id then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_"..i, true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_"..i, false)    
        end
    end
end

function M:hideSelectType()
    self:updateMsg("set_click", true)
    self:setObjectVisible("weapon_mask_btn", false)
    self.m_model.m_select_slot_index = 0
    self:updateWeaNode()
end

function M:formationWeapopPop()
    local tab_cls = CustomRequire("UI.Formation.FormationWeaponPop")
    self.m_weapon_pop = tab_cls.new(self.m_control, {parent = self.m_content_panel})
end

function M:fonmationWeapopDestory()
    if self.m_weapon_pop then
        self.m_weapon_pop = nil
    end
end

--阵法 -----------------------------------------------------------------------------------------------------------------
function M:updateHeavenUI()
    if self.m_model:isOpenHeaven() == false then
        self:setObjectVisible("heaven_node", false)
        return
    end
    self:setObjectVisible("heaven_node", false)
    self.m_control:setOnceTimer(1,function()
        self:setObjectVisible("heaven_node", true)
        self:setTextByLanKey("heaven_no_text", "heaven_no_str")
        self.m_model:updateHeaven()--每次刷新，都会重新计算激活阵法
        local heaven_teams = self.m_model.m_heaven_teams
        if next(heaven_teams) ~= nil then
            self:setObjectVisible("heaven_no_btn", false)
            self:setObjectVisible("heaven_list", true)
            self:updateHeavenScroll(heaven_teams)
        else
            self:setObjectVisible("heaven_list", false)
            self:setObjectVisible("heaven_no_btn", true)
        end
    end)
end

--激活的阵法列表
function M:updateHeavenScroll(heaven_teams)
    local data = heaven_teams
    if self.m_heaven_scroll == nil then
        local list_scroll = self:findGameObject("heaven_list")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeavenCell(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_select_heaven_obj ~= nil then
                    self:refreshHeavenCellSelect(self.m_select_heaven_obj, false)
                end
                self.m_select_heaven_obj = cell_object
                self:refreshHeavenCellSelect(self.m_select_heaven_obj, true)
                if click_name == "xiangqing_btn" then
                    self:updateMsg("check_heaven_cell", cell_data)
                elseif click_name == "cell_img" then
                    self:updateMsg("click_heaven_cell", cell_data)
                end
            end,
        }
        self.m_heaven_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_heaven_scroll:reloadData(data, false)
    end
end

--阵法图标
function M:updateHeavenCell(obj, index, cell_data)
    local heaven_team = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cell_img = luaBehaviour:FindImage("cell_img")
    GameUtil:updateResourcesImg(cell_img,"Texture/heaven_earth/" .. heaven_team.active_data.icon)
    if heaven_team.id == self.m_model.m_select_heaven_id then
        self.m_select_heaven_obj = obj
        self:refreshHeavenCellSelect(obj, true)
    else
        self:refreshHeavenCellSelect(obj, false)
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "xiangqing_text", "new_str_0338")
end

function M:refreshHeavenCellSelect(obj, is_select)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_bg", is_select == true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"select_obj", is_select == true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"xiangqing_btn", is_select == true)
end

--关闭阵法详情
function M:closeHeavenDetail()
    self:setObjectVisible("heaven_detail_pop", false)
end

--阵法详情
function M:showHeavenDetail(heaven_team)
    self:setObjectVisible("heaven_detail_pop", true)
    self:setTextByLanKey("heaven_name_text", "heavenEarth_text_013", heaven_team.active_data.team_name, heaven_team.lv)
    self:setTextByLanKey("heaven_effect_text", heaven_team.active_effect.array_describe)
    local cond_array = self.m_model:formatCond(heaven_team.active_data.activate_array)
    for i = 1, 5 do
        local cond = cond_array[i]
        local obj = self:findGameObject("heaven_hero_cell_" .. i)
        if cond == nil then
            obj:SetActive(false)
        else
            obj:SetActive(true)
            local luaBehaviour = UIUtil.findLuaBehaviour(obj)
            LuaBehaviourUtil.setImg(luaBehaviour, "item_img", "TX_Temp", "hero_head_ui")
            LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", "a_ui_currency_ws_lan_small", "hero_head_ui")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img", false)
            if cond[1] == 1 then
                local sex = cond[3]
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "type_img", sex == 1 and "a_tdzz_nanjiaobiao" or "a_tdzz_nvjiaobiao", ResourceUtil:getLanAtlas())
            elseif cond[1] == 2 then
                local job_type = cond[3]
                local job_cfg = GlobalConfig.CLASS_MERIDIAN[job_type] or GlobalConfig.CLASS_MERIDIAN[1]
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "type_img", job_cfg.pro_icon, ResourceUtil:getLanAtlas())
            elseif cond[1] == 3 then
                local hero_id = cond[2]
                local hero_quality = cond[3]
                local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                local frame_name = quality_item.hero_item_frame
                LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
                local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
                if hero_cfg ~= nil then
                    LuaBehaviourUtil.setImg(luaBehaviour,"item_img", hero_cfg.icon, "hero_head_ui")
                end
            elseif cond[1] == 4 then
                local sp_type = cond[2]
                local hero_quality = cond[3]
                local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                local frame_name = quality_item.hero_item_frame
                LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
                local sp_cfg = GlobalConfig.SP_TYPE_SETTING[sp_type]
                if sp_cfg ~= nil then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img", true)
                    LuaBehaviourUtil.setImg(luaBehaviour,"sp_img", sp_cfg.icon,"hero_ui")
                end
            end
        end
    end
end

--wait delete
--[[
function M:showActiveHeavenHeroes()
    if self.m_model:isOpenHeaven() == false then
        return
    end
    self:setObjectVisible("heaven_detail_pop", false)
    local active_heaven_content = self:findGameObject("active_heaven_content")
    UIUtil.destroyAllChild(active_heaven_content.transform)
    local can_use, all_heros = self.m_model:checkAllHeavens()
    if next(all_heros) == nil then
        self.m_heros_active_heaven_nil = true
    end
    for k,v in pairs(all_heros) do
        local l_hero_data, l_hero_cfg = self.m_model:getHero(v)
        local data = {101,l_hero_data.id,1, v}
        local hero_obj = CommonUIUtil:createHeroElement(data, false, active_heaven_content.transform)
    end
end
]]--

--wait delete
--[[
function M:closeActiveHeavenHeroes()
    self:setObjectVisible("active_heros", false)
end
]]--
--阵法结束 -------------------------------------------------------------------------------------------------------------

--刷新与战力压制相关的UI
function M:refreshCombatSuppressSystem()
    local show_flag = self.m_model:getPVPFlag()
    local pos1 = Vector3.New(-0,-80,0)
    local pos = Vector3.New(-0,60,0)
    local obj = self:findGameObject("CombatSuppressSystemNode")
    if not IsNull(obj) then
        obj:SetActive(show_flag)
        self:setTextByLanKey("show_combat_score_text","new_str_1153")
        self:setObjectVisible("show_combat_score_toggle",show_flag)
        if show_flag then
            self.m_model.mode = GlobalConfig.BATTLE_MODE.UNIONWAR
            if self.m_model.m_mode  == GlobalConfig.BATTLE_MODE.UNIONWAR then
                obj.transform.localPosition = pos1
            else
                obj.transform.localPosition = pos
            end
            self:setTextByLanKey("left_name_text","combat_suppress_system_text_001")
            self:setTextByLanKey("right_name_text","combat_suppress_system_text_001")
            self:setTextByLanKey("show_combat_score_text","combat_suppress_system_text_0012")
            local tog_btn = self:findToggle("show_combat_score_toggle")
            UIUtil.addToggleListener(tog_btn, function(is_on)
                self:switchTabUpdate(is_on)
            end,nil,self.m_uiName)
            self.m_show_combat_score = tog_btn.isOn and 1 or 2
        else
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE or
                    self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL or
                    self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL or
                    self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA
            then
                obj = self:findGameObject("zfliansai_limit")
                obj.transform.localPosition =Vector3.zero
            end
        end
    end
end

function M:switchTabUpdate(is_on)
    self.m_show_combat_score = is_on and 1 or 2
    self:updateLoopScroll()
end

function M:setToggleState()
    local tog_btn = self:findToggle("show_combat_score_toggle")
    UIUtil.setToggleIsOn(tog_btn.transform,false)
end

function M:runBackAnim(func)
    local obj = self:findGameObject("CombatSuppressSystemNode")
    if not IsNull(obj) then
        local parent_luaBehaviour = obj:GetComponent("LuaBehaviour")
        if parent_luaBehaviour then
            local child_obj = LuaBehaviourUtil.findGameObject(parent_luaBehaviour,"content_base")
            if child_obj then
                local child_lb = child_obj:GetComponent("LuaBehaviour")
                child_lb:RunAnim("CombatSuppressSystemNode_content_node",func)
            end
        end
    end
end

function M:runEnterAnim()
    local obj = self:findGameObject("CombatSuppressSystemNode")
    if not IsNull(obj) then
        local parent_luaBehaviour = obj:GetComponent("LuaBehaviour")
        if parent_luaBehaviour then
            local child_obj = LuaBehaviourUtil.findGameObject(parent_luaBehaviour,"content_base")
            if child_obj then
                local child_lb = child_obj:GetComponent("LuaBehaviour")
                child_lb:RunAnim("CombatSuppressSystemNode_content_node_enter",nil)
            end
        end
    end
end

function M:resetCombatSuppressPos()
    local pos1 = Vector3.New(-112,200,0)
    local pos2 = Vector3.New(112,200,0)
    local left_obj = self:findGameObject("left_diban_img")
    local right_obj = self:findGameObject("right_diban_img")
    local left_canvas_group = left_obj.transform:GetComponent("CanvasGroup")
    local right_canvas_group = right_obj.transform:GetComponent("CanvasGroup")
    left_obj.transform.localPosition = pos1
    right_obj.transform.localPosition = pos2
    left_canvas_group.alpha = 1
    right_canvas_group.alpha = 1
end

function M:updateCombatRepressLevel()
    self.my_level = 0
    local my_score = 0
    self.other_level = 0
    local other_score = 0
    --计算自己的分数
    for k,oid in ipairs(self.m_model.main_team) do
        local _,nums1 = GameUtil:countCombatRepressGrade(oid)
        my_score = my_score + nums1
    end
    local _,nums2 = GameUtil:countGlobalCombatRepressGrade()
    my_score = my_score + nums2
    --计算他人的分数
    if self.m_model:getDefDataFlag() then
        --兼容多队的情况
        local teams = {}
        if self.m_model.m_def_data.teams then
            teams = self.m_model.m_def_data.teams[self.m_model.m_formation_index] or {}
        else
            teams = self.m_model.m_def_data.team or {}
        end
        for k,oid in pairs(teams) do
            local hero_data = self.m_model.m_def_data.heros[oid]
            local _,nums1 = GameUtil:countCombatRepressGrade(oid,hero_data)
            other_score = other_score + nums1
        end
        local _,nums3 = GameUtil:countGlobalCombatRepressGrade(self.m_model.m_def_data.combat_repress or {})
        other_score = other_score + nums3
    end
    --根据分数去获取level
    self:setObjectVisible("btn_revert",false)
    --self:setObjectVisible("btn_revert",self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR)
    self.my_level = GameUtil:getCombatSupressLevel(my_score)
    self.other_level = GameUtil:getCombatSupressLevel(other_score)
    self:setTextByLanKey("left_level_text",self.my_level)
    self:setTextByLanKey("right_level_text",self.other_level)
    self.m_model.my_score = my_score
    self:setCombatSuppressFxUi()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then 
        self:UpdateRevertView()
    end
end

function M:UpdateRevertView()
    local text = self.m_model.is_current_leve_type == 1 and "guild_high_war_yan_text_0032" or "guild_high_war_yan_text_0033"
    local level_ = self.m_model.is_current_leve_type == 1 and self.m_model.eff_atk_level or self.m_model.eff_def_level
    local level = GameUtil:getCombatSupressLevel(self.m_model.my_score,level_)
    self:setTextByLanKey("left_level_text",level)
    self:setTextByLanKey("text_revert",text)
end
--设置ui的特效
function M:setCombatSuppressFxUi(average)
    local my_level = self.my_level or 0
    local other_level = self.other_level or 0
    my_level = average and 0 or my_level
    other_level = average and 0 or other_level
    self:setObjectVisible("UI_Combat_Fire_002",my_level > other_level)
    self:setObjectVisible("UI_Combat_Fire_001",my_level < other_level)
end

function M:playTiaoZhan()
    local anim = self.m_luaBehaviour:FindAnimation("Tiaozhan")
    if anim then
        anim:Play("Tiaozhan")
    end
end

--rta布阵倒计时
function M:InitBuzhenCountDown()
    self:setObjectVisible("rta_tiaozhan_tip",false)
    self:setObjectVisible("rta_buzhen_countDown",self.m_model.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA)
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA then
        self:setObjectVisible("CommonCloseNode",false)
        self:setObjectVisible("buzhen_btn",false)
        self:setObjectVisible("buzhen_btn_text",false)

        local buzhenHpConTrans=self:findGameObject("rta_buzhen_countDown").transform
        local buzhenHpCon=buzhenHpConTrans:GetComponent(typeof(CS.HpLabelController))
        self.total_time = self.m_model.m_rta_end_ts- UserDataManager:getServerTime()
        --total_time = math.floor(total_time/1000+0.5)
        local remainingTime=-1
        remainingTime=self.total_time>30 and 30 or self.total_time
        buzhenHpCon:SetText(remainingTime,-1);


        local function tick(event, dt, remaining_time)
            self.total_time=self.m_model.m_rta_end_ts- UserDataManager:getServerTime()

            --local mode_util_item = BattleModeUtil[self.m_model.m_mode]
            --if mode_util_item and mode_util_item.formationControlStartBattle then
            --    mode_util_item.formationControlStartBattle(self.m_control)
            --end
            if self.total_time>=0 then
                remainingTime=self.total_time>30 and 30 or self.total_time
                buzhenHpCon:SetText(remainingTime,-1)
            else
                self.m_control:removeTimer(self.m_buzhenCountDown_timer)
            end

        end
        --EventDispatcher:registerTimeEvent("buzhenCountDown", tick, 1, self.total_time)
        self.m_buzhenCountDown_timer = self.m_control:setTimer(1, tick)
    end
end

function M:setWaitingTiaoZhanTip()
    --self:setObjectVisible("rta_buzhen_countDown",false)
    self:setObjectVisible("rta_tiaozhan_tip",true)
    self:setTextByLanKey("rta_tiaozhan_tip","arena_rta_str_0034")
end

function M:rtaBattleBtnAnim()
    --local trans=self:findGameObject("start_btn").transform
    local sequence = Tweening.DOTween.Sequence()
    --sequence:Append(trans:DOLocalMoveY(-300, 0.3):SetEase(Tweening.Ease.OutSine))
    --sequence:SetLoops(1)
    --sequence:SetAutoKill(true)
    --
    --trans=self:findGameObject("weapon_node").transform
    --sequence = Tweening.DOTween.Sequence()
    --sequence:Append(trans:DOLocalMoveY(-300, 0.3):SetEase(Tweening.Ease.OutSine))
    --sequence:SetLoops(1)
    --sequence:SetAutoKill(true)
    --
    --trans=self:findGameObject("start_btn_text").transform
    --sequence = Tweening.DOTween.Sequence()
    --sequence:Append(trans:DOLocalMoveY(-300, 0.3):SetEase(Tweening.Ease.OutSine))
    --sequence:SetLoops(1)
    --sequence:SetAutoKill(true)

    trans=self:findGameObject("bottom_obj").transform
    sequence = Tweening.DOTween.Sequence()
    sequence:AppendInterval(0.5)
    sequence:Append(trans:DOLocalMoveY(-300, 1):SetEase(Tweening.Ease.OutSine))
    sequence:SetLoops(1)
    sequence:SetAutoKill(true)
end

function M:rtaResetUI()
    --local trans=self:findGameObject("start_btn").transform
    --UIUtil.setLocalPosition(trans,-130.19,91.89)
    --trans=self:findGameObject("weapon_node").transform
    --UIUtil.setLocalPosition(trans,-134.9,32.3)
    --trans=self:findGameObject("start_btn_text").transform
    --UIUtil.setLocalPosition(trans,0,0)

    trans=self:findGameObject("bottom_obj").transform
    UIUtil.setLocalPosition(trans,0,0)

    self:setObjectVisible("CommonCloseNode",true)
end

function M:destroy()
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA then
        self:rtaResetUI()
        EventDispatcher:unRegisterEvent("buzhenCountDown")
    end

    self:closeMultiFormationNode()
    for k, v in pairs(self.helperList) do
        --v:destroy()
        ResourceUtil:ReturnItem(v)
    end
    if self.m_weapon_pop then
        self.m_weapon_pop:destroy()
        self.m_weapon_pop = nil
    end
    self.helperList = {}
    M.super.destroy(self)
end

return M



