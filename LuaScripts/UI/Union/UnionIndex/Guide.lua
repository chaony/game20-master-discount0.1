local guide = class("UnionIndex", LikeOO.OOGuideBase)

-- 点击申请按钮
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("join_btn")
    if node then
        self.m_listener = {
            key = "join_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
