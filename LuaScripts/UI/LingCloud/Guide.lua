local guide = class("LingCloud", LikeOO.OOGuideBase)

-- 天下演武
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("left_start_btn")
    if node then
        self.m_listener = {
            key = "left_start_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 巅峰论剑
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("right_start_btn")
    if node then
        self.m_listener = {
            key = "right_start_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
