local M = class("WorldMapJournalLegend",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "journal_btn" then
        self:openView("WorldMap.WorldMapJournal", {show_gift = false})
        self:closeView()
    elseif msg == "left_arrow_btn" then
        if self.m_model.previous_area_id ~= nil then
            self.m_model.cur_area_id = self.m_model.previous_area_id
            self.m_model:getMapData()
            self.m_model:refreshArea()
            self.m_model:refreshSelectIndex()
            self.m_view:refreshBook(true)
        end
    elseif msg == "right_arrow_btn" then
        if self.m_model.next_area_id ~= nil then
            self.m_model.cur_area_id = self.m_model.next_area_id
            self.m_model:getMapData()
            self.m_model:refreshArea()
            self.m_model:refreshSelectIndex()
            self.m_view:refreshBook(false)
        end
    elseif msg == "select_cell" then
        self.m_model.m_select_index = data
        self.m_view:refreshUI()
    elseif msg == "go_btn" then
        self:closeView()
        if data then
            self:onClick_goBtn(data.map_id)
        end
    end
end

function M:onClick_goBtn(mapId)
    local map_table = ConfigManager:getCfgByName("regional_map")
    local map_data = map_table[mapId]
    if LikeOO.Map2DControl.curMap2D ~= nil then
        LikeOO.Map2DControl:closeMap()
    end
    if map_data.area == self.m_model.m_area_id then
        SceneManager.curScene:setCameraPos(mapId)
    else
        self:updateMsg("change_scene", {area_id = map_data.area, map_id = mapId, view_callBack = function()
            SceneManager.curScene:setCameraPos(mapId)
        end}, "WorldMap.WorldMapMain")
    end
end

return M;
