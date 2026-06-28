local guide = class("HangReward", LikeOO.OOGuideBase)

-- 点击领取
function guide:excuteGuideFunc1(info)
    local node = self.m_view.m_cur_tab_node:findGameObject("get_reward_btn")
    if node then
        self.m_listener = {
            key = "get_reward_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击快速挂机页签
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("tog_2")
    if node then
        self.m_listener = {
            key = "check_tag",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
