local M = class("MazeStageRelicSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.MazeStage.MazeStageRelicSelect.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self:closeView()
    elseif msg == "select_btn" then
        if self.m_model.m_select_index == nil or self.m_model.m_select_index == -1 then
            return
        end
        local heirloom_pool = self.m_model.m_cell_data.heirloom_pool or {}
        local heirloom_id = heirloom_pool[self.m_model.m_select_index]
        self:updateMsg("maze_select_heirloom", {data = self.m_model.m_cell_data, heirloom_id = heirloom_id, select_cell_obj = self.m_view.m_select_cell}, "MazeStage")
        -- self:closeView()
    elseif msg == "cell_bg" then
        -- 引导用
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
