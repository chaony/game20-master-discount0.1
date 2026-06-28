local M = class("WorldBossSelectMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Activities.WorldBoss.WorldBossSelectMain.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 87})
    elseif msg == "worldboss_btn" then
        QuickOpenFuncUtil:openFunc(29, {data = self.m_model.world_boss_data})
    elseif msg == "activeboss_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(self.m_model.m_activeboss_open_id)
        if open_flag then
            self:openView("Activities.WorldBoss.HeroBossTrainPop", {data = self.m_model.hero_train_data})
        else
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif msg == "update_hero_train_data" then
        self.m_model:updateHerTrainData(data)
    elseif msg == "legend_btn" then
        self:openView("Legend", {data = self.m_model.legend_data})
    elseif msg == "jubao_btn" then
        QuickOpenFuncUtil:openFunc(41)
    elseif msg == "update_boss_data" then
        self.m_model.boss_num = self.m_model:getLeftTimes(data.battle_times)
        self.m_view:refreshUI()
    elseif msg == "update_red_point" then
        self.m_view:refreshUI()
    elseif msg == "update_quest" then
        if data and next(data) then
            self.m_model.hero_train_data.quests = data
        end
    end
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshUI()
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
