local guide = class("TowerStageStartBattle", LikeOO.OOGuideBase)

-- 展示奖励
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("reward_bg_img")
    if node then
        self.m_listener = {

        }   
        self:guideTargetNode(node.transform, 1, 2)
    end
end

-- 点击战斗按钮
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("start_battle_btn")
    if node then
        self.m_listener = {
            key = "start_battle_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
