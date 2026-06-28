local guide = class("EquipmentLevelUp", LikeOO.OOGuideBase)
-- 一键添加
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("yijianf_btn")
    if node then
        self.m_control.slid_lock = true
        self.m_listener = {
            key = "yijianf_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 确定
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("replace_btn")
    if node then
        self.m_control.slid_lock = true
        self.m_listener = {
            key = "replace_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
