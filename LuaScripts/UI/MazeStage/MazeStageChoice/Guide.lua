local guide = class("MazeStageChoice", LikeOO.OOGuideBase)

-- 点击第一层
function guide:excuteGuideFunc1(info)
    local cell = self.m_view.m_loop_scroll_view.m_cache_cells[1]
    local luaBehaviour = UIUtil.findLuaBehaviour(cell.transform)
    local node = luaBehaviour:FindGameObject("task_cell_btn")
    if node then
        self.m_listener = {
            key = "task_cell_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
