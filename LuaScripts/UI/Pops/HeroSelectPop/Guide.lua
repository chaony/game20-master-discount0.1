local guide = class("HeroSelectPop", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_view.m_guide_cell)
    local node = luaBehaviour:FindGameObject("head_btn")
    if node then
        self.m_listener = {

        }   
        self:guideTargetNode(node.transform, 1, 2)
    end
end

return guide
