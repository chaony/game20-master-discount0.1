local guide = class("HuntTreasures", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("big_map_btn")
    if node then
        self.m_listener = {
            key = "big_map_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc2(info)
    local node = self.m_view.m_area_node.m_mine_tab[5]
    if node then
        self.m_listener = {
            key = "click_mine",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("my_area_btn")
    if node then
        self.m_listener = {
            key = "my_area_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide