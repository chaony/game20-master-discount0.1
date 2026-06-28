local M = class("RacconGameEntranceControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "start_btn" then
        self:startGame()
    elseif msg == "help_btn" then
        self:showHelpPop()
    end
end

function M:startGame()
    self:openView("Raccon.RacconGame")
    self:closeView()
end

function M:showHelpPop()
    local params = {}
    params.title = "raccon_text_0021"
    params.content = "tid#XiaoHuanXiongDes_9"
    self:openView("Pops.CommonHelpPop", params)
end

function M:destroy()
    M.super.destroy(self)
end

return M
