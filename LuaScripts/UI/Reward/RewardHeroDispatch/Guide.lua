local guide = class("WorldMapRewardSend", LikeOO.OOGuideBase)

-- 点击派遣格子
function guide:excuteGuideFunc1(info)
    local node = self.m_view.m_guide_cell
    if node then
        self.m_listener = {
            key = "check_send_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 展示英雄列表
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("bg")
    if node then
        self.m_listener = {
            
        }   
        self:guideTargetNode(node.transform, 1, 2)
    end
end

-- 展示需求说明
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("need_bg")
    if node then
        self.m_listener = {
            
        }   
        self:guideTargetNode(node.transform, 1, 2)
    end
end

-- 一键派遣
function guide:excuteGuideFunc4(info)
    local node = self.m_view:findGameObject("quck_send_btn")
    if node then
        self.m_listener = {
            key = "quck_send_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 派遣
function guide:excuteGuideFunc5(info)
    local node = self.m_view:findGameObject("send_btn")
    if node then
        self.m_listener = {
            key = "send_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
