local guide = class("FateStory", LikeOO.OOGuideBase)

-- 点击关卡
function guide:excuteGuideFunc1(info)
    local node = nil
    self.m_view:lockTouch()
    local function endCallBack()
        self.m_view:unlockTouch()
        local cell_node = self.m_view.m_list_scroll.m_cache_cells[1]
        if cell_node then
            node = cell_node
        end
        if node then
            self.m_listener = {
                key = "click",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
    self.m_control:setOnceTimer(0.28, endCallBack)
end

return guide