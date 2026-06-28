local M = class("FindThePairsLevelsControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "open_game" then
        self:openView("LittleGames.FindThePairs.FindThePairsGame")
    end
end

return M
