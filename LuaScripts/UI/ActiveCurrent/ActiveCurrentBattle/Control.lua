local M = class("ActiveCurrentBattleControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint", nil, "ActiveCurrent.ActiveCurrentMain")
        self:closeView()
    elseif msg == "Tiaozhan" then
        local evil_shadow_stage_config = ConfigManager:getCfgByName("hero_event_stage")
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
    elseif msg == "refresh_rank_info" then --刷新排行数据
        self:getRankingData()
    elseif msg == "ranking_btn" then --排行、奖励页展示
        self:openView("ActiveCurrent.ActiveCurrentRankListPop", {vsn = self.m_model.m_version, data = self.m_model.m_data})
    elseif msg == "battle_end_refresh_ui" then  --战斗结束后刷新
        self:updateMsg("refresh_data", nil, "ActiveCurrent.ActiveCurrentMain")
        if data ~= nil then
            self:getRankingData()
            self.m_model:updateMaxDamage(data)
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    end
end

--获取排行榜信息
function M:getRankingData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg("update_data")
        end
        self.m_model:updateServer(response)
        self.m_view:refreshUI()
        self.m_view:showReward(true)
    end
    self.m_model:getNetData("hero_event_rank_info",{version = self.m_model.m_version,start = 1,ends = 20},netCallback)
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

return M
