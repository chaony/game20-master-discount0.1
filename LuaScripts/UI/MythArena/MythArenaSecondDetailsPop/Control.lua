local M = class("MythArenaSecondDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "look_player" then
        if data then
            self:openView("Pops.PlayerInfo", {uid = data , look_model = 10})
        end        
    elseif msg == "record_btn" then
        if data then
            self:openView("MythArena.MythArenaBattleDetailPop", {battle_id = data, log_data = item_data})
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
