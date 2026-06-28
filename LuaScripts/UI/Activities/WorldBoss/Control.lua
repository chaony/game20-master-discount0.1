local M = class("WorldBossPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_model.state = 1;
    SceneManager:changeScene(SceneManager.SceneID.BossScene, self.m_model,true)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
        self:challengeWoldBossTeam();
    end
    SceneManager:scenestart()
    self.m_guide_file_name = "UI.Activities.WorldBoss.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:startGuide()
    UserDataManager.guide_data:setAnyTeamGuide(40, 3)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 29})
    elseif msg == "close_mop_up" then
        self:updateMsg(99999,nil,"Activities.WorldBoss.WorldBossMopUp")
    elseif msg == "challenge_btn" then
        -- self.m_model:canChallenge() 
        local left_times = self.m_model:getLeftTimes()
        if left_times > 0 then
            self:challengeWoldBossTeam()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0574"), delay_close = 2})
            --self:buyLeftTimes()
        end
    elseif msg == "record_btn" then
        local params = {}
        params.damage_log = self.m_model.m_data.damage_log
        params.battle_config_id = self.m_model.m_data.battle_config_id
        self:openView("Activities.WorldBoss.WorldBossLog", params)
    elseif msg == "rank_btn" then
        self:openView("Activities.WorldBoss.WorldBossRank", {boss_id = self.m_model.m_boss_id})
    elseif msg == "reward_btn" then
        if self.m_model.m_data.self_rank > 0 then
        local params = {}
            params.dan_data = self.m_model.m_reward
            params.rank = self.m_model.m_data.self_rank
            params.max_damage = self.m_model:getMaxBattleDamage()
            self:openView("Activities.WorldBoss.WorldBossReward", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0016"), delay_close = 2})
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "world_boss_str_0017"
        params.content = "tid#boss_rush1"
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
        self:openView("Activities.WorldBoss.WorldBossMopUp", {data = self.m_model.m_data, boss_id = self.m_model.m_boss_id})
    elseif msg == "update_data" then
        if data then
            self.m_model:updateData(data)
            self.m_view:refreshUI()
        end
    elseif msg == "new_rank_btn" then
        self:openView("Activities.WorldBoss.WorldBossRank2", {data = self.m_model.m_data, boss_id = self.m_model.m_boss_id})
    elseif "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "refresh_score" then
        local like_index = data and data or 0
        self.m_model:updateKillRankScore(like_index)
    end
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:showSkill(index, click_transform)
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
        self:updateMsg("update_boss_data", response , "Activities.WorldBoss.WorldBossSelectMain")
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("world_boss_index", nil, receivetCallback)
end

function M:requestReceive(data)
	local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response.seven_tour_received)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("active_receive_seven_tour", params, receivetCallback)
end

function M:challengeWoldBossTeam()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
        local hero_train = ConfigManager:getCfgByName("train_challenge")
        local hero_train_cfg = hero_train[self.m_model.m_boss_id]
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.ACTIVE, 
                                   assist_heros = self.m_model.m_data.present_hero, 
                                   battle_config_id = self.m_model.m_data.battle_config_id, 
                                   battle_id = hero_train_cfg.stage_battle, 
                                   addition_race = hero_train_cfg.goodness_race, 
                                   boss_id = self.m_model.m_boss_id})
    else
        local world_boss = ConfigManager:getCfgByName("world_boss")
        local world_cfg = world_boss[self.m_model.m_boss_id] or {}
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.WORLD_BOSS, 
                                   assist_heros = self.m_model.m_data.present_hero, 
                                   battle_config_id = self.m_model.m_data.battle_config_id, 
                                   battle_id = world_cfg.battle_id, 
                                   addition_race = world_cfg.goodness_race, 
                                   boss_id = self.m_model.m_boss_id,
                                   boss_max_hp = self.m_model.m_boss_max_hp,
                                   boss_hp_cid = self.m_model.m_boss_hp_cid,
                                   boss_cur_damage = self.m_model:getMaxBattleDamage()})
        EventDispatcher:dipatchEvent("PlayShowAnimator",{ camp = -1,animator = "in" })
    end
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

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end
return M;
