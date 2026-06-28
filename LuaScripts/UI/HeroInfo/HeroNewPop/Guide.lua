local guide = class("HeroNewPop", LikeOO.OOGuideBase)

-- 获得一张新卡牌
function guide:excuteGuideFunc1(info)
    self.m_listener = {
        key = 99999,
    }
    local btn = self.m_view:findGameObject("big_close_btn")
    if btn then 
        self:guideTargetNode(btn.transform, 3, 1, nil, nil, nil, nil, nil, true)
    else
    	self:doNextGuide()
    end
end

return guide
