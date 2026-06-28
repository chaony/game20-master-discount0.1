local M = class("ArenaRaceTopTipsControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.ok_call_back then
            self.m_model:ok_call_back()
        end
        self:closeView()
    end
end

return M
