local guide = class("TotalWorld", LikeOO.OOGuideBase)

-- 高阶竞技
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("hunt_treasure_btn")
    if node then
        self.m_listener = {
            key = "hunt_treasure_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 高阶竞技
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("high_arena_btn")
    if node then
        self.m_listener = {
            key = "high_arena_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 帮会
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("union_btn")
    if node then
        self.m_listener = {
            key = "union_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end


return guide
