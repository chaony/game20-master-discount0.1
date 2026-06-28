local M = class("ActiveBossControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_model.state = 1;
    SceneManager:changeScene(SceneManager.SceneID.ActiveBossScene, self.m_model,true)
    SceneManager:scenestart()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:startGuide()
    UserDataManager.guide_data:setAnyTeamGuide(40, 3)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        self:updateMsg("common_refresh",nil,"parent")
        self:updateMsg("refresh_ui", nil, "CoolSummer")
        if self.m_model.m_open_id == 327 then
            self:updateMsg("refresh_entrances",nil,"HalfAnniversary.HalfAnniversaryMain")
        end
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 29})
    elseif msg == "close_mop_up" then
        self:updateMsg(99999,nil,"Activities.ActiveBoss.ActiveBossMopUp")
    elseif msg == "challenge_btn" then
        -- self.m_model:canChallenge() 
        audio:SendEvtUI("Ui_Fight")
        local left_times = self.m_model:getLeftTimes()
        if left_times > 0 then
            self:challengeWoldBossTeam()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0574"), delay_close = 2})
            --self:buyLeftTimes()
        end
    elseif msg == "record_btn" then
        --local params = {}
        --params.damage_log = self.m_model.m_data.damage_log
        --params.battle_config_id = self.m_model.m_data.battle_config_id
        --self:openView("Activities.WorldBoss.WorldBossLog", params)
    elseif msg == "rank_btn" then
        --self:openView("Activities.WorldBoss.WorldBossRank", {boss_id = self.m_model.m_boss_id})
    elseif msg == "reward_btn" then
        --if self.m_model.m_data.self_rank > 0 then
        --local params = {}
        --    params.dan_data = self.m_model.m_reward
        --    params.rank = self.m_model.m_data.self_rank
        --    params.max_damage = self.m_model:getMaxBattleDamage()
        --    self:openView("Activities.WorldBoss.WorldBossReward", params)
        --else
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0016"), delay_close = 2})
        --end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "world_boss_str_0044"
        params.content = "tid#half_year_boss_Des"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "tips_btn" then
        self.m_view:showTipsDetail(true)
    elseif msg == "tips_detail_panel" then
        self.m_view:showTipsDetail(false)
    elseif msg == "fresh_data" then
        self:freshNetData()
        if SceneManager:getCurSceneView() ~= nil then
            SceneManager:continue()
        end
    elseif msg == "skill_1_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:showSkill(1, sk_obj.transform)
    elseif msg == "skill_2_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:showSkill(2, sk_obj.transform)
    elseif msg == "skill_3_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:showSkill(3, sk_obj.transform)
    elseif msg == "skill_4_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:showSkill(4, sk_obj.transform)
    elseif msg == "mop_up_btn" then
        self:openView("Activities.ActiveBoss.ActiveBossMopUp", {data = self.m_model.m_data, open_id = self.m_model.m_open_id, version = self.m_model.m_version})
    elseif msg == "update_data" then
        if data then
            self.m_model:updateData(data)
            self.m_view:refreshUI()
        end
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "new_rank_btn" and self.m_model.m_open_id == 327 then
        self:openView("Activities.ActiveBoss.ActiveBossRankPop", {data = self.m_model.m_data, open_id = self.m_model.m_open_id, version = self.m_model.m_version})
    elseif msg == "new_rank_btn" and self.m_model.m_open_id == 368 then
        self:openView("Activities.ActiveBoss.ActiveBossCoolRankPop", {data = self.m_model.m_data, open_id = self.m_model.m_open_id, version = self.m_model.m_version})
    elseif msg == "refresh_score" then
        local like_index = data and data or 0
        self.m_model:updateKillRankScore(like_index)
    elseif msg == "rec_kill_reward_btn" then
        audio:SendEvtUI("UI_Pay")
        self:requestKillReward(data)
    elseif msg == "jifen_obj" then
        self.m_view:refreshJifenTips()
    elseif msg == "guide_btn2" then --帮助
        local params = {}
        params.title = self.m_view.opendata.name or "cool_summer_text_0002"
        params.content = "tid#Qingliangxiarides_1"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:showSkill(index, click_transform)
    audio:SendEvtUI("Play_UI_Tab")
    --local world_boss_cycle = ConfigManager:getCfgByName("world_boss_cycle")[self.m_model.m_data.battle_config_id]
    local boss_cfg = self.m_model:getBossCfg()
    --local stage_battle = ConfigManager:getCfgByName("stage_battle")
    local battle_cfg = ConfigManager:getCfgStageBattle(boss_cfg.battle_id)--stage_battle[boss_cfg.battle_id]
    local boss = battle_cfg.monster[battle_cfg.worldboss_position]
    local hero_detail = ConfigManager:getCfgByName("hero_detail")
    local boss_cfg = hero_detail[boss.id]
    self:openView("Pops.SkillPop",{skill = boss_cfg.skill[index], index = index, cur_lv = 1 ,click_transform = click_transform,pivot = Vector2(0.5,1)})
end

function M:freshNetData()
    local function receivetCallback(response)
        self.m_model:updateData(response)
        local boss_max_hp = self.m_model.m_boss_max_hp
        local boss_cur_damage = self.m_model:getMaxBattleDamage()
        local is_die = false
        if boss_cur_damage >= boss_max_hp and boss_cur_damage > 0 then
            is_die = true
        end
        SceneManager.curScene:resetCamera(is_die);
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("common_world_boss_index", {open_id = self.m_model.m_open_id, vsn = self.m_model.m_version}, receivetCallback)
end

function M:requestReceive(data)
	--local function receivetCallback(response)
    --    RewardUtil:rewardTipsByData(response.reward)
    --    self.m_model:updateData(response.seven_tour_received)
    --    self.m_view:refreshUI()
    --end
    --local params = {}
    --params.day = data
    --self.m_model:getNetData("active_receive_seven_tour", params, receivetCallback)
end

function M:challengeWoldBossTeam()
    local world_cfg = self.m_model:getBossCfg()
    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.ACTIVE_BOSS, 
                               assist_heros = self.m_model.m_data.present_hero, 
                               battle_config_id = self.m_model.m_data.battle_config_id, 
                               battle_id = world_cfg.battle_id,
                               boss_max_hp = self.m_model.m_boss_max_hp,
                               boss_hp_cid = self.m_model.m_boss_hp_cid,
                               level_up = self.m_model.level_up,
                               boss_cur_damage = self.m_model:getMaxBattleDamage()})
    EventDispatcher:dipatchEvent("PlayShowAnimator",{ camp = -1,animator = "in" })
end

function M:buyLeftTimes()
    local function buyCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end

    -- local user_data = UserDataManager.user_data
    -- local diamond = user_data:getUserStatusDataByKey("diamond")
    local reset_cost = ConfigManager:getCommonValueById(59)[1]
    local params =
    {
        on_ok_call = function(msg)
            self.m_model:getNetData("world_boss_buy_world_boss_battle_times", nil, buyCallback)
        end,
        no_close_btn = false,
        cost = reset_cost,
        text = string.format(Language:getTextByKey("world_boss_str_0009"), reset_cost[3], 99 - self.m_model.m_data.buy_times)
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

function M:requestKillReward(data)
    local function receivedCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model.m_data.recv_kill_num_reward = response.recv_kill_num_reward
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_id = self.m_model.m_open_id
    params.vsn = self.m_model.m_version
    params.kill_num = data
    self.m_model:getNetData("common_world_boss_recv_kill_num_reward", params, receivedCallback)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end
return M;
