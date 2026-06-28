local M = class("ChivalryBattleControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint", nil, self.m_model.refresh_main)
        self:closeView()
    elseif msg == "Tiaozhan" then
        local evil_shadow_stage_config = ConfigManager:getCfgByName("active_train")
        local evil_shadow_stage_config_item = evil_shadow_stage_config[self.m_model.open_id][self.m_model.m_version]
        if evil_shadow_stage_config_item ~= nil then
            local stage_battle_active = ConfigManager:getCfgByName("stage_battle_active")
            local active_stage_item = stage_battle_active[evil_shadow_stage_config_item[1].stage_battle]
            if active_stage_item then
                local boss_pos = active_stage_item.boss_position or 0
                local boss_size = active_stage_item.boss_size_mode or 1
                self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.COMMON_BATTLE,
                                            def_data = self.m_model.m_data.enemy_data or {},
                                            assist_heros = self.m_model.m_data.assist_heros or {},
                                            five_pos = 0, --五行阵中的位置
                                            boss_pos = boss_pos,
                                            boss_size = boss_size,
                                            boss_id = self.m_model.m_data.train_id or 1,
                                            heirlooms = self.m_model.m_data.heirlooms or {},
                                            version = self.m_model.m_version or 1,
                                            open_id = self.m_model.open_id or 395})
            end
        end
    elseif msg == "refresh_rank_info" then --刷新排行数据
        self:getRankingData()
        self:updateIndexData()
    elseif msg == "ranking_btn" then --排行、奖励页展示
        self:openView("commonActive.commonTrainRankList", {open_id = self.m_model.open_id,active_tab_num = 2 ,version = self.m_model.m_version})
    elseif msg == "battle_end_refresh_ui" then  --战斗结束后刷新
        self:updateMsg("refresh_data", nil, self.m_model.refresh_main)
        if data ~= nil then
            self:updateIndexData()
            --self:getRankingData()
            --self.m_model:updateMaxDamage(data)
            --self.m_model:updateServer(data.data)
            --self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "task_btn" then --挑战任务
        local params = {}
        params.data = self.m_model:getTasks()
        params.open_id = self.m_model.open_id or 1
        params.version = self.m_model.m_version or 0
        params.refresh_ui_name = "Chivalry.ChivalryBattle"
        params.callback = function()
            self.m_view:refreshRedPoint()
        end
        self:openView("commonActive.commonHeroTrainTask", params)
    elseif msg == "refresh_data" then  --刷新数据
        --self:updateData()
    elseif msg == "update_quest" then  --更新任务
        self.m_model:updateServer(data)
        self.m_view:refreshUI()
    elseif msg == "break_btn" then --击破展示
        self:openView("NationalBeautiful.NationalBeautifulBattleBreak",{data = self.m_model.m_data,open_id = self.m_model.open_id,version = self.m_model.m_version})
    end
end

--获取排行榜信息
function M:getRankingData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg("update_data")
            self:closeView()
            return
        end
        self.m_model:updateServer(response)
        self.m_view:refreshUI()
        self.m_view:refreshRank()
    end
    self.m_model:getNetData("common_train_challenge_ranks",{open_id = self.m_model.open_id,version = self.m_model.m_version,start = 1,ends = 20},netCallback)
end

--刷新数据
function M:updateData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:updateServer(response)
        self.m_view:refreshUI()
        self.m_view:refreshRank()
    end
    self.m_model:getNetData("common_train_challenge_ranks",{open_id = self.m_model.open_id,version = self.m_model.m_version,start = 1,ends = 20},netCallback)
end

--刷新战斗首页数据
function M:updateIndexData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:updateServer(response)
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
    end
    self.m_model:getNetData("common_train_challenge_index",{open_id = self.m_model.open_id,version = self.m_model.m_version},netCallback)
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

return M
