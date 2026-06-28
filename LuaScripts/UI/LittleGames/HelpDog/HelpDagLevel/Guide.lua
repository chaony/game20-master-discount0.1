local guide = class("HelpDagLevel", LikeOO.OOGuideBase)

-- 划线
function guide:excuteGuideFunc1(info)
    self.m_view:showGuideBtn()
    local node = self.m_view:findGameObject("guide_btn_1")
    if node then
        self.m_listener = {
            key = "guide_btn_1",
        }
        self:guideTargetGameNode(node.transform, 1, 1)
    end
end

--第一关结束返回关卡界面
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("result")
    if node and self.m_model.m_show_result then
        self.m_listener = {
            key = "result",
        }
        self:guideTargetNode(node.transform,3, 1, nil, nil, nil, nil, nil, true)
    end
end

return guide