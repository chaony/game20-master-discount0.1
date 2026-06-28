local M = class("TowerStageStartBattleControl",LikeOO.OOControlBase)

function M:onEnter()
    
    local data = 
    {
        atk_team = {},
        atk_heros = {},
        def_taam = {},
        def_heros = {},
        mode = 1,
        move_type = 1,
        race = self.m_model.m_race
    }
    SceneManager:changeScene(SceneManager.SceneID.TianJiLouScene,data)
    SceneManager:scenestart()
    self.m_guide_file_name = "UI.TowerStage.TowerStageStartBattle.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
        self:closeView()
    elseif msg == "start_battle_btn" then
        if self.m_model:isMaxStage() then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0210"), delay_close = 2})
            return
        end
        self:openView("Formation",{mode = self.m_model.m_race == 0 and GlobalConfig.BATTLE_MODE.TOWER or GlobalConfig.BATTLE_MODE.RACE_TOWER, race = self.m_model.m_race})
        -- self.m_view:doExitAnim(function()
            
        -- end)
    elseif msg == "item_click" then
    	local player_data = self.m_model:getPlayerDataByIndex(data.index)
        self:openView("Pops.PlayerInfo", {uid = player_data.uid})
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", {title = "tid#tower1", content = "tid#tower2"})
	elseif msg == "rank_btn" then
        self:openView("TowerStage.TowerStageRank", {race = self.m_model.m_race})
	elseif msg == "detail_btn" then
        self:openView("TowerStage.TowerStageDetail", {race = self.m_model.m_race})
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
        if data and data.anim == "enter_anim" then
            self.m_view:doEnterAnim()
        end
    elseif msg == "battle_end_refresh_ui" then
        local result = data.data.result
        if not self.m_model:isMaxStage() and result == 1 then
            self.m_view:setVisibleBattleNode(false)
            self.m_view:setVisibleTipsStartNode(false)
        else
            self.m_view:refreshUI()
        end
    elseif msg == "player_move_end" then
        self.m_view:setVisibleTipsStartNode(true)
        self:setOnceTimer(1.5, function()
            self.m_view:setVisibleBattleNode(true)
            self.m_view:setVisibleTipsStartNode(false)
            self.m_view:refreshUI()
        end)
    end
end


return M
