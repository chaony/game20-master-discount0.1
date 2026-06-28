local guide = class("BiographyChapter", LikeOO.OOGuideBase)

-- 点击派遣
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("battle_btn")
    if node then
        self.m_listener = {
            key = "battle_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
