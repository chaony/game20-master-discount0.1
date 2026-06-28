local guide = class("YinTowerGreatReward", LikeOO.OOGuideBase)

-- 点击前往
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("ok_btn")
    if node then
        self.m_listener = {
            key = "ok_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
