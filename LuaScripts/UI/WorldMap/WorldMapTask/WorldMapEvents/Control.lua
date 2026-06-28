local M = class("WorldMapEventsControl",LikeOO.OOControlBase)

function M:onEnter()
    self:switchTabBtn(self.m_model.m_open_tab_index)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "event_cell_btn" then
        self.m_view:showEventInfo(data.cell_data)
    elseif msg == "go_btn" then
        if self.m_model.m_sel_cell_data then
            local task_table = self.m_model.regional_task_cfg
            local task = task_table[self.m_model.m_sel_cell_data.task_id]
            if self.m_model.m_sel_cell_data.status == 5 then
                local open_flag, tips_str = GameUtil:getStageUnlock(task.stage_id)
                GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
            else
                local motherId = self:getMotherMapId(task.chapter)
                local map = LikeOO.Map2DControl.curMap2D
                if map == nil then
                    SceneManager.curScene:clickObject(motherId);
                else
                    if motherId ~= map.motherMapId then
                        local targetMap = map.map_table[motherId]
                        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0583", Language:getTextByKey(targetMap.name)), delay_close = 2})
                    end
                end
                self:closeView()
            end
        end
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end

--获取任务根场景id
function M:getMotherMapId(id)
    local map_table = ConfigManager:getCfgByName("regional_map")

    local mother_map_id = map_table[id].mother_map_id
    if mother_map_id > 0 then
        return self:getMotherMapId(mother_map_id)
    end
    return id
end

return M;
