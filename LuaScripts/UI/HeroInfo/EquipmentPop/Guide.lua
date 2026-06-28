local guide = class("EquipmentPop", LikeOO.OOGuideBase)
-- 强化
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("intensify_btn")
    if node then
        self.m_control.slid_lock = true
        self.m_listener = {
            key = "intensify_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end


return guide
