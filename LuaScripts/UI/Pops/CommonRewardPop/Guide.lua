local guide = class("CommonRewardPop", LikeOO.OOGuideBase)

-- 关闭界面
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("close_btn")
    if node then
        self.m_listener = {
            key = 99999,
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
