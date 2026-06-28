local M = class("EvilShadowBattleControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateRankData()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPointBattle", nil, "EvilShadow.EvilShadowMain")
        self:closeView()
    elseif msg == "Tiaozhan" then
        local evil_shadow_stage_config = ConfigManager:getCfgByName("evil_shadow_stage")
        local evil_shadow_stage_config_item = evil_shadow_stage_config[self.m_model.m_data.floor]
        if evil_shadow_stage_config_item ~= nil then
            local stage_battle_active = ConfigManager:getCfgByName("stage_battle_active")
            local active_stage_item = stage_battle_active[evil_shadow_stage_config_item.stage_battle]
            if active_stage_item then
                local boss_pos = active_stage_item.boss_position or 0
                local boss_size = active_stage_item.boss_size_mode or 1
                self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.EVIL_SHADOW,
                                            def_data = self.m_model.m_data.enemys["0"] or {},
                                            assist_heros = self.m_model.m_data.assist_heros or {},
                                            five_pos = 0, --五行阵中的位置
                                            boss_pos = boss_pos,
                                            boss_size = boss_size,
                                            boss_id = self.m_model.m_data.floor or 1,
                                            heirlooms = self.m_model.m_data.heirlooms or {},
                                            version = self.m_model.m_data.version or 1})
            end
        end
    elseif msg == "battle_start" then
        
    elseif msg == "battle_end_refresh_ui" then
        if data ~= nil then
            self.m_model:setMaxDamageData(data.data.max_damage or 0)
            self.m_view:updateMaxDamage()
            self:updateRankData()
        end
    elseif msg == "update_data" then
        self:updateMsg(99999)
    elseif msg == "switch_btn" then
        if self.m_model:getRankType() == 1 then
            self.m_model.m_rank_type = 0
        elseif self.m_model:getRankType() == 0 then
            self.m_model.m_rank_type = 1
        end
        self:updateRankData()
    elseif msg == "chakan_btn" then
        self:openView("EvilShadow.EvilShadowRankListPop", {vsn = self.m_model.m_version, data = self.m_model.m_rank_data or {}})
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#evil_shadow_test01", content = "tid#evil_shadow_test02" })
    end
end

function M:updateRankData()
    local function receivetCallback(response)
        if response then
            self.m_model:updateRankData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.version = self.m_model:getVersion()
    params.is_day = self.m_model:getRankType() --排行榜类型
    params.start = 1
    params.stop = 20
    self.m_model:getNetData("evil_shadow_rank_info", params, receivetCallback)
end

return M
