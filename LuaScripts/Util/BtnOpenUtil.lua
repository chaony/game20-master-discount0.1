------------------- BtnOpenUtil

local M = {}

function M:getBtnCfg(id)
    local open_condition = ConfigManager:getCfgByName("open_condition")
    return open_condition[id or -1]
end

-- 按钮开启解锁判断
--[[
    解锁类型：
    hero_evo: 专属装备按照英雄品质解锁
    hero_cfg_evo: 历史最高英雄品质
    has_guild: 公会商店按照是否加入公会解锁
    stage_id: 通过关卡解锁
]]
function M:isBtnOpen(id, cfg)
    cfg = cfg or self:getBtnCfg(id)
    local open_flag, tips_str = self:buttonOpenCondition(id, cfg)
    if open_flag then
        for i, v in ipairs(cfg.multy or {}) do
            if id ~= v then
                open_flag, tips_str = self:isBtnOpen(v)
                if open_flag == false then
                    return open_flag, tips_str
                end
            else
                Logger.logError("open_condition cfg error, key is " .. tostring(id))
            end
        end
    end
    return open_flag, tips_str
end

function M:buttonOpenCondition(id, cfg)
    cfg = cfg or self:getBtnCfg(id)
    local open_flag = false
    local wips_str = Language:getTextByKey("new_str_0055")
    if cfg then
        --功能超前解锁参数，最高优先级
        if cfg.unlock_condition_param3 and cfg.unlock_condition_param3 > 0 then
            local cur_stage = UserDataManager:getCurStage()
            if cur_stage >= cfg.unlock_condition_param3 then
                return true, Language:getTextByKey("new_str_0950")
            end
        end
        
        --功能开启所需要的赛季
        local unlock_season = cfg.season_unlock or 0
        local server_unlock_season = 0
        local season_data = UserDataManager.m_season_data or {}
        if season_data and next(season_data) and season_data.season then
            server_unlock_season = season_data.season
        end
        if server_unlock_season < unlock_season then
            local open_name = Language:getTextByKey(cfg.name or "")
            if cfg.unlock_condition_param3 and cfg.unlock_condition_param3 > 0 then
                local stage_cfg = ConfigManager:getCfgByName("stage")
                local cur_stage_cfg = stage_cfg[cfg.unlock_condition_param3] or {}
                local stage_name = Language:getTextByKey(cur_stage_cfg.map_point_name or "")
                tips_str  = Language:getTextByKey("new_str_1109", open_name, unlock_season, stage_name)
            else
                tips_str  = Language:getTextByKey("new_str_1110", open_name, unlock_season)
            end
            return false, tips_str
        end
        local unlock_condition = cfg.unlock_condition
        local unlock_condition_param = cfg.unlock_condition_param or 0
        if unlock_condition == "hero_evo" then
            --TODO : 在卡牌界面单独判断
        elseif unlock_condition == "hero_cfg_evo" then
            local max_evo = UserDataManager:getHeroHistoryMaxEvo()
            if max_evo >= unlock_condition_param then
                open_flag = true
            else
                local open_name = Language:getTextByKey(cfg.name or "")
                local hero_quality_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[unlock_condition_param]
                local evo_name = Language:getTextByKey(hero_quality_data.name or "")
                tips_str = Language:getTextByKey("new_str_0777", evo_name, open_name)
            end
        elseif unlock_condition == "has_guild" then
            local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id") or ""
            if guild_id ~= "" and guild_id ~= 0 then
                open_flag = true
            else
                tips_str = Language:getTextByKey("new_str_0136")
            end
        elseif unlock_condition == "stage_id" then
            local cur_stage = UserDataManager:getCurStage()
            if cur_stage >= unlock_condition_param then
                open_flag = true
            else
                local stage = ConfigManager:getCfgByName("stage")
                local stage_item = stage[unlock_condition_param] or {}
                local name = Language:getTextByKey(tostring(stage_item.map_point_name))
                local open_name = Language:getTextByKey(cfg.name or "")
                tips_str = Language:getTextByKey("new_str_0135", name, open_name)
            end
        end

        -- 注册后第几天才能开启 --优先提示天数不足
        if cfg.unlock_days and cfg.unlock_days > 0 then
            local day = GameUtil:playerRegisterDays()
            if day < cfg.unlock_days then
                open_flag = false
                local open_name = Language:getTextByKey(cfg.name or "")
                --四象阵单独处理
                if id == 20 then
                    --注册时间的时间戳
                    local reg_ts = UserDataManager.reg_ts;
                    --服务器时间的时间戳
                    local server_ts = UserDataManager:getServerTime();
                    --注册的天数
                    local reg_time = TimeUtil.gmTime(reg_ts)
                    --当前服务的天数
                    local server_time = TimeUtil.gmTime(server_ts)
                    --剩余天数
                    local remain_day = server_time.yday - reg_time.yday - cfg.unlock_days
                    --剩余小时
                    local remain_hour = 23 - server_time.hour;
                    --剩余分钟
                    local remain_min = 59 - server_time.min;
                    --剩余秒
                    local remain_sec = 59 - server_time.sec;
                    if remain_day > 0 then
                        tips_str = Language:getTextByKey("new_str_0764", remain_day, open_name)
                    elseif remain_hour > 0 then
                        tips_str = Language:getTextByKey("new_str_0817", remain_hour, open_name)
                    elseif remain_min > 0 then
                        tips_str = Language:getTextByKey("new_str_0818", remain_min, open_name)
                    elseif remain_sec > 0 then
                        tips_str = Language:getTextByKey("new_str_0819", remain_sec, open_name)
                    end
                else
                    tips_str = Language:getTextByKey("new_str_0764", cfg.unlock_days - day, open_name)
                end
            end
        end

        --功能提前解锁参数
        if open_flag == false and cfg.unlock_condition_param2 and cfg.unlock_condition_param2 > 0 then
            local cur_stage = UserDataManager:getCurStage()
            if cur_stage >= cfg.unlock_condition_param2 then
                open_flag = true
                tips_str = Language:getTextByKey("new_str_0950")
            end
        end
        -- 满足VIP等级后可直接开启
        if open_flag == false and cfg.vip_unlock and cfg.vip_unlock > 0 then
            local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
            if vip >= cfg.vip_unlock then
                open_flag = true
            else
                tips_str = Language:getTextByKey("new_str_0802", cfg.vip_unlock) .. tips_str
            end
        end
    else
        Logger.logWarningAlways(id,"open_condition cfg id not found : ")
    end
    return open_flag, tips_str
