local M = class("QiMenDunJiaBattleDetailControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "normal_close_btn" or msg == "boss_close_btn" or msg == "star_close_btn" then   
        self:closeView()
    --小怪
    elseif msg == "normal_battle_btn" then
        if self.m_model:getStarChooseFlag() == true then
            self:startBattle()
        else
            self.m_model:confirmStart()
            self.m_view:refreshUI()
        end
    elseif msg == "normal_battle_speed_btn" then
    elseif msg == "normal_des_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaContentPop", {content_key = "tid#QMDJ_dec_03"})
    elseif msg == "normal_star_default_btn" then
        self.m_model:updateStarChooseFlag()
        self.m_view:updateStarChooseFlag()
    --boss
    elseif msg == "boss_battle_btn" then
        if self.m_model:getStarChooseFlag() == true then
            self:startBattle()
        else
            self.m_model:confirmStart()
            self.m_view:refreshUI()
        end
    elseif msg == "boss_battle_speed_btn" then
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
    elseif msg == "boss_star_default_btn" then
        self.m_model:updateStarChooseFlag()
        self.m_view:updateStarChooseFlag()
    --难度选择
    elseif msg == "star_battle_btn" then
        self:startBattle()
    elseif msg == "star_des_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaContentPop", {content_key = "tid#QMDJ_dec_05"})
    end
end

function M:startBattle()
   if self.m_model:getJoinGuildDays() >= 1 then--加入帮会当天不可挑战
        local cell_data = self.m_model:getCellData()
        local param_data = {}
        param_data.cell_id = self.m_model:getCellID()
        param_data.stage_id = cell_data.gve_stage_id
        param_data.boss_max_hp = cell_data.max_hp
        param_data.combat_gve_battle = self.m_model:getTeamCombat()
        param_data.def_data = self.m_model:getCellDefTeam()
        param_data.star = self.m_model:getChooseStar() --难度星级
        self:openGveFormation(param_data)
        self:updateMsg(99999)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_men_dun_jia_str_030"), delay_close = 2})
    end
end

-- 奇门遁甲战斗
function M:openGveFormation(data)
    local boss_pos = 1;
    local boss_size = 1;
    local move_camera = 0; -- 是否移动摄像机
    local stage_type = 1; -- 关卡类型 1,2,3 小怪 4 是boss
    local stage_id = data.stage_id -- 先默认写死一个 临时数据
    local cell_id = data.cell_id  --1100200080002  -- 先默认写死一个 临时数据
    local star = data.star --难度星级
    local boss_max_hp = data.boss_max_hp or 999999999999  -- 先默认写死一个 临时数据
    local combat_gve_battle = data.combat_gve_battle or 99999 -- 先默认写死一个 临时数据
    local def_data = data.def_data
    local gve_stage = ConfigManager:getCfgByName("gve_stage") or {}
    local gve_stage_item = gve_stage[stage_id] or {} -- 找到battleid对应的stagebattle
    local race_tab = {1,2,3,4,5,6} -- 默认全种族
    local massif_data = self.m_model:getMassifCfg(self.m_model.m_cell_data.massif_id)
    if massif_data and massif_data.race and _G.next(massif_data.race) then
        race_tab = massif_data.race
    end
    local wall_coef = self.m_model.m_data.wall_coef  -- 地块难度墙
    local lock_hids = self.m_model.m_lock_hids -- 正在打扫战场的英雄配置id
    local version = self.m_model.m_version -- 版本号
    local cur_season = UserDataManager:getCurSeason()
    local gve_tab = ConfigManager:getCfgByName("gve") or {}
    local gve_season_tab = gve_tab[cur_season] or {}
    local difficulty_reduce = gve_season_tab.difficulty_reduce or 0
    if gve_stage_item.battle_id and stage_id and cell_id and massif_data then
        local stage_battle_active = ConfigManager:getCfgByName("gve_stage_battle")
        local active_stage_item = stage_battle_active[gve_stage_item.battle_id] or {}
        boss_pos = active_stage_item.boss_position
        boss_size = active_stage_item.boss_size_mode
        stage_type = gve_stage_item.stage_type
        move_camera = active_stage_item.cam
        local params = {}
        if stage_type == 4 then
            move_camera = 1 -- 是boss要移动相机
            params = {
                mode = GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS, -- 战斗模式
                boss_pos = boss_pos,
                boss_size = boss_size,
                move_camera = move_camera,
                battle_id = gve_stage_item.battle_id,
                cell_id = cell_id, -- 格子id
                star = star,
                stage_type = stage_type, -- 关卡类型
                stage_id = stage_id, -- 关卡id
                boss_max_hp = boss_max_hp, -- boss最大血量
                races = race_tab, --种族限制
                wall_coef = wall_coef, -- 地块难度墙
                difficulty_reduce = difficulty_reduce, -- 每周降低强数值
                lock_hids = lock_hids, -- 正在打扫战场的英雄配置id
                gve_version = version,
            }
        else
            params = {
                mode = GlobalConfig.BATTLE_MODE.GVE_BATTLE, -- 战斗模式
                boss_pos = boss_pos,
                boss_size = boss_size,
                move_camera = move_camera,
                battle_id = gve_stage_item.battle_id,
                cell_id = cell_id, -- 格子id
                star = star,
                stage_type = stage_type, -- 关卡类型
                stage_id = stage_id, -- 关卡id
                combat_gve_battle = combat_gve_battle, -- 奇门遁甲关卡综合战力
                races = race_tab, --种族限制
                wall_coef = wall_coef, -- 地块难度墙
                difficulty_reduce = difficulty_reduce, -- 每周降低强数值
                lock_hids = lock_hids, -- 正在打扫战场的英雄配置id
                gve_version = version,
                def_data = def_data,
            }
        end

        self:openView("Formation", params)
    else
        Logger.logErrorAlways("gve_stage_item.battle_id： " .. tostring(gve_stage_item.battle_id) .. " cell_id : " .. tostring(cell_id) .. " stage_id : " .. tostring(stage_id))
    end
end

function M:showSkill(index, click_transform)
    local boss_skill = self.m_model:getBossSkillInID()
    if boss_skill then
        self:openView("Pops.SkillPop",{skill = boss_skill[index], index = index, cur_lv = 1 ,click_transform = click_transform, pivot = Vector2(0.5,1)})
    end
end

function M:destroy()
    UserDataManager.local_data:setUserDataByKey("qimendunjia_chooseFlag",self.m_model.m_star_choose_pass_flag and 1 or 0)
    M.super.destroy(self)
end

return M
