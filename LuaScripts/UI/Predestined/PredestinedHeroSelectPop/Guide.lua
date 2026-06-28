local guide = class("PredestinedHeroSelectPop", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local cell = self.m_view.m_list_scroll.m_cache_cells[1]
    if cell then
        local luaBehaviour = UIUtil.findLuaBehaviour(cell)
        local node = luaBehaviour:FindGameObject( "quality_img")
        if node then
            self.m_listener = {
                key = "select_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

return guide
