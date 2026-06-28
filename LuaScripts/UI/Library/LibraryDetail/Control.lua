local M = class("LibraryDetailControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_ui", nil, "Library.Library")
        self:closeView()
    elseif msg == "look_hero" then
        self:openView("Library.LibrarySelect", {type_id = self.m_model.m_type_id, data = self.m_model.m_data, hero_cid = data.hero_cid})
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    end
end

return M
