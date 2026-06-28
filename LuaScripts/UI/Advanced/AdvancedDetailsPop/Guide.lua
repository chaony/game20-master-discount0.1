local guide = class("AdvancedDetailsPop", LikeOO.OOGuideBase)

-- 进阶按钮
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("yes_btn")
    if node then
        self.m_listener = {
            key = "yes_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
