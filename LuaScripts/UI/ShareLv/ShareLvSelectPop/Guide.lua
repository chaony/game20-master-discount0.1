local guide = class("ShareLvSelectPop", LikeOO.OOGuideBase)

-- 点击第一个
function guide:excuteGuideFunc2(info)
    if self.m_view.m_guide_cell then
        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_view.m_guide_cell)
        local node = luaBehaviour:FindGameObject("hero_bg")
        if node then
            self.m_listener = {
                key = "select_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    else
        self:doNextGuide()
    end
end

-- 确定
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("ok_btn")
    if node then
        self.m_listener = {
            key = "ok_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
