local guide = class("Pub", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("ten_gacha_btn")
    --local node = self.m_view:findGameObject("one_gacha_btn")
    if node then
        self.m_listener = {
            key = "ten_gacha_btn",
            --key = "one_gacha_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

--点击前缘
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("toggle4")
    if node then
        self.m_listener = {
            key = "toggle4",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
