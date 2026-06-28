local guide = class("LevelUpPop", LikeOO.OOGuideBase)

-- 点击关闭
function guide:excuteGuideFunc7(info)
    local node = self.m_view:findGameObject("close_btn")
    if node then
        self.m_listener = {
            key = 99999,
        }   
        self:guideTargetNode(node.transform, 2, 1)
    else
    	self:doNextGuide()
    end
end

return guide
