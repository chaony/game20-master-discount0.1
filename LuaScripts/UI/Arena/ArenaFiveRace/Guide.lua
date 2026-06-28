local guide = class("ArenaFiveRace", LikeOO.OOGuideBase)

-- 点击挑战
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("challenge_btn")
    if node then
        self.m_listener = {
            key = "challenge_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
