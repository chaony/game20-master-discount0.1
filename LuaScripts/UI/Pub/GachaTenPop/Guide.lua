local guide = class("PubTen", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("open_all_btn")
    if node then
        self.m_listener = {
            key = "oneKey_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
