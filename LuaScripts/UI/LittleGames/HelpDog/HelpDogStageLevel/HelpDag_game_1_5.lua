local M = class("HelpDag_game_1_5",LikeOO.OOUIbase)

M.m_uiName = "LittleGames/HelpDog/HelpDogStageLevel/HelpDag_game_1_5"

function M:onEnter()
    self.DrawLine = self:findGameObject("PanelGame"):GetComponent("DrawLine")
end

function M:cleanPoint()
    self.DrawLine:ClearPoint()
end

return M