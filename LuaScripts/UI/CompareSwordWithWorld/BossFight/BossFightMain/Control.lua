local M = class("BossFightMainControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(0.5, handler(self, self.updateTime))
    SceneManager:getCurSceneModel():setCameraShow(false)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
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
    elseif msg == "main_refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "switch_tab" then
        self.m_model.m_select_data = data
        self.m_view:refreshUI()
    elseif msg == "new_rank_btn" then
        self:openView("CompareSwordWithWorld.BossFight.BossFightDamageRankList",
                {selectData = self.m_model.m_select_data })
    elseif msg == "reward_btn_img" then
        self:openView("CompareSwordWithWorld.BossFight.BossFightRewardPop", { version = self.m_model.m_version or 1, rank = self.m_model.m_self_boss_damage_rank, count = self.m_model.m_rank_count })
    elseif msg == "challenge_btn" then
        local stage_battle_active = ConfigManager:getCfgByName("stage_battle_active")
        local active_stage_item = stage_battle_active[self.m_model.m_select_data.battle_id]
        if active_stage_item then
            local boss_pos = active_stage_item.boss_position or 0
            local boss_size = active_stage_item.boss_size_mode or 1
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS,
                                       version = self.m_model.m_version,
                                       assist_heros = self.m_model.m_data.present_hero,
                                       battle_id = self.m_model.m_select_data.battle_id,
                --races = self.m_model.m_select_data.race,
                                       addition_race = self.m_model.m_select_data.race,
                                       boss_max_hp = self.m_model.m_boss_max_hp or 1,
                                       boss_hp_cid = self.m_model.m_boss_hp_cid or 1,
                                       boss_cur_damage = self.m_model.m_boss_max_damage,
                                       open_id = self.m_model.m_params.open_id or 414 ,
                                       battle_id  = self.m_model.m_select_data.battle_id ,   })
        end
    elseif msg == "refreshData" then
        self:requestForMainDataUpdate()
    elseif msg == "pop_not_open" then
        local idx = data.index
        GameUtil:lookInfoTips(static_rootControl, { msg = self.m_model.m_boss_cfg[idx].unopened_tips or Language:getTextByKey("new_str_0576"), delay_close = 2 })
    elseif msg == "help_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = self.m_model.m_phase_info_cfg[1].name or "", content = "tid#Full_service_tips" })
    elseif msg == "shili_root" then
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("game_of_heaven_and_earth_reward_text_009"), delay_close = 2 })
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 35})
        
    end
end

--请求主数据更新
function M:requestForMainDataUpdate()
    local function netCallback(response)
        if response then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("full_service_index", nil, netCallback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:showSkill(index, click_transform)
    local stage_battle = ConfigManager:getCfgByName("stage_battle_active")
    local battle_cfg = stage_battle[self.m_model.m_select_data.battle_id]
    local boss = battle_cfg.monster[battle_cfg.worldboss_position]
    if boss and next(boss) then
        local hero_detail = ConfigManager:getCfgByName("hero_detail")
        local boss_cfg = hero_detail[boss.id]
        self:openView("CompareSwordWithWorld.BossFight.BossSkillPop", { skill = boss_cfg.skill[index], 
                                         index = index, cur_lv = 1, 
                                         boss_idx = self.m_model.m_select_data.id, 
                                         click_transform = click_transform, 
                                         pivot = Vector2(0.5, 1),
        })
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    SceneManager:getCurSceneModel():setCameraShow(true)
    M.super.destroy(self)
end

return M
