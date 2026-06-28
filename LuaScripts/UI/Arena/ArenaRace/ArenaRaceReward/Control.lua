local M = class("ArenaRaceRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:updateMsg(99999)
    elseif msg == "time_update_end_refresh" then
        self:updateMsg(99999)
        self:updateMsg("refresh_ui",nil,"Arena.ArenaRace.ArenaRace")
    end
end

return M
