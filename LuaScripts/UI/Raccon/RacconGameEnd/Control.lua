local M = class("RacconGameEndControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:openView("Raccon.RacconGameEntrance")
        self:updateMsg("close_view", nil, "Raccon.RacconGame")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
