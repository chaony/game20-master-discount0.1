local guide = class("Settlement", LikeOO.OOGuideBase)

-- 进入结算记录完成引导步
function guide:excuteGuideFunc1(info)
    self:doNextGuide()
end

-- 点击关闭
function guide:excuteGuideFunc5(info)
    local node = self.m_view:findGameObject("close_btn")

    if node then
        --self.m_listener = {
        --    key = 99999,
        --}   
        
        local function clickCallback()
            self.m_control:updateMsg("common_refresh", nil, "parent")
            self.m_control:updateMsg(99999)
        end
        
        self:guideTargetNode(node.transform, 1, 3, nil, nil, nil, nil, nil, true, clickCallback)
    end
end

return guide
