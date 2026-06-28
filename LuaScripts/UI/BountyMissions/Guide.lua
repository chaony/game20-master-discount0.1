local guide = class("BountyMissions", LikeOO.OOGuideBase)

-- 点击派遣
function guide:excuteGuideFunc1(info)
	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_view.m_guide_cell)
    local node = luaBehaviour:FindGameObject("send_btn")
    if node then
        self.m_listener = {
            key = "open_send",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
