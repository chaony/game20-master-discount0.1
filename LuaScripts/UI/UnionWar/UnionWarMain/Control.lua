local M = class("UnionWarMainControl",LikeOO.OOControlBase)

function M:onEnter()    
    if SceneManager.curScene.sceneId == SceneManager.SceneID.UnionWarScene then
        SceneManager.curScene.unionwar_data = self.m_model
        SceneManager:getCurSceneView():setBGMusic()
    else
        SceneManager:changeScene(SceneManager.SceneID.UnionWarScene,self.m_model.m_data)
        SceneManager:scenestart()
    end
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:refreshBattle()
    self:setOnceTimer(1, function()
        EventDispatcher:dipatchEvent("UnionWar_TeamChanged")
    end)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "cell_click" then
        audio:SendEvtUI("UI_Popup_N3")
        self:openView("UnionWar.UnionWarSmallTip", {cell_id = data.index, union_war_data = self.m_model.m_data})
    elseif msg == "log_btn" then
        --self:openView("UnionWar.UnionWarLog", {union_war_type = self.m_model.m_data.type, default_tab = 2})
        local function callback(response)
            local function callbackindex(response_index)
                local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
                if guild_id and guild_id > 0 then
                    self:openView("UnionWar.UnionWarLog", {union_war_type = self.m_model.m_data.type, default_tab = 2, active_data = response_index, active_list_data = response.rank_data})
                end
            end
            self.m_model:getNetData("guild_index", nil, callbackindex)
        end
        self.m_model:getNetData("gvg_active_rank", nil, callback)
    elseif msg == "team_btn" or msg == "attak_team_btn_1" or msg == "attak_team_btn_2" or msg == "attak_team_btn_3" then
        self:openView("UnionWar.UnionWarDispatch", {data = self.m_model.m_data})
    elseif msg == "hint" then
        self:openView("Pops.CommonHelpPop", {title = "tid#GuildWar_2", content = "tid#GuildWar_1"})
    elseif msg == "change_scene" then
        SceneManager:changeScene(SceneManager.SceneID.UnionWarScene,self.m_model.m_data)
        self:setOnceTimer(1, function()
            self:refreshMainData()
        end)
    elseif msg == "refresh_data" then
        self:refreshMainData()
    elseif msg == "union_war_kick_out_player" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("UnionWar_str_052"), delay_close = 2})
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "simulated_battle_btn" then
        self.m_model:changeSimulatedBattleFlag()
        self.m_view:updateSimulatedBattleStatus()
    elseif msg == "round_reward_btn" then --回合奖励
        self:openView("UnionWar.UnionWarRewardPop",{isActive_num = 2})
    elseif msg == "season_reward_btn" then --赛季奖励
        self:openView("UnionWar.UnionWarRewardPop",{isActive_num = 3})
   end
end

function M:destroy()
    if self:hasChild("Main.Outskirts") then
        self:updateMsg("change_scene", nil, "Main.Outskirts")
    else
        audio:SendEvtBGM("Set_State_ShiWu01")
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

function M:requestMainData(refresh)
    if not self.m_model.m_refresh_requesting and static_rootControl:can3DTouchByViewName("UnionWar.UnionWarMain") then
        local function callBack()
            self.m_model.m_refresh_requesting = false
        end
        self:refreshMainData(callBack, refresh)
    end
end

function M:refreshMainData(callBack, refresh)
    local function netDataCallBack(response)
        if response then
            table.merge(self.m_model.m_data, response)
            self.m_view:refreshUI()
            if SceneManager.curScene.sceneId == SceneManager.SceneID.UnionWarScene then
                SceneManager.curScene.m_data = self.m_model.m_data
            end
            EventDispatcher:dipatchEvent("UnionWar_TeamChanged")
        end
        if callBack then
            callBack(response)
        end
    end
    self.m_model:getNetData("gvg_battle_field", {refresh = refresh or 0}, netDataCallBack, 0, true);
end

function M:refreshBattle()
    local function tick()
        self:requestMainData(1)
    end
    self:setTimer(10, tick)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "gvg_teams_update" then
        self.m_view:refreshAttackTeams()
    end
end

return M