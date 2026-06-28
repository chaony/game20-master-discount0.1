local M = class("WorldMapEncounterDetailControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "select_drama_item" then
        if self.m_model.finish_flag then
            self:updateMsg(99999)
            return
        end
        local event_data = self.m_model:getEventData()
        local tdata = {}
        tdata.event_id = event_data.id
        tdata.option_id = data.index
        if not data.cell_data.finish_flag then
            tdata.sel_event_id = data.cell_data.id
        else
            self.m_model.select_index = data.index
            self.m_model.select_cell_data = data.cell_data
        end
        tdata.event_type = self.m_model.m_event_type
        tdata.x = self.m_model.m_x
        tdata.y = self.m_model.m_y
        tdata.finish_flag = data.cell_data.finish_flag
        static_rootControl:updateMsg("map_chioce_option",tdata,"WorldMap.WorldMapMain")
    elseif msg == "battle_btn" then
        local event_data = self.m_model:getEventData()
        local event_battle = event_data.event_battle or 0
        if event_battle > 0 then
            --进入战斗
            static_rootControl:updateMsg("map_event_battle_start", {event_id = event_data.id, event_type = self.m_model.m_event_type, x = self.m_model.m_x, y = self.m_model.m_y}, "WorldMap.WorldMapMain")
        end
    elseif msg == "select_update_ui" then
        if self.m_model.select_index and self.m_model.select_cell_data then
            --对于结束选项，客户端需要显示一下选中的信息
            self.m_model:selectIndexData(self.m_model.select_index)
            self.m_view:refreshSelectInfo(self.m_model.select_cell_data.id)
            self.m_model.finish_flag = self.m_model.select_cell_data.finish_flag
        end
    end
end

return M;
