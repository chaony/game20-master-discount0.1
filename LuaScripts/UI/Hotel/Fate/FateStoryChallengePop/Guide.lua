local guide = class("FateStoryChallengePop", LikeOO.OOGuideBase)

-- 点击挑战
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("challenge_btn")
    if node then
        self.m_listener = {
            key = "challenge_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    else
    	self:doNextGuide()
    end
end

return guide
