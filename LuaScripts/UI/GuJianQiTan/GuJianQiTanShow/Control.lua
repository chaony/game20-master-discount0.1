local M = class("GuJianQiTanShowControl",LikeOO.OOControlBase)


function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:updateMsg("update_activity_show_done_flag", nil, "GuJianQiTan.GuJianQiTanMain")
        self:closeView()
    elseif msg == "help_btn" then --帮助说明
        audio:SendEvtUI("UI_Popup_N1")
        local params = {}
        params.title = "gu_jian_qi_tan_str_002"
        params.content = "tid#SwordDes1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "battle_end_refresh_ui" then
        self:refreshCustom()
        SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
    elseif msg == "challenge_btn" then --挑战
        audio:SendEvtUI("Ui_Fight")
        self:startBattle()
    else
        audio:SendEvtUI("UI_Square_Mon")
        local stage_btns = self.m_model:getStageBtns()
        for k, v in pairs(stage_btns) do
            if msg == v then
                self.m_model:setSelectedStage(k)
                break
            end
        end
        self.m_view:updateEnemyAndReward()
    end
end

function M:refreshCustom()
    local function callback(response)
        self.m_model:updateNetData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("ancient_sword_and_wonderland_index", nil, callback, nil, true)
end

function M:startBattle()
    if self.m_model:getSelectedStage() ~= 0 then
        if self.m_model:stageCheck() == true then
            local stage_cfg = self.m_model:getSelectedStageData()
            if stage_cfg then
                local stage_done_flag = self.m_model:checkStageDone(stage_cfg.id)
                if stage_done_flag == false and stage_cfg.win_event then
                    UserDataManager:setTempData("GuJianQiTan_win_event", stage_cfg.win_event)
                else
                    UserDataManager:setTempData("GuJianQiTan_win_event", 0)
                end
                if stage_done_flag == false and stage_cfg.open_event then
                    self:openView("GuJianQiTan.GuJianQiTanShowBeforeStory", {mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MULT, stage_id = stage_cfg.id, open_event = stage_cfg.open_event})
                else
                    self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MULT, stage_id = stage_cfg.id})
                end
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_014", self.m_model:getSelectedStageUnlockName()), delay_close = 2 })
        end
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_015"), delay_close = 2 })
    end
end


return M;
