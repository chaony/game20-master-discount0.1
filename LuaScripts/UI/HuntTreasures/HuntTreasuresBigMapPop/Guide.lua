local guide = class("HuntTreasuresBigMapPop", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("map_btn_1")
    if node then
        self.m_listener = {
            key = "map_btn_1",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide