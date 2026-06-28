------------------- BattleModeUtil
---@class BattleModelUtil
local M = {}

-- 不一定每个方法都需要实现

--formationModel ： 布阵初始化
--formationControlClose ：关闭布阵界面
--formationControl ： 布阵挑战按钮
--formationControlSaveTeam ： 布阵保存队伍
--gamePanelModel ： 战斗初始化
--gamePanelControlExit ： 战斗界面暂停后的推出战斗按钮
--gamePanelControlRestart ： 战斗界面暂停后的重新开始战斗按钮
--settlementModel ： 结算初始化
--settlementControlToFormation ： 结算后继续布阵挑战
--settlementControlClose ： 结算后结算挑战

-----------------------------------------------------------------单队伍----------------------------------------------------------------------------
-- 推图
M[GlobalConfig.BATTLE_MODE.STAGE] = {
    formationControl = function(control, team, callfunc)
        if control:isStoryLevel() then
            --剧情关战斗
            local level_id = UserDataManager:getBattleStage()
            control.m_model:getNetData(
                "scenario_battle_start",
                {
                    relic = control.m_model.m_solts,
                    battle_pet = control.m_model.m_battle_pet,
                    team = team,
                    normal_array = control.m_model.m_normal_array,
                    deployment = control.m_model.m_atk_deployment,
                    s_id = level_id,
                    node_id = control.m_model.node_id
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
            )
        else
            control.m_model:getNetData(
                "stage_battle_start2",
                {
                    team = team,  
                    relic = control.m_model.m_solts,
                    battle_pet = control.m_model.m_battle_pet,
                    normal_array = control.m_model.m_normal_array,
                    deployment = control.m_model.m_atk_deployment
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
            )
        end
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData("stage_battle_end2", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
            "challenge_btn",
            {new_chapter = control.m_new_chapter, auto_battle_flag = auto_battle_flag},
            "parent"
        )
    end
}

M[GlobalConfig.BATTLE_MODE.XIAKEDAO] = {
    ---@param control FormationControl
    formationControl = function(control, team, callfunc)
        if control:isStoryLevel() then
            --剧情关战斗
            --local level_id = UserDataManager:getBattleStage()
            --control.m_model:getNetData(
            --        "scenario_battle_start",
            --        {
            --            relic = control.m_model.m_solts,
            --            battle_pet = control.m_model.m_battle_pet,
            --            team = team,
            --            normal_array = control.m_model.m_normal_array,
            --            deployment = control.m_model.m_atk_deployment,
            --            s_id = level_id,
            --            node_id = control.m_model.node_id
            --        },
            --        callfunc,
            --        false,
            --        nil,
            --        GlobalConfig.POST
            --)
        else
            control.m_model:getNetData(
                    "hero_isle_battle_start",
                    {
                        team = team,
                        relic = control.m_model.m_solts,
                        battle_pet = control.m_model.m_battle_pet,
                        normal_array = control.m_model.m_normal_array,
                        deployment = control.m_model.m_atk_deployment
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        end
    end,
    ---@param model SettlementModel
    settlementModel=function(model,upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData("hero_isle_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "mijing_btn",
                {},
                "Xiakedao"
        )
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:setOnceTimer(1,function()
            control:updateMsg("common_refresh", nil, "Xiakedao")
            control:updateMsg("change_scene", nil, "Main.Outskirts")
            control:closeView()
        end)
    end,
    ---@param control GamePanelControl
    gamePanelControlRestart = function(control)
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("mijing_btn", nil, "Xiakedao")
    end
}

M[GlobalConfig.BATTLE_MODE.RACCON] = {
    formationControl = function(controlllfunc)
        if control:isStoryLevel() then
            --剧情关战斗
            local url = (control.m_model.m_special_open_id and control.m_model.m_special_version) and "raccon_common_battle_start" or "raccon_battle_start"
            local level_id = UserDataManager:getBattleStage()
            control.m_model:getNetData(
                    url,
                    {
                        open_id = control.m_model.m_special_open_id,
                        vsn = control.m_model.m_special_version,
                        relic = control.m_model.m_solts,
                        battle_pet = control.m_model.m_battle_pet,
                        team = team,
                        deployment = control.m_model.m_atk_deployment,
                        s_id = level_id,
                        node_id = control.m_model.node_id
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        else
            local url = (control.m_model.m_special_open_id and control.m_model.m_special_version) and "raccon_common_battle_start" or "raccon_battle_start"
            control.m_model:getNetData(
                    url,
                    {
                        open_id = control.m_model.m_special_open_id,
                        vsn = control.m_model.m_special_version,
                        team = team,
                        hero_id = control.m_model.m_raccon_hero_id,
                        stage_id = control.m_model.m_stage_id,
                        relic = control.m_model.m_solts,
                        battle_pet = control.m_model.m_battle_pet,
                        normal_array = control.m_model.m_normal_array,
                        deployment = control.m_model.m_atk_deployment
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        end
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("refreh_index", response, "Raccon.RacconXkz")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        local params = {}
        params.stage_id = control.m_model.m_params.stage_id
        params.raccon_hero_id = control.m_model.m_params.raccon_hero_id
        params.battle_id = control.m_model.m_params.battle_id
        params.mode = control.m_model.m_params.mode
        control:updateMsg("rebattle", params, "Raccon.RacconXkzDetail")
        control:updateMsg("rebattle",params, "NationalBeautiful.NationalBeautifulXkzDetail")
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            upload_data.stage_id = model.m_params.stage_id
            upload_data.hero_id = model.m_params.raccon_hero_id
            local url = (model.m_special_open_id and model.m_special_version) and "raccon_common_battle_end" or "raccon_battle_end"
            if model.m_special_open_id and model.m_special_version then
                upload_data.open_id = model.m_special_open_id
                upload_data.vsn = model.m_special_version
            end
            model:getData(url, upload_data, function(response)
                if response and response.new_unlock_hero then
                    control:updateMsg("unlock_new_chapter", response.new_unlock_hero, "Raccon.RacconXkzDetail")
                    control:updateMsg("unlock_new_chapter", response.new_unlock_hero, "NationalBeautiful.NationalBeautifulXkzDetail")
                end
            end, GlobalConfig.POST, {forceBack = true})
        end
    end,
    ---@param control SettlementControl
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "challenge_btn",
                {new_chapter = control.m_new_chapter, auto_battle_flag = auto_battle_flag},
                "parent"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("refreh_index", response, "Raccon.RacconXkz")
        control:updateMsg("refreh_index", response, "NationalBeautiful.NationalBeautifulXkz")
        --control:updateMsg("refreh_index", response, "Raccon.RacconXkzDetail")
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            control:closeView()
        end
    end
}

-- 多队推图
M[GlobalConfig.BATTLE_MODE.MULT_STAGE] = {
    formationControl = function(control, teams, callfunc)
        if control:isStoryLevel() then
            --剧情关战斗
            local level_id = UserDataManager:getBattleStage()
            control.m_model:getNetData(
                    "scenario_battle_start",
                    {
                        relic = control.m_model.m_solts,
                        teams = teams,
                        battle_pets = control.m_model.m_mult_battle_pets,
                        normal_arrays = control.m_model.m_mult_normal_array,
                        deployment = control.m_model.m_atk_deployment,
                        s_id = level_id,
                        node_id = control.m_model.node_id
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        else
            control.m_model:getNetData(
                    "stage_mul_team_battle_start",
                    {
                        teams = teams,
                        battle_pets = control.m_model.m_mult_battle_pets,
                        relics = control.m_model.m_mult_solts,
                        deployments = control.m_model.m_mult_deployments,
                        normal_arrays = control.m_model.m_mult_normal_array,
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        end
    end,
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("mult_team_stage"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("mult_team_stage"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("mult_team_stage"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("mult_team_stage"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("mult_team_stage"))
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        local _, _, teams = GameUtil:getBattleStageCfg()
        for i = 1, teams do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        model.m_show_record_btn = false
        if model.m_quick_pass then
            model:callBack(model.m_params.data)
        else
            model.m_result = upload_data.result
            model:getData("stage_mul_team_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "challenge_btn",
                {new_chapter = control.m_new_chapter, auto_battle_flag = auto_battle_flag},
                "parent"
        )
    end
}


M[GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI] = {
    ---@param control FormationControl
    formationControl = function(control, teams, callfunc)
        if control:isStoryLevel() then
            --剧情关战斗
            local level_id = UserDataManager:getBattleStage()
            control.m_model:getNetData(
                    "scenario_battle_start",
                    {
                        relic = control.m_model.m_solts,
                        teams = teams,
                        battle_pets = control.m_model.m_mult_battle_pets,
                        normal_arrays = control.m_model.m_mult_normal_array,
                        deployment = control.m_model.m_atk_deployment,
                        s_id = level_id,
                        node_id = control.m_model.node_id
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        else
            control.m_model:getNetData(
                    "hero_isle_mul_team_battle_start",
                    {
                        teams = teams,
                        battle_pets = control.m_model.m_mult_battle_pets,
                        relics = control.m_model.m_mult_solts,
                        deployments = control.m_model.m_mult_deployments,
                        normal_arrays = control.m_model.m_mult_normal_array,
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        end
    end,
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("hero_isle_mul"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("hero_isle_mul"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("hero_isle_mul"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("hero_isle_mul"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("hero_isle_mul"))
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        --local _, _, teams = GameUtil:getBattleStageCfg()
        --for i = 1, teams do
        --    if model.mult_main_teams[i] == nil then
        --        model.mult_main_teams[i] = {}
        --    end
        --    model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        --end

        local stage_tab = ConfigManager:getCfgByName("hero_isle_layer")
        local data = stage_tab[model.m_params.layer]
        local battle_id_tab = data["battles"] or {}
        local teamNum=#battle_id_tab
        for i = 1, teamNum do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end

        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    ---@param model SettlementModel
    settlementModel = function(model, upload_data)
        model.m_show_record_btn = false
        if model.m_quick_pass then
            model:callBack(model.m_params.data)
        else
            model.m_result = upload_data.result
            model:getData("hero_isle_mul_team_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    ---@param control SettlementControl
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "mijing_btn",
                {
                    func=function()
                        control:updateMsg("common_refresh", nil, "Xiakedao")
                        control:updateMsg("change_scene", nil, "Main.Outskirts")
                        control:closeView()
                    end
                },
                "Xiakedao"
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    settlementControlClose = function(control, mode, model, type)
        --if control.m_model:checIsSkip() == true then
        --    control:closeView()
        --    control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        --    control:updateMsg("battle_end_refresh_ui", nil, "GuJianQiTan.GuJianQiTanShow")
        --else
        --    control:closeView()
        --    control:updateMsg("battle_end_refresh_ui", nil, "GuJianQiTan.GuJianQiTanShow")
        --end
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:setOnceTimer(1,function()
            control:updateMsg("common_refresh", nil, "Xiakedao")
            control:updateMsg("change_scene", nil, "Main.Outskirts")
            control:closeView()
        end)
    end,
    ---@param control GamePanelControl
    gamePanelControlRestart = function(control)
        control:updateMsg("common_refresh", nil, "Xiakedao")
        control:updateMsg("mijing_btn", nil, "Xiakedao")
    end
}

-- 古剑奇谭，多队伍
M[GlobalConfig.BATTLE_MODE.GU_JIAN_MULT] = {
    formationControl = function(control, teams, callfunc)
        control.m_model:getNetData(
                "ancient_sword_and_wonderland_battle_start",
                {
                    teams = teams,
                    relics = control.m_model.m_mult_solts,
                    battle_pets = control.m_model.m_mult_battle_pets,
                    deployments = control.m_model.m_mult_deployments,
                    normal_arrays = control.m_model.m_mult_normal_array,
                    ancient_sword_now_id = control.m_model.m_stage_id
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("ancient_sword"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("ancient_sword"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("ancient_sword"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("ancient_sword"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("ancient_sword"))
        for i = 1, 2 do
            if i > model.m_team_nums then
                model.mult_main_teams[i] = nil
            elseif model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            if model.m_mult_deployments[i] == nil or i > model.m_team_nums then
                model.m_mult_deployments[i] = 1
            end
            if model.m_mult_solts[i] == nil or i > model.m_team_nums then
                model.m_mult_solts[i] = {}
            end
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 2 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or 1
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("Tiaozhan", nil, "GuJianQiTan.GuJianQiTanShow")
    end,
    settlementModel = function(model, upload_data)
        upload_data.ancient_sword_now_id = model.m_stage_id
        model.m_show_record_btn = false
        if model.m_quick_pass then
            model:callBack(model.m_params.data)
        else
            model.m_result = upload_data.result
            model:getData("ancient_sword_and_wonderland_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "challenge_btn",
                {new_chapter = control.m_new_chapter, auto_battle_flag = auto_battle_flag},
                "parent"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
            control:updateMsg("battle_end_refresh_ui", nil, "GuJianQiTan.GuJianQiTanShow")
        else
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "GuJianQiTan.GuJianQiTanShow")
        end
    end
}

-- 爬塔
M[GlobalConfig.BATTLE_MODE.TOWER] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "tower_battle_start",
            {team = team, relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,deployment = control.m_model.m_atk_deployment},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        control:updateMsg("common_refresh", nil, "Budo")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Budo")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_race = model.m_params.ext_data.race or 0
        upload_data.race = model.m_race
        model:getData("tower_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
            "battle_end_refresh_ui",
            {data = model.m_data, mode = mode, open_formation = 1, func = func, auto_battle_flag = auto_battle_flag},
            "Budo"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {reward = control.m_model.m_rewards}, "Budo")
        if control.m_model:checIsSkip() == true then
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        end
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 种族塔
M[GlobalConfig.BATTLE_MODE.RACE_TOWER] = {
    formationModel = function(model)
        local key = "race_tower_" .. model.m_race
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey(key))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey(key)
        model.m_normal_array = table.copy(UserDataManager:getNormalArray(key))
        model.m_battle_pet = table.copy(UserDataManager:getPet(key))
    end,
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "tower_battle_start",
            {team = team, relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,race = control.m_model.m_race, deployment = control.m_model.m_atk_deployment},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("common_refresh", nil, "Budo")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("race_tower_" .. model.m_race))
    end,
    settlementModel = function(model, upload_data)
        model.m_race = model.m_params.ext_data.race or 0
        upload_data.race = model.m_race
        model:getData("tower_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
            "battle_end_refresh_ui",
            {data = model.m_data, mode = mode, open_formation = 1, func = func, auto_battle_flag = auto_battle_flag},
            "Budo"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {reward = control.m_model.m_rewards}, "Budo")
        if control.m_model:checIsSkip() == true then
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        end
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 活动爬塔
M[GlobalConfig.BATTLE_MODE.ACTIVE_TOWER] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "tower_active_battle_start",
                {team = team, relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,deployment = control.m_model.m_atk_deployment, layer = control.m_model.m_budo_floor},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("common_refresh", nil, "BudoServer")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("tower_active"))
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "BudoServer")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model:getData("tower_active_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "battle_end_refresh_ui",
                {data = model.m_data, mode = mode, open_formation = 1, func = func, auto_battle_flag = auto_battle_flag},
                "BudoServer"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {reward = control.m_model.m_rewards}, "BudoServer")
        if control.m_model:checIsSkip() == true then
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        end
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}
-- 迷宫
M[GlobalConfig.BATTLE_MODE.MAZE] = {
    formationControl = function(control, team, callfunc)
        local mver = UserDataManager:getTempData("maze_stage_mver")
        if control.m_model.m_params.type == "maze_encounter_battle_start" then
            control.m_model:getNetData(
                "maze_encounter_battle_start",
                {
                    cell_id = control.m_model.m_params.def_data.id,
                    team = team,
                    battle_pet = control.m_model.m_battle_pet,
                    relic = control.m_model.m_solts,
                    normal_array = control.m_model.m_normal_array,
                    deployment = control.m_model.m_atk_deployment,
                    mver = mver
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
            )
        else
            control.m_model:getNetData(
                "maze_battle_start",
                {
                    cell_id = control.m_model.m_params.def_data.id,
                    team = team,
                    battle_pet = control.m_model.m_battle_pet,
                    relic = control.m_model.m_solts,
                    normal_array = control.m_model.m_normal_array,
                    deployment = control.m_model.m_atk_deployment,
                    mver = mver
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
            )
        end
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "MazeStage")
        control:closeView()
    end,
    gamePanelControlRestart = function(control, m_type)
        control:updateMsg("battle_end_refresh_ui", {data = {m_type = m_type}, open_formation = 1}, "MazeStage")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "MazeStage")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        local mver = UserDataManager:getTempData("maze_stage_mver")
        upload_data.mver = mver
        upload_data.cell_id = model.m_params.def_data.id
        if model.m_params.battle_type == "maze_encounter_battle_start" then
            model:getData("maze_encounter_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        else
            model:getData("maze_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        if model.m_result ~= 1 then
            control:openView("Pops.TransitionPage")
        end
        control:updateMsg(
            "battle_end_refresh_ui",
            {data = model.m_data, open_formation = model.m_result == 1 and 0 or 1, func = func},
            "MazeStage"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "MazeStage")
    end
}

-- 古剑奇谭，迷宫
M[GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE] = {
    formationControl = function(control, team, callfunc)
        local mver = UserDataManager:getTempData("gu_jian_maze_mver")
        if control.m_model.m_params.type == "maze_encounter_battle_start" then
            control.m_model:getNetData(
                    "maze_encounter_battle_start",
                    {
                        cell_id = control.m_model.m_params.def_data.id,
                        team = team,
                        relic = control.m_model.m_solts,
                        battle_pet = control.m_model.m_battle_pet,
                        normal_array = control.m_model.m_normal_array,
                        deployment = control.m_model.m_atk_deployment,
                        mver = mver
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        else
            control.m_model:getNetData(
                    "ancient_sword_and_wonderland_battle_start2",
                    {
                        cell_id = control.m_model.m_params.def_data.id,
                        team = team,
                        battle_pet = control.m_model.m_battle_pet,
                        relic = control.m_model.m_solts,
                        normal_array = control.m_model.m_normal_array,
                        deployment = control.m_model.m_atk_deployment,
                        mver = mver
                    },
                    callfunc,
                    false,
                    nil,
                    GlobalConfig.POST
            )
        end
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "GuJianQiTan.GuJianQiTanMaze")
        control:closeView()
    end,
    gamePanelControlRestart = function(control, m_type)
        control:updateMsg("battle_end_refresh_ui", {data = {m_type = m_type}, open_formation = 1}, "GuJianQiTan.GuJianQiTanMaze")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "GuJianQiTan.GuJianQiTanMaze")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        local mver = UserDataManager:getTempData("gu_jian_maze_mver")
        upload_data.mver = mver
        upload_data.cell_id = model.m_params.def_data.id
        if model.m_params.battle_type == "maze_encounter_battle_start" then
            model:getData("maze_encounter_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        else
            model:getData("ancient_sword_and_wonderland_battle_end2", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        if model.m_result ~= 1 then
            control:openView("Pops.TransitionPage")
        end
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data, open_formation = model.m_result == 1 and 0 or 1, func = func}, "GuJianQiTan.GuJianQiTanMaze")
    end,
    settlementControlClose = function(control, mode, model, type)
        control:openView("Loading.SyncLoadBigLoading", {isShowBg = true})
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "GuJianQiTan.GuJianQiTanMaze")
    end
}

-- 竞技场
M[GlobalConfig.BATTLE_MODE.LOCAL_ARENA] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "arena_battle_start",
            {
                team = team,
                battle_pet = control.m_model.m_battle_pet,
                relic = control.m_model.m_solts,
                normal_array = control.m_model.m_normal_array,
                defend_uid = control.m_model.m_params.defend_uid,
                deployment = control.m_model.m_atk_deployment
            },
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        -- model:getData("arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            --model:getData("arena_battle_end_sync2", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    ---@param control SettlementControl
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:goToMain(mode, model)
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaNormal.ArenaNormalChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaNormal.ArenaNormalLog")
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Arena.ArenaNormal.ArenaNormal")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 种族竞技场
M[GlobalConfig.BATTLE_MODE.RACE_ARENA] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "race_arena_battle_start",
            {
                team = team,
                relic = control.m_model.m_solts,
                battle_pet = control.m_model.m_battle_pet,
                normal_array = control.m_model.m_normal_array,
                defend_uid = control.m_model.m_params.defend_uid,
                deployment = control.m_model.m_atk_deployment
            },
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
        --control.m_model:getNetData("race_arena_battle_start_sync",{team = team, defend_uid = control.m_model.m_params.defend_uid, deployment = control.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,

    settlementModel = function(model, upload_data)
        -- model:getData("arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            --model:getData("race_arena_battle_end_sync", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:goToMain(mode, model)
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaRace.ArenaRaceChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaRace.ArenaRaceLog")
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Arena.ArenaRace.ArenaRace")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
    end
}
-- 苗疆觅宝
M[GlobalConfig.BATTLE_MODE.MINING] = {
    formationControl = function(control, team, callfunc)
        control:updateMsg(99999,nil,"HuntTreasures.HuntTreasuresAreaInfoPop")
        control.m_model:getNetData("mining_battle_start",{team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,mine_oid = control.m_model.m_params.mine_oid, deployment = control.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("mining"))
        for i = 1,4 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        local region_id = model.m_region_id or 1
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("mining_"..region_id))
        --model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    formationModel = function(model)
        local temp_team = table.copy(UserDataManager.hero_data:getMultTeamByKey("mining"))
        local temp_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("mining"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("mining"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("mining"))
        if not (temp_team[model.m_params.region_id]) then
            temp_team = table.copy(UserDataManager.hero_data:getMultTeamByKey("mining_defense"))
            temp_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("mining_defense"))
            model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("mining_defense"))
            model.m_battle_pet = table.copy(UserDataManager:getPet("mining_defense"))
        end
        if temp_team[model.m_params.region_id] == nil then
            temp_team[model.m_params.region_id] = {}
            temp_deployments[model.m_params.region_id] = 1
        end
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("mining_"..model.m_params.region_id))
        --model.main_team = temp_team[model.m_params.region_id]
        model.m_atk_deployment = temp_deployments[model.m_params.region_id] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:goToMain(mode, model)
    end,
    settlementControlClose = function(control, mode, model, type)
        local occupy_success = nil
        if model and model.m_data and model.m_data.occupy_success then
            occupy_success = model.m_data.occupy_success
        end
        control:updateMsg("battle_end_refresh_ui", { occupy_success = occupy_success }, "HuntTreasures")
        --control:updateMsg("battle_end_refresh_ui",{data = model.m_data},"Arena.ArenaRace.ArenaRace")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 夺宝奇兵
M[GlobalConfig.BATTLE_MODE.ACTIVE_MINING] = {
    formationControl = function(control, team, callfunc)
        control:updateMsg(99999,nil,"HuntTreasuresGuild.HuntTreasuresGuildAreaInfoPop")
        local ver = UserDataManager.local_data:getLocalDataByKey("HuntTreasuresGuildVersion", 1) -- 存贮活动版本号
        control.m_model:getNetData("active_mining_battle_start",{ver = ver, team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array, mine_oid = control.m_model.m_params.mine_oid, deployment = control.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("active_mining"))
        for i = 1,4 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        local region_id = model.m_region_id or 1
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("active_mining_"..region_id))
        --model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    formationModel = function(model)
        local temp_team = table.copy(UserDataManager.hero_data:getMultTeamByKey("active_mining"))
        local temp_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("active_mining"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("active_mining"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("active_mining"))
        if not (temp_team[model.m_params.region_id]) then
            model.m_battle_pet = table.copy(UserDataManager:getPet("active_mining_defense"))
            temp_team = table.copy(UserDataManager.hero_data:getMultTeamByKey("active_mining_defense"))
            temp_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("active_mining_defense"))
            model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("active_mining_defense"))
        end
        if temp_team[model.m_params.region_id] == nil then
            temp_team[model.m_params.region_id] = {}
            temp_deployments[model.m_params.region_id] = 1
        end
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("active_mining_"..model.m_params.region_id))
        --model.main_team = temp_team[model.m_params.region_id]
        model.m_atk_deployment = temp_deployments[model.m_params.region_id] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:goToMain(mode, model)
    end,
    settlementControlClose = function(control, mode, model, type)
        local occupy_success = nil
        if model and model.m_data and model.m_data.occupy_success then
            occupy_success = model.m_data.occupy_success
        end
        control:updateMsg("battle_end_refresh_ui", { occupy_success = occupy_success }, "HuntTreasuresGuild")
        --control:updateMsg("battle_end_refresh_ui",{data = model.m_data},"Arena.ArenaRace.ArenaRace")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}
-- 世界boss
M[GlobalConfig.BATTLE_MODE.WORLD_BOSS] = {
    formationControl = function(control, team, callfunc)
        local battle_config = control.m_model.m_params.battle_config_id
        local boss_id = control.m_model.m_params.boss_id
        control.m_model:getNetData(
            "world_boss_battle_start2",
            {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, config_id = battle_config,normal_array = control.m_model.m_normal_array, deployment = control.m_model.m_atk_deployment, boss_id = boss_id},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        local boss_cur_damage = control.m_model.m_boss_cur_damage and control.m_model.m_boss_cur_damage or 0
        local boss_max_hp = control.m_model.m_boss_max_hp and control.m_model.m_boss_max_hp or 0
        local is_die = false
        if boss_cur_damage >= boss_max_hp and boss_cur_damage > 0 then
            is_die = true
        end
        SceneManager:getCurSceneModel():resetCamera(is_die)
        control:openView("Activities.WorldBoss")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_result = 1
        model:setRoundResult()
        --upload_data.damage = model.m_damage
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        upload_data.use_time = model.m_battle_time
        upload_data.damage = model.m_params.boss_dmg
        upload_data.result = 1 --boss结果默认胜利
        upload_data.boss_id = model.m_params.boss_id
        model:getData("world_boss_battle_end2", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        SceneManager:continue()
        control:updateMsg("fresh_data",nil, "Activities.WorldBoss")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 公会boss
M[GlobalConfig.BATTLE_MODE.UNION_BOSS] = {
    formationControl = function(control, team, callfunc)
        local battle_config = control.m_model.m_params.battle_config_id
        control.m_model:getNetData(
            "guild_boss_battle_start",
            {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, config_id = battle_config, normal_array = control.m_model.m_normal_array,deployment = control.m_model.m_atk_deployment},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        SceneManager:getCurSceneView():resetCamera()
        control:openView("UnionBoss")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_result = 1
        model:setRoundResult()
        upload_data.damage = model.m_damage
        upload_data.result = 1 --公会boss结果默认胜利
        model:getData("guild_boss_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("fresh_data", nil, "UnionBoss")
    end
}

-- 时光之巅
M[GlobalConfig.BATTLE_MODE.TOP_OF_TIME] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "rpg_battle_start",
            {
                team = team,
                battle_pet = control.m_model.m_battle_pet,
                relic = control.m_model.m_solts,
                normal_array = control.m_model.m_normal_array,
                chapter_id = control.m_model.chapter_id,
                block_id = control.m_model.block_id,
                deployment = control.m_model.m_atk_deployment
            },
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "Shiguang")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_end_refresh_ui", {data = {}, open_formation = 1}, "Shiguang")
    end,
    settlementModel = function(model, upload_data)
        local grid_data = UserDataManager:getTempData("shiguang_grid_data")
        upload_data.chapter_id = grid_data.chapter_id
        upload_data.block_id = grid_data.block_id
        model:getData("rpg_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        if model.m_result ~= 1 then
            control:openView("Pops.TransitionPage")
        end
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data, open_formation = model.m_result == 1 and 0 or 1, func = func}, "Shiguang")
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Shiguang")
    end
}

-- 五行阵
M[GlobalConfig.BATTLE_MODE.FIVE_ARRAY] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "mood_shadow_battle_start",
            {team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment, version = control.m_model.version},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Fivelines")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_start", nil, "Fivelines")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Fivelines")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        --总伤害
        upload_data.damage = model.m_damage or 0
        if upload_data.damage > 0 then
            upload_data.result = 1;
            model.m_result = 1
        end
        Logger.logError(" 上传的总伤害 "..model.m_damage.." upload_data.result "..upload_data.result )
        --版本号
        upload_data.version = model.version
        model:getData("mood_shadow_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Fivelines")
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "MoonShadow.MoonShadowBattle")
        end
    end
}


-- 邪极魅影
--M[GlobalConfig.BATTLE_MODE.EVIL_SHADOW] = {
--    formationControl = function(control, team, callfunc)
--        control.m_model:getNetData(
--                "evil_shadow_battle_start",
--                {team = team,relic = control.m_model.m_solts, position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment, version = control.m_model.version},
--                callfunc,
--                false,
--                nil,
--                GlobalConfig.POST
--        )
--    end,
--    formationControlClose = function(control)
--        control:updateMsg("battle_end_refresh_ui", nil, "EvilShadow.EvilShadowBattle")
--        control:closeView()
--    end,
--    gamePanelControlRestart = function(control)
--        control:updateMsg("battle_start", nil, "EvilShadow.EvilShadowBattle")
--    end,
--    gamePanelControlExit = function(control)
--        control:updateMsg("battle_end_refresh_ui", nil, "EvilShadow.EvilShadowBattle")
--        control:closeView()
--    end,
--    settlementModel = function(model, upload_data)
--        model.m_five_pos = model.m_params.m_five_pos
--        model.m_floor = model.m_params.m_floor
--        upload_data.position = model.m_five_pos
--        --总伤害
--        upload_data.damage = model.m_damage or 0
--        if upload_data.damage > 0 then
--            upload_data.result = 1;
--            model.m_result = 1
--        end
--        --版本号
--        upload_data.version = model.version
--        model:getData("evil_shadow_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
--    end,
--    settlementControlClose = function(control, mode, model, type)
--        if control.m_model:checIsSkip() == true then
--            control:closeView()
--            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
--        else
--            --       end
--            --   end })
--            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
--            --      if open_flag == "open_view" then
--            control:closeView()
--            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "EvilShadow.EvilShadowBattle")
--        end
--    end
--}
-- 龙泉剑影
M[GlobalConfig.BATTLE_MODE.DRAGONSWORD] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "active_dragonsword_battle_start",
                {team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array,deployment = control.m_model.m_atk_deployment, vsn = control.m_model.version},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Dragonsword.DragonswordBattle")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_start", nil, "Dragonsword.DragonswordBattle")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Dragonsword.DragonswordBattle")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor--总伤害
        if upload_data.damage > 0 then
            upload_data.result = 1
            model.m_result = 1
        end
        --版本号
        upload_data.version = model.version
        model:getData("active_dragonsword_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Dragonsword.DragonswordBattle")
        end
    end
}

-- 唐伯虎通用活动
M[GlobalConfig.BATTLE_MODE.EVIL_SHADOW] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "hero_event_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment, version = control.m_model.version},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "ActiveCurrent.ActiveCurrentBattle")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_start", nil, "ActiveCurrent.ActiveCurrentBattle")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "ActiveCurrent.ActiveCurrentBattle")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        --总伤害
        upload_data.damage = model.m_damage or 0
        if upload_data.damage > 0 then
            upload_data.result = 1;
            model.m_result = 1
        end
        --版本号
        upload_data.version = model.version
        model:getData("hero_event_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "ActiveCurrent.ActiveCurrentBattle")
        end
    end
}

-- 三侠五义活动
M[GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "chivalrous_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment, version = control.m_model.version},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_start", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        --总伤害
        upload_data.damage = model.m_damage or 0
        if upload_data.damage > 0 then
            upload_data.result = 1;
            model.m_result = 1
        end
        --版本号
        upload_data.version = model.version
        model:getData("chivalrous_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
        end
    end
}

-- 通用试炼活动
M[GlobalConfig.BATTLE_MODE.COMMON_BATTLE] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "common_train_challenge_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet, normal_array = control.m_model.m_normal_array,position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment, version = control.m_model.version,open_id = control.m_model.open_id},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Chivalry.ChivalryBattle")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("battle_start", nil, "Chivalry.ChivalryBattle")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Chivalry.ChivalryBattle")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        --总伤害
        upload_data.damage = model.m_damage or 0
        if upload_data.damage > 0 then
            upload_data.result = 1;
            model.m_result = 1
        end
        --版本号
        upload_data.version = model.version
        upload_data.open_id = model.m_params.open_id
        model:getData("common_train_challenge_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Chivalry.ChivalryBattle")
        end
    end
}

-- 四象阵
M[GlobalConfig.BATTLE_MODE.FOUR_TOWER] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "four_tower_battle_start",
                {team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet,vsn = control.m_model.version,normal_array = control.m_model.m_normal_array, position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "FivelinesNew")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("reward_open_btn", {cell_data = {type = control.m_model.m_type}, index = control.m_model.m_five_pos, is_restart = true}, "FivelinesNew")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "FivelinesNew")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        upload_data.vsn = model.version
        model:getData("four_tower_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control and control.m_model and control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            --       end
            --   end })
            --    control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --      if open_flag == "open_view" then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {index = model.m_five_pos, result = model.m_result}, "FivelinesNew")
        end
    end
}

-- 极阴塔
M[GlobalConfig.BATTLE_MODE.YINYANG_TOWER] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "dark_tower_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array,vsn = control.m_model.version, position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "YinTower")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("reward_open_btn", {cell_data = {type = control.m_model.m_type}, index = control.m_model.m_five_pos, is_restart = true}, "YinTower")
    end,

    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "YinTower")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        upload_data.vsn = model.version
        model:getData("dark_tower_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control and control.m_model and control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {index = model.m_five_pos, result = model.m_result}, "YinTower")
        end
    end
}

-- 罗天摘星
M[GlobalConfig.BATTLE_MODE.WD_TOWER] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "wdtower_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array,vsn = control.m_model.version, position = control.m_model.m_five_pos, deployment = control.m_model.m_atk_deployment},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "WdTower")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlRestart = function(control)
        control:updateMsg("reward_open_btn", {cell_data = {type = control.m_model.m_type}, index = control.m_model.m_five_pos, is_restart = true}, "WdTower")
    end,

    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "WdTower")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_five_pos = model.m_params.m_five_pos
        model.m_floor = model.m_params.m_floor
        upload_data.position = model.m_five_pos
        upload_data.vsn = model.version
        model:getData("wdtower_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        if control and control.m_model and control.m_model:checIsSkip() == true then
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", nil, "Formation")
        else
            control:closeView()
            control:updateMsg("battle_end_refresh_ui", {index = model.m_five_pos, result = model.m_result}, "WdTower")
        end
    end
}
-- 大地图
M[GlobalConfig.BATTLE_MODE.BIG_MAP] = {
    formationControl = function(control, team, callfunc)
        if control.m_model.m_params.type == "occupy_battle_start" then
            local params = {}
            params.team = team
            params.deployment = control.m_model.m_atk_deployment
            params.building_id = control.m_model.m_params.building_id
            params.relic = control.m_model.m_solts
            params.battle_pet = control.m_model.m_battle_pet
            params.normal_array = control.m_model.m_normal_array
            control.m_model:getNetData("big_map_plunder_occupy_front", params, callfunc, nil, nil, GlobalConfig.POST)
        elseif control.m_model.m_params.type == "pillage_battle_start" then
            local params = {}
            params.team = team
            params.deployment = control.m_model.m_atk_deployment
            params.event_id = control.m_model.m_params.event_id
            params.building_id = control.m_model.m_params.building_id
            params.relic = control.m_model.m_solts
            params.battle_pet = control.m_model.m_battle_pet
            params.normal_array = control.m_model.m_normal_array
            control.m_model:getNetData("big_map_plunder_seize_front", params, callfunc, nil, nil, GlobalConfig.POST)
        elseif control.m_model.m_params.type == "regional_battle_start" then
            local params = {}
            params.map_id = UserDataManager:getTempData("regional_battle_map_id")
            params.task_id = UserDataManager:getTempData("regional_battle_task_id")
            params.art_type = UserDataManager:getTempData("regional_battle_art_type")
            params.article_id = UserDataManager:getTempData("regional_battle_article_id")
            params.choice_id = UserDataManager:getTempData("regional_battle_choice_id")
            params.team = team
            params.battle_pet = control.m_model.m_battle_pet
            params.relic = control.m_model.m_solts
            params.deployment = control.m_model.m_atk_deployment
            params.normal_array = control.m_model.m_normal_array
            control.m_model:getNetData("big_map_regional_battle_start", params, callfunc, nil, nil, GlobalConfig.POST)
        elseif control.m_model.m_params.type == "adventure_battle_start" then
            local event_id = UserDataManager:getTempData("map_battle_event_id")
            local event_type = UserDataManager:getTempData("map_battle_event_type")
            local map_battle_pos = UserDataManager:getTempData("map_battle_pos")
            local params = {}
            params.event_id = event_id
            params.type = event_type
            params.battle_pet = control.m_model.m_battle_pet
            params.team = team
            params.deployment = control.m_model.m_atk_deployment
            params.relic = control.m_model.m_solts
            params.map_pos = map_battle_pos
            params.normal_array = control.m_model.m_normal_array
            control.m_model:getNetData("big_map_event_battle_start", params, callfunc, nil, nil, GlobalConfig.POST)
        end
        --control.m_model:getNetData("big_map_plunder_occupy_front",{team = team,  deployment = control.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        local map_id = UserDataManager.cur_map_id
        if control.m_model.m_big_world_cur_scene_id and control.m_model.m_big_world_cur_scene_id ~= -1 then
            map_id = control.m_model.m_big_world_cur_scene_id
        end
        SceneManager:changeScene(map_id)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "WorldMap.WorldMapMain")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        local event_id = UserDataManager:getTempData("map_battle_event_id")
        local event_type = UserDataManager:getTempData("map_battle_event_type")
        if event_id and event_type then
            upload_data.event_id = event_id
            upload_data.type = event_type
            model:getData("big_map_event_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        else
            if model.m_params.battle_type == "occupy_battle_start" then
                local building_id = UserDataManager:getTempData("map_occupy_battle_building_id")
                upload_data.building_id = building_id
                model:getData("big_map_plunder_occupy_back", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            elseif model.m_params.battle_type == "pillage_battle_start" then
                local building_id_seize = UserDataManager:getTempData("plunder_seize_front_battle")
                if building_id_seize ~= nil then
                    upload_data.building_id = building_id_seize.building_id
                    upload_data.event_id = building_id_seize.event_id
                    model:getData("big_map_plunder_seize_back", upload_data, nil, GlobalConfig.POST, {forceBack = true})
                end
            end
        end
        local map_id = UserDataManager:getTempData("regional_battle_map_id")
        local task_id = UserDataManager:getTempData("regional_battle_task_id")
        local art_type = UserDataManager:getTempData("regional_battle_art_type")
        local article_id = UserDataManager:getTempData("regional_battle_article_id")
        local choice_id = UserDataManager:getTempData("regional_battle_choice_id")
        if map_id then
            upload_data.map_id = map_id
            upload_data.task_id = task_id
            upload_data.art_type = art_type
            upload_data.article_id = article_id
            upload_data.choice_id = choice_id
            model:getData("big_map_regional_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "WorldMap.WorldMapMain")
        control:closeView()
    end
}


-- 随机江湖
M[GlobalConfig.BATTLE_MODE.NEW_BIG_MAP] = {
    formationControl = function(control, team, callfunc)
        local params = {}
        params.map_id = UserDataManager:getTempData("new_regional_battle_map_id")
        params.task_id = UserDataManager:getTempData("new_regional_battle_task_id")
        params.art_type = UserDataManager:getTempData("new_regional_battle_art_type")
        params.article_id = UserDataManager:getTempData("new_regional_battle_article_id")
        params.choice_id = UserDataManager:getTempData("new_regional_battle_choice_id")
        params.team = team
        params.relic = control.m_model.m_solts
        params.battle_pet = control.m_model.m_battle_pet
        params.normal_array = control.m_model.m_normal_array
        params.deployment = control.m_model.m_atk_deployment
        control.m_model:getNetData("new_big_map_regional_battle_start", params, callfunc, nil, nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        local map_id = UserDataManager.cur_map_id
        if control.m_model.m_big_world_cur_scene_id and control.m_model.m_big_world_cur_scene_id ~= -1 then
            map_id = control.m_model.m_big_world_cur_scene_id
        end
        SceneManager:changeScene(map_id)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "WorldMapNew.WorldMemoryMain")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        local map_id = UserDataManager:getTempData("new_regional_battle_map_id")
        local task_id = UserDataManager:getTempData("new_regional_battle_task_id")
        local art_type = UserDataManager:getTempData("new_regional_battle_art_type")
        local article_id = UserDataManager:getTempData("new_regional_battle_article_id")
        local choice_id = UserDataManager:getTempData("new_regional_battle_choice_id")
        if map_id then
            upload_data.map_id = map_id
            upload_data.task_id = task_id
            upload_data.art_type = art_type
            upload_data.article_id = article_id
            upload_data.choice_id = choice_id
            model:getData("new_big_map_regional_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "WorldMapNew.WorldMemoryMain")
        control:closeView()
    end
}

-- 传记
M[GlobalConfig.BATTLE_MODE.BIOGRAPHY] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "biography_battle_start",
            {
                team = team,
                deployment = control.m_model.m_atk_deployment,
                normal_array = control.m_model.m_normal_array,
                bio_id = control.m_model.m_bio_id,
                battle_pet = control.m_model.m_battle_pet,
                chapter_id = control.m_model.m_chapter_id,
                relic = control.m_model.m_solts,
                stage_id = control.m_model.m_stage_id
            },
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        upload_data.bio_id = model.m_params.bio_id
        upload_data.chapter_id = model.m_params.chapter_id
        upload_data.stage_id = model.m_params.stage_id
        model:getData("biography_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

--  活动 侠客试炼
M[GlobalConfig.BATTLE_MODE.ACTIVE] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "train_challenge_battle_start",
            {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array, version = control.m_model.version, deployment = control.m_model.m_atk_deployment},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        --SceneManager:getCurSceneModel():resetCamera();
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView("Activities.WorldBoss")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("update_hero_train", control.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        model.m_result = 1
        model:setRoundResult()
        upload_data.damage = model.m_damage
        upload_data.version = model.version
        upload_data.result = 1 --大侠试炼结果默认胜利
        model:getData("train_challenge_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:closeView("Activities.WorldBoss")
        control:updateMsg("update_hero_train", control.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
        control:updateMsg("update_hero_train_data", control.m_model.m_data, "Activities.WorldBoss.WorldBossSelectMain")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

--  武道场
M[GlobalConfig.BATTLE_MODE.RAID] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
            "raid_battle_start",
            {team = team, relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array, deployment = control.m_model.m_atk_deployment, raid_sort = control.m_model.m_raid_sort},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "Main.Outskirts")
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("battle_end_refresh_ui", nil, "Taoist")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            upload_data.raid_sort = model.m_raid_sort
            model:getData("raid_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Taoist")
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Taoist")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 竞技场防守阵容
M[GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE] = {
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:arenaSetDefendTeam()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

-- 种族竞技场防守阵容
M[GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE] = {
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:raceArenaSetDefendTeam()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

-- 推图队伍设置
M[GlobalConfig.BATTLE_MODE.STAGE_SET_TEAM] = {
    formationControlSaveTeam = function(control)
        control:stageSetTeam()
    end
}

-----------------------------------------------------------------多队伍----------------------------------------------------------------------------

-- 高阶竞技场 多队伍
M[GlobalConfig.BATTLE_MODE.HIGH_ARENA] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("high_arena"))
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("high_arena"))
        model.m_def_mult_deployments = model.m_def_data.deployments or {}
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("high_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("high_arena"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.m_def_deployment = model.m_def_mult_deployments[model.m_formation_index] or 1
    end,
    formationControl = function(control, teams, callfunc, deployments)
        control.m_model:getNetData(
            "high_arena_battle_start",
            {teams = teams,normal_arrays = control.m_model.m_mult_normal_array, battle_pets = control.m_model.m_mult_battle_pets,relics = control.m_model.m_mult_solts, defend_uid = control.m_model.m_params.defend_uid, deployments = deployments},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = left_num > right_num and 1 or 0
            -- model:getData("high_arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherLog")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaHigher.ArenaHigher")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

M[GlobalConfig.BATTLE_MODE.MYTH_ARENA] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("myth_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("myth_arena"))
        model.m_def_mult_deployments = model.m_def_data.deployments or {}
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("myth_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("myth_arena"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("myth_arena"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.m_def_deployment = model.m_def_mult_deployments[model.m_formation_index] or 1
    end,
    formationControl = function(control, teams, callfunc, deployments)
        control.m_model:getNetData(
                "myth_arena_battle_start",
                {teams = teams, relics = control.m_model.m_mult_solts, battle_pets = control.m_model.m_mult_battle_pets, battle_pet = control.m_model.m_battle_pet, normal_arrays = control.m_model.m_mult_normal_array,defend_uid = control.m_model.m_params.defend_uid, deployments = deployments},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("myth_arena"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = left_num > right_num and 1 or 0
            -- model:getData("high_arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "MythArena.MythArenaMain")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}


-- 高阶竞技场 多队伍
M[GlobalConfig.BATTLE_MODE.HUASHAN_SWORD] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("arena_mountain_hua"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("arena_mountain_hua"))
        model.m_def_mult_deployments = model.m_def_data.deployments or {}
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("arena_mountain_hua"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("arena_mountain_hua"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("arena_mountain_hua"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.m_def_deployment = model.m_def_mult_deployments[model.m_formation_index] or 1
    end,
    formationControl = function(control, teams, callfunc, deployments)
        control.m_model:getNetData(
            "arena_mountain_hua_battle_start",
            {teams = teams, relics = control.m_model.m_mult_solts, battle_pets = control.m_model.m_mult_battle_pets, normal_arrays = control.m_model.m_mult_normal_array, defend_uid = control.m_model.m_params.defend_uid, deployments = deployments},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("arena_mountain_hua"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = left_num > right_num and 1 or 0
            -- model:getData("high_arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "HuashanSword.HuashanSwordChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "HuashanSwordHuashanSwordLog")
        control:updateMsg("battle_end_refresh_ui", nil, "HuashanSword.HuashanSwordMain")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

--  多编队
M[GlobalConfig.BATTLE_MODE.MULT_FORMATION] = {
    formationModel = function(model)
        local formation = UserDataManager.hero_data:getFormation()
        local index = tostring(model.m_formation_id)
        if formation[index] then
            model.main_team = table.copy(formation[index].team)
        else
            model.main_team = {}
        end
    end
}

-- 高阶竞技场防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena_defense"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("high_arena_defense"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("high_arena_defense"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("high_arena_defense"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("high_arena_defense"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:highArenaSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

M[GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("myth_arena_defense"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("myth_arena_defense"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("myth_arena_defense"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("myth_arena_defense"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("myth_arena_defense"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:mythArenaSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}


-- 华山论剑防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.HUASHAN_SWORD_DEFENSE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("arena_mountain_hua_defense"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("arena_mountain_hua_defense"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("arena_mountain_hua_defense"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("arena_mountain_hua_defense"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("arena_mountain_hua_defense"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:huashanSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

-- 天级赛阵容 多队伍
M[GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_race_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("top_race_arena"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("top_race_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("top_race_arena"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("top_race_arena"))
        model.m_def_mult_deployments = model.m_def_data.deployments or {}
        if not(next(model.mult_main_teams)) then
            model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_race_arena_defense"))
        end
        if not(next(model.m_mult_normal_array)) then
            model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("top_race_arena_defense"))
        end
        if not(next(model.m_mult_battle_pets)) then
            model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("top_race_arena_defense"))
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 2 do
                model.m_mult_normal_array[i] = 0
            end
        end
        for i = 1, 2 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.m_def_deployment = model.m_def_mult_deployments[model.m_formation_index] or 1
    end,
    formationControl = function(control, teams, callfunc, deployments)
        control.m_model:getNetData("race_arena_top_battle_start",{teams = teams, battle_pets = control.m_model.m_mult_battle_pets, normal_arrays = control.m_model.m_mult_normal_array,relics = control.m_model.m_mult_solts, defend_uid = control.m_model.m_params.defend_uid, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_race_arena"))
        for i = 1,2 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack( model.m_params.data )
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = upload_data.result or model.m_result
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui",nil,"Arena.ArenaRace.ArenaRaceChallenge")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end,
}

-- 天级赛防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE] = {
    ---@param model FormationModel
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_race_arena_defense"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("top_race_arena_defense"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("top_race_arena_defense"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("top_race_arena_defense"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("top_race_arena_defense"))
        model.m_def_mult_deployments = {-1, -1}
        for i = 1, 2 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 2 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:topArenaRaceSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}


-- 争锋联赛，单队，设置进攻阵容
M[GlobalConfig.BATTLE_MODE.ZF_ARENA] = {
    ---@param model FormationModel
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("rise_arena_atk_sgl"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("rise_arena_atk_sgl")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("rise_arena_atk_sgl"))
        --model.m_battle_pet = table.copy(UserDataManager:getPet("rise_arena_atk_sgl"))
        model:removeRepeatJobHero()
    end,
    ---@param control FormationControl
    formationControl = function(control, teams, callfunc)
        control.m_model:getNetData(
                "rise_arena_do_battle_sgl",
                {team= teams,
                 relic = control.m_model.m_solts,
                 normal_array = control.m_model.m_mult_normal_array,
                 deployment= control.m_model.m_mult_deployments,
                 defend_uid = control.m_model.m_params.defend_uid},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlSaveTeam = function(control)
        -- 进攻队伍不保存
        --control:fulwinArenaSetDefendTeams(1)
        control:updateMsg(99999)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:closeView()
        else
            control:closeView()
        end
    end,

    ---@param model SettlementModel
    settlementModel = function(model, upload_data)
        -- model:getData("arena_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            --model:getData("arena_battle_end_sync2", upload_data, nil, GlobalConfig.POST, {forceBack = true})
            model:getData()
        end
    end,
    ---@param control SettlementControl
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:goToMain(mode, model)
    end,

    ---@param control SettlementControl
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaPeak.ArenaPeakChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaRace.ArenaRaceLog")
        control:updateMsg("refresh_ui", nil, "Arena.ArenaPeak.ArenaPeak")
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Arena.ArenaPeak.ArenaPeak")

    end
}


-- 争锋联赛，多队，设置进攻阵容
M[GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL] = {
    ---@param model FormationModel
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("rise_arena_atk_mul"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("rise_arena_atk_mul"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("rise_arena_atk_mul"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("rise_arena_atk_mul"))
        --model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("rise_arena_atk_mul"))
        model.m_def_mult_deployments = {-1, -1, -1}
        local m_team_nums=model.m_team_nums
        for i = 1, m_team_nums do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}

            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, m_team_nums do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model:updateTeam_ban()
        model:removeRepeatJobHero()
    end,
    formationControl = function(control, teams, callfunc)
        control.m_model:getNetData(
                "rise_arena_do_battle_mul",
                {teams= teams, deployments= control.m_model.m_mult_deployments, relics = control.m_model.m_mult_solts, normal_arrays = control.m_model.m_mult_normal_array,
                 defend_uid = control.m_model.m_params.defend_uid},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlSaveTeam = function(control)
        -- 进攻队伍不保存
        --control:fulwinArenaSetDefendTeams(3)
        control:updateMsg(99999)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,

    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:closeView()
        else
            --EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
    ---@param model GamePanelModel
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("rise_arena_atk_mul"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack( model.m_params.data )
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = upload_data.result or model.m_result
            model:getData()
        end
    end,

    ---@param control SettlementControl
    --settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
    --    control:goToMain(mode, model)
    --end,

    ---@param control SettlementControl
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaPeak.ArenaPeakChallenge")
        control:updateMsg("battle_end_refresh_ui", nil, "Arena.ArenaRace.ArenaRaceLog")
        control:updateMsg("refresh_ui", nil, "Arena.ArenaPeak.ArenaPeak")
        control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Arena.ArenaPeak.ArenaPeak")
    end
}

-- 争锋联赛防守阵容 单队伍
M[GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("rise_arena_def_sgl"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("rise_arena_def_sgl")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("rise_arena_def_sgl"))
        --model.m_battle_pet = table.copy(UserDataManager:getPet("rise_arena_def_sgl"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("rise_arena_atk_sgl"))
        model:removeRepeatJobHero()
    end,
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:zfArenaSetDefendTeams(1)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            control:closeView()
        end
    end,
}

-- 争锋联赛防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL] = {
    ---@param model FormationModel
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("rise_arena_def_mul"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("rise_arena_def_mul"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("rise_arena_def_mul"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("rise_arena_def_mul"))
        --model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("rise_arena_def_mul"))
        model.m_def_mult_deployments = {-1, -1, -1}

        local m_team_nums=model.m_team_nums
        for i = 1, m_team_nums do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
            model.m_def_mult_deployments[i]=-1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, m_team_nums do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model:removeRepeatJobHero()
    end,
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:zfArenaSetDefendTeams(3)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:updateMsg("refresh_ban_heros",{heros_ban=control.m_model.m_forbidden_hero_ids},"Arena.ArenaPeak.ArenaPeak")
            control:updateMsg("refresh_ban_heros",{heros_ban=control.m_model.m_forbidden_hero_ids},"Arena.ArenaHigher.ArenaHigherDefendTeam")
        else
            control:closeView()
        end
    end,
}


M[GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("season_race_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("season_race_arena"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("season_race_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("season_race_arena"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("season_race_arena"))
        model.m_def_mult_deployments = model.m_def_data.deployments or {}
        if not(next(model.mult_main_teams)) then
            model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("season_race_arena_defense"))
        end
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.m_def_deployment = model.m_def_mult_deployments[model.m_formation_index] or 1
    end,
    formationControl = function(control, teams, callfunc, deployments)
        control.m_model:getNetData("race_arena_season_battle_start",{teams = teams, battle_pets = control.m_model.m_mult_battle_pets, relics = control.m_model.m_mult_solts,normal_arrays = control.m_model.m_mult_normal_array, defend_uid = control.m_model.m_params.defend_uid, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
    end,
    formationControlClose = function(control)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("season_race_arena"))
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack( model.m_params.data )
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = upload_data.result or model.m_result
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("battle_end_refresh_ui",nil,"Arena.ArenaRace.ArenaRaceChallenge")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end,
}

-- 五行联赛防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("season_race_arena_defense"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("season_race_arena_defense"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("season_race_arena_defense"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("season_race_arena_defense"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("season_race_arena_defense"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    ---@param control FormationControl
    formationControlSaveTeam = function(control)
        control:fiveArenaRaceSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}


-- 苗疆觅宝防守阵容 多队伍--2021-11-1  改为单阵容
M[GlobalConfig.BATTLE_MODE.MINING_DEFENSE] = {
    formationModel = function(model)
        -- model.m_mult_team_flag = true
        -- model.mining_defense_teams = table.copy(UserDataManager.hero_data:getTeamByKey("mining_defense"))
        -- model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("mining_defense"))
        -- model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("mining_defense"))
        -- model.m_def_mult_deployments = {-1, -1, -1, -1}
        -- for i = 1, 4 do
        --     if model.mining_defense_teams[i] == nil then
        --         model.mining_defense_teams[i] = {}
        --     end
        --     model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        -- end
        -- model.main_team = model.mining_defense_teams[model.m_formation_index] or {}
        -- model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("mining_defense_"..model.m_formation_index))
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("mining_defense_"..model.m_formation_index))
        model.m_battle_pet = table.copy(UserDataManager:getPet("mining_defense_"..model.m_formation_index))
        model.m_mult_deployments = 1
    end,
    formationControlSaveTeam = function(control)
        control:requestSaveMiningDefenseTeam()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:updateMsg("refresh_data", nil, "HuntTreasures.HuntTreasuresAreaInfoPop")
            control:updateMsg("battle_end_refresh_ui", nil, "HuntTreasures")
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}
-- 夺宝奇兵防守阵容 多队伍--2021-11-1  改为单阵容
M[GlobalConfig.BATTLE_MODE.ACTIVE_MINING_DEFENSE] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("active_mining_defense_"..model.m_formation_index))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("active_mining_defense_"..model.m_formation_index))
        model.m_battle_pet = table.copy(UserDataManager:getPet("active_mining_defense_"..model.m_formation_index))
        model.m_mult_deployments = 1
    end,
    formationControlSaveTeam = function(control)
        control:requestSaveActiveMiningDefenseTeam()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:updateMsg("refresh_data", nil, "HuntTreasuresGuild.HuntTreasuresGuildAreaInfoPop")
            control:updateMsg("battle_end_refresh_ui", nil, "HuntTreasuresGuild")
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

-- 巅峰论剑防守阵容 多队伍
M[GlobalConfig.BATTLE_MODE.TOP_ARENA_DEFENSE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("top_arena"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("top_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("top_arena"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("top_arena"))
        if next(model.mult_main_teams) == nil then
            model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena_defense"))
        end
        if next(model.m_mult_normal_array) == nil then
            model.m_mult_normal_array = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena_defense"))
        end
        if next(model.m_mult_battle_pets) == nil then
            model.m_mult_battle_pets = table.copy(UserDataManager.hero_data:getMultPets("high_arena_defense"))
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:topArenaSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

-- 巅峰论剑阵容 多队伍
M[GlobalConfig.BATTLE_MODE.TOP_ARENA] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_arena"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("top_arena"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("top_arena"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("top_arena"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("top_arena"))
        if next(model.mult_main_teams) == nil then
            model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena_defense"))
        end
        model.m_def_mult_deployments = {-1, -1, -1}
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:topArenaSetDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
}

local function unionWarFormationModel(model, team_key)
    model.m_mult_team_flag = true
    model.union_war_teams = table.copy(UserDataManager:getGvgTeamsByKey(team_key))
    -- model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray(team_key))
    local sel_team = model.union_war_teams[tostring(model.m_formation_index)]
    model.m_mult_solts = {}
    model.m_mult_battle_pets = {} --= table.copy(UserDataManager:getMultPets("mult_team_stage"))
    for k,v in pairs(model.union_war_teams) do
        model.m_mult_battle_pets[tonumber(k)] = v.battle_pet or ""
    end
    for k,v in pairs(model.union_war_teams) do
        model.m_mult_solts[tonumber(k)] = v.relic or {}
    end
    model.m_mult_normal_array = {}
    for k,v in pairs(model.union_war_teams) do
        model.m_mult_normal_array[tonumber(k)] = v.normal_array or 0
    end
    if sel_team ~= nil then
        model.main_team = table.copy(sel_team.team)
        model.temp_team = table.copy(sel_team.team)
        model.m_atk_deployment = sel_team.deployment
    else
        model.main_team = {}
        model.temp_team = {}
    end
end

local function unionWarFormationControlClose(control)
    if control.m_model.m_team_changed_flag or UserDataManager:getGvgTeamSetRewardFlag() == true then
        UserDataManager:setGvgTeamSetRewardFlag(false)
        control:saveFormation()
    else
        if static_rootControl:hasChild("UnionWar.UnionWarMain") then
            control:updateMsg("change_scene", nil, "UnionWar.UnionWarMain")
        elseif static_rootControl:hasChild("Arena.ArenaSelectMain") then
            control:updateMsg("change_scene", nil, "Main.Outskirts")
        else
            audio:SendEvtBGM("Set_State_ShiWu01")
        end
        control:closeView()
    end
end

local function unionWarTeamHasNullTips(control, callback)
    local params = {
        text = Language:getTextByKey("UnionWar_str_100"),
        ok_text = Language:getTextByKey("UnionWar_str_battleBegin"),
        cancel_text = Language:getTextByKey("UnionWar_str_cancel"),
        tow_close_btn = true,
        on_ok_call = function()
            if control.m_model then
                callback()
            end
        end
    }
    static_rootControl:openView("Pops.CommonPop", params, "union_war_team_has_null_tips")
end

local function unionWarFirstBattleTips(control, callback)
    local params = {
        text = Language:getTextByKey("UnionWar_str_battleLockTeam"),
        ok_text = Language:getTextByKey("UnionWar_str_battleBegin"),
        cancel_text = Language:getTextByKey("UnionWar_str_cancel"),
        tow_close_btn = true,
        on_ok_call = function()
            if control.m_model then
                if control.m_model:checkUnionTeamHasNull() then
                    unionWarTeamHasNullTips(control, callback)
                else
                    callback()
                end
            end
        end
    }
    static_rootControl:openView("Pops.CommonPop", params, "union_war_first_battle_tips")
end

-- 帮会战 多队伍
M[GlobalConfig.BATTLE_MODE.UNIONWAR] = {
    formationModel = function(model)
        unionWarFormationModel(model, "atk_teams")
    end,
    formationControl = function(control, teams, callfunc, deployments)
        local function __doBeginBattle()
            local simulated_battle_flag = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
            local def_data = control.m_model.m_def_data
            local params = {
                team = teams,
                star = def_data.star or 1,
                team_id = control.m_model.m_formation_index,
                cell_id = def_data.cell_id,
                key = def_data.key,
                --relics = control.m_model.m_mult_solts,
                --relic = control.m_model.m_solts,
                relic = control.m_model.m_mult_solts[control.m_model.m_formation_index],
                battle_pet = control.m_model.m_mult_battle_pets[control.m_model.m_formation_index],
                deployments = deployments,
                mock_battle = simulated_battle_flag == true and 1 or 0,
                normal_array = control.m_model.m_mult_normal_array[control.m_model.m_formation_index],
            }
            if simulated_battle_flag then
                local function netCallBack(response)
                    control.m_model.m_params.gvg_data.remain_mock_times = response.remain_mock_times
                    control.m_view:refreshRemainMockTimesText()
                    control:openView("Settlement", { result = response.result, mode = GlobalConfig.BATTLE_MODE.UNIONWAR, battle_data = {}, data = response})
                    --control:closeView()
                end
                control.m_model:getNetData("gvg_battle_start", params, netCallBack, false, nil, GlobalConfig.POST)
            else
                control.m_model:getNetData("gvg_battle_start", params, callfunc, false, nil, GlobalConfig.POST)
            end
        end
        local function checkTeamsChange()
            if control.m_model.m_team_changed_flag then
                control:requestSaveUnionWarTeam(__doBeginBattle)
            else
                __doBeginBattle()
            end
        end
        local attckedTeam = control.m_model.m_params.gvg_data.atk_use 
        if attckedTeam and next(attckedTeam) then
            checkTeamsChange()
        else
            unionWarFirstBattleTips(control, checkTeamsChange)
        end
    end,
    formationControlSaveTeam = function(control)
        control:requestSaveUnionWarTeam()
    end,
    formationControlClose = function(control)
        unionWarFormationControlClose(control)
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "UnionWar.UnionWarMain")
        control:closeView()
    end,
    gamePanelModel = function(model)
        model.main_team = {}
    end,
    settlementModel = function(model, upload_data)
        local simulated_battle_flag = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
        if simulated_battle_flag then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("change_scene", nil, "UnionWar.UnionWarMain")
    end
}

-- 帮会战 多队伍进攻
M[GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK] = {
    formationModel = function(model)
        unionWarFormationModel(model, "atk_teams")
    end,
    formationControlSaveTeam = function(control)
        control:requestSaveUnionWarTeam()
    end,
    formationControlClose = function(control)
        unionWarFormationControlClose(control)
    end,
    gamePanelModel = function(model)
        model.main_team = {}
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("change_scene", nil, "UnionWar.UnionWarMain")
    end
}

-- 帮会战 多队伍防守
M[GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE] = {
    formationModel = function(model)
        unionWarFormationModel(model, "def_teams")
    end,
    formationControlSaveTeam = function(control)
        control:requestSaveUnionWarTeam()
    end,
    formationControlClose = function(control)
        unionWarFormationControlClose(control)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    gamePanelModel = function(model)
        model.main_team = {}
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("change_scene", nil, "UnionWar.UnionWarMain")
    end
}

-- 帮会战 多队伍进攻
M[GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        local net_teams, net_solts = UserDataManager:getGuildHighWarTeamsByKey()
        model.mult_main_teams,model.m_mult_solts = table.copy(net_teams), table.copy(net_solts)
        model.m_mult_deployments = {}
        model.m_def_mult_deployments = {-1, -1, -1, -1, -1}
        for i = 1, GameUtil:getGuildHighWarTeamNums() do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            if model.m_mult_solts[i] == nil then
                model.m_mult_solts[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControl = function(control, team, callfunc)
        local cell_id = control:closeView()
    end,
    formationControlSaveTeam = function(control)
        control:guildHighWarSetDefendTeams()
    end,
    gamePanelModel = function(model)
        model.main_team = {}
    end,
    
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            --if SceneManager.curScene.sceneId ~= SceneManager.SceneID.GuildHighWar then
            --    local model = control.m_model.m_guild_high_war_model
            --    SceneManager:changeScene(SceneManager.SceneID.GuildHighWar, {parent_model = model}, false);
            --end
            control:updateMsg("refresh_screen_data", nil, "GuildHighWar.GuildHighWarMain")
            if static_rootControl:hasChild("UnionWar") then
                --control:updateMsg("refresh_data",nil,"Union.UnionWar")
                --EventDispatcher:dipatchEvent("refresh_dfbhz_team_data", {})
                EventDispatcher:dipatchEvent("refresh_dfbhz_team_data", {})
            end
            
            --control:openView("GuildHighWar.GuildHighWarMain")
            control:closeView()
        end
    end,
    settlementControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            --if SceneManager.curScene.sceneId ~= SceneManager.SceneID.GuildHighWar then
            --    local model = control.m_model.m_guild_high_war_model
            --    SceneManager:changeScene(SceneManager.SceneID.GuildHighWar, {parent_model = model}, false);
            --end
            control:updateMsg("refresh_screen_data", nil, "GuildHighWar.GuildHighWarMain")
            --control:openView("GuildHighWar.GuildHighWarMain")
            control:closeView()
        end
    end
}


-- 江湖传说
M[GlobalConfig.BATTLE_MODE.LEGEND] = {
    formationControl = function(control, team, callfunc)
        local stage_id = control.m_model.m_params.battle_id
        control.m_model:getNetData(
            "legend_battle_start",
            {team = team, stage_id = stage_id, battle_pet = control.m_model.m_battle_pet, relic = control.m_model.m_solts,normal_array = control.m_model.m_normal_array,deployment = control.m_model.m_atk_deployment},
            callfunc,
            false,
            nil,
            GlobalConfig.POST
        )
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        model.m_result = 1
        model.m_show_record_btn = false
        upload_data.stage_id = model.m_stage_id
        upload_data.value = model.m_legend_value
        model:getData("legend_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("fresh_data", nil, "Activities.WorldBoss")
    end
}

-- 奇门遁甲
M[GlobalConfig.BATTLE_MODE.GVE_BATTLE] = {
    formationControl = function(control, team, callfunc)
        local cell_id = control.m_model.m_params.cell_id
        local star = control.m_model.m_params.star
        local request_key = "gve_battle_start"
        if control.m_model.m_formation_skip_battle == 1 then --跳过战斗
            request_key = "gve_battle_start_back"
        end
        control.m_model:getNetData(
                request_key,
                {team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array,cell_id = cell_id --[[ 格子id--]], star = star, deployment = control.m_model.m_atk_deployment, ver = control.m_model.m_gve_version},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "QiMenDunJia.QiMenDunJiaMain")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model:setRoundResult()
        if model.m_skip_battle == 1 then --跳过战斗
            model:getData()
        else
            upload_data.ver = model.m_params.gve_version
            upload_data.cell_id = model.m_params.cell_id
            upload_data.star = model.m_params.star
            upload_data.use_time = model.m_battle_time
            upload_data.damage = model.m_params.boss_dmg
            upload_data.result = model.m_result -- 要根据stage_type判断是否强制胜利，1、3打不死（强制胜利），2、4打得死
            model:getData("gve_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        SceneManager:continue()
        control:updateMsg("change_scene", {result = model.m_result or 0, battle_ret_data = model.m_data}, "QiMenDunJia.QiMenDunJiaMain")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "QiMenDunJia.QiMenDunJiaMain")
        control:closeView()
    end
}

-- 奇门遁甲BOSS
M[GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS] = {
    formationControl = function(control, team, callfunc)
        local cell_id = control.m_model.m_params.cell_id
        local star = control.m_model.m_params.star
        control.m_model:getNetData(
                "gve_battle_start",
                {team = team,relic = control.m_model.m_solts, battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array, cell_id = cell_id --[[ 格子id--]], star = star, deployment = control.m_model.m_atk_deployment, ver = control.m_model.m_gve_version},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:updateMsg("change_scene", nil, "QiMenDunJia.QiMenDunJiaMain")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        --model.m_result = 1
        model:setRoundResult()
        upload_data.ver = model.m_params.gve_version
        upload_data.cell_id = model.m_params.cell_id
        upload_data.star = model.m_params.star
        upload_data.use_time = model.m_battle_time
        upload_data.damage = model.m_params.boss_dmg
        upload_data.result = model.m_result -- 要根据stage_type判断是否强制胜利，1、2,3打怪4打boss
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        model:getData("gve_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        SceneManager:continue()
        control:updateMsg("change_scene", {result = model.m_result or 0, battle_ret_data = model.m_data}, "QiMenDunJia.QiMenDunJiaMain")
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("change_scene", nil, "QiMenDunJia.QiMenDunJiaMain")
        control:closeView()
    end
}

-- 风云擂台，单队，设置防守阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_ONE] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("friend_arena_defense1"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("friend_arena_defense1")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("friend_arena_defense1"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("friend_arena_defense1"))
    end,
    formationControlSaveTeam = function(control)
        control:fulwinArenaSetDefendTeams(1)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    ---@param control FormationControl
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}

-- 风云擂台，三队，设置防守阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_THREE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("friend_arena_defense3"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("friend_arena_defense3"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("friend_arena_defense3"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("friend_arena_defense3"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("friend_arena_defense3"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:fulwinArenaSetDefendTeams(3)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}

-- 风云擂台，单队，设置进攻阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("friend_arena1"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("friend_arena1")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("friend_arena1"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("friend_arena1"))
    end,
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "friend_arena_select_battle_start_team",
                {team = team, relic = control.m_model.m_solts,normal_array = control.m_model.m_normal_array,battle_pet = control.m_model.m_battle_pet, deployment = control.m_model.m_atk_deployment, defend_uid = control.m_model.m_params.defend_uid, fair = control.m_model.m_fair_fulwin},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlSaveTeam = function(control)
        -- 进攻队伍不保存
        --control:fulwinArenaSetDefendTeams(1)
        control:updateMsg(99999)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:closeView()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = left_num > right_num and 1 or 0
            model:getData()
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        control:openView("Pops.TransitionPage")
        control:updateMsg(
                "challenge_btn",
                {new_chapter = control.m_new_chapter, auto_battle_flag = auto_battle_flag},
                "parent"
        )
    end,
    settlementControlClose = function(control, mode, model, type)
        --control:updateMsg("battle_end_refresh_ui", nil, "Taoist")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 风云擂台，三队，设置进攻阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("friend_arena3"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("friend_arena3"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("friend_arena3"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("friend_arena3"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("friend_arena3"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControl = function(control, teams, callfunc)
        control.m_model:getNetData(
                "friend_arena_select_battle_start_teams",
                {teams = teams, relics = control.m_model.m_mult_solts,battle_pets = control.m_model.m_mult_battle_pets, normal_arrays = control.m_model.m_mult_normal_array,
                deployments = control.m_model.m_mult_deployments, defend_uid = control.m_model.m_params.defend_uid, fair = control.m_model.m_fair_fulwin},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlSaveTeam = function(control)
        -- 进攻队伍不保存
        --control:fulwinArenaSetDefendTeams(3)
        control:updateMsg(99999)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
            control:closeView()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            local left_num, right_num = model:getVSNum()
            model.m_result = left_num > right_num and 1 or 0
            model:getData()
        end
    end,
    settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
        --control:updateMsg("battle_end_refresh_ui", {data = model.m_data}, "Taoist")
    end,
    settlementControlClose = function(control, mode, model, type)
        --control:updateMsg("battle_end_refresh_ui", nil, "Taoist")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

-- 风云擂台，单队，设置攻击阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("friend_arena1"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("friend_arena1")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("friend_arena1"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("friend_arena1"))
        for k, v in pairs(model.main_team) do
            local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
            if model.m_races and hero_cfg and not table.indexof(model.m_races, hero_cfg.race) then -- 去掉锁定种族
                model.main_team[k] = ""
            end
        end
    end,
    formationControlSaveTeam = function(control)
        control:fulwinArenaSetDefendTeams(1)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}

-- 风云擂台，三队，设置进攻阵容
M[GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("friend_arena3"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("friend_arena3"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("friend_arena3"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("friend_arena3"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("friend_arena3"))
        model.m_def_mult_deployments = {-1, -1, -1}

        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            else
                for k, v in pairs(model.mult_main_teams[i]) do
                    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                    if model.m_races and hero_cfg and not table.indexof(model.m_races, hero_cfg.race) then -- 去掉锁定种族
                        model.mult_main_teams[i][k] = ""
                    end
                end    
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:fulwinArenaSetDefendTeams(3)
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end,
}

-- 活动boss
M[GlobalConfig.BATTLE_MODE.ACTIVE_BOSS] = {
    formationControl = function(control, team, callfunc)
        local battle_config = control.m_model.m_params.battle_config_id
        local scene_model = SceneManager:getCurSceneModel()
        local open_id = scene_model.m_data.m_open_id
        local vsn = scene_model.m_data.m_version
        local level_up = scene_model.m_data.level_up
        
        control.m_model:getNetData(
                "common_world_boss_battle_start",
                {team = team,relic = control.m_model.m_solts,normal_array = control.m_model.m_normal_array,battle_pet = control.m_model.m_battle_pet, deployment = control.m_model.m_atk_deployment, open_id = open_id, vsn = vsn, level_up = level_up},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        local boss_cur_damage = control.m_model.m_boss_cur_damage and control.m_model.m_boss_cur_damage or 0
        local boss_max_hp = control.m_model.m_boss_max_hp and control.m_model.m_boss_max_hp or 0
        local is_die = false
        if boss_cur_damage >= boss_max_hp and boss_cur_damage > 0 then
            is_die = true
        end
        SceneManager:getCurSceneModel():resetCamera(is_die)
        control:openView("Activities.ActiveBoss")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_result = 1
        model:setRoundResult()
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        upload_data.use_time = model.m_battle_time
        upload_data.damage = model.m_params.boss_dmg
        upload_data.result = 1 --boss结果默认胜利
        local scene_model = SceneManager:getCurSceneModel()
        upload_data.open_id = scene_model.m_data.m_open_id
        upload_data.vsn = scene_model.m_data.m_version
        model:getData("common_world_boss_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        SceneManager:continue()
        control:updateMsg("fresh_data",nil, "Activities.ActiveBoss")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}


-- 宠物斗技
M[GlobalConfig.BATTLE_MODE.PET_DOUJI] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("pet_pvp"))
    end,
    formationControlSaveTeam = function(control)
        control:petDoujiSetTeam() 
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:petDoujiSetTeam()
        else
            control:closeView()
            if control:hasChild("PetBreeding.PetBreedingMain") then 
                control:updateMsg("refresh_sence", nil, "PetBreeding.PetBreedingMain")
            else
                SceneManager:changeScene(Battle.BattleGlobalConfig.SCENE_ID.HangUpScene)
            end
        end
    end,
    gamePanelControlExit = function(control)
        control:closeView()
        control:updateMsg("refreshPetModel", nil, "PetBreeding.PetArenaMain")
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("refreshPetModel", nil, "PetBreeding.PetArenaMain")
        if control:hasChild("PetBreeding.PetBreedingMain") then
            control:updateMsg("refresh_sence", nil, "PetBreeding.PetBreedingMain")
        else
            SceneManager:changeScene(Battle.BattleGlobalConfig.SCENE_ID.HangUpScene)
        end
    end
}

-- 入梦铃
M[GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM] = {
    --formationModel = function(model)
    --    model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("awaken_stage"))
    --    model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("awaken_stage")
    --    model.m_normal_array = table.copy(UserDataManager:getNormalArray("awaken_stage"))
    --    model.m_battle_pet = table.copy(UserDataManager:getPet("awaken_stage"))
    --end,
    formationControl = function(control, team, callfunc)
        local stage_id = control.m_model.m_params.stage_id
        control.m_model:getNetData(
                "awaken_stage_battle_start",
                {
                    team = team,
                    deployment = control.m_model.m_atk_deployment,
                    normal_array = control.m_model.m_normal_array,
                    relic = control.m_model.m_solts,
                    battle_pet = control.m_model.m_battle_pet,
                    stage_id = stage_id,
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model:setRoundResult()
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        upload_data.stage_id = model.m_params.stage_id
        model:getData("awaken_stage_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("fresh_data", {stage_data = model.m_data}, "AwakeSystem.AwakeSystemAsleepPop")
    end
}

-- 剑试天下 Boss战阶段
M[GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS] = {
    formationModel = function(model)
        model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("full_service_boss"))
        model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("full_service_boss")
        model.m_normal_array = table.copy(UserDataManager:getNormalArray("full_service_boss"))
        model.m_battle_pet = table.copy(UserDataManager:getPet("full_service_boss"))
    end,
    formationControl = function(control, team, callfunc)
        local battle_id = control.m_model.m_params.battle_id
        local version = control.m_model.m_params.version
        control.m_model:getNetData(
                "full_service_battle_start",
                {version = version,team = team,deployment = 1,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array, battle_id = battle_id},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    formationControlClose = function(control)
        control:openView("CompareSwordWithWorld.BossFight.BossFightMain")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model.m_result = 1
        model:setRoundResult()
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        upload_data.open_id = model.m_params.open_id
        upload_data.version = model.m_params.version
        upload_data.result = 1 --boss结果默认胜利
        upload_data.battle_id = model.m_params.battle_id
        model:getData("full_service_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("refreshData", nil, "CompareSwordWithWorld.BossFight.BossFightMain")
    end
}

-- 剑试天下 积分赛防守阵容
M[GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("full_service_point_race"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("full_service_point_race"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("full_service_point_race"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("full_service_point_race"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("full_service_point_race"))
        model.m_def_mult_deployments = {-1, -1, -1}
        for i = 1, 3 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 3 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:setCompareSwordDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end
    
}

-- 剑试天下 晋级赛防守阵容
M[GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION] = {
    formationModel = function(model)
        model.m_mult_team_flag = true
        model.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("full_service_promotion"))
        model.m_mult_deployments = table.copy(UserDataManager.hero_data:getMultDeploymentByKey("full_service_promotion"))
        model.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("full_service_promotion"))
        model.m_mult_normal_array = table.copy(UserDataManager:getMultNormalArray("full_service_promotion"))
        model.m_mult_battle_pets = table.copy(UserDataManager:getMultPets("full_service_promotion"))
        model.m_def_mult_deployments = {-1, -1, -1,-1,-1}
        for i = 1, 5 do
            if model.mult_main_teams[i] == nil then
                model.mult_main_teams[i] = {}
            end
            model.m_mult_deployments[i] = model.m_mult_deployments[i] or 1
        end
        if next(model.m_mult_normal_array) == nil then
            for i = 1, 5 do
                model.m_mult_normal_array[i] = 0
            end
        end
        model.main_team = model.mult_main_teams[model.m_formation_index] or {}
        model.m_atk_deployment = model.m_mult_deployments[model.m_formation_index] or {}
    end,
    formationControlSaveTeam = function(control)
        control:setCompareSwordDefendTeams()
    end,
    formationControlSceneLoadFinish = function(control)
        SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
    end,
    formationControlClose = function(control)
        if control.m_model.m_team_changed_flag then
            control:saveFormation()
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
            control:closeView()
        end
    end

}

-- 侠客情缘
M[GlobalConfig.BATTLE_MODE.HERO_FATE] = {
    --formationModel = function(model)
    --    model.main_team = table.copy(UserDataManager.hero_data:getTeamByKey("awaken_stage"))
    --    model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("awaken_stage")
    --    model.m_normal_array = table.copy(UserDataManager:getNormalArray("awaken_stage"))
    --    model.m_battle_pet = table.copy(UserDataManager:getPet("awaken_stage"))
    --end,
    formationControl = function(control, team, callfunc)
        local stage_id = control.m_model.m_params.stage_id
        control.m_model:getNetData(
                "hotel_love_battle_start",
                {
                    team = team,
                    deployment = control.m_model.m_atk_deployment,
                    normal_array = control.m_model.m_normal_array,
                    relic = control.m_model.m_solts,
                    battle_pet = control.m_model.m_battle_pet,
                    stage_id = stage_id,
                },
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        model:setRoundResult()
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        upload_data.stage_id = model.m_params.stage_id
        model:getData("hotel_love_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("refresh_data", {stage_data = model.m_data}, "Hotel.Fate")
    end
}

--  活动 天府夺刀 pve
M[GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "hero_boss_battle_start",
                {team = team,relic = control.m_model.m_solts,battle_pet = control.m_model.m_battle_pet,normal_array = control.m_model.m_normal_array, version = control.m_model.version, deployment = control.m_model.m_atk_deployment},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        --SceneManager:getCurSceneModel():resetCamera();
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("update_data", control.m_model.m_data, "Activities.HeroBoss")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            upload_data.skip = 1
        else
            upload_data.skip = 0
        end
        model.m_result = 1
        model:setRoundResult()
        upload_data.damage = model.m_damage
        upload_data.version = model.version
        upload_data.result = 1 --大侠试炼结果默认胜利
        model:getData("hero_boss_battle_end", upload_data, nil, GlobalConfig.POST, {forceBack = true})
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("update_data", control.m_model.m_data, "Activities.HeroBoss")
        control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

--  活动 天府夺刀 pvp
M[GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP] = {
    formationControl = function(control, team, callfunc)
        control.m_model:getNetData(
                "hero_boss_loot_battle",
                {team = team, deployment = control.m_model.m_atk_deployment, relic = control.m_model.m_solts, normal_array = control.m_model.m_normal_array, defend_uid = control.m_model.m_params.defend_uid},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    end,
    formationControlClose = function(control)
        --SceneManager:getCurSceneModel():resetCamera();
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
        control:closeView()
    end,
    gamePanelControlExit = function(control)
        control:updateMsg("update_data", control.m_model.m_data, "Activities.HeroBoss")
        control:closeView()
    end,
    settlementModel = function(model, upload_data)
        if model.m_quick_pass then
            model.m_show_record_btn = false
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
    end,
    settlementControlClose = function(control, mode, model, type)
        control:updateMsg("update_data", control.m_model.m_data, "Activities.HeroBoss")
        --control:updateMsg("change_scene", nil, "Main.Outskirts")
    end
}

--RTA
M[GlobalConfig.BATTLE_MODE.RTA_ARENA] = {

    ---@param model FormationModel
    formationModel = function(model)
        model.main_team = table.copy(model.m_rta_team)
        --model.m_atk_deployment = UserDataManager.hero_data:getDeploymentByKey("rise_arena_atk_sgl")
        --model.m_normal_array = table.copy(UserDataManager:getNormalArray("rise_arena_atk_sgl"))
        --model.m_battle_pet = table.copy(UserDataManager:getPet("rise_arena_atk_sgl"))

    end,

    ---@param control FormationControl
    formationControlSceneLoadFinish=function(control)
        control.syncInfo=function(event,data)
            if data.event_type == "rta.sync" then
                local callback=function(_data)
                    if _data==nil or _data.settle==nil then
                        return
                    end
                    _data=_data.settle
                    if (_data.battle==nil or table.nums(_data.battle)==0) then
                        local self_uid=UserDataManager.user_data:getUid()
                        local winer_isSelf=self_uid==_data.winer

                        local tip_str=nil
                        if winer_isSelf then
                            tip_str=Language:getTextByKey("arena_rta_str_0022")
                        else
                            tip_str=Language:getTextByKey("arena_rta_str_0021")
                        end

                        local params =
                        {
                            on_ok_call = function(msg)
                                ChatUtil:cancelRTAHeart()
                                EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC, control.syncInfo)
                                control:updateMsg("refresh_ui", nil, "Arena.ArenaRTA.RTAMain")
                                control:closeView()
                            end,
                            no_close_btn = true,
                            text =tip_str
                        }
                        static_rootControl:openView("Pops.CommonPop", params)
                        return
                    end

                    local self_uid=UserDataManager.user_data:getUid()
                    local isatker=self_uid== _data.atker
                    local scoreDelta=nil
                    local preScore=nil
                    local self_tier=control.m_model.cur_tier

                    local isVictorious= _data.winer==self_uid
                    local rta_tier_cfg=ConfigManager:getCfgByName("rta_tier")
                    local wendaoBNum=0
                    if isatker then
                        scoreDelta= _data.atk_score- _data.atk_pre_score
                        preScore= _data.atk_pre_score
                    else
                        scoreDelta= _data.defend_score- _data.defend_pre_score
                        preScore= _data.defend_pre_score
                    end
                    wendaoBNum=isVictorious and rta_tier_cfg[self_tier].win_coin or rta_tier_cfg[self_tier].lose_coin

                    control.m_model.m_rta_result=isVictorious and 1 or 0
                    control.m_model.m_wendaoBNum=wendaoBNum
                    control.m_model.m_rta_score=scoreDelta
                    control.m_model.m_preScore=preScore

                    --local battle=_data.battle
                    --if not isatker then
                    --    local atker=battle.atker
                    --    battle.atker=battle.defer
                    --    battle.defer=atker
                    --end
                    --control.m_model.m_rta_battle=battle
                    control.m_model.m_rta_battle=_data.battle

                    control:getBattleStart()
                    ChatUtil:cancelRTAHeart()
                end
                control.m_model:getNetData("rta_sync",nil,callback)
            end
        end
        EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC, control.syncInfo)

        SceneManager:getCurSceneView().canDownFlag = false -- 可拖下阵
    end,

    ---@param control FormationControl
    formationControl = function(control, team, callfunc)
        EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC, control.syncInfo)
        --local callback=function(data)
        --    callfunc(control.m_model.m_rta_battle)
        --end
        --control.m_model:getNetData("rta_sync",nil,callback)
        callfunc(control.m_model.m_rta_battle)
    end,

    ---@param control FormationControl
    formationControlStartBattle = function(control)
        control.m_view:lockTouch()
         local callback=function(data)

             control.m_view:rtaBattleBtnAnim()
             control.m_view:setWaitingTiaoZhanTip()
            if table.nums(data)>0then
                local self_uid=UserDataManager.user_data:getUid()
                local isatker=self_uid==data.atker
                local scoreDelta=nil
                local preScore=nil
                local self_tier=control.m_model.cur_tier

                local isVictorious=data.winer==self_uid
                local rta_tier_cfg=ConfigManager:getCfgByName("rta_tier")
                local wendaoBNum=0
                if isatker then
                    scoreDelta=data.atk_score-data.atk_pre_score
                    preScore=data.atk_pre_score
                    --self_tier=data.atker.tier
                else
                    scoreDelta=data.defend_score-data.defend_pre_score
                    preScore=data.defend_pre_score
                    --self_tier=data.defer.tier
                end
                wendaoBNum=isVictorious and rta_tier_cfg[self_tier].win_coin or rta_tier_cfg[self_tier].lose_coin

                control.m_model.m_rta_result=isVictorious and 1 or 0
                control.m_model.m_wendaoBNum=wendaoBNum
                control.m_model.m_rta_score=scoreDelta
                control.m_model.m_preScore=preScore

                --local battle=data.battle
                --if isatker then
                --    local atker=battle.atker
                --    battle.atker=battle.defer
                --    battle.defer=atker
                --end
                --control.m_model.m_rta_battle=battle

                control.m_model.m_rta_battle=data.battle
                control:getBattleStart()
                --Logger.logWarning("rta_do_battle==================")
            end
        end
        local team = {}
        for i = 1, 5 do
            team[i]= control.m_model.main_team[i] or ""
        end
        control.m_model:getNetData("rta_do_battle",{
            match_id=control.m_model.m_rta_match_id,
                team= team,
               relic = control.m_model.m_solts,
               normal_array = control.m_model.m_mult_normal_array,
               deployment= 1},
                callback,
                false,
                nil,
                GlobalConfig.POST)
    end,

    ---@param model SettlementModel
    settlementModel = function(model, upload_data)
        model.m_show_record_btn = false
        if model.m_quick_pass then
            model:callBack(model.m_params.data)
        else
            model:getData()
        end
        model.m_show_record_btn = false
        model.m_result=model.rta_result
    end,
    ---@param control SettlementControl
    --settlementControlToFormation = function(control, mode, model, func, auto_battle_flag)
    --    control:goToMain(mode, model)
    --end,

    ---@param control SettlementControl
    settlementControlClose = function(control, mode, model, type)
        --control:openView("Arena.ArenaRTA.RTAMain")
        ChatUtil:cancelRTAHeart()
        control:updateMsg("refresh_ui", nil, "Arena.ArenaRTA.RTAMain")
    end,
    gamePanelControlExit=function(control)
        control:setOnceTimer(4,function()
            control:closeView()
        end)
    end
}
return M
