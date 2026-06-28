local guide = class("ArtifactList", LikeOO.OOGuideBase)

-- 穿戴
function guide:excuteGuideFunc1(info)
    local cell_node = self.m_view.m_loop_scroll_view.m_cache_cells[1]
    if cell_node then
        local luaBehaviour = UIUtil.findLuaBehaviour(cell_node)
        local node = luaBehaviour:FindGameObject("check_btn")
        if node then
            self.m_listener = {
                key = "check_btn",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

return guide
