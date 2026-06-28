local guide = class("Predestined", LikeOO.OOGuideBase)


function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("add_hero_btn")
    if node then
        self.m_listener = {
            key = "add_hero_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
