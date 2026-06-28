local guide = class("JuBaoShan", LikeOO.OOGuideBase)

-- 点击扔骰子
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("roll_btn")
    if node then
        self.m_listener = {
            key = "roll_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 首次走到建筑物上（非钱庄），自动打开弹窗，点击一键派遣
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("roll_btn")
    if node then
        self.m_listener = {
            key = "roll_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 首次走到钱庄上，自动打开弹窗，点击一键派遣
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("roll_btn")
    if node then
        self.m_listener = {
            key = "roll_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
