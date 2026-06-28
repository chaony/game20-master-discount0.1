local M = class("GuessTipsPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/GuessTipsPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    local win_bl = self.m_model:checkIsWin()
    local win_num = self.m_model:getWinNum()
    self:setObjectVisible("win_obj", win_bl == true)
    self:setObjectVisible("loser_obj", win_bl == false)
    local py_data = self.m_model:getGuessPlayer()
    self:setTextByLanKey("des_tips_text", "new_str_0905")
    self:setTextByLanKey("Desc_text2", "guess_tips_yj_text")
    if win_bl == true then
        self:setTextByLanKey("Desc_text", "peak_str_0003", self.m_model:getCurBattleStatusName(), py_data.user.name)
        local rate = ConfigManager:getCommonValueById(413,1.5)
        local num = GameUtil:formatNum(win_num*rate)
        local num_text = self:setTextByLanKey("money_num", "+"..num)
        num_text.color = Color( 86/255, 245/255, 59/255)
    else
        self:setTextByLanKey("Desc_text", "peak_str_0004", self.m_model:getCurBattleStatusName(), py_data.user.name)
        local rate = ConfigManager:getCommonValueById(426,0.5)
        local num = GameUtil:formatNum(win_num*rate)
        local num_text = self:setTextByLanKey("money_num", "+"..num)
        num_text.color = Color( 86/255, 245/255, 59/255)
    end
    local cost_data = RewardUtil:getProcessRewardData({135,0,0})
    local itemNode = self:findGameObject("ItemNode")
    if itemNode then
        GameUtil:updateItemElement(itemNode, {135,0,0}, false,true)
    end
end


return M