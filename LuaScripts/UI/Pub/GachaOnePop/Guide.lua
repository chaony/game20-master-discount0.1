local guide = class("PubOne", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("card_top_img")
    if node then
        self.m_listener = {
            key = "card_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
