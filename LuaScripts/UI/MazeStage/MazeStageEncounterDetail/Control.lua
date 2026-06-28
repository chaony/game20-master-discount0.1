local M = class("MazeStageEncounterDetailControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "select_drama_item" then
        Logger.log( "select_drama_item"..tostring(self.m_model.finish_flag))
        if self.m_model.finish_flag then
            self:updateMsg(99999)
            return
        end
        
        local event_data, config = self.m_model:getEventData()
        local tdata = {}
        tdata.event_id = event_data.id
        tdata.option_id = data.cell_data.id
        tdata.id = self.m_model.m_cell_id
        if not data.cell_data.finish_flag then
            tdata.sel_event_id = data.cell_data.id
        end
        self.m_model.select_index = data.index
        self.m_model.select_cell_data = data.cell_data
        --更新事件数据
        local encounter_cfg = ConfigManager:getCfgByName("maze_encounter")
        local encounter_cfg_item = encounter_cfg[self.m_model.select_cell_data.id]
        self.m_model.m_event_data = encounter_cfg_item;
        self.m_model.m_event_data.id = self.m_model.select_cell_data.id;
        --选中
        tdata.event_type = self.m_model.m_event_type
        tdata.finish_flag = data.cell_data.finish_flag
        if encounter_cfg_item.isright == 1 then
            static_rootControl:updateMsg("maze_chioce_option",tdata,"MazeStage")
        else
            SceneManager.curScene:updateCellDataByCellId(self.m_model.select_cell_data.id,self.m_model.select_cell_data)
            self:updateMsg("select_battle_update_ui", self.m_model.select_cell_data, "MazeStage.MazeStageEncounterDetail")
        end
    elseif msg == "battle_btn" then
        local event_data = self.m_model:getEventData()
        local event_battle = event_data.event_battle or 0
        if event_battle > 0 then
            --进入战斗
            local param = { event_id = event_data.id,
                           cell_data = self.m_model.m_data,
                           event_type = GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT,
                           x = self.m_model.m_x,
                           y = self.m_model.m_y}
            static_rootControl:updateMsg("maze_battle_start", param, "MazeStage")
            self:closeView()
        end
    elseif msg == "select_battle_update_ui" then
        self.m_model.m_data = data
        if self.m_model.select_index and self.m_model.select_cell_data then
            --对于结束选项，客户端需要显示一下选中的信息
            self.m_model:selectIndexData(self.m_model.select_index)
            self.m_view:refreshSelectInfo(self.m_model.select_cell_data.id)
            self.m_model.finish_flag = self.m_model.select_cell_data.finish_flag
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
