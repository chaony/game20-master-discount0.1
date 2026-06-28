local guide = class("JewelGachaWishPop", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("one_gacha_btn")
    if node then
        self.m_listener = {
            key = "one_gacha_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
