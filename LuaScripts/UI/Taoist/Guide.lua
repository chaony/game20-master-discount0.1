local guide = class("Taoist", LikeOO.OOGuideBase)

-- 点击挑战
function guide:excuteGuideFunc1(info)
    local cache_cells = self.m_view.m_level_loop_scroll_view.m_cache_cells or {}
    local node = nil
    local event_key = nil
    for i, cell_object in pairs(cache_cells) do
        local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
        local goto_btn = luaBehaviour:FindGameObject("goto_btn")
        if goto_btn.activeSelf then
            node = goto_btn
            event_key = "goto_btn"
            break
        else
            local receive_btn = luaBehaviour:FindGameObject("receive_btn")
            if receive_btn.activeSelf then
                node = receive_btn
                event_key = "receive_btn"
                break
            end
        end
    end
    if node then
        self.m_listener = {
            key = event_key,
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
