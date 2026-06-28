local guide = class("Biography", LikeOO.OOGuideBase)

-- 点击派遣
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("enter_btn")
    if node then
        self.m_listener = {
            key = "enter_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
