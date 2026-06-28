--- 竞技场结算 成功
local M = class("SettlementHeroBossWinNode",LikeOO.OOUIbase)
M.m_uiName = "Settlement/SettlementHeroBossWinNode"

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model.m_data
    self:setTextByLanKey("reward_title_text", "new_str_1144")
    self:setTextByLanKey("score_text", Language:getTextByKey("new_str_0922") .. "<Color=#4fd208>" .. data.obtain_score .."</Color>")
    --[[
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then
        local right_user = self.m_model:getUserInfoBySort(2)
        self:setTextByLanKey("score_text", Language:getTextByKey("new_str_0922") .. "<Color=#4fd208>" .. data.obtain_score .."</Color>")
    else
        self:setTextByLanKey("score_text", Language:getTextByKey("new_str_0922") .. "<Color=#4fd208>" .. data.obtain_score .."</Color>")
    end
    ]]--
end

function M:destroy()
    M.super.destroy(self)
end

return M