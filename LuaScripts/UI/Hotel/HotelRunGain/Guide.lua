local guide = class("HotelRunGain", LikeOO.OOGuideBase)

-- 点击关闭
function guide:excuteGuideFunc1(info)
    --self.m_listener = {
    --    key = 99999,
    --}
    local node = self.m_view:findGameObject("close_btn")
    if node then
        local function clickCallback()
            self.m_control:updateMsg(99999)
        end
        self:guideTargetNode(node.transform, 1, 3, nil, nil, nil, nil, nil, true, clickCallback)
    else
        self:doNextGuide()
    end
end

return guide