end

-- 检查当前关卡开启的功能
function M:getCurStageOpenFuncs()
    local open_func_ids = {}
    local open_condition_cfg = ConfigManager:getCfgByName("open_condition")
    local cur_stage = UserDataManager:getCurStage()
    local day = GameUtil:playerRegisterDays()
    UserDataManager.local_data:setUserDataByKey("open_funcs_day", day)
    local is_ahead = false --提前解锁
    for i, v in pairs(open_condition_cfg) do
        local unlock_condition = v.unlock_condition
        local unlock_condition_param = v.unlock_condition_param or 0
        local unlock_condition_param2 = v.unlock_condition_param2 or 0

        local unlock_season = v.season_unlock or 0
        local server_unlock_season = 0
        local season_data = UserDataManager.m_season_data or {}
        if season_data and next(season_data) and season_data.season then
            server_unlock_season = season_data.season
        end
        if server_unlock_season >= unlock_season then
            if unlock_condition == "stage_id" and unlock_condition_param == cur_stage and v.window_show == 1 then
                local unlock_days = v.unlock_days or 0
                if unlock_days > 0 then
                    if day >= unlock_days then
                        table.insert(open_func_ids, i)
                    end
                else
                    table.insert(open_func_ids, i)
                end
            elseif unlock_condition == "stage_id" and unlock_condition_param2 == cur_stage and v.window_show == 1 then
                --功能提前解锁
                local unlock_days = v.unlock_days or 0
                if unlock_days > day then
                    table.insert(open_func_ids, i)
                    is_ahead = true
                end
            end
        end
    end
    return open_func_ids, is_ahead
end

--[[
    每日登陆时，判断是否有未弹出的功能解锁提示（之前关卡满足但是日期不满足，重新登录后日期满足的）
    如有，在登录弹出的签到功能关闭后，弹出功能解锁提示
    如有多个，只弹出1个（关卡ID小的），其他的不再弹出
]]
function M:getEnterGameOpenFuncs()
    local open_func_ids = {}
    local open_condition_cfg = ConfigManager:getCfgByName("open_condition")
    local cur_stage = UserDataManager:getCurStage()
    local day = GameUtil:playerRegisterDays()
    local open_funcs_day = UserDataManager.local_data:getUserDataByKey("open_funcs_day", day)
    local select_open_id = 0
    local select_stage = 0
    UserDataManager.local_data:setUserDataByKey("open_funcs_day", day)
    for i, v in pairs(open_condition_cfg) do
        local unlock_condition = v.unlock_condition
        local unlock_condition_param = v.unlock_condition_param or 0
        local unlock_condition_param2 = v.unlock_condition_param2 or 0
        if unlock_condition == "stage_id" and unlock_condition_param <= cur_stage and v.window_show == 1 then
            if unlock_condition_param2 > cur_stage then -- 未提前解锁
                local unlock_days = v.unlock_days or 0
                if unlock_days > 0 then
                    if day >= unlock_days and open_funcs_day < unlock_days then
                        if select_stage == 0 or select_stage > unlock_condition_param then
                            select_open_id = i
                            select_stage = unlock_condition_param
                        end
                    end
                end
            end
        end
    end
    if select_open_id > 0 then
        table.insert(open_func_ids, select_open_id)
    end
    return open_func_ids
end

return M
