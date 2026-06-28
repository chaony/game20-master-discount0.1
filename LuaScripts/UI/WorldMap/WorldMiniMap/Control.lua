local M = class("WorldMiniMapControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "map_btn" then
        if self.m_model.map_id == 0 then
            self.m_model:switchMap(self.m_model.map_id)
        else
            self.m_model:switchMap(0)
        end
        self.m_view:refreshUI()
    elseif msg == "refreshHeroPos" then
        if self.m_model.map_id ~= 0 then
            self.m_view:refreshHeroPos(data)
        end    
    elseif msg == "send_move_msg" then
        --self:closeView()
    end
end

return M
