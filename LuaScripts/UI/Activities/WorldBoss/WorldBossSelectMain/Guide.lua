local guide = class("WorldBossSelectMain", LikeOO.OOGuideBase)

-- 选择世界boss
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("worldboss_btn")
    if node then
        self.m_listener = {
            key = "worldboss_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 选择试炼
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("activeboss_btn")
    if node then
        self.m_listener = {
            key = "activeboss_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 江湖传奇
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("legend_btn")
    if node then
        self.m_listener = {
            key = "legend_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
