local M = class("LibraryControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "ok_btn" then
        self:openView("BountyMissions.BountyMissionsHelp")
    elseif msg == "select_cell_btn" then
        self.m_view:setSelectLibraryInfo(data.cell_data)
    elseif msg == "detail_btn" then
        if self.m_model.m_select_data then
            local type_id = self.m_model.m_select_data.cfg.type_id
            self:openView("Library.LibraryDetail", {type_id = type_id, data = self.m_model.m_data})
        end
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "right_btn" then
        self.m_view:loopScrollMoveToCellIndex(-1)
    elseif msg == "left_btn" then
        self.m_view:loopScrollMoveToCellIndex(1)
    elseif msg == "hero_spine_btn" then
        self.m_view:setRandomTalkInfo()
    end
end

return M
