local M = class("HelpDagLevelControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.LittleGames.HelpDog.HelpDagLevel.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" or msg == "result" then    -- 返回
        self:updateMsg("check_guide" ,nil ,"LittleGames.HelpDog")
        self.m_view.m_attr_node:cleanPoint()
        --if self.m_model.m_callback then
        --    self.m_model.m_callback()
        --end
        --self:closeView("Guide.GuideDialog")
        self:closeView()
    elseif msg == "guide_btn_1" then
        self.m_view:setObjectVisible("guide_btn_1", false)
    elseif msg == "StartGame" then
        self.m_view:startGame()
    elseif msg == "nextBtn" then
        self.m_view:resetGame()
    elseif msg == "game_over_successu" then --成功
        audio:SendEvtUI("UI_Dog_Success")
        self:updateMsg("hand_btn")
        self.m_view:deleteLevel()
        self.m_view:refreshUI()
        self.m_view:showResultPanel(true)
        self.m_model.m_show_result = true
        self.m_guide:checkGuide()
        self:gameStreetSettlement()
    elseif msg == "comeBack_btn" then --重新开始
        self.m_view:deleteLevel()
        self.m_view:refreshUI()
    elseif msg == "hand_btn" then  --指引手
        self.m_view:setObjectVisible("hand_btn", false)
    else --失败
        audio:SendEvtUI("UI_Dog_BeDefeated")
        local result = string.split(msg, "game_over_")
        local dog_name = result[2]
        self.m_view:showFailAnim(dog_name)
    end
end

-- 结算
function M:gameStreetSettlement()
    local function netCallback(response)
        self:updateMsg("refresh_ui", { data = response }, "LittleGames.HelpDog")
    end
    local params = {stage_id = self.m_model.stage_id, level_id = self.m_model.level_id}
    self.m_model:getNetData("big_game_complete", params, netCallback)
end



return M
