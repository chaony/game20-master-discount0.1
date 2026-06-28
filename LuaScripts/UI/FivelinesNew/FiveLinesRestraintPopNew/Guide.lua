local guide = class("FiveLinesRestraintPopNew", LikeOO.OOGuideBase)

-- 点前往
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("bg")
    if node then
        self.m_listener = {

        }
        self:guideTargetNode(node.transform, 1, 2)
    end
end

return guide
