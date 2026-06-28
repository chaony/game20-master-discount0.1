local guide = class("Deployment", LikeOO.OOGuideBase)

-- 点击阵法
function guide:excuteGuideFunc1(info)
    local target = info.target[1]
    
    local cell = self.m_view.m_loop_scroll_view.m_cache_cells[target]
    local luaBehaviour = UIUtil.findLuaBehaviour(cell)
    local node = luaBehaviour:FindGameObject("deployment_cell_icon")
    if node then
        self.m_listener = {
            key = "deployment_cell_icon",
        }

        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
