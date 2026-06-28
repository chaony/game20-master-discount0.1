local guide = class("DepositoryPop", LikeOO.OOGuideBase)

-- 点击使用
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("upgrade_btn")
    if node then
        self.m_listener = {
            key = "upgrade_btn",
        }
        
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
