local M = class("WorldMapCompleteControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("change_scene", {area_id = self.m_model.select_id}, "WorldMap.WorldMapMain")
        self:closeView()
    elseif msg == "select_map" then
        if self.m_model:checkAreaOpen(data.id) then
            self.m_model:select_map(data.id)
            self.m_view:refreshUI()
        else
            local condition, tips_str = self.m_model:getOpenCondition(data.id)
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif msg == "openWorldTaskReward" then
        --self:closeView()
        self:openView("WorldMap.WorldMapTaskReward", data)
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    end
end

return M;
