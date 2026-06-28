local M = class("GuildHighWarInvitePopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
