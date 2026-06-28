local guide = class("HuntTreasuresAreaPop", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local cache_cells = self.m_view.m_loop_scroll_view.m_cache_cells or {}
    local node = nil
    local event_key = nil
    --node = self.m_view.m_area_cell_tabs[#self.m_view.m_area_cell_tabs]
    --event_key = "item_click"
    for i, cell_object in pairs(cache_cells) do
        if i == 1 then
            local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
            node = luaBehaviour:FindGameObject("arena_cell_content")
            event_key = "item_click"
            break
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
